@IsTest
private class CombinedFunctions_TEST {

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

    @IsTest
    public static void createEventsForSection() {
        Account dept = new Account(Name = 'Test Dept');
        insert dept;

        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid');
        insert contact;

        hed__Term__c term = new hed__Term__c(Name = '2023SP', hed__Account__c = dept.Id);
        insert term;

        hed__Course__c course = new hed__Course__c(hed__Account__c = dept.Id, Name = 'CO 333', hed__Course_ID__c = 'CO 333', Course_Code__c = 'CO 333');
        insert course;

        Date startDate = Date.newInstance(2023, 6, 20);
        Date endDate = Date.newInstance(2023, 6, 30);
        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'CO 333 100', hed__Course__c = course.Id, hed__Term__c = term.Id, hed__Section_ID__c = '100', lms_hed__LMS_Reference_Code__c = '2023SP-CO-333-100', hed__Start_Date__c = startDate, hed__End_Date__c = endDate);
        insert offering;

        Time startTime = Time.newInstance(8, 15, 0, 0);
        Time endTime = Time.newInstance(10, 45, 0, 0);
        hed__Course_Offering_Schedule__c schedule = new hed__Course_Offering_Schedule__c(hed__Course_Offering__c = offering.Id, hed__Monday__c = true, hed__Wednesday__c = true, hed__Friday__c = true, hed__Start_Time__c = startTime, hed__End_Time__c = endTime);
        insert schedule;

