global with sharing class GetCustomFieldRequest {
    @InvocableVariable(Required=true Label='SObject Record' Description='The SOBject to get a field from.')
    global SObject record;
    @InvocableVariable(Required=true Label='Field Name' Description='The name of the field e.g. Assign_to_My_Tasks__c')
    global String field;
}