@IsTest
global class AzureEventIntegration_TEST {

    @IsTest
    private static void sendEvents() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        AzureEventIntegration.AzureResponse response = AzureEventIntegration.sendEvents(new List<AzureEventIntegration.AzureEvent>{new AzureEventIntegration.AzureEvent('topic', 'eventType', 'subject', new Map<String, Object> {'test' => 'test'})}, false);
        Test.stopTest();

        System.assert(response.success);
    }
    
}