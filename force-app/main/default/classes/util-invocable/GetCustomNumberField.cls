global with sharing class GetCustomNumberField {
    
    @InvocableMethod(Label='GetCustomNumberField' Description = 'Use Apex to grab a custom Number field off of an object.' Category = 'OEE Util')
    global static List<Double> getCustomNumberField(List<GetCustomFieldRequest> requests) {
        List<Double> results = new List<Double>();

        for(GetCustomFieldRequest request : requests) {
            results.add((Double)request.record.get(request.field));
        }

        return results;
    }

}