global with sharing class GetCpsCourse {
    @InvocableMethod(Label='GetCpsCourse' Description = 'Get CPS Course - search term like ACT 205.' Category = 'Middleware Operation')
    global static List<MiddlewareActionResponse> getCpsCourse(List<MiddlewareIntegration.MiddlewareSearchRequest> cpsSearches) {
        List<MiddlewareActionResponse> results = new List<MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareSearchRequest search : cpsSearches) {
            results.add(MiddlewareIntegration.getCpsCourse(search));
        }
        return results;
    }
}