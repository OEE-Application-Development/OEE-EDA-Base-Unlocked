@IsTest
global with sharing class BaseTestUtil {

    global static HttpCalloutMock getEventCalloutMock() {
        return new EventCalloutMock();
    }

    global static HttpCalloutMock getMiddlewareMock(MiddlewareActionResponse response) {
        return getBasicMiddlewareMock(JSON.serialize(response));
    }

    global static HttpCalloutMock getBasicMiddlewareMock(String body) {
        return new MiddlewareMock(body);
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

    global class MiddlewareMock implements HttpCalloutMock {

        private String body;
        global MiddlewareMock(String body) {
            this.body = body;
        }

        global HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody(body);
            return res;
          }
    }

    global void AssertRestResponse() {
        
    }
    
}