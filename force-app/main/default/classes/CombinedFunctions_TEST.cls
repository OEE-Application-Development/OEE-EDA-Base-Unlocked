@IsTest
private class CombinedFunctions_TEST {

    @IsTest
    private static void midpointTriggers() {
        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid', CSU_ID__c = '123456789', Email = 'Email@123.com', hed__AlternateEmail__c = 'AltEmail@123.com');
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
        
        Contact contact1 = new Contact(LastName = 'Test', EID__c = 'test-eid3', CSU_ID__c = '111111111', Email = 'Email1@123.com', hed__AlternateEmail__c = 'AltEmail1@123.com');
        insert contact1;
        Contact contact2 = new Contact(LastName = 'Test', EID__c = 'test-eid4', CSU_ID__c = '222222222', Email = 'Email2@123.com', hed__AlternateEmail__c = 'AltEmail2@123.com');
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

        CourseOfferingAggregates.updateOfferingAggregates(new List<Id>());
        hed__Course_Enrollment__c e = new hed__Course_Enrollment__c(hed__Course_Offering__c = offering.Id, hed__Contact__c = contact.Id);
        insert e;
        CourseOfferingAggregates.updateOfferingAggregates(new List<Id>{offering.Id});
        e = new hed__Course_Enrollment__c(hed__Course_Offering__c = offering.Id, hed__Contact__c = contact.Id, RecordTypeId = ([SELECT Id FROM RecordType WHERE SObjectType = 'hed__Course_Enrollment__c' AND DeveloperName = 'Student' LIMIT 1]).Id);
        insert e;
        CourseOfferingAggregates.updateOfferingAggregates(new List<Id>{offering.Id});

        Test.stopTest();
    }

