global with sharing class OEEKeyHelpers {

    @AuraEnabled(cacheable=false)
    global static boolean setKey(String key, String value) {
        csuoee__OEE_Keys__c keys;
        try {
            keys = [SELECT Id FROM csuoee__OEE_Keys__c LIMIT 1];
        } catch(QueryException qe) {
            keys = new csuoee__OEE_Keys__c();
            insert keys;
        }

        try {
            keys.put(key, value);
            update keys;
        } catch (Exception e) {
            return false;
        }

        return true;
    }
    
}