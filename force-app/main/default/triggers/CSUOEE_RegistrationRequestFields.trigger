trigger CSUOEE_RegistrationRequestFields on Registration_Request__c (before insert) {
    Set<Id> offerings = new Set<Id>();
    for(Registration_Request__c request : (List<Registration_Request__c>)Trigger.new) {
        offerings.add(request.Course_Offering__c);
    }

    Map<Id, Boolean> isCreditMap = new Map<Id, Boolean>();
    for(hed__Course_Offering__c offering : (List<hed__Course_Offering__c>) [select Id, Is_Credit__c from hed__Course_Offering__c where Id in :offerings]) {
        isCreditMap.put(offering.Id, offering.Is_Credit__c);
    }
    
    for(Registration_Request__c request : (List<Registration_Request__c>)Trigger.new) {
        request.Is_Credit__c = isCreditMap.get(request.Course_Offering__c);
    }
}