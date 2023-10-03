@JsonAccess(serializable='always' deserializable='always')
global with sharing class MiddlewareActionResponseData {
    @InvocableVariable(Required=false Label='LoginId' Description='The returned LoginId from GetLoginIdFromOpus.')
    global String loginId;
    @InvocableVariable(Required=false Label='Status' Description='Status of the requested entity (usually an enrollment).')
    global String status;
    @InvocableVariable(Required=false Label='Recommended Action' Description='Message from Middleware - e.g. recommends a canvas drop if line item is dropped.')
    global String recommendedAction;
}