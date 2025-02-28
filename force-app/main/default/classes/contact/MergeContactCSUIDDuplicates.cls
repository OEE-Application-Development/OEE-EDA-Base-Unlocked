public without sharing class MergeContactCSUIDDuplicates {

    public static void mergeContactCSUIDDuplicates() {
        List<AggregateResult> results = [SELECT csuoee__CSU_ID__c FROM Contact WHERE csuoee__CSU_ID__c != null GROUP BY csuoee__CSU_ID__c HAVING COUNT(Id) > 1 LIMIT 500];
        if(results.isEmpty()) return;

        List<String> csuIds = new List<String>();
        for(AggregateResult result : results) {
            csuIds.add((String)result.get('csuoee__CSU_ID__c'));
        }

        Database.executeBatch(new BatchMergeCSUIDDupeContacts(csuIds), 20);
    }

    public static void tryMergeCsuIdContacts(List<Contact> contacts) {
        if(contacts.isEmpty()) return;
        // Map the CSUID matches
        Map<String, List<Contact>> csuIdMap = new Map<String, List<Contact>>();
        for(Contact c : contacts) {
            List<Contact> dupes = csuIdMap.get(c.csuoee__CSU_ID__c);
            if(dupes == null) {
                dupes = new List<Contact>();
                csuIdMap.put(c.csuoee__CSU_ID__c, dupes);
            }
            dupes.add(c);
        }

        // Run them merges...
        for(List<Contact> dupes : csuIdMap.values()) {
            Contact masterRecord = determineMaster(dupes);
            setMasterContactFields(masterRecord, dupes);

            masterRecord = (Contact)OrgUtils.stripRelationships(masterRecord);
            List<Contact> children = new List<Contact>();
            for(Contact dupe : dupes){children.add((Contact)OrgUtils.stripRelationships(dupe));}
            List<Database.MergeResult> results = Database.merge(masterRecord, children);
        }
    }

    private static Contact determineMaster(List<Contact> contacts) {
        RemoveableIterator contactIte = new RemoveableIterator(contacts);
        // Always prefer the Banner linked Contact
        while(contactIte.hasNext()) {
            Contact contact = (Contact)contactIte.next();
            if(contact.Account.RecordType.DeveloperName == 'csuoee__Banner_Account') return (Contact)contactIte.remove();
        }
        contactIte.reset();

        return (Contact)contactIte.remove();
    }

    private static void setMasterContactFields(Contact masterRecord, List<Contact> duplicates) {
        if(OrgUtils.isServiceAcctOwned(masterRecord)) {
            for(Contact duplicate : duplicates) {
                if(!OrgUtils.isServiceAcctOwned(duplicate)) {
                    masterRecord.OwnerId = duplicate.OwnerId;
                    break;
                }
            }
        }
    }
    
}