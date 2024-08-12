global with sharing class LeadEmailMatcher {

    private Map<String, List<String>> emailMap;
    private List<String> extraEmailFields;
    private List<String> extraQueryFields;
    global LeadEmailMatcher(Map<String, List<String>> emailMap) {
        this(emailMap, new List<String>());
    }
    global LeadEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields) {
        this(emailMap, extraEmailFields, new List<String>());
    }
    global LeadEmailMatcher(Map<String, List<String>> emailMap, List<String> extraEmailFields, List<String> extraQueryFields) {
        this.emailMap = emailMap;
        this.extraEmailFields = extraEmailFields;
        this.extraQueryFields = extraQueryFields;
    }

    global Map<String, Lead> match() {
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

        Map<String, Lead> resultMap = new Map<String, Lead>();
        for(Lead l : (List<Lead>)Database.queryWithBinds('SELECT Id'+extraFields+' FROM Lead WHERE '+extraWhere, new Map<String, Object>{'emails' => reverseMap.keySet()}, AccessLevel.USER_MODE)) {
            String passed = reverseMap.get(l.Email.toLowerCase());
            for(String field : extraEmailFields) {
                if(passed != null) break;

                passed = reverseMap.get(((String)l.get(field)).toLowerCase());
            }
            if(passed != null) {
                resultMap.put(passed, l);
            }
        }
        return resultMap;
    }

}