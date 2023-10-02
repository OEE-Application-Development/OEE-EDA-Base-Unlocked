global with sharing class MiddlewareIntegration {

    // Middleware webhook controller always responds with this guy.
    @JsonAccess(serializable='always' deserializable='always')
    global with sharing class MiddlewareActionResponse {
        @InvocableVariable
        global Boolean success;
        @InvocableVariable
        global String message;
        @InvocableVariable
        global MiddlewareActionResponseData data;
        @InvocableVariable
        global Integer httpStatus;

        public MiddlewareActionResponse(){}
        public MiddlewareActionResponse(Boolean success, String message, MiddlewareActionResponseData data) {
            this.success = success;
            this.message = message;
            this.data = data;
            this.httpStatus = httpStatus;
        }
    }

    @JsonAccess(serializable='always' deserializable='always')
    global with sharing class MiddlewareActionResponseData {
        @InvocableVariable
        global String loginId;
        @InvocableVariable
        global String status;
        @InvocableVariable
        global String recommendedAction;
    }
    
    private static Http http = new Http();
    private static MiddlewareActionResponse sendDataRequest(String path) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:oeesvc__MiddlewareSvc'+path);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);
        MiddlewareActionResponse actionResponse;
        try {
           actionResponse = (MiddlewareActionResponse)JSON.deserialize(response.getBody(), MiddlewareActionResponse.class);
           actionResponse.httpStatus = response.getStatusCode();
        } catch(Exception e) {
            return null;
        }
        
        return actionResponse;
    }

    global static MiddlewareActionResponse sendPostRequest(String path, Map<String, String> body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:oeesvc__MiddlewareSvc'+path);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');

        request.setBody(JSON.serialize(body));
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 300)
            return (MiddlewareActionResponse)JSON.deserialize(response.getBody(), MiddlewareActionResponse.class);

        return null;
    }

    global static MiddlewareActionResponse getLoginIdFromOpus(String userId) {
        return sendDataRequest('/action/canvas/loginForUser'+CombinedFunctions.parameterizeRequestParams(new Map<String, String>{'userId' => userId}));
    }

    global with sharing class MiddlewareUserRequest {
        @InvocableVariable(Required=false Label='Is Credit' Description='Mostly only used for enrollment check - Banner vs. Opus')
        global Boolean isCredit = false;
        @InvocableVariable(Required=true Label='User ID' Description='User ID - usually can be Noncredit ID, CSU ID, or FrontDoor ID')
        global String userId;
        @InvocableVariable(Required=true Label='Section Reference' Description='Section Reference')
        global String sectionReference;
    }

    global static MiddlewareActionResponse getEnrollmentStatus(MiddlewareUserRequest request) {
        return sendDataRequest('/action/enrollment/status'+CombinedFunctions.parameterizeRequestParams(new Map<String, String>{'isCredit' => ((request.isCredit)?'true':'false'), 'sectionReference' => request.sectionReference, 'studentId' => request.userId}));
    }

    global static MiddlewareActionResponse getCanvasEnrollmentStatus(MiddlewareUserRequest request) {
        return sendDataRequest('/action/canvas/enrollment/status'+CombinedFunctions.parameterizeRequestParams(new Map<String, String>{'sectionReference' => request.sectionReference, 'studentId' => request.userId}));
    }

    global with sharing class MiddlewareTxRequest {
        @InvocableVariable(Label='CSU Transaction Id')
        global String csuTxId;
        @InvocableVariable(Label='Auth.Net Transaction Id')
        global String processorTxId;
    }

    global static MiddlewareActionResponse validateTx(MiddlewareTxRequest request) {
        return sendPostRequest('/action/tx/validate', new Map<String, String>{'csuTxId' => request.csuTxId, 'processorTxId' => request.processorTxId});
    }

}