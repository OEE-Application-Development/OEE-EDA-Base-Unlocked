global class QueryRegistrationsRequest {
    @AuraEnabled
    @InvocableVariable(Required=true Description='Term in which to search.')
    global hed__Term__c term;
    @AuraEnabled
    @InvocableVariable(Required=true Description='Requested page.')
    global Integer page;
    @AuraEnabled
    @InvocableVariable(Required=true Description='Number of requested results per page.')
    global Integer pageSize;
}