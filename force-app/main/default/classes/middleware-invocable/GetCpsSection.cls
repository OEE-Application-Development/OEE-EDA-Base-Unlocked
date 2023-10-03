global with sharing class GetCpsSection {
    @InvocableMethod(Label='GetCpsSection' Description = 'Get CPS Section - search term like 2023FA-AGBB-2010-200.' Category = 'Middleware Operation')
    global static List<MiddlewareActionResponse> getCpsSection(List<MiddlewareIntegration.MiddlewareSearchRequest> cpsSearches) {
        List<MiddlewareActionResponse> results = new List<MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareSearchRequest search : cpsSearches) {
            results.add(MiddlewareIntegration.getCpsSection(search));
        }
        return results;
    }
}