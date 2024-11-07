global with sharing class MiddlewareIntegration {

    global static HttpRequest getMiddlewareRequest(String method, String path) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:oeesvc__MiddlewareSvc'+path);
        request.setMethod(method);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
    }
    
    private static Http http = new Http();
    private static MiddlewareActionResponse sendDataRequest(String path) {
        HttpRequest request = getMiddlewareRequest('GET', path);
        
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
        HttpRequest request = getMiddlewareRequest('POST', path);

        request.setBody(JSON.serialize(body));
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
            MiddlewareActionResponse middlewareResponse = (MiddlewareActionResponse)JSON.deserialize(response.getBody(), MiddlewareActionResponse.class);
            middlewareResponse.httpStatus = response.getStatusCode();
            return middlewareResponse;
        }

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

    global with sharing class MiddlewareSearchRequest {
        @InvocableVariable(Required = true Label = 'Search Term')
        global String searchTerm;
    }

    // CPS
    global static MiddlewareActionResponse getCpsTerm(MiddlewareSearchRequest request) {
        return sendDataRequest('/action/cps/term'+CombinedFunctions.parameterizeRequestParams(new Map<String, String>{'searchTerm' => request.searchTerm}));
    }
    global static MiddlewareActionResponse getCpsCourse(MiddlewareSearchRequest request) {
        return sendDataRequest('/action/cps/course'+CombinedFunctions.parameterizeRequestParams(new Map<String, String>{'searchTerm' => request.searchTerm}));
    }
    global static MiddlewareActionResponse getCpsSection(MiddlewareSearchRequest request) {
        return sendDataRequest('/action/cps/section'+CombinedFunctions.parameterizeRequestParams(new Map<String, String>{'searchTerm' => request.searchTerm}));
    }

}