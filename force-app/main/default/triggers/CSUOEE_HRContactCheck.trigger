trigger CSUOEE_HRContactCheck on csumidp__HR_Directory_Entry__c (before insert) {
    List<String> csuIds = new List<String>();
    Map<String, csumidp__HR_Directory_Entry__c> csuIdMap = new Map<String, csumidp__HR_Directory_Entry__c>();
    for(csumidp__HR_Directory_Entry__c entry : (List<csumidp__HR_Directory_Entry__c>) Trigger.new) {
        csuIds.add(entry.csumidp__SIS_Person_Id__c);
        csuIdMap.put(entry.csumidp__SIS_Person_Id__c, entry);
    }

    for(Contact c : [select Id from Contact where CSU_ID__c in :csuIds]) {
        csuIdMap.get(c.CSU_ID__c).Primary_Contact__c = c.Id;
    }
}