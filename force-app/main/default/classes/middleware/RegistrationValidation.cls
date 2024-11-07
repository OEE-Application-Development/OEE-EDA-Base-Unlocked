global with sharing class RegistrationValidation {
    
    /**
     * /salesforce/action/registration/{regId}/validate
     */
    @AuraEnabled
    public static csuoee__Registration__c validateRegistration(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+((Integer)reg.csuoee__Registration_Id__c)+'/validate';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
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
    public static List<csuoee__Registration_Line_Item__c> validateLineItems(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+((Integer)reg.csuoee__Registration_Id__c)+'/lineItems';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
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
    public static List<hed__Course_Enrollment__c> validateEnrollments(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+((Integer)reg.csuoee__Registration_Id__c)+'/enrollments';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        try {
            return(List<hed__Course_Enrollment__c>)JSON.deserialize(response.getBody(), List<SObject>.class);
        } catch(Exception e) {
            throw new AuraException('Unknown error from middleware. Please check logs.');
        }
    }

}