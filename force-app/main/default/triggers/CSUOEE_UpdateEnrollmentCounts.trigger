trigger CSUOEE_UpdateEnrollmentCounts on hed__Course_Enrollment__c (after insert, after update, after delete) {
    // Other trigger prevents contactless / offeringless updates.
    // That trigger also prevent switching offerings, so it's safe to just look at new for insert / update - only use old for delete.
    Set<Id> offeringsToUpdate = new Set<Id>();
    if(Trigger.isDelete) {
        for(hed__Course_Enrollment__c enrollment : (List<hed__Course_Enrollment__c>)Trigger.old) {
            offeringsToUpdate.add(enrollment.hed__Course_Offering__c);
        }
    } else {
        for(hed__Course_Enrollment__c enrollment : (List<hed__Course_Enrollment__c>)Trigger.new) {
            offeringsToUpdate.add(enrollment.hed__Course_Offering__c);
        }
    }

    CombinedFunctions.updateOfferingAggregates(new List<Id>(offeringsToUpdate));
}