trigger CSUOEE_ApplyHRtoContact on csumidp__HR_Directory_Entry__c (after insert, after update) {
    Map<Id, csumidp__HR_Directory_Entry__c> oldMap = Trigger.oldMap;
    Map<Id, Contact> updateMap = new Map<Id, Contact>();
    for(csumidp__HR_Directory_Entry__c entry : Trigger.new) {
        csumidp__HR_Directory_Entry__c oldEntry = (oldMap!=null)?oldMap.get(entry.Id):new csumidp__HR_Directory_Entry__c(Primary_Contact__c = null);

        if(entry.Primary_Contact__c == null) {
            if(oldEntry.Primary_Contact__c == null) {
                // No change, continue!
                continue;
            }
            //Blank... need to clear the lookup from the old Contact!
            // It's possible this contact was moved to someone else!
            if(!updateMap.containsKey(oldEntry.Primary_Contact__c)) {
                updateMap.put(oldEntry.Primary_Contact__c, new Contact(Id = oldEntry.Primary_Contact__c, HR_Directory_Entry__c = null));
            }
        } else {
            //New value to Contact -- should always be safe to try to update.
            updateMap.put(entry.Primary_Contact__c, new Contact(Id = entry.Primary_Contact__c, HR_Directory_Entry__c = entry.Id));
            if(oldEntry.Primary_Contact__c != null) {
                //There was a different, previous Contact... update that one to be blank if it's not already included.
                if(!updateMap.containsKey(oldEntry.Primary_Contact__c)) {
                    updateMap.put(oldEntry.Primary_Contact__c, new Contact(Id = oldEntry.Primary_Contact__c, HR_Directory_Entry__c = null));
                }
            }
        }
    }

    update updateMap.values(); 
}