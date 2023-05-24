@IsTest
private class CombinedFunctions_TEST {

    @IsTest
    private static void handleEnrollments() {
        Account dept = new Account(Name = 'Test Dept');
        insert dept;

        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid');
        insert contact;

        hed__Term__c term = new hed__Term__c(Name = '2023SP', hed__Account__c = dept.Id);
        insert term;

        hed__Course__c course = new hed__Course__c(hed__Account__c = dept.Id, Name = 'CO 333', hed__Course_ID__c = 'CO 333', Course_Code__c = 'CO 333');
        insert course;

        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'CO 333 100', hed__Course__c = course.Id, hed__Term__c = term.Id, hed__Section_ID__c = '100', lms_hed__LMS_Reference_Code__c = '2023SP-CO-333-100');
        insert offering;

        Test.startTest();
        CombinedFunctions.EnrollmentRequest request = new CombinedFunctions.EnrollmentRequest();
        request = new CombinedFunctions.EnrollmentRequest('test-eid', '2023SP-CO-333-100', false);
        System.assert(request != null);

        hed__Course_Enrollment__c enrollment = CombinedFunctions.handleStudentEnrollment(contact, '2023SP-CO-333-100', false);
        System.assert(enrollment != null);
        CombinedFunctions.handleStudentEnrollment(contact, '2023SP-CO-333-100', true);

        enrollment = CombinedFunctions.handleInstructorEnrollment(contact, '2023SP-CO-333-100', false);
        System.assert(enrollment != null);
        CombinedFunctions.handleInstructorEnrollment(contact, '2023SP-CO-333-100', true);

        enrollment = CombinedFunctions.handleInstructorEnrollment(contact, '2023SP-CO-333-1', false);
        System.assert(enrollment == null);

        Test.stopTest();
    }
    
}