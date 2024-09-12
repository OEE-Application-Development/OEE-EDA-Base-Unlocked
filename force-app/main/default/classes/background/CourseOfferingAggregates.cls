global class CourseOfferingAggregates {
    
    @future
    public static void updateOfferingAggregates(List<Id> offeringIds) {
        AggregateResult[] enrollmentCounts = [SELECT hed__Course_Offering__c, RecordType.DeveloperName, COUNT(Id)Enrollment_Count, AVG(hed__Grade__c)Avg_Grade FROM hed__Course_Enrollment__c WHERE hed__Course_Offering__c IN :offeringIds GROUP BY hed__Course_Offering__c, RecordType.DeveloperName];
    
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
            // For large updates, row locks can stop this. Don't fail just because we can't update everything.
            while(!toUpdate.isEmpty()) {
                List<Database.SaveResult> saveResults = Database.update(toUpdate.values(), false, System.AccessLevel.SYSTEM_MODE);
                for(Database.SaveResult saveResult : saveResults) {
                    if(saveResult.success) {
                        toUpdate.remove(saveResult.id);
                    }
                }
            }
        }
    }

}