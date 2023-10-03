global with sharing class GetLoginIdFromOpus {
    @InvocableMethod(Label='GetLoginIdFromOpus' Description = 'Ask Middleware to lookup Canvas Login ID in Opus.' Category = 'Middleware Operation')
    global static List<MiddlewareActionResponse> getLoginIdFromOpus(List<String> userIds) {
        List<MiddlewareActionResponse> results = new List<MiddlewareActionResponse>();
        for(String userId : userIds) {
            results.add(MiddlewareIntegration.getLoginIdFromOpus(userId));
        }
        return results;
    }
}