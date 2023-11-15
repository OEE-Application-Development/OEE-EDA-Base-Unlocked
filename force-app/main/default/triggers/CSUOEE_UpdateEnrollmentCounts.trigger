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

    AggregateResult[] enrollmentCounts = [SELECT hed__Course_Offering__c, RecordType.DeveloperName, COUNT(Id)Enrollment_Count, AVG(hed__Grade__c)Avg_Grade FROM hed__Course_Enrollment__c WHERE hed__Course_Offering__c IN :offeringsToUpdate GROUP BY hed__Course_Offering__c, RecordType.DeveloperName];
    
    Map<Id, hed__Course_Offering__c> toUpdate = new Map<Id, hed__Course_Offering__c>();
    for(AggregateResult enrollmentCount : enrollmentCounts) {
        Id offeringId = (Id) enrollmentCount.get('hed__Course_Offering__c');
        String recordTypeName = (String) enrollmentCount.get('DeveloperName');
        Integer counts = (Integer) enrollmentCount.get('Enrollment_Count');
        Double avgGrade = (Double) enrollmentCount.get('Avg_Grade');

        hed__Course_Offering__c offering = toUpdate.get(offeringId);
        if(offering == null) {
            offering = new hed__Course_Offering__c(Id = offeringId, Confirmed_Enrollments__c = 0, Pending_Enrollments__c = 0, Avg_Grade_Point__c = 0.00);
            toUpdate.put(offeringId, offering);
        }
        if(recordTypeName == 'Student') {
            offering.Confirmed_Enrollments__c = counts;
            offering.Avg_Grade_Point__c = avgGrade;
        } else if(recordTypeName == 'Student_Pending') {
            offering.Pending_Enrollments__c = counts;
        }
    }

    if(!toUpdate.isEmpty()) {
        update toUpdate.values();
    }
}