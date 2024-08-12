global with sharing class ContactEmailMatcher {

    private Map<String, List<String>> emailMap;
    private List<String> extraEmailFields;
    private List<String> extraQueryFields;
    global ContactEmailMatcher(Map<String, List<String>> emailMap) {
        this(emailMap, new List<String>());
    }
    global ContactEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields) {
        this(emailMap, extraEmailFields, new List<String>());
    }
    global ContactEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields, List<String> extraQueryFields) {
        this.emailMap = emailMap;
        this.extraEmailFields = extraEmailFields;
        this.extraQueryFields = extraQueryFields;
    }

    global Map<String, Contact> match() {
        Map<String, String> reverseMap = new Map<String, String>();
        for(String id : emailMap.keySet()) {
            for(String email : emailMap.get(id)) {
                reverseMap.put(email.toLowerCase(), id);
            }
        }

        String extraFields = ', Email', extraWhere = 'Email IN :emails';
        for(String field : extraEmailFields) {
            extraFields += ', '+field;
            extraWhere += ' OR '+field+' IN :emails';
        }
        for(String field : extraQueryFields) {
            extraFields += ', '+field;
        }
        Map<String, Contact> resultMap = new Map<String, Contact>();
        for(Contact c : (List<Contact>)Database.queryWithBinds('SELECT Id'+extraFields+' FROM Contact WHERE '+extraWhere, new Map<String, Object>{'emails' => reverseMap.keySet()}, AccessLevel.USER_MODE)) {
            String passed = reverseMap.get(c.Email.toLowerCase());
            for(String field : extraEmailFields) {
                if(passed != null) break;

                passed = reverseMap.get(((String)c.get(field)).toLowerCase());
            }
            if(passed != null) {
                resultMap.put(passed, c);
            }
        }
        return resultMap;
    }
    
}