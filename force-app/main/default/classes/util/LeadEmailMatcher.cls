global with sharing class LeadEmailMatcher {

    private Map<Id, List<String>> emailMap;
    private List<String> extraEmailFields;
    global LeadEmailMatcher(Map<Id, List<String>> emailMap) {
        this(emailMap, new List<String>());
    }
    global LeadEmailMatcher(Map<Id, List<String>> emailMap, List<String> extraEmailFields) {
        this.emailMap = emailMap;
        this.extraEmailFields = extraEmailFields;
    }

    global Map<Id, Id> match() {
        Map<String, Id> reverseMap = new Map<String, Id>();
        for(Id id : emailMap.keySet()) {
            for(String email : emailMap.get(id)) {
                reverseMap.put(email.toLowerCase(), id);
            }
        }

        String extraFields = ', Email', extraWhere = 'Email IN :emails';
        for(String field : extraEmailFields) {
            extraFields += ', '+field;
            extraWhere += ' OR '+field+' IN :emails';
        }

        Map<Id, Id> resultMap = new Map<Id, Id>();
        for(Lead l : (List<Lead>)Database.queryWithBinds('SELECT Id'+extraFields+' FROM Lead WHERE '+extraWhere, new Map<String, Object>{'emails' => reverseMap.keySet()}, AccessLevel.USER_MODE)) {
            Id passed = reverseMap.get(l.Email.toLowerCase());
            for(String field : extraEmailFields) {
                if(passed != null) break;

                passed = reverseMap.get(((String)l.get(field)).toLowerCase());
            }
            if(passed != null) {
                resultMap.put(passed, l.Id);
            }
        }
        return resultMap;
    }

}