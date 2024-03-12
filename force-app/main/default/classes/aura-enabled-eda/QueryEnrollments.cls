global with sharing class QueryEnrollments {

    @AuraEnabled(cacheable = true)
    global static List<hed__Course_Enrollment__c> getStudentEnrollments(hed__Term__c term, Contact contact) {
        return getSpecifiedEnrollments(new Map<String, Object> {'recordTypeName' => 'Student'}, term, contact);
    }

    @AuraEnabled(cacheable = true)
    global static List<hed__Course_Enrollment__c> getPendingStudentEnrollments(hed__Term__c term, Contact contact) {
        return getSpecifiedEnrollments(new Map<String, Object> {'recordTypeName' => 'Student_Pending'}, term, contact);
    }

    @AuraEnabled(cacheable = true)
    global static List<hed__Course_Enrollment__c> getFacultyEnrollments(hed__Term__c term, Contact contact) {
        return getSpecifiedEnrollments(new Map<String, Object> {'recordTypeName' => 'Faculty'}, term, contact);
    }

    private static List<hed__Course_Enrollment__c> getSpecifiedEnrollments(Map<String, Object> bindParameters, hed__Term__c term, Contact contact) {
        String whereClause = 'RecordType.DeveloperName = :recordTypeName';
        if(term != null && term.Id != null) {
            whereClause += ' AND hed__Course_Offering__r.hed__Term__c = :termId';
            bindParameters.put('termId', term.Id);
        }
        return runEnrollmentQuery(contact.Id, whereClause, bindParameters);
    }

    /**
     * Query using user mode - that means course connection permissions need properly set.
     */
    private static List<hed__Course_Enrollment__c> runEnrollmentQuery(Id contactId, String andWhereClause, Map<String, Object> bindMap) {
        bindMap.put('contactId', contactId);

        return (List<hed__Course_Enrollment__c>) Database.queryWithBinds(
            'SELECT Id, hed__Course_Offering__r.hed__Term__r.Name, hed__Course_Offering__r.hed__Course__r.Name, hed__Course_Offering__r.Name FROM hed__Course_Enrollment__c WHERE hed__Contact__c = :contactId AND ('
                +andWhereClause+') ORDER BY hed__Course_Offering__r.hed__Course__r.Course_Code__c', 
            bindMap, 
            AccessLevel.USER_MODE);
    }
    
}