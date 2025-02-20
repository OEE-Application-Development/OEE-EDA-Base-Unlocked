Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'University_College' LIMIT 1].Id;
List<Account> accounts = [SELECT Id, RecordTypeId FROM Account WHERE RecordType.DeveloperName = 'Academic_Program'];
for(Account acct : accounts) {
    acct.RecordTypeId = recordTypeId;
}
if(!accounts.isEmpty())update accounts;