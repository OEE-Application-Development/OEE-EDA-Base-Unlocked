global class ScheduleUtils {

    /**
     * Get the scheduled tasks for the job.
     */
    public static List<hed__Trigger_Handler__c> getScheduledTasks(CronSchedulable job) {
        return [SELECT Id, Name, hed__Object__c, hed__Active__c, hed__Asynchronous__c, hed__Class__c, hed__Load_Order__c, hed__Trigger_Action__c, hed__User_Managed__c FROM hed__Trigger_Handler__c WHERE hed__Object__c = :job.getJobName() ORDER BY hed__Load_Order__c];
    }

    /**
     * Looks for the handler that describes the schedule job itself. Check active & remove from the list since it doesn't need to run itself.
     */
    public static Boolean isJobActive(CronSchedulable job, List<hed__Trigger_Handler__c> classes) {
        Integer idx = 0;
        for(hed__Trigger_Handler__c handler : classes) {
            if(handler.hed__Class__c == ('csuoee.'+job.getJobName())) {
                classes.remove(idx);
                return handler.hed__Active__c;
            }
            idx++;
        }

        return false;
    }

    public static void runTasks(CronSchedulable job) {
        List<hed__Trigger_Handler__c> classes = getScheduledTasks(job);
        if(!isJobActive(job, classes)) return;
        
        for(hed__Trigger_Handler__c task : tasks) {
            if(task.hed__Active__c) runTask(task);
        }
    }

    private static void runTask(hed__Trigger_Handler__c task) {
        List<String> className = task.hed__Class__c.split('[.]');
        if(className.get(0)!='csuoee')return;

        try {
            ((OEETask)Type.forName('csuoee', className.get(1)).newInstance()).runTask();
        } catch(Exception e) {
            // Just skip & move on
        }
    }

    /** Global Utils **/
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

    global static void registerTaskHandler(CronSchedulable schedulable, OEETask task, Integer loadOrder) {
        // Campaign Check
        hed__Trigger_Handler__c taskRef;
        String nsTaskName = 'csuoee.'+task.className();
        try {
            taskRef = [SELECT Id, Name, hed__Object__c, hed__Active__c, hed__Asynchronous__c, hed__Class__c, hed__Load_Order__c, hed__Trigger_Action__c, hed__User_Managed__c FROM hed__Trigger_Handler__c WHERE hed__Object__c = :schedulable.getJobName() AND hed__Class__c = :nsTaskName LIMIT 1];
        } catch(QueryException qe) {
            taskRef =  null;
        }
        if(taskRef == null) {
            // First time setup
            taskRef = new hed__Trigger_Handler__c(Name = task.className()+' Task', hed__Object__c = schedulable.getJobName(), hed__Active__c = true, hed__Asynchronous__c = true, hed__Class__c = nsTaskName, hed__Load_Order__c = loadOrder, hed__Trigger_Action__c = 'Run', hed__User_Managed__c = true);
            insert taskRef;
        } else {
            taskRef.hed__Active__c = true;
            taskRef.hed__Load_Order__c = loadOrder;

            update taskRef;
        }
    }

    global static void unregisterTaskHandler(CronSchedulable schedulable, OEETask task) {
        // Campaign Check
        hed__Trigger_Handler__c taskRef;
        String nsTaskName = 'csuoee.'+task.className();
        try {
            taskRef = [SELECT Id, Name, hed__Object__c, hed__Active__c, hed__Asynchronous__c, hed__Class__c, hed__Load_Order__c, hed__Trigger_Action__c, hed__User_Managed__c FROM hed__Trigger_Handler__c WHERE hed__Object__c = :schedulable.getJobName() AND hed__Class__c = :nsTaskName LIMIT 1];
            taskRef.hed__Active__c = false;
            update taskRef;
        } catch(QueryException qe) {
            taskRef =  null;
        }
    }
    
}