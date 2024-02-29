@RestResource(urlMapping = '/contact/cps')
public class CpsUpsert {

    @HttpPost
    public static Map<String, String> upsertCpsContact(Contact cpsContact) {
        // OK - First, CSU_ID
        if(cpsContact.CSU_ID__c != null) {
            // Great - we MUST have them, so don't do an update!
            return new Map<String, String> {'success' => 'true', 'message' => 'CSU_ID set, no update.'};
        }

        Contact instructor = [SELECT Id from Contact where Email = :cpsContact.Email or hed__University_Email__c = :cpsContact.Email LIMIT 1];

    }
    
}