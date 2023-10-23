global with sharing class ImportCanvasEnrollment {
    // This should be temporary - SF is f***ing up and not allowing a redeploy of the Canvas package
    @InvocableMethod(Label='ImportCanvasEnrollment' Description = 'Import Canvas Enrollment by Enrollment ID' Category = 'Canvas Operation')
    global static List<lms_hed__LMS_Course_Enrollment__c> importCanvasEnrollment(List<String> enrollmentIds) {
        List<lms_hed__LMS_Course_Enrollment__c> results = new List<lms_hed__LMS_Course_Enrollment__c>();
        for(String enrollmentId : enrollmentIds) {
            try {
                results.add(lookupEnrollment(enrollmentId));
            } catch(Exception e) {
                results.add(null);
            }
        }
        return results;
    }

    private static Http http = new Http();
    private static lms_hed__LMS_Course_Enrollment__c lookupEnrollment(String externalId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:can_hed__Canvas/api/v1/accounts/1/enrollments/'+externalId);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        String body;
        try {
            body = http.send(request).getBody();
        } catch (CalloutException ce) {
            throw new AuraHandledException('Canvas Credentials are missing or not configured correctly. Please refer to Canvas Home Page to see how to set it up. '+ce.getMessage());
        }

        CanvasEnrollmentResponse remoteEnrollment = (CanvasEnrollmentResponse)JSON.deserialize(body, CanvasEnrollmentResponse.class);
        lms_hed__LMS_Course_Enrollment__c sfEnrollment = 
            new lms_hed__LMS_Course_Enrollment__c(
                lms_hed__LMS_Account__r = new lms_hed__LMS_Account__c(lms_hed__LMS_External_ID__c = String.valueOf(remoteEnrollment.user_id)),
                lms_hed__Course_Offering__r = new hed__Course_Offering__c(lms_hed__LMS_Offering_ID__c = String.valueOf(remoteEnrollment.course_section_id)),
                lms_hed__Enrollment_Link__c = remoteEnrollment.html_url,
                lms_hed__LMS_Course_Term__r = new lms_hed__LMS_Course_Term__c(lms_hed__LMS_Course_ID__c = String.valueOf(remoteEnrollment.course_id)),
                lms_hed__LMS_External_ID__c = String.valueOf(remoteEnrollment.id)
            );

        upsert sfEnrollment lms_hed__LMS_External_ID__c;
        return sfEnrollment;
    }

    public class CanvasEnrollmentResponse {

        public Long id;
        public Long user_id;
        public Long course_id;
        public String type;
        public Long course_section_id;
        public String enrollment_state;
        public String role;
        public Integer role_id;
        public Datetime last_activity_at;
        public Datetime last_attended_at;
        public CanvasGrades grades;
        public String sis_account_id;
        public String sis_course_id;
        public String sis_section_id;
        public String html_url;
        
    }

    public class CanvasGrades {

        public String html_url;
        public String current_grade;
        public Double current_score;
        public String final_grade;
        public Double final_score;
        public Double unposted_current_score;
        public String unposted_current_grade;
        public Double unposted_final_score;
        public String unposted_final_grade;
    
    }

}