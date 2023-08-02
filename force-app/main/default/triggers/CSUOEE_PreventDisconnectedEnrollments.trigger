trigger CSUOEE_PreventDisconnectedEnrollments on hed__Course_Enrollment__c (before insert, before update) {
    for(hed__Course_Enrollment__c enrollment : (List<hed__Course_Enrollment__c>) Trigger.new) {
        if(String.isBlank(enrollment.hed__Contact__c) || String.isBlank(enrollment.hed__Course_Offering__c))
            enrollment.addError('Contact and Offering must be set on an enrollment.');

        if(Trigger.isUpdate) {
            hed__Course_Enrollment__c old = Trigger.oldMap.get(enrollment.Id);
            if(old != null)
                if(old.hed__Contact__c != enrollment.hed__Contact__c || old.hed__Course_Offering__c != enrollment.hed__Course_Offering__c)
                    enrollment.addError('Cannot change the offering or contact on an enrollment. Delete and recreate if required.');
        }
    }


}