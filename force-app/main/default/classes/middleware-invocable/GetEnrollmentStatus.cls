global with sharing class GetEnrollmentStatus {
    @InvocableMethod(Label='GetEnrollmentStatus' Description = 'Get Enrollment status - if credit, from Banner; if PE, from Opus.')
    global static List<MiddlewareIntegration.MiddlewareActionResponse> getEnrollmentStatus(List<MiddlewareIntegration.MiddlewareUserRequest> enrollmentRequests) {
        List<MiddlewareIntegration.MiddlewareActionResponse> results = new List<MiddlewareIntegration.MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareUserRequest request : enrollmentRequests) {
            results.add(MiddlewareIntegration.getEnrollmentStatus(request));
        }
        return results;
    }
}