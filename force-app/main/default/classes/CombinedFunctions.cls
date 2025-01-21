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

    global static List<String> addStringToList(List<String> strings, String s, boolean inFront) {
        if(inFront) {
            List<String> newList = new List<String>{s};
            newList.addAll(strings);
            return newList;
        } else {
            strings.add(s);
            return strings;
        }
    }

    private static final String EVENT_OFFSET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    global static List<EventRelation> enlistEnrollmentInEvent(List<hed__Course_Offering_Schedule__c> schedules, List<Id> studentIds) {
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

    @AuraEnabled(cacheable = true)
    public static Id getPublicChannelByName(String channelName) {
        if(channelName == '') return null;
        return [SELECT Id, Name FROM ManagedContentChannel WHERE Name = :channelName AND Type = 'PublicUnauthenticated' LIMIT 1].Id;
    }

    @AuraEnabled(cacheable = true)
    public static Id getWorkspaceByName(String workspaceName) {
        if(workspaceName == '') return null;

        return [SELECT Id FROM ManagedContentSpace WHERE Name = :workspaceName LIMIT 1].Id;
    }

    private static Map<String, Object> parseCMSFileData(String channelId, String contentKey) {
        Map<String, Object> results = new Map<String, Object>();
        Map<String, Object> fileMap = ConnectApi.ManagedContentDelivery.getManagedContentForChannel(channelId, contentKey, true).ContentBody;
        // Search for the ApexWrapped data
        for(Object val : fileMap.values()) {
            if(String.valueOf(val).contains('ApexMapWrapper')) {
                Map<String, Object> mapData = (Map<String, Object>)ConnectApi.ConnectUtilities.unwrapApexWrapper(val);
                for(String key : mapData.keySet()) {
                    if('url'.equals(key)) {
                        results.put(key, String.valueOf(mapData.get(key)));
                    } else if('source'.equals(key)) {
                        Map<String, Object> sourceData = (Map<String, Object>)mapData.get('source');
                        String mimeType = (String)(sourceData.get('mimeType'));
                        if(mimeType != null) {
                            results.put('isImage', mimeType.contains('image'));
                            results.put('mimeType', mimeType);
                        }
                    }
                }
            }
        }

        return results;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, Object> evalCMSContent(String channelId, String contentKey) {
        if(channelId == '' || contentKey == '') return new Map<String, Object>();
        try {
            return parseCMSFileData(channelId, contentKey);
        } catch (Exception e) {
            return new Map<String, Object>{'isImg' => false};
        }
    }

    @AuraEnabled
    public static Map<String, Object> setWorkspaceFile(Id recordId, String objectName, String fieldName, String publicUrlField, String channelId, String contentKey) {
        Schema.SObjectType refObjType = Schema.getGlobalDescribe().get(objectName);
        SObject refObject = refObjType.newSObject(recordId);

        try {
            Map<String, Object> results = new Map<String, Object>{ 'success' => true, 'message' => 'Content found and associated.'};
            results.putAll(parseCMSFileData(channelId, contentKey));

            refObject.put(fieldName, contentKey);
            if(results.containsKey('url')) {
                refObject.put(publicUrlField, results.get('url'));
            }
            update refObject;
            return results;
        } catch(ConnectApi.NotFoundException nfe) {
            return new Map<String, Object>{ 'success' => false, 'message' => 'Content not found, did you remember to publish it?'};
        }
    }

    @AuraEnabled(cacheable = true)
    public static Id getContentIdForCMSKey(String key){
        try {
            return [SELECT Id FROM ManagedContent WHERE ContentKey = :key LIMIT 1].Id;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static void clearWorkspaceFile(Id recordId, String objectName, String fieldName, String publicUrlField){
        Schema.SObjectType refObjType = Schema.getGlobalDescribe().get(objectName);
        SObject refObject = refObjType.newSObject(recordId);

        refObject.put(fieldName, null);
        refObject.put(publicUrlField, null);
        
        update refObject;
    }

    @AuraEnabled
    public static Boolean associateFile(Id recordId, Id contentDocumentId, String objectName, String fieldName, String publicUrlField) {
        Schema.SObjectType refObjType = Schema.getGlobalDescribe().get(objectName);
        SObject refObject = refObjType.newSObject(recordId);
        
        try {
            // ... and, make it visible
            ContentVersion cv = [SELECT Id, VersionDataUrl FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true LIMIT 1];
            ContentDistribution distribution = new ContentDistribution(
                ContentVersionId = cv.Id,
                Name = 'Public Download',
                PreferencesPasswordRequired = false,
                PreferencesAllowOriginalDownload = true,
                PreferencesAllowPDFDownload = true,
                PreferencesAllowViewInBrowser = true,
                PreferencesNotifyOnVisit = true,
                PreferencesExpires = false
            );
            insert distribution;

            distribution = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id LIMIT 1];
            
            refObject.put(fieldName, contentDocumentId);
            refObject.put(publicUrlField, distribution.DistributionPublicUrl);
            update refObject;
        } catch(Exception e) {
            return false;
        }
        
        return true;
    }

    @AuraEnabled
    global static Map<String, String> getImage(Id contentDocumentId) {
        try {
            ContentVersion cv = [SELECT Id, VersionDataUrl FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true LIMIT 1];
            ContentDistribution distribution = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId = :cv.Id LIMIT 1];
            return new Map<String, String> {'InternalUrl' => cv.VersionDataUrl, 'ExternalUrl' => distribution.DistributionPublicUrl};
        } catch(QueryException qe) {
            return new Map<String, String> {'InternalUrl' => null, 'ExternalUrl' => null, 'Error' => 'true', 'ErrorMessage' => qe.getMessage()};
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
    
    @AuraEnabled(cacheable = true)
    global static hed__Course_Offering__c getNextActiveOffering(Id courseId) {
        List<hed__Course_Offering__c> offerings = [select Id, Name, lms_hed__LMS_Reference_Code__c, lms_hed__LMS_Offering_ID__c, lms_hed__LMS_Course_Term__r.lms_hed__LMS_Course_ID__c from hed__Course_Offering__c where hed__Course__c = :courseId and hed__Term__c in (select Id from hed__Term__c where Is_Visible__c = true and RecordType.DeveloperName = 'Credit') order by lms_hed__LMS_Offering_ID__c LIMIT 10];
        if(offerings.isEmpty()) return null;

        return offerings.get(0);
    }

    
    private static String LEAD_CONVERTED_STATUS = null;
    global static String getLeadConvertedStatus() {
        if(LEAD_CONVERTED_STATUS == null) {
            LEAD_CONVERTED_STATUS = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
        }

        return LEAD_CONVERTED_STATUS;
    }

    /**
     * Generic method to match Contact/Leads on Email.
     * 
     * Also utilizes a Contact <-> Account relationship lookup
     * 
     * e.g. Noncredit could use Contact.csuoee__Noncredit_ID__c <-> Account.hed__School_Code__c
     *      or Credit Contact.csuoee__PIDM__c <-> Account.hed__School_Code__c
     * 
     */
    global static ConvertResult attemptConvertByEmail(List<Contact> contacts, List<String> contactEmailFields) {
        // First - set up the Email map, that's what we're matching on.
        Map<String, Contact> emailMap = new Map<String, Contact>();
        Map<String, List<String>> queryMap = new Map<String, List<String>>();
        for(Contact contact : contacts) {
            if(contact.Email == null) throw new QueryException('Contact sent without Email.');
            Contact replaced = emailMap.put(contact.Email.toLowerCase(), contact);
            if(replaced != null) throw new QueryException('Contacts have duplicate emails.');

            queryMap.put(contact.Email, new List<String>{contact.Email.toLowerCase()});
        }

        // Define matchers
        ContactEmailMatcher contactMatcher = new ContactEmailMatcher(queryMap, contactEmailFields, new List<String>{'AccountId'});
        LeadEmailMatcher leadMatcher = new LeadEmailMatcher(queryMap, new List<String>(), new List<String>{'OwnerId'});

        // Return matches
        Map<String, SObject> contactMatches = contactMatcher.match();
        Map<String, SObject> leadMatches = leadMatcher.match();

        // For matched Contacts, bring in the old IDs
        for(String email : contactMatches.keySet()) {
            Contact passedContact = emailMap.get(email.toLowerCase());
            Contact foundContact = (Contact)contactMatches.get(email);

            passedContact.Id = foundContact.Id;
            passedContact.AccountId = foundContact.AccountId;
        }

        Map<String, List<String>> schoolCodeMap = new Map<String, List<String>>();
        // ... one more round on unmatched contacts going by Accounts
        for(Contact contact : emailMap.values()) {
            // Don't need to update 
            if(contact.Id != null && contact.Account != null && contact.Account.hed__School_Code__c != null) {
                // We need to look up the account
                schoolCodeMap.put(contact.Email.toLowerCase(), new List<String>{contact.Account.hed__School_Code__c});
            }
        }

        if(!schoolCodeMap.isEmpty()) {
            // Map Account Ids for conversion
            AccountSchoolCodeMatcher accountMatcher = new AccountSchoolCodeMatcher(schoolCodeMap);
            Map<String, SObject> accountMatches = accountMatcher.match();
            for(String email : accountMatches.keySet()) {
                Account foundAccount = (Account)accountMatches.get(email.toLowerCase());
                Contact passedContact = emailMap.get(email.toLowerCase());

                passedContact.AccountId = foundAccount.Id;
            }
        }

        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        // Start converting - if we have a contact/account, then use that. If not, convert -> apply update.
        for(String email : leadMatches.keySet()) {
            Lead lead = (Lead)leadMatches.get(email);

            Database.LeadConvert toConvert = new Database.LeadConvert();
            toConvert.setLeadId(lead.Id);

            Contact contact = emailMap.get(email.toLowerCase());
            if(contact.Id != null) {
                toConvert.setAccountId(contact.AccountId);
                toConvert.setContactId(contact.Id);
            }
            toConvert.setDoNotCreateOpportunity(true);
            toConvert.setConvertedStatus(getLeadConvertedStatus());
            toConvert.setOwnerId(lead.OwnerId);
            
            leadsToConvert.add(toConvert);
        }

        List<Contact> successfulConverts = new List<Contact>();
        List<Contact> unsuccessfulConverts = new List<Contact>();
        if(!leadsToConvert.isEmpty()) {
            for(Database.LeadConvertResult result : Database.convertLead(leadsToConvert, false)) {
                // Get the lead back
                Lead passedLead;
                for(SObject lead : leadMatches.values()) {
                    if(lead.Id == result.getLeadId()) {
                        passedLead = (Lead)lead;
                        break;
                    }
                }
                Contact passedContact = emailMap.get(passedLead.Email.toLowerCase());
                if(result.isSuccess()) {
                    // Assign Ids post convert - doesn't matter if they were set previously
                    passedContact.Id = result.getContactId();
                    passedContact.AccountId = result.getAccountId();

                    if(passedContact.AccountId != null && passedContact.Account != null) {
                        passedContact.Account = null;
                    }
                    successfulConverts.add(passedContact);
                } else {
                    // At a minimum, we'll have the lead so we can get the email
                    unsuccessfulConverts.add(passedContact);
                }
            }
        }

        if(!successfulConverts.isEmpty()) {
            update successfulConverts;
        }

        return new ConvertResult(successfulConverts, unsuccessfulConverts);
    }
    
}