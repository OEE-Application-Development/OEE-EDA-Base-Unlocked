global with sharing class ConfirmedAzureEventIntegration {
    @InvocableMethod(Label='Enroll Student in Section' Description='Sends confirmation request')
    global static List<AzureEventIntegration.AzureResponse> enrollStudent(List<ConfirmedRequest> requests) {
        List<AzureEventIntegration.AzureResponse> responses = new List<AzureEventIntegration.AzureResponse>();
        for(ConfirmedRequest request : requests) {
            responses.add(AzureEventIntegration.sendEvent(ConfirmedEvent(request.userId, request.offeringReference), request.isCredit));
        }
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

        global ConfirmedRequest(String userId, String offeringReference, Boolean isCredit) {
            super(isCredit);
            this.userId = userId;
            this.offeringReference = offeringReference;
        }
    }
}