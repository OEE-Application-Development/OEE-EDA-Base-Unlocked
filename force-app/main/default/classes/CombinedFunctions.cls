/**
 * Global class that contains functions to be used in either Credit or PE.
 */
global class CombinedFunctions {

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
            offering = [select Id, (select Id from hed__Course_Offering_Schedules__r) from hed__Course_Offering__c where lms_hed__LMS_Reference_Code__c = :reference LIMIT 1];
        } catch(QueryException qe) {
            return null;
        }

        hed__Course_Enrollment__c enrollment;
        hed__Course_Enrollment__c existing;
        try {
            existing = [Select Id, hed__Status__c from hed__Course_Enrollment__c where hed__Contact__c = :contact.Id and hed__Course_Offering__c = :offering.Id LIMIT 1];
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

            update enrollment;
        }

        if(!isInstructor && !isDrop) {
            // Get this student onto the scheduled events.
            enlistEnrollmentInEvent(offering.hed__Course_Offering_Schedules__r, contact.Id);
        }

        return enrollment;
    }

    private static void enlistEnrollmentInEvent(List<hed__Course_Offering_Schedule__c> schedules, Id studentId) {
        List<Id> scheduleIds = new List<Id>();for(hed__Course_Offering_Schedule__c schedule : schedules){scheduleIds.add(schedule.Id);}
        List<Event> events = [select Id from Event where WhatId in :scheduleIds];

        List<EventRelation> eventRelations = new List<EventRelation>();
        for(Event event : events) {
            eventRelations.add(
                new EventRelation(EventId = event.Id, IsParent = true, IsWhat = false, RelationId = studentId)
            );
        }
        insert eventRelations;
    }

    global static List<Event> createEventsForSection(hed__Course_Offering__c offering) {
        //CombinedFunctions.createEventsForSection([select Id, hed__Start_Date__c, hed__End_Date__c, lms_hed__Computed_LMS_Reference__c, lms_hed__LMS_Course_Term__c, hed__Faculty__c from hed__Course_Offering__c where Id = 'a0CDE00000cpDiK2AU' LIMIT 1]);
        try {
            System.debug(offering.hed__Start_Date__c+'|'+offering.hed__End_Date__c+'|'+offering.lms_hed__Computed_LMS_Reference__c+'|'+offering.lms_hed__LMS_Course_Term__c+'|'+offering.hed__Faculty__c);
        } catch(SObjectException soe) {
            // User didn't pass in all fields.
            offering = [select Id, hed__Start_Date__c, hed__End_Date__c, lms_hed__Computed_LMS_Reference__c, lms_hed__LMS_Course_Term__c, hed__Faculty__c from hed__Course_Offering__c where Id = :offering.Id LIMIT 1];
        }
        if(offering.hed__Start_Date__c == null) throw new IllegalArgumentException('Couldn\'t create events for offering... hed__Start_Date__c of offering is not set!');
        if(offering.hed__End_Date__c == null) throw new IllegalArgumentException('Couldn\'t create events for offering... hed__End_Date__c of offering is not set!');

        // Step #1 - Get schedules
        List<Event> changedSchedules = new List<Event>();
        List<Event> createdSchedules = new List<Event>();
        
        List<Id> contacts = null;
        for(hed__Course_Offering_Schedule__c schedule : [select Id, Schedule_Reference__c, hed__Facility__c, hed__Facility__r.Name, hed__Monday__c, hed__Tuesday__c, hed__Wednesday__c, hed__Thursday__c, hed__Friday__c, hed__Saturday__c, hed__Sunday__c, hed__Start_Time__c, hed__End_Time__c, Eventbrite_Event__c from hed__Course_Offering_Schedule__c where hed__Course_Offering__c = :offering.Id]) {
            
            // Recurring logic should be smart enough to handle an offering schedule all in one.
            String patternText = offeringScheduleToRecurrence2PatternText(schedule);
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
        List<hed__Course_Offering_Schedule__c> schedules = null;
        for(hed__Course_Enrollment__c enrollment : [select Id, hed__Contact__c from hed__Course_Enrollment__c where hed__Course_Offering__c = :offering.Id]) {
            if(schedules == null) schedules = [select Id from hed__Course_Offering_Schedule__c where hed__Course_Offering__c = :offering.Id];
            enlistEnrollmentInEvent(schedules, enrollment.hed__Contact__c);
        }

        return createdSchedules;
    }

    private static String offeringScheduleToRecurrence2PatternText(hed__Course_Offering_Schedule__c schedule) {
        //RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR
        String rrule = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=';
        if(schedule.hed__Sunday__c) rrule+='SU,';
        if(schedule.hed__Monday__c) rrule+='MO,';
        if(schedule.hed__Tuesday__c) rrule+='TU,';
        if(schedule.hed__Wednesday__c) rrule+='WE,';
        if(schedule.hed__Thursday__c) rrule+='TH,';
        if(schedule.hed__Friday__c) rrule+='FR,';
        if(schedule.hed__Saturday__c) rrule+='SA,';

        return rrule.substring(0, rrule.length()-1);
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
        return '['+offering.lms_hed__Computed_LMS_Reference__c+'] - Class Session';
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
    
}