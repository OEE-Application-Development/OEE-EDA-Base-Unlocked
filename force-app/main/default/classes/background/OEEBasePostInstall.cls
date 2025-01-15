global class OEEBasePostInstall implements InstallHandler {

    global void onInstall(InstallContext context) {
        // Hourly
        hed__Trigger_Handler__c globalHrEnable;
        try {
            globalHrEnable = [SELECT Id, Name, hed__Object__c, hed__Active__c, hed__Asynchronous__c, hed__Class__c, hed__Load_Order__c, hed__Trigger_Action__c, hed__User_Managed__c FROM hed__Trigger_Handler__c WHERE hed__Object__c = 'EveryHour' AND hed__Class__c = 'csuoee.EveryHour' LIMIT 1];
        } catch(QueryException qe) {
            globalHrEnable =  null;
        }
        if(globalHrEnable == null) {
            // First time setup
            globalHrEnable = new hed__Trigger_Handler__c(Name = 'OEE Every Hour Job', hed__Object__c = 'EveryHour', hed__Active__c = true, hed__Asynchronous__c = true, hed__Class__c = 'csuoee.EveryHour', hed__Load_Order__c = 1, hed__Trigger_Action__c = 'Run', hed__User_Managed__c = true);
            insert globalHrEnable;

            // Kick it off!
            System.schedule(globalHrEnable.Name, EveryHour.HR_SCHEDULE, new EveryHour());
        }

        // Daily
        hed__Trigger_Handler__c globalDayEnable;
        try {
            globalDayEnable = [SELECT Id, Name, hed__Object__c, hed__Active__c, hed__Asynchronous__c, hed__Class__c, hed__Load_Order__c, hed__Trigger_Action__c, hed__User_Managed__c FROM hed__Trigger_Handler__c WHERE hed__Object__c = 'EveryHour' AND hed__Class__c = 'csuoee.EveryHour' LIMIT 1];
        } catch(QueryException qe) {
            globalDayEnable =  null;
        }
        if(globalDayEnable == null) {
            // First time setup
            globalDayEnable = new hed__Trigger_Handler__c(Name = 'OEE Every Day Job', hed__Object__c = 'EveryDay', hed__Active__c = true, hed__Asynchronous__c = true, hed__Class__c = 'csuoee.EveryDay', hed__Load_Order__c = 1, hed__Trigger_Action__c = 'Run', hed__User_Managed__c = true);
            insert globalDayEnable;

            // Kick it off!
            System.schedule(globalDayEnable.Name, EveryDay.DAY_SCHEDULE, new EveryDay());
        }
    }
    
}