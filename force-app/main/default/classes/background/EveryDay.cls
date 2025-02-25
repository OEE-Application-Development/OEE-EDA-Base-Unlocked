global class EveryDay implements CronSchedulable {
    
    global String getJobName() {
        return 'EveryDay';
    }

    global static String DAY_SCHEDULE = '0 0 5 * * ?';
    global String getSchedule() {
        return DAY_SCHEDULE;
    }
    
    global void execute(SchedulableContext sc) {
        ScheduleUtils.runTasks(this);
    }

}