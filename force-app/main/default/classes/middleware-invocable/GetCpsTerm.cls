global with sharing class GetCpsTerm {
    @InvocableMethod(Label='GetCpsTerm' Description = 'Get CPS Term - search term like Summer 2023.' Category = 'Middleware Operation')
    global static List<MiddlewareActionResponse> getCpsTerm(List<MiddlewareIntegration.MiddlewareSearchRequest> cpsSearches) {
        List<MiddlewareActionResponse> results = new List<MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareSearchRequest search : cpsSearches) {
            results.add(MiddlewareIntegration.getCpsTerm(search));
        }
        return results;
    }
}