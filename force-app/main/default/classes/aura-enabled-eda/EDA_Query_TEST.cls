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
        
        hed__Term__c creditTerm = new hed__Term__c(Name = 'Credit Term', hed__Account__c = school.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Term__c' AND DeveloperName = 'Credit' LIMIT 1]).Id, hed__Start_Date__c = Date.today().addDays(-1), hed__End_Date__c = Date.today().addDays(1));
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

        hed__Course_Enrollment__c studentCreditEnrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = creditOffering.Id, hed__Contact__c = student.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student' LIMIT 1]).Id, hed__Credits_Earned__c = 2.0);
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

        Account testProgram = new Account(Name = 'Academic Credit Program');
        insert testProgram;

        hed__Program_Plan__c plan = new hed__Program_Plan__c(Name = 'Test Plan', hed__Account__c = testProgram.Id, hed__Is_Primary__c = true, hed__Total_Required_Credits__c = 6);
        insert plan;

        Map<String, Id> reqRecordTypeMap = new Map<String, Id>();
        for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'hed__Plan_Requirement__c']) {
            reqRecordTypeMap.put(rt.DeveloperName, rt.Id);
        }

        hed__Plan_Requirement__c courseContainer = new hed__Plan_Requirement__c(Name = 'Courses Required', RecordTypeId = reqRecordTypeMap.get('Requirement_Container'), hed__Program_Plan__c = plan.Id, hed__Sequence__c = 1, csuoee__Requires_All_Child_Reqs__c = true, hed__Credits__c = 4);
        insert courseContainer;

        hed__Plan_Requirement__c subjectContainer = new hed__Plan_Requirement__c(Name = 'Subjects Required', RecordTypeId = reqRecordTypeMap.get('Requirement_Container'), hed__Program_Plan__c = plan.Id, hed__Sequence__c = 2, csuoee__Requires_All_Child_Reqs__c = true, hed__Credits__c = 2);
        insert subjectContainer;

        hed__Plan_Requirement__c eitherOrContainer = new hed__Plan_Requirement__c(Name = '1 of 2 Course Req', RecordTypeId = reqRecordTypeMap.get('Requirement_Container'), hed__Plan_Requirement__c = courseContainer.Id, hed__Sequence__c = 1, csuoee__Requires_All_Child_Reqs__c = false, hed__Credits__c = 2);
        insert eitherOrContainer;

        hed__Course__c c1 = new hed__Course__c(Name = 'C1', hed__Account__c = school.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course__c' AND DeveloperName = 'Credit' LIMIT 1]).Id, Course_Code__c = 'CRED 101');
        insert c1;
        hed__Course__c c2 = new hed__Course__c(Name = 'C2', hed__Account__c = school.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course__c' AND DeveloperName = 'Credit' LIMIT 1]).Id, Course_Code__c = 'CRED 102');
        insert c2;

        List<hed__Plan_Requirement__c> courseReqs = new List<hed__Plan_Requirement__c> {
            new hed__Plan_Requirement__c(Name = 'Credit Course', RecordTypeId = reqRecordTypeMap.get('Course_Requirement'), hed__Course__c = creditCourse.Id, hed__Plan_Requirement__c = courseContainer.Id, hed__Sequence__c = 2, hed__Credits__c = 2.0),
            new hed__Plan_Requirement__c(Name = 'CC1', RecordTypeId = reqRecordTypeMap.get('Course_Requirement'), hed__Course__c = c1.Id, hed__Plan_Requirement__c = eitherOrContainer.Id, hed__Sequence__c = 1, hed__Credits__c = 2.0),
            new hed__Plan_Requirement__c(Name = 'CC2', RecordTypeId = reqRecordTypeMap.get('Course_Requirement'), hed__Course__c = c2.Id, hed__Plan_Requirement__c = eitherOrContainer.Id, hed__Sequence__c = 2, hed__Credits__c = 2.0),
            new hed__Plan_Requirement__c(Name = 'CRED2', csuoee__Subject__c = 'CRED2', RecordTypeId = reqRecordTypeMap.get('Subject_Requirement'), hed__Plan_Requirement__c = subjectContainer.Id, hed__Credits__c = 2.0)
        };
        insert courseReqs;
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

    @IsTest
    private static void shortcuts() {
        Test.startTest();
        QueryEnrollments.getStudentEnrollmentsInCurrentTerm([SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1]);
        QueryEnrollments.getPendingStudentEnrollmentsInCurrentTerm([SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1]);
        QueryEnrollments.getFacultyEnrollmentsInCurrentTerm([SELECT Id FROM Contact WHERE LastName = 'Instructor' LIMIT 1]);
        Test.stopTest();
    }

    @IsTest
    private static void getPlanCompletion() {
        Test.startTest();
        List<String> errors = QueryProgramCompletion.isValidCreditPlan([SELECT Id FROM hed__Program_Plan__c LIMIT 1].Id);
        System.assert(!errors.isEmpty(), errors.toString());
        hed__Course__c creditCourse2 = new hed__Course__c(Name = 'Credit Course', hed__Account__c = [SELECT Id FROM Account WHERE Name = 'School' LIMIT 1].Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course__c' AND DeveloperName = 'Credit' LIMIT 1]).Id, Course_Code__c = 'CRED2 100');
        insert creditCourse2;
        hed__Course_Offering__c creditOffering2 = new hed__Course_Offering__c(hed__Term__c = [SELECT Id FROM hed__Term__c WHERE Name = 'Credit Term' LIMIT 1].Id, hed__Course__c = creditCourse2.Id, Name = 'CRED2 100 10');
        insert creditOffering2;
        Id contactId = [SELECT Id FROM Contact WHERE LastName = 'Student' LIMIT 1].Id;
        hed__Course_Enrollment__c studentCreditEnrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = creditOffering2.Id, hed__Contact__c = contactId, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student' LIMIT 1]).Id, hed__Credits_Earned__c = 2.0);
        insert studentCreditEnrollment;

        PlanCompletionComparison comparison = QueryProgramCompletion.getPlanCompletion(contactId, [SELECT Id FROM hed__Program_Plan__c LIMIT 1].Id);
        System.assertEquals(4, comparison.Result.EarnedCredits, 'Expected Credits do not match: 4, '+String.valueOf(comparison.Result.EarnedCredits));

        hed__Course__c creditCourse = new hed__Course__c(Name = 'Credit Course 3', hed__Account__c = [SELECT Id FROM Account WHERE Name = 'School' LIMIT 1].Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course__c' AND DeveloperName = 'Credit' LIMIT 1]).Id, Course_Code__c = 'CRED 200');
        insert creditCourse;
        hed__Course_Offering__c creditOffering = new hed__Course_Offering__c(hed__Term__c = [SELECT Id FROM hed__Term__c WHERE Name = 'Credit Term' LIMIT 1].Id, hed__Course__c = creditCourse.Id, Name = 'CRED 200 10');
        insert creditOffering;
        hed__Plan_Requirement__c newReq = new hed__Plan_Requirement__c(Name = 'CC3', hed__Credits__c = 2.0, RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Course_Requirement' LIMIT 1].Id, hed__Course__c = creditCourse.Id, hed__Plan_Requirement__c = [SELECT Id FROM hed__Plan_Requirement__c WHERE Name = 'Courses Required' LIMIT 1].Id, hed__Sequence__c = 3);
        insert newReq;

        hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(hed__Course_Offering__c = creditOffering.Id, hed__Contact__c = contactId, RecordTypeId = ([SELECT Id FROM RecordType WHERE SobjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student' LIMIT 1]).Id);
        insert enrollment;

        comparison = QueryProgramCompletion.getPlanCompletion(contactId, [SELECT Id FROM hed__Program_Plan__c LIMIT 1].Id);
        System.assertEquals(4, comparison.Result.EarnedCredits, 'Expected Credits do not match: 4, '+String.valueOf(comparison.Result.EarnedCredits));

        errors = QueryProgramCompletion.isValidCreditPlan([SELECT Id FROM hed__Program_Plan__c LIMIT 1].Id);
        System.assert(!errors.isEmpty(), errors.toString());

        Test.stopTest();
    }
    
}