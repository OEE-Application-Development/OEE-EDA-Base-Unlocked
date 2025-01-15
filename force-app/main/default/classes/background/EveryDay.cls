global class EveryDay implements Schedulable {
    
    global static String DAY_SCHEDULE = '0 0 5 * * ?';
    global void execute(SchedulableContext sc) {
        // Get applicable Apex classes...
        List<hed__Trigger_Handler__c> classes = [SELECT Id, Name, hed__Object__c, hed__Active__c, hed__Asynchronous__c, hed__Class__c, hed__Load_Order__c, hed__Trigger_Action__c, hed__User_Managed__c FROM hed__Trigger_Handler__c WHERE hed__Object__c = 'EveryDay' ORDER BY hed__Load_Order__c];

        if(!ScheduleUtils.isJobActive('csuoee.EveryDay', classes)) return;

        ScheduleUtils.runTasks(classes);
    }

}