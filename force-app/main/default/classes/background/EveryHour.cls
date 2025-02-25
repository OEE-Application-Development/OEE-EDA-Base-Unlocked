global class EveryHour implements CronSchedulable {
    
    global String getJobName() {
        return 'EveryHour';
    }

    private static String HR_SCHEDULE = '10 0 * * * ?';
    global String getSchedule() {
        return HR_SCHEDULE;
    }

    global void execute(SchedulableContext sc) {
        ScheduleUtils.runTasks(this);
    }

}