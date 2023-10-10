@IsTest
global class MiddlewareIntegration_TEST {

    @TestSetup
    static void generateCourseData() {
        Account testDepartment = new Account(Name = 'Test Deparment');
        insert testDepartment;

        RecordType creditType = [select Id from RecordType where DeveloperName = 'Credit' and SobjectType = 'hed__Course__c' LIMIT 1];
        hed__Course__c testCourse = new hed__Course__c(Name = 'CO 333', Course_Code__c = 'CO 333', hed__Account__c = testDepartment.Id, hed__Course_ID__c = 'CO 333', RecordTypeId = creditType.Id);
        insert testCourse;

        hed__Term__c testTerm = new hed__Term__c(Name = '2023SP', lms_hed__LMS_Reference_Code__c = '2023SP', hed__Account__c = testDepartment.Id);
        insert testTerm;

        hed__Course_Offering__c testOffering = new hed__Course_Offering__c(Name = 'CO 333 100', hed__Course__c = testCourse.Id, hed__Section_ID__c = '100', hed__Term__c = testTerm.Id, lms_hed__LMS_Reference_Code__c = '2023SP-CO-333-100');
        insert testOffering;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Person');
        insert testContact;
    }

    @IsTest
    private static void checkEnrollmentStatus() {
        Test.startTest();
        MiddlewareActionResponseData data = new MiddlewareActionResponseData();
        data.status = 'RW';
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getMiddlewareMock(new MiddlewareActionResponse(true, 'Test Message', data)));

        hed__Course_Offering__c offering = [select Id, Is_Credit__c from hed__Course_Offering__c LIMIT 1];
        Contact contact = [select Id, Front_Door_ID__c from Contact LIMIT 1];

        List<hed__Course_Enrollment__c> results = CheckEnrollmentStatusViaMiddleware.checkEnrollmentStatuses(
            new List<hed__Course_Enrollment__c>{
                new hed__Course_Enrollment__c(hed__Course_Offering__c = offering.Id, hed__Course_Offering__r = offering, hed__Contact__c = contact.Id, hed__Contact__r = contact)
            }
        );
        Test.stopTest();

        System.assertEquals('RW', results.get(0).hed__Status__c, 'Status not set properly.');
    }

    @IsTest
    private static void sendPostRequest() {
        Test.startTest();
        MiddlewareActionResponseData data = new MiddlewareActionResponseData();
        data.status = 'RW';
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getMiddlewareMock(new MiddlewareActionResponse(true, 'Test Message', data)));

        MiddlewareActionResponse resp = MiddlewareIntegration.sendPostRequest('/bananas', new Map<String, String>{'test' => 'test'});
        Test.stopTest();

        System.assert(resp != null);
    }

    // Invocables

    @IsTest
    private static void testInvocables() {
        Test.startTest();
        MiddlewareActionResponseData data = new MiddlewareActionResponseData();
        data.status = 'Confirmed';
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getMiddlewareMock(new MiddlewareActionResponse(true, 'Test Message', data)));

        MiddlewareIntegration.MiddlewareUserRequest userReq = new MiddlewareIntegration.MiddlewareUserRequest();
        userReq.isCredit = false;
        userReq.sectionReference = '2023SP-CO-333-100';
        userReq.userId = 'testuser';

        GetCanvasEnrollmentStatus.getCanvasEnrollmentStatus(new List<MiddlewareIntegration.MiddlewareUserRequest>{userReq});
        GetEnrollmentStatus.getEnrollmentStatus(new List<MiddlewareIntegration.MiddlewareUserRequest>{userReq});
        
        GetLoginIdFromOpus.getLoginIdFromOpus(new List<String>{'testuser'});
        
        MiddlewareIntegration.MiddlewareTxRequest txReq = new MiddlewareIntegration.MiddlewareTxRequest();
        txReq.csuTxId = '12345';
        txReq.processorTxId = '12345';
        ValidateTx.validateTx(new List<MiddlewareIntegration.MiddlewareTxRequest>{txReq});

        Test.stopTest();
    }

    @IsTest
    private static void testTxList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getTxMiddlewareMock(new MiddlewareActionTxResponse(true, 'Test Message', new List<MiddlewareTransactionResponse>{})));
        List<MiddlewareActionTxResponse> responses = GetTransactionsOnInvoice.getTransactionsOnInvoice(new List<String>{'12345'});

        System.assert(responses.get(0).data.isEmpty());
        Test.stopTest();
    }

    @IsTest
    private static void testCpsSearches() {
        Test.startTest();
        MiddlewareActionResponseData data = new MiddlewareActionResponseData();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getMiddlewareMock(new MiddlewareActionResponse(true, 'Test Message', data)));

        MiddlewareIntegration.MiddlewareSearchRequest req = new MiddlewareIntegration.MiddlewareSearchRequest();
        req.searchTerm = 'Test';

        GetCpsTerm.getCpsTerm(new List<MiddlewareIntegration.MiddlewareSearchRequest>{req});
        GetCpsCourse.getCpsCourse(new List<MiddlewareIntegration.MiddlewareSearchRequest>{req});
        GetCpsSection.getCpsSection(new List<MiddlewareIntegration.MiddlewareSearchRequest>{req});

        Test.stopTest();
    }
    
}