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
    
    /* Validation */
    @IsTest
    private static void queryRegistrations() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock('[{"attributes": {"type": "csuoee__Registration__c"}, "Id": "a05VA0000089pM6YAI", "Name": "Reg#1", "csuoee__Registration_Id__c": 1, "csuoee__Online_Account__r": {"attributes": {"type": "Account"}, "hed__School_Code__c": "TEST"}}]'));

        List<csuoee__Registration__c> results = RegistrationValidation.queryRegistrations(new hed__Term__c(lms_hed__LMS_Reference_Code__c = '2024SP-NCT', RecordType = new RecordType(DeveloperName = 'Noncredit')), 1, 10);
        System.assert(results.size() == 1);

        QueryRegistrationsRequest request = new QueryRegistrationsRequest();
        request.term = new hed__Term__c(lms_hed__LMS_Reference_Code__c = '2024SP', RecordType = new RecordType(DeveloperName = 'Credit'));
        request.page = 1;
        request.pageSize = 10;

        RegistrationValidation.queryRegistrationsInvocable(new List<QueryRegistrationsRequest>{request});

        Test.stopTest();
    }
    @IsTest
    private static void queryRegistrationsFail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock(''));

        try {
            List<csuoee__Registration__c> results = RegistrationValidation.queryRegistrations(new hed__Term__c(lms_hed__LMS_Reference_Code__c = '2024SP-NCT', RecordType = new RecordType(DeveloperName = 'Noncredit')), 1, 10);
            System.assert(false, 'This should have errored.');
        } catch(AuraException ae) {

        }

        Test.stopTest();
    }

    @IsTest
    private static void validateRegistration() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock('{"attributes": {"type": "csuoee__Registration__c"}, "Id": "a05VA0000089pM6YAI", "Name": "Reg#1", "csuoee__Registration_Id__c": 1, "csuoee__Online_Account__r": {"attributes": {"type": "Account"}, "hed__School_Code__c": "TEST"}}'));

        csuoee__Registration__c result = RegistrationValidation.validateRegistration(new csuoee__Registration__c(csuoee__Registration_Id__c = 1));
        System.assert(result.csuoee__Registration_Id__c == 1);

        Test.stopTest();
    }
    
    @IsTest
    private static void validateRegistrationFail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock(''));

        try {
            csuoee__Registration__c result = RegistrationValidation.validateRegistration(new csuoee__Registration__c(csuoee__Registration_Id__c = 1));
            System.assert(false, 'This should have errored.');
        } catch(AuraException ae) {

        }

        Test.stopTest();
    }
    
    @IsTest
    private static void validateLineItems() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock('[{"attributes": {"type": "csuoee__Registration_Line_Item__c"}, "csuoee__Course_Offering__c": "a05VA0000089pM6YAI", "csuoee__Registration__r": {"csuoee__Registration_Id__c": 1}}, {"attributes": {"type": "csuoee__Registration_Line_Item__c"}, "csuoee__Course_Offering__c": "a05VA0000089pM6YAI", "csuoee__Registration__r": {"csuoee__Registration_Id__c": 1}}]'));

        List<csuoee__Registration_Line_Item__c> results = RegistrationValidation.validateLineItems(new csuoee__Registration__c(csuoee__Registration_Id__c = 1));
        System.assert(results.size() == 2);

        Test.stopTest();
    }
    
    @IsTest
    private static void validateLineItemsFail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock(''));

        try {
            List<csuoee__Registration_Line_Item__c> results = RegistrationValidation.validateLineItems(new csuoee__Registration__c(csuoee__Registration_Id__c = 1));
            System.assert(false, 'This should have errored.');
        } catch(AuraException ae) {

        }

        Test.stopTest();
    }
    
    @IsTest
    private static void validateEnrollments() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock('[{"attributes": {"type": "hed__Course_Enrollment__c"}, "hed__Contact__c": "a05VA0000089pM6YAI", "hed__Course_Offering__c": "a05VA0000089pM6YAI"}, {"attributes": {"type": "hed__Course_Enrollment__c"}, "hed__Contact__c": "a05VA0000089pM6YAI", "hed__Course_Offering__c": "a05VA0000089pM6YAI"}]'));

        List<hed__Course_Enrollment__c> results = RegistrationValidation.validateEnrollments(new csuoee__Registration__c(csuoee__Registration_Id__c = 1));
        System.assert(results.size() == 2);

        Test.stopTest();
    }
    
    @IsTest
    private static void validateEnrollmentsFail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getBasicMiddlewareMock(''));

        try {
            List<hed__Course_Enrollment__c> results = RegistrationValidation.validateEnrollments(new csuoee__Registration__c(csuoee__Registration_Id__c = 1));
            System.assert(false, 'This should have errored.');
        } catch(AuraException ae) {

        }

        Test.stopTest();
    }

}