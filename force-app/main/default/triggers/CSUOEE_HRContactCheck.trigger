trigger CSUOEE_HRContactCheck on csumidp__HR_Directory_Entry__c (before insert, before update) {
    Map<String, csumidp__HR_Directory_Entry__c> csuIdMap = new Map<String, csumidp__HR_Directory_Entry__c>();
    for(csumidp__HR_Directory_Entry__c entry : (List<csumidp__HR_Directory_Entry__c>) Trigger.new) {
        csuIdMap.put(entry.csumidp__SIS_Person_Id__c, entry);
    }

    for(Contact c : [select Id, CSU_ID__c from Contact where CSU_ID__c in :csuIdMap.keySet()]) {
        csuIdMap.remove(c.CSU_ID__c).Primary_Contact__c = c.Id;
    }

    for(csumidp__HR_Directory_Entry__c noContact : csuIdMap.values()) {
        noContact.Primary_Contact__c = null;
    }
}