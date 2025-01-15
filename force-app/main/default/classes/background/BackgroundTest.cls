@IsTest
private with sharing class BackgroundTest {

    @IsTest
    private static void emptyTest() {
        // Just shouldn't error
        Test.startTest();
        System.schedule('No Data Hourly Test', EveryHour.HR_SCHEDULE, new EveryHour());
        System.schedule('No Data Daily Test', EveryDay.DAY_SCHEDULE, new EveryDay());
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
    }

}