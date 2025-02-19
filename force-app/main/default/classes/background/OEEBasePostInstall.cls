global class OEEBasePostInstall implements InstallHandler {

    global void onInstall(InstallContext context) {
        // Hourly
        ScheduleUtils.registerGlobalHandler(new EveryHour());

        // Daily
        ScheduleUtils.registerGlobalHandler(new EveryDay());
    }
    
}