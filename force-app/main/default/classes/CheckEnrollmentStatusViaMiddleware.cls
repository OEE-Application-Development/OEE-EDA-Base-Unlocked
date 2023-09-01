global with sharing class CheckEnrollmentStatusViaMiddleware {
    @InvocableMethod(Label='Get Unique Account' Description='Get Account by Record Type & School Code')
    global static List<hed__Course_Enrollment__c> checkEnrollmentStatuses(List<hed__Course_Enrollment__c> enrollments) {
        
        for(hed__Course_Enrollment__c enrollment : enrollments) {
            String responseStatus = MiddlewareIntegration.getEnrollmentStatus(enrollment.hed__Course_Offering__r.Is_Credit__c, enrollment.Offering_Reference__c, enrollment.hed__Contact__r.Front_Door_ID__c);
            if(responseStatus == null) continue;

            enrollment.hed__Status__c = responseStatus;
        }

        return enrollments;
    }
}