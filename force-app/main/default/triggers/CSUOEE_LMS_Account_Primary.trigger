trigger CSUOEE_LMS_Account_Primary on lms_hed__LMS_Account__c (after insert, after update) {
    Map<Id, Id> primaryMapping = new Map<Id, Id>();
    for(lms_hed__LMS_Account__c lmsAcct : (List<lms_hed__LMS_Account__c>) Trigger.new) {
        primaryMapping.put(lmsAcct.lms_hed__Account_Owner__c, lmsAcct.Id);
    }

    List<Contact> primaryAccountSet = new List<Contact>();
    for(Contact c : [select Id from Contact where (Primary_Canvas_Account__c = null or Primary_Canvas_Account__c = '') and Id in :primaryMapping.keySet()]) {
        c.Primary_Canvas_Account__c = primaryMapping.get(c.Id);
        primaryAccountSet.add(c);
    }

    if(!primaryAccountSet.isEmpty()) {
        update primaryAccountSet;
    }
}