@JsonAccess(serializable='always' deserializable='always')
global with sharing class MiddlewareActionResponseData {
    @AuraEnabled
    @InvocableVariable(Required=false Label='Id' Description='Id of the requested object e.g. CPS Section Id.')
    global String id;
    @AuraEnabled
    @InvocableVariable(Required=false Label='LoginId' Description='The returned LoginId from GetLoginIdFromOpus.')
    global String loginId;
    @AuraEnabled
    @InvocableVariable(Required=false Label='Status' Description='Status of the requested entity (usually an enrollment).')
    global String status;
    @AuraEnabled
    @InvocableVariable(Required=false Label='Recommended Action' Description='Message from Middleware - e.g. recommends a canvas drop if line item is dropped.')
    global String recommendedAction;
}