public class ScheduleUtils {

    /**
     * Looks for the handler that describes the schedule job itself. Check active & remove from the list since it doesn't need to run itself.
     */
    public static Boolean isJobActive(String scheduleClassName, List<hed__Trigger_Handler__c> classes) {
        Integer idx = 0;
        for(hed__Trigger_Handler__c handler : classes) {
            if(handler.hed__Class__c == scheduleClassName) {
                classes.remove(idx);
                return handler.hed__Active__c;
            }
            idx++;
        }

        return false;
    }

    public static void runTasks(List<hed__Trigger_Handler__c> tasks) {
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
    
}