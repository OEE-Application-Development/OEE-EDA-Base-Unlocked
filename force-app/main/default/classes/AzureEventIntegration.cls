global with sharing class AzureEventIntegration {

    private static String parseCallout(Boolean isCredit) {
        return (isCredit)?'callout:Azure_PE_Creds':'callout:Azure_PE_Creds';
    }
    
    private static Http http = new Http();
    global static AzureResponse sendEvent(AzureEvent event, Boolean isCredit) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(parseCallout(isCredit));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        request.setBody(JSON.serialize(event));
        
        HttpResponse response = http.send(request);
        return new AzureResponse(event.id, isSuccessResponse(response.getStatusCode()));
    }

    private static boolean isSuccessResponse(Integer statusCode) {
        return (statusCode >= 200) && (statusCode < 300);
    }

    global class AzureEvent {
        String id = (new Uuid()).getValue();
        String topic;
        String eventType;
        String subject;
        Datetime eventTime = Datetime.now();
        Map<String, Object> data;
        String dataVersion = '1.0';

        public AzureEvent(){}
        public AzureEvent(String topic, String eventType, String subject, Map<String, Object> data) {
            this.topic = topic;
            this.eventType = eventType;
            this.subject = subject;
            this.data = data;
        }
    }

    global class AzureResponse {
        @InvocableVariable(label='Event Id' description='Id of the created event' required=true)
        global String uuid;
        @InvocableVariable(label='Event Send Success' description='True if event made it to Azure' required=true)
        global Boolean success;

        public AzureResponse(String uuid, Boolean success) {
            this.uuid = uuid;
            this.success = success;
        }
    }

    global abstract class AzureRequest {
        @InvocableVariable(Required=true Description='Is this event credit or PE?')
        global Boolean isCredit;

        public AzureRequest(Boolean isCredit) {
            this.isCredit = isCredit;
        }
    }

}