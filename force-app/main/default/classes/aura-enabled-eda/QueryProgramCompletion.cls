global with sharing class QueryProgramCompletion {

    @AuraEnabled(cacheable = true)
    global static PlanCompletionComparison getPlanCompletion(Id contactId, Id programPlanId) {
        // Get the breadth of the program... we can <i>probably</i> assume it's not more than 5 deep...
        PlanCompletionComparison comparison = new PlanCompletionComparison([SELECT Id, Name, hed__Total_Required_Credits__c, hed__Is_Primary__c, (SELECT Id, hed__Plan_Requirement__c, Name, hed__Description__c, csuoee__Long_Description__c, RecordType.DeveloperName, hed__Credits__c, hed__Category__c, hed__Course__c, hed__Course__r.hed__Credit_Hours__c, csuoee__Required_Amount__c, hed__Sequence__c FROM hed__Plan_Requirements__r ORDER BY hed__Sequence__c) FROM hed__Program_Plan__c WHERE Id = :programPlanId LIMIT 1]);
        fillChildren(comparison);

        // Get Student Course Completions.
        List<hed__Course_Enrollment__c> enrollments = [SELECT Id, hed__Course_Offering__r.hed__Course__c, hed__Course_Offering__r.hed__Course__r.csuoee__Course_Code__c, hed__Credits_Earned__c FROM hed__Course_Enrollment__c WHERE hed__Contact__c = :contactId AND hed__Credits_Earned__c > 0];
        comparison.evaluateProgramStatus(enrollments);
        return comparison;
    }

    private static void fillChildren(PlanCompletionComparison comparison) {
        List<Id> containerIds = comparison.getUncheckedContainers();
        while(!containerIds.isEmpty()) {
            comparison.addRequirements([SELECT Id, hed__Plan_Requirement__c, Name, hed__Description__c, csuoee__Long_Description__c, RecordType.DeveloperName, hed__Credits__c, hed__Category__c, hed__Course__c, hed__Course__r.hed__Credit_Hours__c, csuoee__Required_Amount__c, hed__Sequence__c, (SELECT Id, hed__Plan_Requirement__c, Name, hed__Description__c, csuoee__Long_Description__c, RecordType.DeveloperName, hed__Credits__c, hed__Category__c, hed__Course__c, hed__Course__r.hed__Credit_Hours__c, csuoee__Required_Amount__c, hed__Sequence__c FROM hed__Plan_Requirements__r ORDER BY hed__Sequence__c) FROM hed__Plan_Requirement__c WHERE hed__Plan_Requirement__c IN :containerIds ORDER BY hed__Sequence__c]);
            containerIds = comparison.getUncheckedContainers();
        }
    }
    
}