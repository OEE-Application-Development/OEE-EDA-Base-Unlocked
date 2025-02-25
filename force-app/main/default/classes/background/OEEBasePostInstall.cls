global class OEEBasePostInstall implements InstallHandler {

    global void onInstall(InstallContext context) {
        // Hourly
        ScheduleUtils.registerGlobalHandler(new EveryHour());

        // Every 30 Minutes after the hour - schedule on both hourly/30 min. for every 30 min. run
        ScheduleUtils.registerGlobalHandler(new EveryHour30());

        // Daily
        ScheduleUtils.registerGlobalHandler(new EveryDay());

        // CSU_ID Contact merger
        ScheduleUtils.registerTaskHandler(new EveryDay(), new CheckCSUIDDupes(), 1);
    }
    
}