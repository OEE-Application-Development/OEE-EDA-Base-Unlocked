trigger CSUOEE_SetOfferingAvailability on hed__Course_Offering__c (before insert, before update) {
    // Is Available for Registration
    Date today = Date.today();
    for(hed__Course_Offering__c offering : Trigger.new) {
        if(offering.csuoee__Registration_Start_Date__c == null || offering.csuoee__Registration_End_Date__c == null || offering.csuoee__Confirmed_Enrollments__c == null || offering.hed__Capacity__c == null) continue;
        offering.csuoee__Is_Available_for_Registration__c = (today >= offering.csuoee__Registration_Start_Date__c && today <= offering.csuoee__Registration_End_Date__c && offering.csuoee__Confirmed_Enrollments__c < offering.hed__Capacity__c);
    }
}