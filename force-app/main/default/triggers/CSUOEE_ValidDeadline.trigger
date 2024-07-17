trigger CSUOEE_ValidDeadline on csuoee__Deadline__c (before insert, before update) {
    for(csuoee__Deadline__c deadline : Trigger.new) {
        if(deadline.csuoee__Occurance__c == null && (deadline.csuoee__Yearly_Date__c == null || deadline.csuoee__Yearly_Date__c == '')) {
            deadline.addError('One of csuoee__Occurance__c or csuoee__Yearly_Date__c must be set.');
        }
    }
}