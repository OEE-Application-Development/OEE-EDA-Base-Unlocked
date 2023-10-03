global with sharing class GetEnrollmentStatus {
    @InvocableMethod(Label='GetEnrollmentStatus' Description = 'Get Enrollment status - if credit, from Banner; if PE, from Opus.' Category = 'Middleware Operation')
    global static List<MiddlewareActionResponse> getEnrollmentStatus(List<MiddlewareIntegration.MiddlewareUserRequest> enrollmentRequests) {
        List<MiddlewareActionResponse> results = new List<MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareUserRequest request : enrollmentRequests) {
            results.add(MiddlewareIntegration.getEnrollmentStatus(request));
        }
        return results;
    }
}