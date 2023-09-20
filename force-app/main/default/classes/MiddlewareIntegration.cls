global with sharing class MiddlewareIntegration {

    // Middleware webhook controller always responds with this guy.
    @JsonAccess(serializable='always' deserializable='always')
    global with sharing class MiddlewareActionResponse {
        global Boolean success;
        global String message;
        global Map<String, String> data;

        public MiddlewareActionResponse(){}
        public MiddlewareActionResponse(Boolean success, String message, Map<String, String> data) {
            this.success = success;
            this.message = message;
            this.data = data;
        }
    }
    
    private static Http http = new Http();
    private static MiddlewareActionResponse sendDataRequest(String path) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CSUOnline_Middleware_Creds'+path);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 300)
            return (MiddlewareActionResponse)JSON.deserialize(response.getBody(), MiddlewareActionResponse.class);

        return null;
    }

    global static String getEnrollmentStatus(Boolean isCredit, String sectionReference, String frontDoorId) {
        MiddlewareActionResponse response = sendDataRequest('/action/enrollment/status?isCredit='+((isCredit)?'true':'false')+'&sectionReference='+sectionReference+'&studentId='+frontDoorId);
        if(response.success) {
            return (String)response.data.get('status');
        }
        return null;
    }

    global static MiddlewareActionResponse sendPostRequest(String path, Map<String, String> body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CSUOnline_Middleware_Creds'+path);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');

        request.setBody(JSON.serialize(body));
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 300)
            return (MiddlewareActionResponse)JSON.deserialize(response.getBody(), MiddlewareActionResponse.class);

        return null;
    }

    //TODO: Implement other middleware calls here I guess.

}