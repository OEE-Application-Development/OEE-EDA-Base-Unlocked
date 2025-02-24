public without sharing class BatchMergeCSUIDDupeContacts implements Database.Batchable<SObject> {

    List<String> csuIds;
    public BatchMergeCSUIDDupeContacts(List<String> csuIds) {
        this.csuIds = csuIds;

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocatorWithBinds('SELECT Id, AccountId, Account.RecordType.DeveloperName, Account.hed__School_Code__c, csuoee__CSU_ID__c, FirstName, LastName, Email FROM Contact WHERE csuoee__CSU_ID__c IN :csuIds ORDER BY csuoee__CSU_ID__c', new Map<String, Object>{'csuIds' => this.csuIds}, AccessLevel.SYSTEM_MODE);
    }
   
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        MergeContactCSUIDDuplicates.tryMergeCsuIdContacts(scope);
    }

    public void finish(Database.BatchableContext bc) {

    }
    
}