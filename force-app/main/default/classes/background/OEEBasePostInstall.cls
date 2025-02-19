global class OEEBasePostInstall implements InstallHandler {

    global void onInstall(InstallContext context) {
        // Hourly
        OrgUtils.registerGlobalHandler(new EveryHour());

        // Daily
        OrgUtils.registerGlobalHandler(new EveryDay());
    }
    
}