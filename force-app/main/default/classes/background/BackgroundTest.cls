@IsTest
private with sharing class BackgroundTest {

    @IsTest
    private static void emptyTest() {
        // Just shouldn't error
        Test.startTest();
        ScheduleUtils.registerGlobalHandler(new EveryHour());
        ScheduleUtils.registerGlobalHandler(new EveryDay());
        Test.stopTest();
    }

    @IsTest
    private static void installTest() {
        hed__Trigger_Handler__c fakeTask = new hed__Trigger_Handler__c(Name = 'Fake Task', hed__Object__c = 'EveryHour', hed__Active__c = true, hed__Asynchronous__c = true, hed__Class__c = 'csuoee.BackgroundTest', hed__Load_Order__c = 1, hed__Trigger_Action__c = 'Run', hed__User_Managed__c = true);
        insert fakeTask;

        OEEBasePostInstall postinstall = new OEEBasePostInstall();
        Test.testInstall(postinstall, null);

        hed__Trigger_Handler__c all = [SELECT Id FROM hed__Trigger_Handler__c WHERE hed__Object__c = 'EveryHour' AND hed__Class__c = 'csuoee.EveryHour' LIMIT 1];
        System.Assert(all != null);

        ScheduleUtils.registerTaskHandler(new EveryDay(), new CheckCSUIDDupes(), 1);
        ScheduleUtils.unregisterTaskHandler(new EveryDay(), new CheckCSUIDDupes());
    }

    @IsTest
    private static void checkCSUIDDupes() {
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%Standard%' LIMIT 1].Id,
            FirstName = 'Service',
            LastName = 'Account',
            Email = 'test12397589@testuser.com',
            Username = 'test12397589@testuser.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        Contact c1 = new Contact(FirstName = 'f1', LastName = 'l2', Email = 'f1l2@gmail.com', csuoee__CSU_ID__c = '1111111'), c2 = new Contact(OwnerId = u.Id, FirstName = 'f1', LastName = 'l2', Email = 'f1l2@colostate.edu', csuoee__CSU_ID__c = '1111111');
        List<Contact> contacts = new List<Contact>{c1, c2};
        insert contacts;
        Test.startTest();
        (new CheckCSUIDDupes()).runTask();
        Test.stopTest();
    }

}