global with sharing class RegistrationValidation {
    
    /**
     * /salesforce/action/registration/{regId}/validate
     */
    @AuraEnabled
    public static csuoee__Registration__c validateRegistration(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+Integer.format(reg.csuoee__Registration_Id__c)+'/validate';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        try {
            return(csuoee__Registration__c)JSON.deserialize(response.getBody(), SObject.class);
         } catch(Exception e) {
             return null;
         }
    }
    
    /**
     * /salesforce/action/registration/{regId}/enrollments
     */
    @AuraEnabled
    public static hed__Course_Enrollment__c validateEnrollments(csuoee__Registration__c reg) {
        String path = '/salesforce/action/registration/'+Integer.format(reg.csuoee__Registration_Id__c)+'/enrollments';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        try {
            return(hed__Course_Enrollment__c)JSON.deserialize(response.getBody(), List<SObject>.class);
         } catch(Exception e) {
             return null;
         }
    }

}