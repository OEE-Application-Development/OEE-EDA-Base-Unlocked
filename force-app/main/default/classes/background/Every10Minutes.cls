global class Every10Minutes implements CronSchedulable {
    
    global String getJobName() {
        return 'Every10Minutes';
    }

    global static String DAY_SCHEDULE = '0 */10 * * * ?';
    global String getSchedule() {
        return DAY_SCHEDULE;
    }
    
    global void execute(SchedulableContext sc) {
        ScheduleUtils.runTasks(this);
    }

}