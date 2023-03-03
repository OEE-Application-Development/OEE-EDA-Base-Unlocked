@IsTest
global class AzureEventIntegration_TEST {

    @IsTest
    private static void ConfirmedAzureEventIntegration() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EventCalloutMock());
        List<AzureEventIntegration.AzureResponse> responses = ConfirmedAzureEventIntegration.enrollStudent(new List<ConfirmedAzureEventIntegration.ConfirmedRequest>{ new ConfirmedAzureEventIntegration.ConfirmedRequest('learn.colostate.edu', '2023SP-AGBB-205-100', false) });
        Test.stopTest();

        System.assert(responses.size() == 1);
    }

    global class EventCalloutMock implements HttpCalloutMock{
      global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('Event Created.');
        return res;
      }
    }
    
}