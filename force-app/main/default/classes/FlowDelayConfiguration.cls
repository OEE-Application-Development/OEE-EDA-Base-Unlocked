global with sharing class FlowDelayConfiguration {
    
    @AuraEnabled
    public String delayIncrement;
    @AuraEnabled
    public Integer delayAmount;
    private FlowDelayConfiguration(String delayIncrement, Integer delayAmount) {
        this.delayAmount = delayAmount;
        this.delayIncrement = delayIncrement;
    }

    global static FlowDelayConfiguration DayDelay(Integer delayAmount) {
        return new FlowDelayConfiguration('Days', delayAmount);
    }

    global static FlowDelayConfiguration HourDelay(Integer delayAmount) {
        return new FlowDelayConfiguration('Hours', delayAmount);
    }

    global String getDelayIncrement() {
        return delayIncrement;
    }

    global Integer getDelayAmount() {
        return delayAmount;
    }

}