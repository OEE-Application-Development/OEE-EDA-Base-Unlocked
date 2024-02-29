@IsTest
private class BaseRest_TEST {

    @IsTest
    private static void CpsUpsert_POST() {
        // Initial New Insert
        Contact cpsContact = new Contact(FirstName = 'First', LastName = 'Last'); 
        Map<String, String> result = CpsUpsert.upsertCpsContact(cpsContact);
        System.assertEquals(result.get('success'), 'false', 'Bad Result');
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        cpsContact.CPS_Provider_ID__c = 12345;
        result = CpsUpsert.upsertCpsContact(cpsContact);
        System.assertEquals(result.get('success'), 'true', 'Bad Result');
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');
        
        result = CpsUpsert.upsertCpsContact(cpsContact);
        System.assertEquals(result.get('success'), 'true', 'Bad Result');
        cpsContact.Id = result.get('Id');
        cpsContact.Email = 'test@123.com';

        update cpsContact;
        result = CpsUpsert.upsertCpsContact(cpsContact);
        System.assertEquals(result.get('success'), 'true', 'Bad Result');
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        cpsContact.CSU_ID__c = 'C12345';
        update cpsContact;

        result = CpsUpsert.upsertCpsContact(cpsContact);
        System.assertEquals(result.get('success'), 'true', 'Bad Result');
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        Contact cpsContact2 = new Contact(FirstName = 'First', LastName = 'Last', Email = 'fake@colostate.edu'); 
        insert cpsContact2;

        cpsContact2.CPS_Provider_ID__c = 23456;

        result = CpsUpsert.upsertCpsContact(cpsContact2);
        System.assertEquals(result.get('success'), 'true', 'Bad Result');
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        Contact cpsContact3 = new Contact(FirstName = 'First', LastName = 'Last', CPS_Provider_ID__c = 23456); 

        result = CpsUpsert.upsertCpsContact(cpsContact3);
        System.assertEquals(result.get('success'), 'true', 'Bad Result');
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        Contact cpsContact4 = new Contact(FirstName = 'First', LastName = 'Last', CPS_Provider_ID__c = 23456); 

        result = CpsUpsert.upsertCpsContact(cpsContact4);
        System.assertEquals(result.get('success'), 'true', 'Bad Result');
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, CPS_Provider_ID__c FROM Contact];
        System.assertEquals(contacts.size(), 2, contacts);
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        Contact cpsContact5 = new Contact(FirstName = 'First', LastName = 'Last', CPS_Provider_ID__c = 234567); 
        result = CpsUpsert.upsertCpsContact(cpsContact5);
        contacts = [SELECT Id, FirstName, LastName, Email, CPS_Provider_ID__c FROM Contact];
        System.assertEquals(result.get('message'), 'Instructor inserted', contacts);
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');

        cpsContact5 = new Contact(FirstName = 'First', LastName = 'Last', CPS_Provider_ID__c = 234567, Email = 'fake2@colostate.edu'); 
        result = CpsUpsert.upsertCpsContact(cpsContact5);
        System.assertNotEquals(result.get('csuoee__Front_Door_ID__c'), '', 'Bad Result');
    }
    
}