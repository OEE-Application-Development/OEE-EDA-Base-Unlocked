global with sharing class OEEPassword {
    
    /**
     * Use Middleware endpoint.
     */
    global static String generatePassword(Integer length) {

        String path = '/salesforce/action/password/generate?length='+length.toString();
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        return response.getBody();
    }

}