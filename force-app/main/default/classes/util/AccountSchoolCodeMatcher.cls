global with sharing class AccountSchoolCodeMatcher extends ObjectStringMatcher {

    global AccountSchoolCodeMatcher(Map<String, List<String>> schoolCodeMap) {
        this(schoolCodeMap, new List<String>());
    }
    global AccountSchoolCodeMatcher(Map<String, List<String>> schoolCodeMap, List<String> extraAccountFields) {
        this(schoolCodeMap, extraAccountFields, new List<String>());
    }
    
    global AccountSchoolCodeMatcher(Map<String, List<String>> schoolCodeMap, List<String> extraAccountFields, List<String> extraQueryFields) {
        super(Account.getSObjectType(), schoolCodeMap, CombinedFunctions.addStringToList(extraAccountFields, 'hed__School_Code__c', true), extraQueryFields);
    }

}