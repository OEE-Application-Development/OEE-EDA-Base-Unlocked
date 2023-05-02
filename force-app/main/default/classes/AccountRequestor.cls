global with sharing class AccountRequestor {

    final static Map<Id, Map<String, Account>> accountMap = new Map<Id, Map<String, Account>>();
    
    @InvocableMethod(Label='Get Unique Account' Description='Get Account by Record Type & School Code')
    global static List<Account> getAccount(List<AccountRequest> requests) {
        List<Account> accounts = new List<Account>();
        for(AccountRequest request : requests) {
            Map<String, Account> typeMap = accountMap.get(request.recordTypeId);
            if(typeMap == null) {
                typeMap = new Map<String, Account>();
                accountMap.put(request.recordTypeId, typeMap);
            }

            Account account = typeMap.get(request.schoolCode);
            if(account == null) {
                try {
                    account = [select Id, Name, hed__School_Code__c from Account where RecordTypeId = :request.recordTypeId and hed__School_Code__c = :request.schoolCode LIMIT 1];
                } catch(Exception e) {
                    account = null;
                }

                if(account != null) {
                    typeMap.put(request.schoolCode, account);
                }
            }

            accounts.add(account);
        }
        return accounts;
    }

    global class AccountRequest {
        @InvocableVariable(Required=true Description='RecordTypeId')
        global Id recordTypeId;

        @InvocableVariable(Required=true Description='hed_School_Code__c field on Account')
        global String schoolCode;

        public AccountRequest(){}
        public AccountRequest(Id recordTypeId, String schoolCode) {
            this.recordTypeId = recordTypeId;
            this.schoolCode = schoolCode;
        }
    }
    
}