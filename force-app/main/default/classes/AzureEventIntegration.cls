global with sharing class AzureEventIntegration {

    private static String parseCallout(Boolean isCredit) {
        return (isCredit)?'callout:Azure_Credit_Creds':'callout:Azure_PE_Creds';
    }
    
    private static Http http = new Http();
    global static AzureResponse sendEvents(List<AzureEvent> events, Boolean isCredit) {
        List<String> uuids = new List<String>();
        for(AzureEvent event : events) {
            uuids.add(event.id);
        }

        try {
            sendFutureEvents(JSON.serialize(events), isCredit);
        } catch(CalloutException ce) {
            return new AzureResponse(uuids, false);
        }
        
        return new AzureResponse(uuids, true);
    }

    @future(callout = true)
    global static void sendFutureEvents(String eventsBody, Boolean isCredit) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(parseCallout(isCredit));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        request.setBody(eventsBody);
        
        HttpResponse response = http.send(request);
    }

    private static boolean isSuccessResponse(Integer statusCode) {
        return (statusCode >= 200) && (statusCode < 300);
    }

    global class AzureEvent {
        String id = System.UUID.randomUUID().toString();
        String topic;
        String eventType;
        String subject;
        Datetime eventTime = Datetime.now();
        Map<String, Object> data;
        String dataVersion = '1.0';

        global AzureEvent(){}
        global AzureEvent(String topic, String eventType, String subject, Map<String, Object> data) {
            this.topic = topic;
            this.eventType = eventType;
            this.subject = subject;
            this.data = data;
        }
    }

    global class AzureResponse {
        @InvocableVariable(label='Event Id' description='Id of the created event' required=true)
        global List<String> uuids;
        @InvocableVariable(label='Event Send Success' description='True if event made it to Azure' required=true)
        global Boolean success;

        public AzureResponse(List<String> uuids, Boolean success) {
            this.uuids = uuids;
            this.success = success;
        }
    }

    global abstract class AzureRequest {
        @InvocableVariable(Required=true Description='Is this event credit or PE?')
        global Boolean isCredit;

        global AzureRequest(Boolean isCredit) {
            this.isCredit = isCredit;
        }
    }

}