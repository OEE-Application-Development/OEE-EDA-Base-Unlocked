@RestResource(urlMapping = '/contact/cps')
global class CpsUpsert {

    @HttpPost
    global static Map<String, String> upsertCpsContact(Contact cpsContact) {
        if(cpsContact.CPS_Provider_ID__c == null) {
            return new Map<String, String> {'success' => 'false', 'message' => 'CPS upsert requires csuoee__CPS_PRovider_ID__c.'};
        }

        // OK - First, CSU_ID
        if(cpsContact.CSU_ID__c != null) {
            // Great - we MUST have them!
            Contact upsertContact = new Contact(CSU_ID__c = cpsContact.CSU_ID__c, CPS_Provider_ID__c = cpsContact.CPS_Provider_ID__c);
            Database.UpsertResult result = Database.upsert(upsertContact, Contact.CSU_ID__c, false);
            return new Map<String, String> {'success' => 'true', 'message' => 'CSU_ID set.', 'Id' => result.id};
        }

        // Second, official email.
        try {
            Contact instructor = [SELECT Id, CPS_Provider_ID__c from Contact where Email = :cpsContact.Email or hed__UniversityEmail__c = :cpsContact.Email LIMIT 1];
            if(instructor.Id != null) {
                if(instructor.CPS_Provider_ID__c == null) {
                    instructor.CPS_Provider_ID__c = cpsContact.CPS_Provider_ID__c;
                    update instructor;
                }
                return new Map<String, String> {'success' => 'true', 'message' => 'Contact found, no update.', 'Id' => instructor.Id};
            }
        } catch (QueryException qe) {
            // No contact found.
        }

        // Third, Provider ID
        try {
            Contact instructor = [SELECT Id from Contact where CPS_Provider_ID__c = :cpsContact.CPS_Provider_ID__c LIMIT 1];
            return new Map<String, String> {'success' => 'true', 'message' => 'CPS_Provider_ID__c found.', 'Id' => instructor.Id};
        } catch (QueryException qe) {
            // No contact found.
        }

        insert cpsContact;
        return new Map<String, String> {'success' => 'true', 'message' => 'Instructor inserted', 'Id' => cpsContact.Id};
    }
    
}