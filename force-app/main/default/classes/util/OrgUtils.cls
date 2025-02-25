global without sharing class OrgUtils {

    private static String orgNs = null;
    global static String getOrgNs() {
        if(orgNs == null) {
            orgNs = ([SELECT NamespacePrefix FROM Organization].NamespacePrefix);
            if(orgNs != '') {
                orgNs = orgNs + '__';
            }
        }
        return orgNs;
    }

    private static Id svcAcctId = null;
    global static Boolean isServiceAcctOwned(SObject obj) {
        if(svcAcctId == null) {
            svcAcctId = [SELECT Id FROM User WHERE Name = 'Service Account' LIMIT 1].Id;
        }

        Id ownerId = (Id)obj.get('OwnerId');
        if(ownerId == null) return false;
        return ownerId == svcAcctId;
    }

    /**
     * This method removes Relationships from an object (by cloning it) so merges can be performed.
     */
    global static SObject stripRelationships(SObject toStrip) {
        SObject copy = toStrip.getSObjectType().newSObject(toStrip.Id);
        Map<String, Object> fieldMap = toStrip.getPopulatedFieldsAsMap();
        for(String key : fieldMap.keySet()) {
            Object value = fieldMap.get(key);
            if(value instanceof SObject) {
                continue;
            }

            copy.put(key, value);
        }
        return copy;
    }
    
}