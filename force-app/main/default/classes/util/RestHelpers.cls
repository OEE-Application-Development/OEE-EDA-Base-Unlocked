global class RestHelpers {
    
    global static void setJsonResponse(Object o) {
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(o, true));
        RestContext.response.headers.put('Content-Type', 'application/json');
        RestContext.response.headers.put('Content-Length', String.valueOf(RestContext.response.responseBody.size()));
    }

    global static void trySetJsonResponse(Object o) {
        if(o == null) {
            RestContext.response.statusCode = 404;
            setJsonResponse(NOT_FOUND);
            return;
        }

        setJsonResponse(o);
    }

    global static void setNotFoundResponse(String msg) {
        RestContext.response.statusCode = 404;
        setJsonResponse(new Map<String, String>{'message' => msg});
    }

    private static final Map<String, String> NOT_FOUND = new Map<String, String>{'message' => 'Requested resource not found.'};
    
}