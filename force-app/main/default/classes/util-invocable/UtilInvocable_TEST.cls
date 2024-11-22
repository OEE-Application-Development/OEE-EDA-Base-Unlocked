@IsTest
private with sharing class UtilInvocable_TEST {

    @TestSetup
    static void generateUtilData() {
        insert new List<Account>{new Account(Name = 'Account1'), new Account(Name = 'Account2')};
    }
    
    @IsTest
    private static void getFirstItemFromCollection() {
        Test.startTest();

        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assert(GetFirstItemFromCollection.getFirstItemFromCollection(new List<List<Account>>{new List<Account>()}).get(0) == null, 'Util Invocable did not work...');
        System.assert(GetFirstItemFromCollection.getFirstItemFromCollection(new List<List<Account>>{accounts}).get(0).Id == accounts.get(0).Id, 'Util Invocable did not work...');

        Test.stopTest();
    }

    @IsTest
    private static void GetSObjectByIdFromCollection() {
        Test.startTest();

        List<Account> accounts = [SELECT Id, Name FROM Account];
        GetSObjectByIdFromCollection.GetRecordByIdRequest request = new GetSObjectByIdFromCollection.GetRecordByIdRequest();
        request.id = accounts.get(0).id;
        request.records = accounts;
        System.assert(GetSObjectByIdFromCollection.getSObjectByIdFromCollection(new List<GetSObjectByIdFromCollection.GetRecordByIdRequest>{request}).get(0).id == accounts.get(0).id, 'Util Invocable did not work...');

        Test.stopTest();
    }

}