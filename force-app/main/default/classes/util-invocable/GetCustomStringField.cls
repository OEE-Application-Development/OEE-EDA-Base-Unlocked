global with sharing class GetCustomStringField {
    
    @InvocableMethod(Label='GetCustomStringField' Description = 'Use Apex to grab a custom String field off of an object.' Category = 'OEE Util')
    global static List<String> getCustomStringField(List<GetCustomFieldRequest> requests) {
        List<String> results = new List<String>();

        for(GetCustomFieldRequest request : requests) {
            results.add((String)request.record.get(request.field));
        }

        return results;
    }

}