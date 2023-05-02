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

    @IsTest
    private static void getAccount() {
        RecordType deptType = [select Id from RecordType where DeveloperName = 'Administrative' LIMIT 1];
        List<AccountRequestor.AccountRequest> requests = new List<AccountRequestor.AccountRequest>{new AccountRequestor.AccountRequest(deptType.Id, 'CSUOEE')};
        
        List<Account> accts = AccountRequestor.getAccount(requests);

        System.assert(accts.get(0) == null);

        Account acct = new Account(Name = 'test', RecordTypeId = deptType.Id, hed__School_Code__c = 'CSUOEE');
        insert acct;

        accts = AccountRequestor.getAccount(requests);
        System.assert(accts.get(0) != null);
    }
    
}