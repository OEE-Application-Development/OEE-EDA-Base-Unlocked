global with sharing class GetCustomBooleanField {
    
    @InvocableMethod(Label='GetCustomBooleanField' Description = 'Use Apex to grab a custom Boolean field off of an object.' Category = 'OEE Util')
    global static List<Boolean> getCustomBooleanField(List<GetCustomFieldRequest> requests) {
        List<Boolean> results = new List<Boolean>();

        for(GetCustomFieldRequest request : requests) {
            results.add((Boolean)request.record.get(request.field));
        }

        return results;
    }

}