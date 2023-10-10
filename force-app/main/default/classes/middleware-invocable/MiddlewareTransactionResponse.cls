global with sharing class MiddlewareTransactionResponse {
    @InvocableVariable(Required=true Label='Invoice Number' Description='Invoice this transaction appears on.')
    global String invoiceNumber;
    
    @InvocableVariable(Required=true Label='Payment Type' Description='e.g. Credit Card')
    global String paymentType;
    
    @InvocableVariable(Required=true Label='CSU Trans ID' Description='Transaction ID in Opus.')
    global String csuTransId;
    
    @InvocableVariable(Label='Processor Trans ID' Description='Authorize.Net trans ID.')
    global String processorTransId;
    
    @InvocableVariable(Label='Processor Trans Status' Description='Status of transaction in Authorize.Net.')
    global String processorTransStatus;
    
    @InvocableVariable(Required=true Label='Amount' Description='Amount of the payment.')
    global Decimal amount;

    @InvocableVariable(Required=true Label='Is Successful?' Description='Was the transaction successful?')
    global Boolean isSuccessful;
    
    @InvocableVariable(Required=true Label='Is Actual?' Description='True if payment, False if Sponsor transfer.')
    global Boolean isActual;
    
    @InvocableVariable(Label='Posted At' Description='Datetime at which the payment was applied.')
    global Datetime postedAt;

    @InvocableVariable(Label='Failure Reason' Description='If not successful, this should contain the reason why.')
    global String failureReason;
}