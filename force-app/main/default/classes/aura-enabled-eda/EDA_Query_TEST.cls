@IsTest
private class EDA_Query_TEST {

    @TestSetup
    static void setupEnrollmentData() {
        Account school = new Account(Name = 'School');
        insert school;

        Contact student = new Contact(LastName = 'Student');
        insert student;

        Contact instructor = new Contact(LastName = 'Instructor');
        insert instructor;
        
        hed__Term__c creditTerm = new hed__Term__c(Name = 'Credit Term', hed__Account__c = school.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Term__c' AND DeveloperName = 'Credit' LIMIT 1]).Id);
        insert creditTerm;

        hed__Term__c noncreditTerm = new hed__Term__c(Name = 'Noncredit Term', hed__Account__c = school.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Term__c' AND DeveloperName = 'Noncredit' LIMIT 1]).Id);
        insert noncreditTerm;

        hed__Course__c creditCourse = new hed__Course__c(Name = 'Credit Course', hed__Account__c = school.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course__c' AND DeveloperName = 'Credit' LIMIT 1]).Id, Course_Code__c = 'CRED 100');
        insert creditCourse;

        hed__Course__c noncreditCourse = new hed__Course__c(Name = 'Noncredit Course', hed__Account__c = school.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course__c' AND DeveloperName = 'Noncredit' LIMIT 1]).Id, Course_Code__c = 'NONCRED 100');
        insert noncreditCourse;

        hed__Course_Offering__c creditOffering = new hed__Course_Offering__c(hed__Term__c = creditTerm.Id, hed__Course__c = creditCourse.Id, Name = 'CRED 100 10');
        insert creditOffering;

        hed__Course_Offering__c noncreditOffering = new hed__Course_Offering__c(hed__Term__c = noncreditTerm.Id, hed__Course__c = noncreditCourse.Id, Name = 'CRED 100 10');
        insert noncreditOffering;

        hed__Course_Enrollment__c studentCreditEnrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = creditOffering.Id, hed__Contact__c = student.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student' LIMIT 1]).Id);
        insert studentCreditEnrollment;

        hed__Course_Enrollment__c studentPendingCreditEnrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = creditOffering.Id, hed__Contact__c = student.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student_Pending' LIMIT 1]).Id);
        insert studentPendingCreditEnrollment;

        hed__Course_Enrollment__c facultyCreditEnrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = creditOffering.Id, hed__Contact__c = instructor.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Faculty' LIMIT 1]).Id);
        insert facultyCreditEnrollment;

        creditOffering.hed__Faculty__c = instructor.Id;
        update creditOffering;

        hed__Course_Enrollment__c studentNonreditEnrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = noncreditOffering.Id, hed__Contact__c = student.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student' LIMIT 1]).Id);
        insert studentNonreditEnrollment;

        hed__Course_Enrollment__c facultyNoncreditEnrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = noncreditOffering.Id, hed__Contact__c = instructor.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Faculty' LIMIT 1]).Id);
        insert facultyNoncreditEnrollment;

        noncreditOffering.hed__Faculty__c = instructor.Id;
        update creditOffering;
    }

    @IsTest
    private static void getStudentCreditEnrollment() {
        Test.startTest();
        List<hed__Course_Enrollment__c> creditEnrollments = QueryEnrollments.getStudentEnrollments([SELECT Id FROM hed__Term__c WHERE Name = 'Credit Term' LIMIT 1], [SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1]);
        System.assert(creditEnrollments.size() == 1, 'Did not return single enrollment. Returned: ' + creditEnrollments.size());

        List<hed__Course_Enrollment__c> allEnrollments = QueryEnrollments.getStudentEnrollments(null, [SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1]);
        System.assert(allEnrollments.size() == 2, 'Did not return credit AND noncredit enrollment. Returned: ' + allEnrollments.size());

        Test.stopTest();
    }

    @IsTest
    private static void getStudentNoncreditEnrollment() {
        Test.startTest();
        List<hed__Course_Enrollment__c> creditEnrollments = QueryEnrollments.getStudentEnrollments([SELECT Id FROM hed__Term__c WHERE Name = 'Noncredit Term' LIMIT 1], [SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1]);
        System.assert(creditEnrollments.size() == 1, 'Did not return single enrollment. Returned: ' + creditEnrollments.size());

        Test.stopTest();
    }

    @IsTest
    private static void getStudentPendingEnrollment() {
        Test.startTest();
        List<hed__Course_Enrollment__c> creditEnrollments = QueryEnrollments.getPendingStudentEnrollments([SELECT Id FROM hed__Term__c WHERE Name = 'Credit Term' LIMIT 1], [SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1]);
        System.assert(creditEnrollments.size() == 1, 'Did not return single enrollment. Returned: ' + creditEnrollments.size());

        Test.stopTest();
    }

    @IsTest
    private static void getFacultyEnrollment() {
        Test.startTest();
        List<hed__Course_Enrollment__c> creditEnrollments = QueryEnrollments.getFacultyEnrollments([SELECT Id FROM hed__Term__c WHERE Name = 'Credit Term' LIMIT 1], [SELECT Id FROM Contact WHERE LastName = 'Instructor' LIMIT 1]);
        System.assert(creditEnrollments.size() == 1, 'Did not return single enrollment. Returned: ' + creditEnrollments.size());

        List<hed__Course_Enrollment__c> allEnrollments = QueryEnrollments.getFacultyEnrollments(null, [SELECT Id FROM Contact WHERE LastName = 'Instructor' LIMIT 1]);
        System.assert(allEnrollments.size() == 2, 'Did not return credit AND noncredit enrollment. Returned: ' + allEnrollments.size());

        Test.stopTest();
    }
    
}