global class EveryHour30 implements CronSchedulable {
    
    global String getJobName() {
        return 'EveryHour30';
    }

    global static String DAY_SCHEDULE = '10 30 * * * ?';
    global String getSchedule() {
        return DAY_SCHEDULE;
    }
    
    global void execute(SchedulableContext sc) {
        ScheduleUtils.runTasks(this);
    }

}