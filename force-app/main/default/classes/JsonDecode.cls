global with sharing class JsonDecode {

    @InvocableMethod(Label='Decode an object from the given string.' Description='Decode an object from the given string.')
    global static List<SObject> decode(List<JsonDecodeRequest> requests) {
        List<SObject> results = new List<SObject>();
        for(JsonDecodeRequest request : requests) {
            SObject d = (SObject)JSON.deserialize(request.body, System.Type.forName(request.type));

            results.add(d);
        }

        return results;
    }

    global class JsonDecodeRequest {
        @InvocableVariable(Required=true Description='Type (sObject) to deserialize.')
        global String type;

        @InvocableVariable(Required=true Description='JSON to deserialize.')
        global String body;

        global JsonDecodeRequest(String type, String body) {
            this.type = type;
            this.body = body;
        }
    }
    
}