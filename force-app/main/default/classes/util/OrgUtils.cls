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
    
}