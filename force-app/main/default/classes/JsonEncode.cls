global with sharing class JsonEncode {

    @InvocableMethod(Label='Encode an object to a JSON string' Description='Encode an object to a JSON string')
    global static List<String> encode(List<JsonEncodeRequest> requests) {
        List<String> results = new List<String>();
        for(JsonEncodeRequest request : requests) {
            results.add(JSON.serialize(request.body, true));
        }

        return results;
    }

    global class JsonEncodeRequest {

        @InvocableVariable(Required=true Description='JSON to deserialize.')
        global SObject body;

        global JsonEncodeRequest(SObject body) {
            this.body = body;
        }
    }
    
}