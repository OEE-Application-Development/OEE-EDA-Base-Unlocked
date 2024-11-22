global with sharing class GetSObjectByIdFromCollection {

    @InvocableMethod(Label='GetSObjectByIdFromCollection' Description = 'Get SObject from a record collection by passed Id.' Category = 'OEE Util')
    global static List<SObject> getSObjectByIdFromCollection(List<GetRecordByIdRequest> requests) {
        List<SObject> results = new List<SObject>();
        for(GetRecordByIdRequest request : requests) {
            SObject result = null;
            for(SObject record : request.records) {
                if(record.Id == request.id) {
                    result = record;
                }
            }
            results.add(result);
        }
        return results;
    }

    global class GetRecordByIdRequest {
        @InvocableVariable(Required=true Label='Id' Description='The Id to search for.')
        global Id id;
        @InvocableVariable(Required=true Label='Record Collection' Description='Records to search in.')
        global List<SObject> records;
    }
    
}