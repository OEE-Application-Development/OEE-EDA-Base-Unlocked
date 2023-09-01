trigger CSUOEE_GenerateFrontDoorID on Contact (before insert) {
    for(Contact c : (List<Contact>)Trigger.new) {
        if(c.Front_Door_ID__c == null)c.Front_Door_ID__c = (new Uuid()).getValue();
    }
}