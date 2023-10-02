global with sharing class GetLoginIdFromOpus {
    @InvocableMethod(Label='GetLoginIdFromOpus' Description = 'Ask Middleware to lookup Canvas Login ID in Opus.')
    global static List<MiddlewareIntegration.MiddlewareActionResponse> getLoginIdFromOpus(List<String> userIds) {
        List<MiddlewareIntegration.MiddlewareActionResponse> results = new List<MiddlewareIntegration.MiddlewareActionResponse>();
        for(String userId : userIds) {
            results.add(MiddlewareIntegration.getLoginIdFromOpus(userId));
        }
        return results;
    }
}