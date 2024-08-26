global with sharing class LeadEmailMatcher extends ObjectStringMatcher {

    global LeadEmailMatcher(Map<String, List<String>> emailMap) {
        this(emailMap, new List<String>());
    }
    global LeadEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields) {
        this(emailMap, extraEmailFields, new List<String>());
    }
    
    global LeadEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields, List<String> extraQueryFields) {
        super(Lead.getSObjectType(), emailMap, (List<String>)CombinedFunctions.addItemToList(extraEmailFields, 'Email', true), extraQueryFields);
    }

}