    @IsTest
    private static void associateFile() {
        Account dept = new Account(Name = 'Test Dept');
        insert dept;
        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid');
        insert contact;
        csuoee__Instructor__c inst = new csuoee__Instructor__c(Name = 'Test', csuoee__Primary_Contact__c = contact.Id);
        insert inst;

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf('This is text.');
        cv.Title = 'test.txt';
        cv.PathOnClient = 'test.txt';
        insert cv;

        Test.startTest();

        System.assert(CombinedFunctions.associateFile(inst.Id, [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId, 'csuoee__Instructor__c', 'csuoee__Instructor_Headshot__c', 'csuoee__Headshot_Public_Link__c'), 'Failed to associate file.');
        System.assert(!CombinedFunctions.associateFile(inst.Id, [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId, 'csuoee__Instructor__c', 'NOT_A_FIELD', 'csuoee__Headshot_Public_Link__c'), 'Sent a bad field but it succeeded?');

        System.assert(CombinedFunctions.getImage([SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId).get('InternalUrl') != null, 'Could not find Internal Url for image.');

        System.assert([SELECT Id, csuoee__Headshot_Public_Link__c FROM csuoee__Instructor__c LIMIT 1].csuoee__Headshot_Public_Link__c != null, 'Public link not generated.');

        System.assert(CombinedFunctions.getContentIdForCMSKey('key') == null, 'Huh?');

        try{System.assert(CombinedFunctions.getWorkspaceByName('key') == null, 'Huh?');}catch(QueryException qe){System.assert(qe.getMessage().contains('SObject'));}
        try{System.assert(CombinedFunctions.getPublicChannelByName('key') == null, 'Huh?');}catch(QueryException qe){System.assert(qe.getMessage().contains('SObject'));}

        // Any function against ConnectApi will fail.
        try {CombinedFunctions.setWorkspaceFile(inst.Id, 'csuoee__Instructor__c', 'csuoee__Instructor_Headshot__c', 'csuoee__Headshot_Public_Link__c', 'channel', 'key');} catch(Exception e){}
        try {CombinedFunctions.evalCMSContent('channel', 'key');} catch(Exception e){}
        try {CombinedFunctions.clearWorkspaceFile(inst.Id, 'csuoee__Instructor__c', 'csuoee__Instructor_Headshot__c', 'csuoee__Headshot_Public_Link__c');} catch(Exception e){}

        Test.stopTest();
    }

    @IsTest
    private static void accountDeadlineTest() {
        Account dept = new Account(Name = 'Test Dept');
        insert dept;

        csuoee__Deadline__c deadline = new csuoee__Deadline__c(csuoee__Account__c = dept.Id, Name = 'test', csuoee__Category__c = 'Test Category');
        try {
            insert deadline;
            System.assert(false, 'Insert of empty deadline succeeded.');
        } catch(DmlException de) {
            System.assert(true);
        }

        deadline.csuoee__Yearly_Date__c = '5/1';
        insert deadline;
    }

    @IsTest
    private static void contactMatcherTest() {
        Test.startTest();
        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid', CSU_ID__c = '123456789', Email = 'Email@123.com', hed__AlternateEmail__c = 'AltEmail@123.com');
        insert contact;
        
        Contact contact1 = new Contact(LastName = 'Test', EID__c = 'test-eid3', CSU_ID__c = '111111111', Email = 'Email1@123.com', hed__AlternateEmail__c = 'AltEmail1@123.com');
        insert contact1;
        Contact contact2 = new Contact(LastName = 'Test', EID__c = 'test-eid4', CSU_ID__c = '222222222', Email = 'Email2@123.com', hed__AlternateEmail__c = 'AltEmail2@123.com', hed__UniversityEmail__c = 'student@colostate.edu', hed__Preferred_Email__c = 'University Email');
        insert contact2;

        ContactEmailMatcher matcher = new ContactEmailMatcher(new Map<String, List<String>>{ 'a2WQm0000012liDMAQ' => new List<String>{ 'AltEmail@123.com' }});
        Map<String, SObject> results = matcher.match();

        System.assertEquals(1, results.size(), 'Incorrect result size.');

        List<String> emails = new List<String>{'AltEmail@123.com'};

        matcher = new ContactEmailMatcher(new Map<String, List<String>>{ 'a2WQm0000012liDMAQ' => new List<String>{ 'AltEmail@123.com' }}, new List<String>{ 'hed__AlternateEmail__c' });
        matcher.match();

        matcher = new ContactEmailMatcher(new Map<String, List<String>> { 'a2WQm0000012liDMAQ' => new List<String>{ 'altemail2@123.com' }}, new List<String>{'hed__AlternateEmail__c', 'hed__UniversityEmail__c'}, new List<String>{'Name'});
        results = matcher.match();

        System.assertEquals(1, results.size(), 'Incorrect result size on university email.');

        Test.stopTest();
    }

    @IsTest
    private static void leadMatcherTest() {
        Test.startTest();
        Lead lead = new Lead(LastName = 'Test', Email = 'Email@123.com', Company = 'Test Company');
        insert lead;
        
        Lead lead1 = new Lead(LastName = 'Test', Email = 'Email1@123.com', Company = 'Test Company');
        insert lead1;
        Lead lead2 = new Lead(LastName = 'Test', Email = 'Email2@123.com', Phone = '+123456789', Company = 'Test Company');
        insert lead2;

        LeadEmailMatcher matcher = new LeadEmailMatcher(new Map<String, List<String>>{ 'a2WQm0000012liDMAQ' => new List<String>{ 'Email@123.com' }});
        Map<String, SObject> results = matcher.match();

        System.assertEquals(1, results.size(), 'Incorrect result size.');

        List<String> emails = new List<String>{'AltEmail@123.com'};

        try {
            matcher = new LeadEmailMatcher(new Map<String, List<String>>{ 'a2WQm0000012liDMAQ' => new List<String>{ 'AltEmail@123.com' }}, new List<String>{ 'hed__AlternateEmail__c' });
            matcher.match();
        } catch(QueryException qe) {
            // No extra emails on Lead right now
        }

        matcher = new LeadEmailMatcher(new Map<String, List<String>> { 'a2WQm0000012liDMAQ' => new List<String>{ '+123456789' }}, new List<String>{'Phone'}, new List<String>{'Name'});
        results = matcher.match();

        System.assertEquals(1, results.size(), 'Incorrect result size on phone.');

        Test.stopTest();
    }

    @IsTest
    private static void attemptConvertByEmail() {
        Lead lead = new Lead(LastName = 'Test', Email = 'Email@123.com', Company = 'Test Company');
        insert lead;
        
        Lead lead1 = new Lead(LastName = 'Test', Email = 'Email1@123.com', Company = 'Test Company');
        insert lead1;
        Lead lead2 = new Lead(LastName = 'Test', Email = 'Email2@123.com', Phone = '+123456789', Company = 'Test Company');
        insert lead2;

        Contact contact = new Contact(LastName = 'Test', EID__c = 'test-eid', CSU_ID__c = '123456789', Email = 'Email@123.com', hed__AlternateEmail__c = 'AltEmail@123.com');
        insert contact;

        Contact contact2 = new Contact(LastName = 'Test2', EID__c = 'test-eid2', CSU_ID__c = '223456789', Email = 'Email2@123.com', hed__AlternateEmail__c = 'Email2@123.com');
        insert contact2;
        
        Account fakePEacct = new Account(Name = 'Opus Account', hed__School_Code__c = 'learn.colostate.edu.123456');
        insert fakePEacct;

        Test.startTest();

        ConvertResult result = CombinedFunctions.attemptConvertByEmail(
            new List<Contact>{
                new Contact(LastName = 'Test', EID__c = 'test-eid', CSU_ID__c = '123456789', Email = 'AltEmail@123.com'),
                new Contact(LastName = 'Test1', EID__c = 'test-eid1', CSU_ID__c = '111111111', Email = 'Email@123.com'),
                new Contact(LastName = 'Test2', EID__c = 'test-eid2', CSU_ID__c = '222222222', Email = 'Email2@123.com', Account = new Account(hed__School_Code__c = 'learn.colostate.edu.123456'))
            },
            new List<String>{'hed__AlternateEmail__c', 'hed__UniversityEmail__c'}
        );
        System.assert(!result.success.isEmpty(), 'Failed to convert leads.');

        Test.stopTest();
    }

    @IsTest
    private static void testOEEKeyHelpers() {
        Test.startTest();

        try {
            new OEEKeyEncryptor('AES', 'csuoee__Azure_Key__c', '0123456789abcdef');
            System.assert(false);
        } catch(SecurityException se) {
            System.assert(true);
        }

        try {
            new OEEKeyEncryptor('AES256', 'csuoee__Azure_Key__c', '0123456789');
            System.assert(false);
        } catch(SecurityException se) {
            System.assert(true);
        }

        try {
            new OEEKeyEncryptor('AES256', 'csuoee__Azure_Key__c', '0123456789abcdef');
            System.assert(false);
        } catch(QueryException se) {
            System.assert(true);
        }

        boolean success = OEEKeyHelpers.setKey('csuoee__Azure_Key__c', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        System.assert(!success);

        success = OEEKeyHelpers.setKey('csuoee__Azure_Key__c', EncodingUtil.base64Encode(Crypto.generateAesKey(256)));
        System.assert(success);

        OEEKeyEncryptor encryptor = new OEEKeyEncryptor('AES256', 'csuoee__Azure_Key__c', '0123456789abcdef');
        Blob encrypted = encryptor.encrypt(Blob.valueOf('abcdefghijklmnopqrstuvwxyz'));

        System.assertEquals(encryptor.decrypt(encrypted).toString(), 'abcdefghijklmnopqrstuvwxyz');

        Test.stopTest();
    }

    @IsTest
    private static void testRequirementValidation() {
        hed__Program_Plan__c plan = new hed__Program_Plan__c(Name = 'Test Plan');
        insert plan;

        Test.startTest();
        hed__Plan_Requirement__c req1 = new hed__Plan_Requirement__c(Name = 'Req1', csuoee__Is_Template__c = true, RecordTypeId = hed__Plan_Requirement__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Requirement_Container').getRecordTypeId());
        try {
            insert req1;
            System.assert(false);
        } catch(DmlException de) {
            // Set that plan.
            req1.hed__Program_Plan__c = plan.Id;
            insert req1;
        }

        hed__Plan_Requirement__c req2 = new hed__Plan_Requirement__c(Name = 'Req2', csuoee__Instance_Of__c = req1.Id);
        try {
            insert req2;
            System.assert(false);
        } catch(DmlException de) {
            // Set correct Record Type.
            req2.RecordTypeId = hed__Plan_Requirement__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Template_Instance').getRecordTypeId();
            insert req2;
        }

        Test.stopTest();
    }

}