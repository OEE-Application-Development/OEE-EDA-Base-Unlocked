global with sharing class ContactEmailMatcher extends ObjectStringMatcher {

    global ContactEmailMatcher(Map<String, List<String>> emailMap) {
        this(emailMap, new List<String>());
    }
    global ContactEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields) {
        this(emailMap, extraEmailFields, new List<String>());
    }
    
    global ContactEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields, List<String> extraQueryFields) {
        super(Contact.getSObjectType(), emailMap, (List<String>)CombinedFunctions.addItemToList(extraEmailFields, 'Email', true), extraQueryFields);
    }
    
}