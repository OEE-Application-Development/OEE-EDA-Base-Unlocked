/**
 * Global class that contains functions to be used in either Credit or PE.
 */
global class CombinedFunctions {

    global class EnrollmentRequest {
        @InvocableVariable(Required=true Description='User Id (CSU ID or NetID for Credit, Noncredit ID for PE) of the Contact.')
        global String userId;

        @InvocableVariable(Required=true Description='Reference of the offering.')
        global String offeringReference;

        @InvocableVariable(Required=false Description='Is this a drop instead of a confirm?')
        global Boolean isDrop = false;

        public EnrollmentRequest(){}
        public EnrollmentRequest(String userId, String offeringReference, Boolean isDrop) {
            this.userId = userId;
            this.offeringReference = offeringReference;
            this.isDrop = isDrop;
        }
    }

    public static hed__Course_Enrollment__c handleStudentEnrollment(Contact contact, String reference, Boolean isDrop) {
        return handleEnrollment(contact, reference, isDrop, false);
    }

    public static hed__Course_Enrollment__c handleInstructorEnrollment(Contact contact, String reference, Boolean isDrop) {
        return handleEnrollment(contact, reference, isDrop, true);
    }

    private static hed__Course_Enrollment__c handleEnrollment(Contact contact, String reference, Boolean isDrop, Boolean isInstructor) {
        if(contact == null) return null;

        RecordType enrollmentType;
        try {
            if(isInstructor) {
                enrollmentType = [select Id from RecordType where SobjectType = 'hed__Course_Enrollment__c' and DeveloperName = 'Faculty' LIMIT 1];
            } else {
                enrollmentType = [select Id from RecordType where SobjectType = 'hed__Course_Enrollment__c' and DeveloperName = 'Student' LIMIT 1];
            }
        } catch(Exception e) {
            enrollmentType = null;
        }

        hed__Course_Offering__c offering = null;
        try {
            offering = [select Id from hed__Course_Offering__c where lms_hed__LMS_Reference_Code__c = :reference LIMIT 1];
        } catch(QueryException qe) {
            return null;
        }

        hed__Course_Enrollment__c enrollment;
        hed__Course_Enrollment__c existing;
        try {
            existing = [Select Id, hed__Status__c from hed__Course_Enrollment__c where hed__Contact__c = :contact.Id and hed__Course_Offering__c = :offering.Id LIMIT 1];
        } catch(QueryException qe) {
            if(isDrop) return null;// Nothing to undo
            existing = null;
        }
        if(existing == null) {
            enrollment = new hed__Course_Enrollment__c(hed__Contact__c = contact.Id, hed__Course_Offering__c = offering.Id, hed__Status__c = 'Enrolled');
            if(enrollmentType != null) {
                enrollment.RecordTypeId = enrollmentType.Id;
            }
            insert enrollment;
        } else {
            enrollment = existing;
            if(isDrop) {
                enrollment.hed__Status__c = 'Withdrew';
            } else {
                enrollment.hed__Status__c = 'Enrolled';
            }

            update enrollment;
        }

        return enrollment;
    }
    
}