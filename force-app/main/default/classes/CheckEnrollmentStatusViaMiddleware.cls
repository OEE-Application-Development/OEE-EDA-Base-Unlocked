global with sharing class CheckEnrollmentStatusViaMiddleware {
    @InvocableMethod(Label='Update Registration Status' Description='Get Registration Status from Middleware')
    global static List<hed__Course_Enrollment__c> checkEnrollmentStatuses(List<hed__Course_Enrollment__c> enrollments) {
        
        for(hed__Course_Enrollment__c enrollment : enrollments) {
            String responseStatus;
            try {
                MiddlewareIntegration.MiddlewareUserRequest req = new MiddlewareIntegration.MiddlewareUserRequest();
                req.isCredit = enrollment.hed__Course_Offering__r.Is_Credit__c;
                req.sectionReference = enrollment.Offering_Reference__c;
                req.userId = enrollment.hed__Contact__r.Front_Door_ID__c;
                responseStatus = MiddlewareIntegration.getEnrollmentStatus(req).data.status;
            } catch(SObjectException soe) {
                // Not enough fields were provided.
                if(enrollment.Id != null) {
                    hed__Course_Enrollment__c refresh = [select Id, hed__Course_Offering__r.Is_Credit__c, Offering_Reference__c, hed__Contact__r.Front_Door_ID__c from hed__Course_Enrollment__c where Id = :enrollment.Id LIMIT 1];
                    MiddlewareIntegration.MiddlewareUserRequest refReq = new MiddlewareIntegration.MiddlewareUserRequest();
                    refReq.isCredit = refresh.hed__Course_Offering__r.Is_Credit__c;
                    refReq.sectionReference = refresh.Offering_Reference__c;
                    refReq.userId = refresh.hed__Contact__r.Front_Door_ID__c;
                    responseStatus = MiddlewareIntegration.getEnrollmentStatus(refReq).data.status;
                }
            }
            if(responseStatus == null) continue;

            enrollment.hed__Status__c = responseStatus;
        }

        return enrollments;
    }
}