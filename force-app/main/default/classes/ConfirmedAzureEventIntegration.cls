global with sharing class ConfirmedAzureEventIntegration {
    @InvocableMethod(Label='Enroll Student in Section' Description='Sends confirmation request')
    global static List<AzureEventIntegration.AzureResponse> enrollStudent(List<ConfirmedRequest> requests) {
        List<AzureEventIntegration.AzureEvent> creditEvents = new List<AzureEventIntegration.AzureEvent>();
        List<AzureEventIntegration.AzureEvent> noncreditEvents = new List<AzureEventIntegration.AzureEvent>();
        for(ConfirmedRequest request : requests) {
            if(request.isCredit)
                creditEvents.add(ConfirmedEvent(request.userId, request.offeringReference));
            else
                noncreditEvents.add(ConfirmedEvent(request.userId, request.offeringReference));
        }

        List<AzureEventIntegration.AzureResponse> responses = new List<AzureEventIntegration.AzureResponse>();
        
        // Credit
        if(!creditEvents.isEmpty())
            responses.add(
                AzureEventIntegration.sendEvents(creditEvents, true)
            );
        
        // Noncredit
        if(!noncreditEvents.isEmpty())
            responses.add(
                AzureEventIntegration.sendEvents(noncreditEvents, true)
            );
        
        return responses;
    }

    private static AzureEventIntegration.AzureEvent ConfirmedEvent(String studentId, String sectionReference) {
        return new AzureEventIntegration.AzureEvent(
            'registration', 
            'Confirmed', 
            'csuoee/noncredit/registration', 
            new Map<String, Object>{'studentId' => studentId, 'sectionReference' => sectionReference}
        );
    }

    global class ConfirmedRequest extends AzureEventIntegration.AzureRequest {
        @InvocableVariable(Required=true Description='User Id (Noncredit ID) of the Contact.')
        global String userId;

        @InvocableVariable(Required=true Description='Reference of the offering.')
        global String offeringReference;

        @InvocableVariable(Required=true Description='Is this event credit or PE?')
        global Boolean isCredit;

        global ConfirmedRequest(String userId, String offeringReference, Boolean isCredit) {
            super(isCredit);
            this.isCredit = isCredit;
            this.userId = userId;
            this.offeringReference = offeringReference;
        }
    }
}