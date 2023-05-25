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

    @IsTest
    private static void midpointTriggers() {
        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid', CSU_ID__c = '123456789');
        insert contact;

        csumidp__HR_Directory_Entry__c entry = new csumidp__HR_Directory_Entry__c(Name = 'Test', csumidp__Midpoint_Id__c = '11111', csumidp__Net_Id__c = 'test-eid', csumidp__SIS_Person_Id__c = '123456789', csumidp__Last_Name__c = 'Test');
        insert entry;

        entry = [select Id, Primary_Contact__c from csumidp__HR_Directory_Entry__c where Id = :entry.Id LIMIT 1];
        System.assert(entry.Primary_Contact__c.equals(contact.Id));

        csumidp__HR_Directory_Entry__c dupe1 = new csumidp__HR_Directory_Entry__c(Name = 'Test', csumidp__Midpoint_Id__c = '22222', csumidp__Net_Id__c = 'test-eid2', csumidp__SIS_Person_Id__c = '987654321', csumidp__Last_Name__c = 'Test');
        insert dupe1;

        dupe1 = [select Id, Primary_Contact__c from csumidp__HR_Directory_Entry__c where Id = :dupe1.Id LIMIT 1];

        entry.csumidp__SIS_Person_Id__c = '987654321';
        dupe1.csumidp__SIS_Person_Id__c = '123456789';

        update new List<csumidp__HR_Directory_Entry__c>{entry, dupe1};
        
        Contact contact1 = new Contact(LastName = 'Test', EID__c = 'test-eid3', CSU_ID__c = '111111111');
        insert contact1;
        Contact contact2 = new Contact(LastName = 'Test', EID__c = 'test-eid4', CSU_ID__c = '222222222');
        insert contact2;

        csumidp__HR_Directory_Entry__c hr = new csumidp__HR_Directory_Entry__c(Name = 'Test', csumidp__Midpoint_Id__c = '33333', csumidp__Net_Id__c = 'test-eid3', csumidp__SIS_Person_Id__c = '111111111', csumidp__Last_Name__c = 'Test');
        insert hr;
        hr = [select Id, Primary_Contact__c, csumidp__SIS_Person_Id__c from csumidp__HR_Directory_Entry__c where Id = :hr.Id LIMIT 1];

        hr.csumidp__SIS_Person_Id__c = '222222222';
        update hr;

        hr = [select Id, Primary_Contact__c, csumidp__SIS_Person_Id__c from csumidp__HR_Directory_Entry__c where Id = :hr.Id LIMIT 1];
        hr.csumidp__SIS_Person_Id__c = '333333333';

        update hr;

        hr = [select Id, Primary_Contact__c, csumidp__SIS_Person_Id__c from csumidp__HR_Directory_Entry__c where Id = :hr.Id LIMIT 1];
        hr.csumidp__SIS_Person_Id__c = '123456789';

        try {
            update hr;
            System.assert(false);
        } catch (DmlException de) {
            // This should fail
            System.assert(true);
        }
    }
    
}