        Test.startTest();
        hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(hed__Contact__c = contact.Id, hed__Course_Offering__c = offering.Id);
        insert enrollment;
        CombinedFunctions.createEventsForSection(offering);
        CombinedFunctions.createEventsForSection(offering);
        CombinedFunctions.enlistEnrollmentInEvent(new List<hed__Course_Offering_Schedule__c>{schedule}, new List<Id>{contact.Id});
        Test.stopTest();
    }

    @IsTest
    public static void overloadEvent() {
        Account dept = new Account(Name = 'Test Dept');
        insert dept;

        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid');
        insert contact;

        hed__Term__c term = new hed__Term__c(Name = '2023SP', hed__Account__c = dept.Id);
        insert term;

        hed__Course__c course = new hed__Course__c(hed__Account__c = dept.Id, Name = 'CO 333', hed__Course_ID__c = 'CO 333', Course_Code__c = 'CO 333');
        insert course;

        Date startDate = Date.newInstance(2023, 6, 20);
        Date endDate = Date.newInstance(2023, 6, 30);
        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'CO 333 100', hed__Course__c = course.Id, hed__Term__c = term.Id, hed__Section_ID__c = '100', lms_hed__LMS_Reference_Code__c = '2023SP-CO-333-100', hed__Start_Date__c = startDate, hed__End_Date__c = endDate, hed__Faculty__c = contact.Id);
        insert offering;

        Time startTime = Time.newInstance(8, 15, 0, 0);
        Time endTime = Time.newInstance(10, 45, 0, 0);
        hed__Course_Offering_Schedule__c schedule = new hed__Course_Offering_Schedule__c(hed__Course_Offering__c = offering.Id, hed__Monday__c = true, hed__Wednesday__c = true, hed__Friday__c = true, hed__Start_Time__c = startTime, hed__End_Time__c = endTime);
        insert schedule;
        CombinedFunctions.createEventsForSection(offering);

        List<Contact> allTheStudents = new List<Contact>{
            new Contact(LastName = 'A1'),
            new Contact(LastName = 'A2'),
            new Contact(LastName = 'A3'),
            new Contact(LastName = 'A4'),
            new Contact(LastName = 'A5'),
            new Contact(LastName = 'A6'),
            new Contact(LastName = 'A7'),
            new Contact(LastName = 'A8'),
            new Contact(LastName = 'A9'),
            new Contact(LastName = 'A10'),
            new Contact(LastName = 'A11'),
            new Contact(LastName = 'A12'),
            new Contact(LastName = 'A13'),
            new Contact(LastName = 'A14'),
            new Contact(LastName = 'A15'),
            new Contact(LastName = 'A16'),
            new Contact(LastName = 'A17'),
            new Contact(LastName = 'A18'),
            new Contact(LastName = 'A19'),
            new Contact(LastName = 'A20'),
            new Contact(LastName = 'A21'),
            new Contact(LastName = 'A22'),
            new Contact(LastName = 'A23'),
            new Contact(LastName = 'A24'),
            new Contact(LastName = 'A25'),
            new Contact(LastName = 'A26'),
            new Contact(LastName = 'A27'),
            new Contact(LastName = 'A28'),
            new Contact(LastName = 'A29'),
            new Contact(LastName = 'A30'),
            new Contact(LastName = 'A31'),
            new Contact(LastName = 'A32'),
            new Contact(LastName = 'A33'),
            new Contact(LastName = 'A34'),
            new Contact(LastName = 'A35'),
            new Contact(LastName = 'A36'),
            new Contact(LastName = 'A37'),
            new Contact(LastName = 'A38'),
            new Contact(LastName = 'A39'),
            new Contact(LastName = 'A40'),
            new Contact(LastName = 'A41'),
            new Contact(LastName = 'A42'),
            new Contact(LastName = 'A43'),
            new Contact(LastName = 'A44'),
            new Contact(LastName = 'A45'),
            new Contact(LastName = 'A46'),
            new Contact(LastName = 'A47'),
            new Contact(LastName = 'A48'),
            new Contact(LastName = 'A49'),
            new Contact(LastName = 'A50')
        };

        insert allTheStudents;

        List<Id> allTheStudentIds = new List<Id>();
        for(Contact student : allTheStudents) {
            allTheStudentIds.add(student.Id);
        }
        Test.startTest();
        CombinedFunctions.enlistEnrollmentInEvent(new List<hed__Course_Offering_Schedule__c>{schedule}, allTheStudentIds);
        Test.stopTest();
    }

    @IsTest
    private static void refreshData() {
        List<Account> accts = new List<Account>{new Account(Name = 'A1'), new Account(Name = 'A2'), new Account(Name = 'A3')};
        insert accts;

        CombinedFunctions.refreshData(new List<String>(), 'Account', new List<String>{'Name'});

        accts = (List<Account>) CombinedFunctions.refreshData(CombinedFunctions.peelIds(accts), 'Account', new List<String>{'Id', 'Name'});
        System.assert(accts.size() == 3);

        Account child = new Account(Name = 'C1', ParentId = accts.get(0).Id);
        insert child;

        accts = (List<Account>) CombinedFunctions.refreshChildren(child.ParentId, 'Account', 'ParentId', new List<String>{'id', 'Name'});
        System.assert(accts.size() == 1);
    }

    @IsTest
    private static void simpleEmail() {
        Test.startTest();
        Email_Simple_Request__c r1 = new Email_Simple_Request__c(Name = 'test', Email_Body__c = 'kasdjflaskdjflkasdjflkadsfjlkasdj', Email_Recipient_List__c = '');
        try {
            insert r1;
            System.assert(false);
        } catch(Exception e) {
            System.assert(true);
        }

        r1.Email_Recipient_List__c = 'a.b@c.com';
        insert r1;

        System.assert(r1.Id != null);

        Test.stopTest();
    }

    @IsTest
    private static void createRegistrationBatch() {
        Account dept = new Account(Name = 'Test Dept');
        insert dept;

        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid');
        insert contact;

        hed__Term__c term = new hed__Term__c(Name = '2023SP', hed__Account__c = dept.Id);
        insert term;

        hed__Course__c course = new hed__Course__c(hed__Account__c = dept.Id, Name = 'CO 333', hed__Course_ID__c = 'CO 333', Course_Code__c = 'CO 333');
        insert course;

        Date startDate = Date.newInstance(2023, 6, 20);
        Date endDate = Date.newInstance(2023, 6, 30);
        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'CO 333 100', hed__Course__c = course.Id, hed__Term__c = term.Id, hed__Section_ID__c = '100', lms_hed__LMS_Reference_Code__c = '2023SP-CO-333-100', hed__Start_Date__c = startDate, hed__End_Date__c = endDate, hed__Faculty__c = contact.Id);
        insert offering;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        CombinedFunctions.createRegistrationBatch(new List<Id>{offering.Id}, new List<Id>{contact.Id}, null, 0);
        Test.stopTest();
    }
    
    @IsTest
    private static void getContactsByEmails() {
        Test.startTest();
        CombinedFunctions.getContactsByEmails(null);
        CombinedFunctions.getContactsByEmails('aksldfjlasd,sakdlfj');
        Test.stopTest();
    }

    @IsTest
    private static void getNextActiveOffering() {
        Account account = new Account(Name = 'Test College');
        insert account;

        hed__Course__c course = new hed__Course__c(Name = 'Test Course', hed__Account__c = account.Id, hed__Course_ID__c = 'Test Course', Course_Code__c = 'Test Course');
        insert course;

        RecordType creditTerm = [select Id from RecordType where SobjectType = 'hed__Term__c' and DeveloperName = 'Credit' LIMIT 1];
        hed__Term__c term = new hed__Term__c(Name = 'Test Term', RecordTypeId = creditTerm.Id, hed__Account__c = account.Id, Is_Visible__c = false);
        insert term;

        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'Test Course 100', hed__Course__c = course.Id, hed__Term__c = term.Id);
        insert offering;

        Test.startTest();
        hed__Course_Offering__c result = CombinedFunctions.getNextActiveOffering(course.Id);
        System.assert(result == null);

        term.Is_Visible__c = true;
        update term;

        result = CombinedFunctions.getNextActiveOffering(course.Id);
        System.assert(result != null);

        Test.stopTest();
    }

    @IsTest
    private static void updateOfferingAggregates() {
        Test.startTest();
        Account dept = new Account(Name = 'Test Dept');
        insert dept;

        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid');
        insert contact;

        hed__Term__c term = new hed__Term__c(Name = '2023SP', hed__Account__c = dept.Id);
        insert term;

        hed__Course__c course = new hed__Course__c(hed__Account__c = dept.Id, Name = 'CO 333', hed__Course_ID__c = 'CO 333', Course_Code__c = 'CO 333');
        insert course;

        Date startDate = Date.newInstance(2023, 6, 20);
        Date endDate = Date.newInstance(2023, 6, 30);
        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'CO 333 100', hed__Course__c = course.Id, hed__Term__c = term.Id, hed__Section_ID__c = '100', lms_hed__LMS_Reference_Code__c = '2023SP-CO-333-100', hed__Start_Date__c = startDate, hed__End_Date__c = endDate, hed__Faculty__c = contact.Id);
        insert offering;

        CombinedFunctions.updateOfferingAggregates(new List<Id>());
        hed__Course_Enrollment__c e = new hed__Course_Enrollment__c(hed__Course_Offering__c = offering.Id, hed__Contact__c = contact.Id);
        insert e;
        CombinedFunctions.updateOfferingAggregates(new List<Id>{offering.Id});
        e = new hed__Course_Enrollment__c(hed__Course_Offering__c = offering.Id, hed__Contact__c = contact.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SObjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student' LIMIT 1]).Id);
        insert e;
        CombinedFunctions.updateOfferingAggregates(new List<Id>{offering.Id});

        Test.stopTest();
    }

    @IsTest
    private static void associateFile() {
        Account dept = new Account(Name = 'Test Dept');
        insert dept;
        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid');
        insert contact;

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf('This is text.');
        cv.Title = 'test.txt';
        cv.PathOnClient = 'test.txt';
        insert cv;


        Test.startTest();

        System.assert(CombinedFunctions.associateFile(contact.Id, [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId, 'Contact', 'csuoee__Instructor_Headshot__c'), 'Failed to associate file.');
        System.assert(!CombinedFunctions.associateFile(contact.Id, [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId, 'Contact', 'NOT_A_FIELD'), 'Sent a bad field but it succeeded?');

        Test.stopTest();
    }

}