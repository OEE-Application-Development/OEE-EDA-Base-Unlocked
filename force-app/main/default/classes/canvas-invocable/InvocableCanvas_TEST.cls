@IsTest
private class InvocableCanvas_TEST {

    @TestSetup
    static void enrollmentData() {
        RecordType rt = [select Id from RecordType WHERE DeveloperName = 'LMS' LIMIT 1];
        Account acct = new Account(RecordTypeId = rt.Id, Name = 'Canvas');
        insert acct;

        Contact testContact = new Contact(LastName = 'User');
        insert testContact;

        lms_hed__LMS_Account__c userAcct = new lms_hed__LMS_Account__c(lms_hed__LMS__c = acct.Id, lms_hed__Account_Owner__c = testContact.Id, Name = 'Test User', lms_hed__Primary_Login__c = 'testuser', lms_hed__LMS_External_ID__c = '217915');
        insert userAcct;

        hed__Course__c course = new hed__Course__c(Name = 'Test Course', hed__Account__c = acct.Id, Course_Code__c = 'TestCourse');
        insert course;

        hed__Term__c term = new hed__Term__c(Name = 'Summer', hed__Account__c = acct.Id);
        insert term;

        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'Test Offering', hed__Course__c = course.Id, hed__Term__c = term.Id, lms_hed__LMS_Offering_ID__c = '187330');
        insert offering;

        lms_hed__LMS_Course_Term__c courseTerm = new lms_hed__LMS_Course_Term__c(lms_hed__LMS__c = acct.Id, Name = 'Test Course', lms_hed__Course__c = course.Id, lms_hed__Term__c = term.Id, lms_hed__LMS_Course_ID__c = '174363');
        insert courseTerm;
    }

    @IsTest
    private static void importCanvasEnrollment() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CanvasEnrollmentMock());
        List<lms_hed__LMS_Course_Enrollment__c> imported = ImportCanvasEnrollment.importCanvasEnrollment(new List<String>{'4643082'});
        Test.stopTest();
        System.assert(imported.get(0) != null);
    }

    class CanvasEnrollmentMock implements HttpCalloutMock {
        CanvasEnrollmentMock() {}

        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"id": 4643082,"user_id": 217915,"course_id": 174363,"type": "StudentEnrollment","created_at": "2023-10-23T16:24:12Z","updated_at": "2023-10-23T16:24:12Z","associated_user_id": null,"start_at": null,"end_at": null,"course_section_id": 187330,"root_account_id": 1,"limit_privileges_to_course_section": false,"enrollment_state": "active","role": "StudentEnrollment","role_id": 9,"last_activity_at": null,"last_attended_at": null,"total_activity_time": 0,"sis_import_id": null,"grades": {"html_url": "https://colostate.instructure.com/courses/174363/grades/217915","current_grade": null,"current_score": null,"final_grade": null,"final_score": null,"unposted_current_score": null,"unposted_current_grade": null,"unposted_final_score": null,"unposted_final_grade": null},"sis_account_id": "Noncredit Courses","sis_course_id": "2023FA-NCT-AGBB-2099","course_integration_id": null,"sis_section_id": "2023FA-NCT-AGBB-2099-200","section_integration_id": null,"sis_user_id": "Student1530588","html_url": "https://colostate.instructure.com/courses/174363/users/217915"}');
            return res;
          }
    }

    @IsTest
    private static void lookupLogins() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CanvasLoginsMock());
        lms_hed__LMS_Account__c result = GetCanvasLogins.lookupLogins(new lms_hed__LMS_Account__c(lms_hed__LMS_External_ID__c = '229424'));

        System.assertEquals(result.lms_hed__Primary_Login__c, 'winterrk');

        Test.stopTest();
    }

    class CanvasLoginsMock implements HttpCalloutMock {
        CanvasLoginsMock() {}

        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('[{"id":229445,"user_id":229424,"account_id":1,"workflow_state":"active","unique_id":"winterrk","created_at":"2020-07-16T19:57:41Z","sis_user_id":"Student1462027","integration_id":null,"authentication_provider_id":null,"declared_user_type":null},{"id":229445,"user_id":229424,"account_id":1,"workflow_state":"active","unique_id":"5WINTERRK","created_at":"2020-07-16T19:57:41Z","sis_user_id":"Student1462027","integration_id":null,"authentication_provider_id":null,"declared_user_type":null}]');
            return res;
          }
    }

    @IsTest
    private static void lookupLoginsReverse() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CanvasLoginsReverseMock());
        lms_hed__LMS_Account__c result = GetCanvasLogins.lookupLogins(new lms_hed__LMS_Account__c(lms_hed__LMS_External_ID__c = '229424'));

        System.assertEquals(result.lms_hed__Primary_Login__c, 'winterrk');

        Test.stopTest();
    }

    class CanvasLoginsReverseMock implements HttpCalloutMock {
        CanvasLoginsReverseMock() {}

        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('[{"id":229445,"user_id":229424,"account_id":1,"workflow_state":"active","unique_id":"5WINTERRK","created_at":"2020-07-16T19:57:41Z","sis_user_id":"Student1462027","integration_id":null,"authentication_provider_id":null,"declared_user_type":null},{"id":229445,"user_id":229424,"account_id":1,"workflow_state":"active","unique_id":"winterrk","created_at":"2020-07-16T19:57:41Z","sis_user_id":"Student1462027","integration_id":null,"authentication_provider_id":null,"declared_user_type":null}]');
            return res;
          }
    }
    
}