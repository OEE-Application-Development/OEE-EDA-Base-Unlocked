global interface CronSchedulable extends Schedulable {

    String getJobName();
    String getSchedule();
    
}