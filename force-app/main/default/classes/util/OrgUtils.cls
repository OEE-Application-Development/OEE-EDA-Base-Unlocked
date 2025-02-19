global without sharing class OrgUtils {

    private static String orgNs = null;
    global static String getOrgNs() {
        if(orgNs == null) {
            orgNs = ([SELECT NamespacePrefix FROM Organization].NamespacePrefix);
            if(orgNs != '') {
                orgNs = orgNs + '__';
            }
        }
        return orgNs;
    }

    global static void registerGlobalHandler(CronSchedulable schedulable) {
        hed__Trigger_Handler__c globalEnable;
        String nsName = 'csuoee.'+schedulable.getJobName(), jobName = 'OEE '+schedulable.getJobName()+' Job';
        try {
            globalEnable = [SELECT Id, Name, hed__Object__c, hed__Active__c, hed__Asynchronous__c, hed__Class__c, hed__Load_Order__c, hed__Trigger_Action__c, hed__User_Managed__c FROM hed__Trigger_Handler__c WHERE hed__Object__c = :schedulable.getJobName() AND hed__Class__c = :nsName LIMIT 1];
        } catch(QueryException qe) {
            globalEnable =  null;
        }
        if(globalEnable == null) {
            // First time setup
            globalEnable = new hed__Trigger_Handler__c(Name = jobName, hed__Object__c = schedulable.getJobName(), hed__Active__c = true, hed__Asynchronous__c = true, hed__Class__c = nsName, hed__Load_Order__c = 1, hed__Trigger_Action__c = 'Run', hed__User_Managed__c = true);
            insert globalEnable;

            // Kick it off!
            System.schedule(globalEnable.Name, schedulable.getSchedule(), schedulable);
        }
    }

    global static void registerTaskHandler(CronSchedulable schedulable) {

    }
    
}