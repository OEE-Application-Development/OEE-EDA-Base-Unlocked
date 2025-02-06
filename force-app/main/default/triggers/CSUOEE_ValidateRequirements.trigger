trigger CSUOEE_ValidateRequirements on hed__Plan_Requirement__c (before insert, before update) {
    for(hed__Plan_Requirement__c req : Trigger.new) {
        if(req.csuoee__Instance_Of__c != null && req.RecordTypeId != hed__Plan_Requirement__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Template_Instance').getRecordTypeId()) {
            req.addError('Only Requirements of type Template_Instance can have an csuoee__Instance_Of__c set.');
            continue;
        }
        if(req.csuoee__Is_Template__c && (req.hed__Program_Plan__c == null || req.hed__Plan_Requirement__c != null || req.RecordTypeId != hed__Plan_Requirement__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Requirement_Container').getRecordTypeId())) {
            req.addError('Template Containers must be attached to a Program Plan, not a parent requirement.');
            continue;
        }
    }
}