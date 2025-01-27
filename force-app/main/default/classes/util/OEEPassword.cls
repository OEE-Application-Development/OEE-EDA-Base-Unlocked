global with sharing class OEEPassword {
    
    /**
     * Use Middleware endpoint.
     */
    global String generatePassword(Integer length) {

        String path = '/salesforce/action/password/generate?length=16';
        HttpResponse response = MiddlewareIntegration.sendMiddlewareRequest('GET', path);
        try {
            return response.getBody();
        } catch(Exception e) {
            throw new AuraException('Unknown error from middleware. Please check logs.');
        }
    }

}