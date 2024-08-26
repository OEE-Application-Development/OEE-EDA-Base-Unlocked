global abstract with sharing class ObjectStringMatcher {

    private Map<String, List<String>> searchMap;
    private List<String> searchFields;
    private List<String> extraQueryFields;

    private Schema.SObjectType type;
    global ObjectStringMatcher(Schema.SObjectType type, Map<String, List<String>> searchMap) {
        this(type, searchMap, new List<String>());
    }
    global ObjectStringMatcher(Schema.SObjectType type, Map<String, List<String>> searchMap, List<String> searchFields) {
        this(type, searchMap, searchFields, new List<String>());
    }
    global ObjectStringMatcher(Schema.SObjectType type, Map<String, List<String>> searchMap, List<String> searchFields, List<String> extraQueryFields) {
        if(searchFields.isEmpty()) throw new QueryException('Searcher requires at least one field to filter on.');

        this.type = type;
        this.searchMap = searchMap;
        this.searchFields = searchFields;
        this.extraQueryFields = extraQueryFields;
    }

    protected Map<String, SObject> runmatch() {
        Map<String, String> reverseMap = new Map<String, String>();
        for(String id : searchMap.keySet()) {
            for(String searchTerm : searchMap.get(id)) {
                reverseMap.put(searchTerm.toLowerCase(), id);
            }
        }

        String fields = '', whereClause = '';
        for(String field : searchFields) {
            fields += ','+field;
            whereClause += ' OR '+field+' IN :values';
        }
        whereClause = whereClause.substring(3);

        for(String field : extraQueryFields) {
            fields += ','+field;
        }

        Map<String, SObject> resultMap = new Map<String, SObject>();
        for(SObject result : Database.queryWithBinds('SELECT Id'+fields+' FROM '+type.getDescribe().getName()+' WHERE '+whereClause, new Map<String, Object>{'values' => reverseMap.keySet()}, AccessLevel.USER_MODE)) {
            String passed = null;
            for(String field : searchFields) {
                if(passed != null) break;

                // Not all other queried fields may have a value
                Object fieldValue = result.get(field);
                if(fieldValue == null) continue;

                passed = reverseMap.get(((String)fieldValue).toLowerCase());
            }
            if(passed != null) {
                resultMap.put(passed, result);
            }
        }
        return resultMap;
    }
    
}