trigger CSUOEE_ReqCaveatAutoNumber on csuoee__Program_Plan_Caveat__c (before insert) {
    Set<Id> planIds = new Set<Id>();
    for(csuoee__Program_Plan_Caveat__c caveat : Trigger.new) {
        if(caveat.csuoee__Caveat_Enumeration__c != null) continue;

        planIds.add(caveat.csuoee__Program_Plan__c);
    }
    Map<Id, Integer> enumMaxMap = new Map<Id, Integer>();
    for(AggregateResult result : [SELECT csuoee__Program_Plan__c, MAX(csuoee__Caveat_Enumeration__c) MaxEnum FROM csuoee__Program_Plan_Caveat__c WHERE csuoee__Program_Plan__c IN :planIds GROUP BY csuoee__Program_Plan__c]) {
        enumMaxMap.put((Id)result.get('csuoee__Program_Plan__c'), (Integer.valueOf((Decimal)result.get('MaxEnum'))));
    }
    for(csuoee__Program_Plan_Caveat__c caveat : Trigger.new) {
        if(caveat.csuoee__Caveat_Enumeration__c != null) continue;

        Integer offset = enumMaxMap.get(caveat.csuoee__Program_Plan__c)+1;
        caveat.csuoee__Caveat_Enumeration__c = offset;
        enumMaxMap.put(caveat.csuoee__Program_Plan__c, offset);
    }
}