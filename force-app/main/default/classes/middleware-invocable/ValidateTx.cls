global with sharing class ValidateTx {
    @InvocableMethod(Label='ValidateTx' Description = 'Validate a transaction between Authorize.Net & Opus.' Category = 'Middleware Operation')
    global static List<MiddlewareIntegration.MiddlewareActionResponse> validateTx(List<MiddlewareIntegration.MiddlewareTxRequest> txRequests) {
        List<MiddlewareIntegration.MiddlewareActionResponse> results = new List<MiddlewareIntegration.MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareTxRequest request : txRequests) {
            results.add(MiddlewareIntegration.validateTx(request));
        }
        return results;
    }
}