global with sharing class GetTransactionsOnInvoice {
    @InvocableMethod(Label='GetTransactionsOnInvoice' Description = 'Ask Middleware to find all transactions for invoice.' Category = 'Middleware Operation')
    global static List<MiddlewareActionTxResponse> getTransactionsOnInvoice(List<String> invoiceIds) {
        List<MiddlewareActionTxResponse> results = new List<MiddlewareActionTxResponse>();
        for(String invoiceId : invoiceIds) {
            results.add(MiddlewareIntegration.getTransactionList(invoiceId));
        }
        return results;
    }
}