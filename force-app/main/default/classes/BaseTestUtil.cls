@IsTest
global with sharing class BaseTestUtil {

    global static HttpCalloutMock getEventCalloutMock() {
        return new EventCalloutMock();
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