global with sharing class GetCanvasLogins {
    
    @InvocableMethod(Label='GetCanvasLogins' Description = 'Sets (but does not save) Primary/Alternate Login IDs' Category = 'Canvas Operation')
    global static List<lms_hed__LMS_Account__c> getCanvasLogins(List<lms_hed__LMS_Account__c> canvasAccounts) {
        for(lms_hed__LMS_Account__c canvasAccount : canvasAccounts) {
            lookupLogins(canvasAccount);
        }
        return canvasAccounts;
    }

    public static lms_hed__LMS_Account__c lookupLogins(lms_hed__LMS_Account__c canvasAccount) {
        if(canvasAccount.lms_hed__LMS_External_ID__c == null) return canvasAccount;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:can_hed__Canvas/api/v1/users/'+canvasAccount.lms_hed__LMS_External_ID__c+'/logins');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        String body;
        try {
            body = http.send(request).getBody();
        } catch (CalloutException ce) {
            throw new AuraHandledException('Canvas Credentials are missing or not configured correctly. Please refer to Canvas Home Page to see how to set it up. '+ce.getMessage());
        }

        List<CanvasLogin> logins = (List<CanvasLogin>)JSON.deserialize(body, List<CanvasLogin>.class);

        canvasAccount.lms_hed__Primary_Login__c = null;
        canvasAccount.lms_hed__Alternate_Login__c = null;
        // Student### = PE primary, Instructors might have 2x Credit primary
        for(CanvasLogin login : logins) {
            if(canvasAccount.lms_hed__Primary_Login__c == null) {
                canvasAccount.lms_hed__Primary_Login__c = login.unique_id;
            } else {
                if(login.unique_id.startsWith('5')) {
                    canvasAccount.lms_hed__Alternate_Login__c = login.unique_id;
                } else {
                    // Instructor - swap   
                    canvasAccount.lms_hed__Alternate_Login__c = canvasAccount.lms_hed__Primary_Login__c;
                    canvasAccount.lms_hed__Primary_Login__c = login.unique_id;
                }
            }
        }

        return canvasAccount;
    }

    public class CanvasLogin {

        public Long id;
        public Long user_id;
        public String workflow_state;
        public String unique_id;
        public String sis_user_id;

    }

}