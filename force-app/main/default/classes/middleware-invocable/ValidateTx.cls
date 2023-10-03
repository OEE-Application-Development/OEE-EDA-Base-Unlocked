global with sharing class ValidateTx {
    @InvocableMethod(Label='ValidateTx' Description = 'Validate a transaction between Authorize.Net & Opus.' Category = 'Middleware Operation')
    global static List<MiddlewareActionResponse> validateTx(List<MiddlewareIntegration.MiddlewareTxRequest> txRequests) {
        List<MiddlewareActionResponse> results = new List<MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareTxRequest request : txRequests) {
            results.add(MiddlewareIntegration.validateTx(request));
        }
        return results;
    }
}