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
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getMiddlewareMock(new MiddlewareIntegration.MiddlewareActionResponse(true, 'Test Message', new Map<String, String>{'status' => 'RW'})));

        MiddlewareIntegration.getEnrollmentStatus(true, '2023SP-CO-333-100', 'test-person');
        Test.stopTest();

        System.assertEquals('RW', results.get(0).hed__Status__c, 'Status not set properly.');
    }
    
}