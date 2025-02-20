Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Banner_Account'].Id;
List<Account> accounts = [SELECT Id, RecordTypeId FROM Account WHERE RecordType.DeveloperName = 'Academic_Program'];
for(Account acct : accounts) {
    acct.RecordTypeId = recordTypeId;
}
update accounts;