/**
 * Global class that contains functions to be used in either Credit or PE.
 */
global class CombinedFunctions {

    global static String parameterizeRequestParams(Map<String, String> paramMap) {
        if(paramMap.keySet().isEmpty()) return '';
        String params = '?';
        for(String key : paramMap.keySet()) {
            String value = paramMap.get(key);
            if(value == null) continue;
            params = params + EncodingUtil.urlEncode(key, 'UTF-8')+'='+EncodingUtil.urlEncode(value, 'UTF-8')+'&';
        }

        return params;
    }

    global class EnrollmentRequest {
        @InvocableVariable(Required=true Description='User Id (CSU ID or NetID for Credit, Noncredit ID for PE) of the Contact.')
        global String userId;

        @InvocableVariable(Required=true Description='Reference of the offering.')
        global String offeringReference;

        @InvocableVariable(Required=false Description='Is this a drop instead of a confirm?')
        global Boolean isDrop = false;

        @InvocableVariable(Required=false Description='Extra status info.')
        global String statusInfo = null;

        global EnrollmentRequest(){}
        global EnrollmentRequest(String userId, String offeringReference, Boolean isDrop) {
            this.userId = userId;
            this.offeringReference = offeringReference;
            this.isDrop = isDrop;
        }
        global EnrollmentRequest(String userId, String offeringReference, Boolean isDrop, String statusInfo) {
            this.userId = userId;
            this.offeringReference = offeringReference;
            this.isDrop = isDrop;
            this.statusInfo = statusInfo;
        }
    }

    global static hed__Course_Enrollment__c handleStudentEnrollment(Contact contact, String reference, Boolean isDrop) {
        return handleEnrollment(contact, reference, isDrop, false);
    }

    global static hed__Course_Enrollment__c handleInstructorEnrollment(Contact contact, String reference, Boolean isDrop) {
        return handleEnrollment(contact, reference, isDrop, true);
    }

    private static hed__Course_Enrollment__c handleEnrollment(Contact contact, String reference, Boolean isDrop, Boolean isInstructor) {
        if(contact == null) return null;

        RecordType enrollmentType;
        try {
            if(isInstructor) {
                enrollmentType = [select Id from RecordType where SobjectType = 'hed__Course_Enrollment__c' and DeveloperName = 'Faculty' LIMIT 1];
            } else {
                enrollmentType = [select Id from RecordType where SobjectType = 'hed__Course_Enrollment__c' and DeveloperName = 'Student' LIMIT 1];
            }
        } catch(Exception e) {
            enrollmentType = null;
        }

        hed__Course_Offering__c offering = null;
        try {
            offering = [select Id, hed__Faculty__c, (select Id, hed__Course_Offering__r.hed__Faculty__c from hed__Course_Offering_Schedules__r) from hed__Course_Offering__c where lms_hed__LMS_Reference_Code__c = :reference LIMIT 1];
        } catch(QueryException qe) {
            return null;
        }

        hed__Course_Enrollment__c enrollment;
        hed__Course_Enrollment__c existing;
        try {
            existing = [Select Id, hed__Status__c, hed__Contact__c, hed__Course_Offering__c from hed__Course_Enrollment__c where hed__Contact__c = :contact.Id and hed__Course_Offering__c = :offering.Id LIMIT 1];
        } catch(QueryException qe) {
            if(isDrop) return null;// Nothing to undo
            existing = null;
        }
        if(existing == null) {
            enrollment = new hed__Course_Enrollment__c(hed__Contact__c = contact.Id, hed__Course_Offering__c = offering.Id, hed__Status__c = 'Enrolled');
            if(enrollmentType != null) {
                enrollment.RecordTypeId = enrollmentType.Id;
            }
            insert enrollment;
        } else {
            enrollment = existing;
            if(isDrop) {
                enrollment.hed__Status__c = 'Withdrew';
            } else {
                enrollment.hed__Status__c = 'Enrolled';
            }
            if(enrollmentType != null) {
                enrollment.RecordTypeId = enrollmentType.Id;
            }

            update enrollment;
        }

        if(!isInstructor && !isDrop && false) {
            // Get this student onto the scheduled events.
            enlistEnrollmentInEvent(offering.hed__Course_Offering_Schedules__r, new List<Id>{contact.Id});
        }

        return enrollment;
    }

    private static final String EVENT_OFFSET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    public static List<EventRelation> enlistEnrollmentInEvent(List<hed__Course_Offering_Schedule__c> schedules, List<Id> studentIds) {
        List<Id> scheduleIds = new List<Id>();for(hed__Course_Offering_Schedule__c schedule : schedules){scheduleIds.add(schedule.Id);}
        Map<Id, Id> instructorScheduleMap = mapScheduleInstructors(schedules);
        Map<Id, List<Event>> eventMap = mapEvents([select Id, WhatId, WhoId, Subject, WhoCount, Recurrence2PatternText, ActivityDateTime, DurationInMinutes, Location, Description from Event]);// where WhatId in :scheduleIds
        Map<Id, Integer> attendeeCounts = new Map<Id, Integer>();
        addEventWhoCounts(eventMap.values(), attendeeCounts);

        List<EventRelation> eventRelations = new List<EventRelation>();

        for(Id studentId : studentIds) {
            for(Id scheduleId : eventMap.keySet()) {
                Id instructor = instructorScheduleMap.get(scheduleId);
                if(studentId.equals(instructor)) continue;

                Boolean requiresNew = false;
                for(Event running : eventMap.get(scheduleId)) {
                    if(attendeeCounts.get(running.Id) >= 50) {requiresNew = true; break;}
                }

                if(requiresNew) {
                    List<Event> fullEvents = eventMap.get(scheduleId);

                    String newSubject = fullEvents.get(0).Subject;
                    Integer endHash = newSubject.lastIndexOf('#');
                    Integer offset = EVENT_OFFSET.indexOf(newSubject.substring(endHash+1));
                    newSubject = newSubject.substring(0, endHash)+'#'+EVENT_OFFSET.substring(offset, offset+1);

                    List<Event> newSeries = new List<Event>();
                    for(Event fullEvent : fullEvents) {
                        newSeries.add(
                            new Event(
                                WhoId = fullEvent.WhoId, 
                                //Recurrence2PatternText = fullEvent.Recurrence2PatternText, 
                                IsVisibleInSelfService = false,
                                WhatId = fullEvent.WhatId,
                                ActivityDateTime = fullEvent.ActivityDateTime,
                                DurationInMinutes = fullEvent.DurationInMinutes,
        
                                Subject = newSubject,
                                Location = fullEvent.Location,
                                Description = fullEvent.Description
                            )
                        );


                    }
                    insert newSeries;
                    eventMap.put(scheduleId, newSeries);

                    addEventWhoCounts(new List<List<Event>>{newSeries}, attendeeCounts);
                }

                for(Event event : eventMap.get(scheduleId)) {
                    eventRelations.add(
                        new EventRelation(EventId = event.Id, IsParent = true, IsWhat = false, RelationId = studentId)
                    );

                    Integer ct = attendeeCounts.get(event.Id);
                    if(ct == null) ct = 0;
                    attendeeCounts.put(event.Id, ct+1);
                }
            }
        }
        
        try {
            insert eventRelations;
            return eventRelations;
        } catch (DmlException de) {
            throw de;
        }
    }

    /*
     *  Instructors are the WhoId of the event - don't duplicate their relation!
     */
    private static Map<Id, Id> mapScheduleInstructors(List<hed__Course_Offering_Schedule__c> schedules) {
        Map<Id, Id> instructorMap = new Map<Id, Id>();
        for(hed__Course_Offering_Schedule__c schedule : schedules) {
            instructorMap.put(schedule.Id, schedule.hed__Course_Offering__r.hed__Faculty__c);
        }
        return instructorMap;
    }

    /*
     *   Since events cannot have more than 50 attendees, we could run into a scenario where an offering gets overloaded w/ enrollments.
     *   To fix this, map the event to the schedule, and when the event maxes out, spin up an event series for the overage.
     * 
     *   Since recurrance2 doesn't create a series owning event, we need to use the subject to compare.
     */
    private static Map<Id, List<Event>> mapEvents(List<Event> events) {
        hed__Error__c error = new hed__Error__c(hed__Full_Message__c = JSON.serialize(events, true));
        insert error;

        Map<Id, Map<String, List<Event>>> seriesMap = new Map<Id, Map<String, List<Event>>>();
        for(Event e : events) {
            if(!seriesMap.containsKey(e.WhatId)) {
                seriesMap.put(e.WhatId, new Map<String, List<Event>>());
            }
            Map<String, List<Event>> subjectMap = seriesMap.get(e.WhatId);
            if(!subjectMap.containsKey(e.Subject)) {
                subjectMap.put(e.Subject, new List<Event>());
            }
            subjectMap.get(e.Subject).add(e);
        }
        Map<Id, List<Event>> resultMap = new Map<Id, List<Event>>();
        for(Id whatId : seriesMap.keySet()) {
            Map<String, List<Event>> subjectMap = seriesMap.get(whatId);
            String subject = '';
            for(String keySubject : subjectMap.keySet()) {
                if(keySubject.compareTo(subject) > 0) {
                    subject = keySubject;
                }
            }

            resultMap.put(whatId, subjectMap.get(subject));
        }
        return resultMap;
    }

    private static void addEventWhoCounts(List<List<Event>> allEvents, Map<Id, Integer> countMap) {
        for(List<Event> eventList : allEvents) {
            for(Event e : eventList) {
                countMap.put(e.Id, e.WhoCount);
            }
        }
    }

    global static List<Event> createEventsForSection(hed__Course_Offering__c offering) {
        try {
            System.debug(offering.hed__Start_Date__c+'|'+offering.hed__End_Date__c+'|'+offering.lms_hed__Computed_LMS_Reference__c+'|'+offering.lms_hed__LMS_Course_Term__c+'|'+offering.hed__Faculty__c);
        } catch(SObjectException soe) {
            // User didn't pass in all fields.
            offering = [select Id, hed__Start_Date__c, hed__End_Date__c, lms_hed__Computed_LMS_Reference__c, lms_hed__LMS_Course_Term__c, hed__Faculty__c from hed__Course_Offering__c where Id = :offering.Id LIMIT 1];
        }
        if(offering.hed__Start_Date__c == null) throw new IllegalArgumentException('Couldn\'t create events for offering... hed__Start_Date__c of offering is not set!');
        if(offering.hed__End_Date__c == null) throw new IllegalArgumentException('Couldn\'t create events for offering... hed__End_Date__c of offering is not set!');

        List<Event> changedSchedules = new List<Event>();
        List<Event> createdSchedules = new List<Event>();
        
        List<Id> contacts = null;
        for(hed__Course_Offering_Schedule__c schedule : [select Id, Schedule_Reference__c, hed__Facility__c, hed__Facility__r.Name, hed__Monday__c, hed__Tuesday__c, hed__Wednesday__c, hed__Thursday__c, hed__Friday__c, hed__Saturday__c, hed__Sunday__c, hed__Start_Time__c, hed__End_Time__c from hed__Course_Offering_Schedule__c where hed__Course_Offering__c = :offering.Id]) {
            
            // Recurring logic should be smart enough to handle an offering schedule all in one.
            String patternText = offeringScheduleToRecurrence2PatternText(offering, schedule);
            Datetime startDateTime = offeringScheduleToStartDateTime(offering, schedule);
            Integer duration = offeringScheduleToDuration(schedule);
            String subject = offeringScheduleToSubject(offering, schedule);
            String location = offeringScheduleToLocation(offering, schedule);
            String description = offeringScheduleToDescription(offering, schedule);

            changedSchedules.addAll( [select Id from Event where WhatId = :schedule.Id] );

            createdSchedules.add(new Event(
                WhoId = offering.hed__Faculty__c, 
                Recurrence2PatternText = patternText, 
                IsVisibleInSelfService = false,
                WhatId = schedule.Id,
                ActivityDateTime = startDateTime,
                DurationInMinutes = duration,

                Subject = subject,
                Location = location,
                Description = description
            ));
        }
        delete changedSchedules;
        insert createdSchedules;

        return createdSchedules;
    }

    private static String offeringScheduleToRecurrence2PatternText(hed__Course_Offering__c offering, hed__Course_Offering_Schedule__c schedule) {
        //RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR
        String rrule = 'RRULE:FREQ=WEEKLY;BYDAY=';
        if(schedule.hed__Sunday__c) rrule+='SU,';
        if(schedule.hed__Monday__c) rrule+='MO,';
        if(schedule.hed__Tuesday__c) rrule+='TU,';
        if(schedule.hed__Wednesday__c) rrule+='WE,';
        if(schedule.hed__Thursday__c) rrule+='TH,';
        if(schedule.hed__Friday__c) rrule+='FR,';
        if(schedule.hed__Saturday__c) rrule+='SA,';
        rrule = rrule.substring(0, rrule.length()-1);
        rrule+=';WKST=SU;INTERVAL=1;UNTIL=';

        // Build UNTIL string
        Date endDate = offering.hed__End_Date__c;
        String yr = String.valueOf(endDate.year());
        String mo = String.valueOf(endDate.month());
        if(mo.length() == 1) mo = '0'+mo;
        String day = String.valueOf(endDate.day());
        if(day.length() == 1) day = '0'+day;

        rrule+=yr+mo+day+'T000000Z';

        return rrule;
    }

    private static Datetime offeringScheduleToStartDateTime(hed__Course_Offering__c offering, hed__Course_Offering_Schedule__c schedule) {
        Datetime start = offering.hed__Start_Date__c;
        start.addHours(schedule.hed__Start_Time__c.hour());
        start.addMinutes(schedule.hed__Start_Time__c.minute());
        start.addSeconds(schedule.hed__Start_Time__c.second());

        return Datetime.newInstanceGmt(start.year(), start.month(), start.day(), start.hour(), start.minute(), start.second());
    }

    private static Integer offeringScheduleToDuration(hed__Course_Offering_Schedule__c schedule) {
        return (schedule.hed__End_Time__c.hour() - schedule.hed__Start_Time__c.hour())*60 + (schedule.hed__End_Time__c.minute() - schedule.hed__Start_Time__c.minute());
    }

    private static String offeringScheduleToSubject(hed__Course_Offering__c offering, hed__Course_Offering_Schedule__c schedule) {
        return '['+offering.lms_hed__Computed_LMS_Reference__c+'] - Class Session #A';
    }

    private static String offeringScheduleToLocation(hed__Course_Offering__c offering, hed__Course_Offering_Schedule__c schedule) {
        if(schedule.hed__Facility__c == null) {
            if(offering.lms_hed__LMS_Course_Term__c == null)
                return 'Not Specified';
            else
                return 'Canvas';
        }
        return schedule.hed__Facility__r.Name;
    }

    private static String offeringScheduleToDescription(hed__Course_Offering__c offering, hed__Course_Offering_Schedule__c schedule) {
        String body = '<div>Session of class ['+offering.lms_hed__Computed_LMS_Reference__c+']</div>';
        if(offering.lms_hed__LMS_Course_Term__c != null) {
            if(offering.lms_hed__LMS_Course_Term__r.lms_hed__Course_Term_Link__c != null)
                body += '<div>Online Component: '+offering.lms_hed__LMS_Course_Term__r.lms_hed__Course_Term_Link__c+'</div>';
        }

        if(schedule.hed__Facility__c != null) {
            body += '<div>In Person: '+schedule.hed__Facility__r.Name+'</div>';
        }

        return body;
    }

    // ---------------------- LWC ---------------------------

    global static List<Id> peelIds(List<SObject> objects) {
        List<Id> ids = new List<Id>();
        for(SObject obj : objects) {
            ids.add(obj.Id);
        }
        return ids;
    }

    @AuraEnabled(cacheable = true)
    global static List<SObject> refreshData(List<Id> ids, String objectName, List<String> fieldsToRefresh) {
        if(ids.isEmpty()) return new List<SObject>();
        String qry = buildrefreshQry(objectName, fieldsToRefresh)+' where Id in (';
        Boolean first = true;
        for(Id id : ids) {
            if(first) {
                qry+='\''+id+'\'';
                first = false;
            } else {
                qry+=',\''+id+'\'';
            }
        }
        qry+=')';
        return Database.query(qry);
    }

    @AuraEnabled(cacheable = true)
    global static List<SObject> refreshChildren(Id parentId, String childObjectName, String parentFieldName, List<String> fieldsToRefresh) {
        String qry = buildrefreshQry(childObjectName, fieldsToRefresh)+' where '+parentFieldName+'=\''+parentId+'\'';
        return Database.query(qry);
    }

    private static String buildrefreshQry(String objectName, List<String> fieldsToRefresh) {
        String qry = 'select id';
        for(String field : fieldsToRefresh) {
            if(field.equals('id') || field.equals('Id')) continue;
            qry+=','+field;
        }

        qry+=' from '+objectName;
        return qry;
    }

    @AuraEnabled
    global static void createRegistrationBatch(List<Id> offerings, List<Id> contacts, Id sponsorAccount, Double responsibility) {
        Registration_Batch__c batch = new Registration_Batch__c(Sponsor__c = sponsorAccount, Default_Transfer__c = responsibility);
        try {
            insert batch;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        try {
            List<Registration_Request__c> batchEnrollments = new List<Registration_Request__c>();
            for(Id offering : offerings) {
                for(Id contact : contacts) {
                    batchEnrollments.add(
                        new Registration_Request__c(
                            Student__c = contact, 
                            Course_Offering__c = offering, 
                            Registration_Batch__c = batch.Id, 
                            Line_Item_ID__c = (new Uuid()).getValue()
                        )
                    );
                }
            }
            insert batchEnrollments;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        try {
            batch.Is_Ready__c = true;

            update batch;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    global static List<Id> getContactsByEmails(String emails) {
        if(emails == null) return new List<Id>();
        Set<String> allEmails = new Set<String>();
        for(String email : emails.split(',')) {
            allEmails.add(email.trim());
        }
        return peelIds([select Id from Contact where Email in :allEmails]);
    }
    
}