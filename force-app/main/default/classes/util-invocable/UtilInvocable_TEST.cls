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

    @IsTest
    private static void GetCustomField() {
        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'Test String', hed__Capacity__c = 3, csuoee__Requires_Canvas__c = true);
        Test.startTest();

        GetCustomFieldRequest request = new GetCustomFieldRequest();
        request.record = offering;

        request.field = 'csuoee__Requires_Canvas__c';
        System.assert(GetCustomBooleanField.getCustomBooleanField(new List<GetCustomFieldRequest>{request}).get(0));

        request.field = 'hed__Capacity__c';
        System.assertEquals(GetCustomNumberField.getCustomNumberField(new List<GetCustomFieldRequest>{request}).get(0), 3);

        request.field = 'Name';
        System.assertEquals(GetCustomStringField.getCustomStringField(new List<GetCustomFieldRequest>{request}).get(0), 'Test String');

        Test.stopTest();
    }

    @IsTest
    private static void IsCollectionEmpty() {
        List<Account> accounts = new List<Account>();

        Test.startTest();

        System.assert(IsCollectionEmpty.isCollectionEmpty(new List<List<SObject>> {accounts, null}).get(0), 'This was an empty list.');

        Test.stopTest();
    }

    @IsTest
    private static void GetObjectHierarchy() {
        Account h0 = new Account(Name = 'TOP');
        insert h0;
        List<Account> h1 = new List<Account> {new Account(Name = '1', hed__School_Code__c = '1', ParentId = h0.Id)};
        List<Account> h2 = new List<Account> {new Account(Name = '21', hed__School_Code__c = '21', Parent = new Account(hed__School_Code__c = '1')),new Account(Name = '22', hed__School_Code__c = '22', Parent = new Account(hed__School_Code__c = '1'))};
        List<Account> h3 = new List<Account> {new Account(Name = '321', hed__School_Code__c = '321', Parent = new Account(hed__School_Code__c = '21')),new Account(Name = '322', hed__School_Code__c = '322', Parent = new Account(hed__School_Code__c = '22'))};
        List<Account> h4 = new List<Account> {new Account(Name = '4321', hed__School_Code__c = '4321', Parent = new Account(hed__School_Code__c = '321')),new Account(Name = '4322', hed__School_Code__c = '4322', Parent = new Account(hed__School_Code__c = '322'))};
        List<Account> h5 = new List<Account> {new Account(Name = '54321', hed__School_Code__c = '54321', Parent = new Account(hed__School_Code__c = '4321')),new Account(Name = '54322', hed__School_Code__c = '54322', Parent = new Account(hed__School_Code__c = '4322'))};
        List<Account> h6 = new List<Account> {new Account(Name = '654321', hed__School_Code__c = '654321', Parent = new Account(hed__School_Code__c = '54321')),new Account(Name = '654322', hed__School_Code__c = '654322', Parent = new Account(hed__School_Code__c = '54322'))};
        insert h1;
        insert h2;
        insert h3;
        insert h4;
        insert h5;
        insert h6;

        Test.startTest();
        GetObjectHierarchy.GetObjectHierarchyRequest request = new GetObjectHierarchy.GetObjectHierarchyRequest();
        request.resultClassName = 'Account';
        request.parentField = 'ParentId';
        request.parentId = h0.Id;
        request.hierarchyField = 'ParentId';
        request.childRelationship = 'ChildAccounts';
        request.fields = new List<String>{'Name', 'hed__School_Code__c', 'ParentId'};

        HierarchyNode top = GetObjectHierarchy.getObjectHierarchy(new List<GetObjectHierarchy.GetObjectHierarchyRequest>{request}).get(0);
        HierarchyNode bottom = top
            .children.get(0)//h1
            .children.get(0)//h2
            .children.get(0)//h3
            .children.get(0)//h4
            .children.get(0)//h5
            .children.get(0);//h6

        System.assert(((Account)bottom.node).hed__School_Code__c == '654321');

        Test.stopTest();
    }

}