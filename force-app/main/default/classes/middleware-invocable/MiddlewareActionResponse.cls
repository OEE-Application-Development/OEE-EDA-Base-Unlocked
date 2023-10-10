@JsonAccess(serializable='always' deserializable='always')
global with sharing class MiddlewareActionResponse {
    @InvocableVariable(Required=true Label='Action Success' Description='True if the intended action succeeded - does not necessarily mean a change was made.')
    global Boolean success;
    @InvocableVariable(Required=true Label='Action Message' Description='General message from server - if success=false, should explain why.')
    global String message;
    @InvocableVariable(Required=true Label='Response Data' Description='A Map of data results - predefined in SF. See Data for descriptions.')
    global MiddlewareActionResponseData data;
    @InvocableVariable(Required=true Label='Response Data' Description='HTTP Response Code - e.g. 200 - OK, 400 - Bad Request.')
    global Integer httpStatus;

    public MiddlewareActionResponse(){}
    public MiddlewareActionResponse(Boolean success, String message, MiddlewareActionResponseData data) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.httpStatus = httpStatus;
    }
}