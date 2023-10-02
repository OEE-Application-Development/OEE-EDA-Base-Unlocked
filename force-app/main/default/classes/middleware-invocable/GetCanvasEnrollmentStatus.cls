global with sharing class GetCanvasEnrollmentStatus {
    @InvocableMethod(Label='GetCanvasEnrollmentStatus' Description = 'Get Canvas Enrollment status - ask middleware about canvas enrollment status of student.' Category = 'Middleware Operation')
    global static List<MiddlewareIntegration.MiddlewareActionResponse> getCanvasEnrollmentStatus(List<MiddlewareIntegration.MiddlewareUserRequest> enrollmentRequests) {
        List<MiddlewareIntegration.MiddlewareActionResponse> results = new List<MiddlewareIntegration.MiddlewareActionResponse>();
        for(MiddlewareIntegration.MiddlewareUserRequest request : enrollmentRequests) {
            results.add(MiddlewareIntegration.getCanvasEnrollmentStatus(request));
        }
        return results;
    }
}