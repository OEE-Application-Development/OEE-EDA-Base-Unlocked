global with sharing class RegistrationValidation {

    @InvocableMethod(Label='Query Registrations' Description = 'Given a term, query for registrations in Opus.' Category = 'Opus')
    global static List<List<csuoee__Registration__c>> queryRegistrationsInvocable(List<QueryRegistrationsRequest> requests) {
        List<List<csuoee__Registration__c>> results = new List<List<csuoee__Registration__c>>();
        for(QueryRegistrationsRequest request : requests) {
            results.add(queryRegistrations(request.term, request.page, request.pageSize));
        }
        return results;
    }

    /**
     * /salesforce/action/registration/query
     */
    @AuraEnabled
    global static List<csuoee__Registration__c> queryRegistrations(hed__Term__c term, Integer page, Integer pageSize) {
        String path = '/salesforce/action/registration/query';
        if(term.RecordType.DeveloperName == 'Noncredit') {
            path = path + '?isCredit=false';
        } else {
            path = path + '?isCredit=true';
        }
        String termReference = term.lms_hed__LMS_Reference_Code__c.replace('-NCT', '');
        path = path + '&term='+termReference + '&page='+page.toString()+'&pageSize='+pageSize.toString();
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        try {
            return(List<csuoee__Registration__c>)JSON.deserialize(response.getBody(), List<SObject>.class);
        } catch(Exception e) {
            throw new AuraException('Unknown error from middleware. Please check logs.');
        }
    }
    
    /**
     * /salesforce/action/registration/{regId}/validate
     */
    @AuraEnabled
    global static csuoee__Registration__c validateRegistration(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+((Integer)reg.csuoee__Registration_Id__c)+'/validate';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        if(response.getStatusCode() == 404) return null;
        try {
            return(csuoee__Registration__c)JSON.deserialize(response.getBody(), SObject.class);
        } catch(Exception e) {
            throw new AuraException('Unknown error from middleware. Please check logs.');
        }
    }
    
    /**
     * /salesforce/action/registration/{regId}/validate
     */
    @AuraEnabled
    global static List<csuoee__Registration_Line_Item__c> validateLineItems(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+((Integer)reg.csuoee__Registration_Id__c)+'/lineItems';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        if(response.getStatusCode() == 404) return null;
        try {
            return(List<csuoee__Registration_Line_Item__c>)JSON.deserialize(response.getBody(), List<SObject>.class);
        } catch(Exception e) {
            throw new AuraException('Unknown error from middleware. Please check logs.');
        }
    }
    
    /**
     * /salesforce/action/registration/{regId}/enrollments
     */
    @AuraEnabled
    global static List<hed__Course_Enrollment__c> validateEnrollments(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+((Integer)reg.csuoee__Registration_Id__c)+'/enrollments';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        if(response.getStatusCode() == 404) return null;
        try {
            return(List<hed__Course_Enrollment__c>)JSON.deserialize(response.getBody(), List<SObject>.class);
        } catch(Exception e) {
            throw new AuraException('Unknown error from middleware. Please check logs.');
        }
    }

}