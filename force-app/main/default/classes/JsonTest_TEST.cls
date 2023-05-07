@IsTest
private class JsonTest_TEST {

    @IsTest
    private static void decode() {
        Contact c = (Contact) JsonDecode.decode(new List<JsonDecode.JsonDecodeRequest>{new JsonDecode.JsonDecodeRequest('Contact', '{"LastName": "Winterrowd"}')}).get(0);
        System.assertEquals('Winterrowd', c.LastName);
    }

    @IsTest
    private static void encode() {
        Contact c = new Contact(LastName = 'Winterrowd');
        String body = JsonEncode.encode(new List<JsonEncode.JsonEncodeRequest>{new JsonEncode.JsonEncodeRequest(c)}).get(0);
        System.assert(body.contains('Winterrowd'));
    }
    
}