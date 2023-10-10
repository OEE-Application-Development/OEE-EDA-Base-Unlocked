global with sharing class MiddlewareActionTxResponse {
    @InvocableVariable(Required=true Label='Action Success' Description='True if the intended action succeeded - does not necessarily mean a change was made.')
    global Boolean success;
    @InvocableVariable(Required=true Label='Action Message' Description='General message from server - if success=false, should explain why.')
    global String message;
    @InvocableVariable(Required=true Label='Transaction List' Description='List of transactions for invoice.')
    global List<MiddlewareTransactionResponse> data;
    @InvocableVariable(Required=true Label='HTTP Status Code' Description='HTTP Response Code - e.g. 200 - OK, 400 - Bad Request.')
    global Integer httpStatus;

    public MiddlewareActionTxResponse(){}
    public MiddlewareActionTxResponse(Boolean success, String message, List<MiddlewareTransactionResponse> data) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.httpStatus = httpStatus;
    }
}