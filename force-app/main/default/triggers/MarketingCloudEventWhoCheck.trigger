trigger MarketingCloudEventWhoCheck on Marketing_Cloud_Journey_Event__c (before insert) {
    for(Marketing_Cloud_Journey_Event__c e : Trigger.new) {
        if(String.isBlank(e.ContactWhoId__c) && String.isBlank(e.LeadWhoId__c)) {
            e.addError('Either Contact or Lead must be set!');
        }
    }
}