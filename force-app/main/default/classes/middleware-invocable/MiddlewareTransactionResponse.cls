global with sharing class MiddlewareTransactionResponse {

    @AuraEnabled
    @InvocableVariable(Required=true Label='Invoice Number' Description='Invoice this transaction appears on.')
    global String invoiceNumber;
    @AuraEnabled
    @InvocableVariable(Required=true Label='Payment Type' Description='e.g. Credit Card')
    global String paymentType;
    @AuraEnabled
    @InvocableVariable(Required=true Label='CSU Trans ID' Description='Transaction ID in Opus.')
    global String csuTransId;
    @AuraEnabled
    @InvocableVariable(Label='Processor Trans ID' Description='Authorize.Net trans ID.')
    global String processorTransId;
    @AuraEnabled
    @InvocableVariable(Label='Processor Trans Status' Description='Status of transaction in Authorize.Net.')
    global String processorTransStatus;
    @AuraEnabled
    @InvocableVariable(Required=true Label='Amount' Description='Amount of the payment.')
    global Decimal amount;

    @AuraEnabled
    @InvocableVariable(Required=true Label='Is Successful?' Description='Was the transaction successful?')
    global Boolean isSuccessful;
    @AuraEnabled
    @InvocableVariable(Required=true Label='Is Actual?' Description='True if payment, False if Sponsor transfer.')
    global Boolean isActual;
    @AuraEnabled
    @InvocableVariable(Label='Posted At' Description='Datetime at which the payment was applied.')
    global Datetime postedAt;

    @AuraEnabled
    @InvocableVariable(Label='Failure Reason' Description='If not successful, this should contain the reason why.')
    global String failureReason;
}