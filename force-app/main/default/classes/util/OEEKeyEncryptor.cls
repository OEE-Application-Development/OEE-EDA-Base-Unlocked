@NamespaceAccessible
public with sharing class OEEKeyEncryptor {

    private String algorithm;
    private Blob key, iv;
    @NamespaceAccessible
    public OEEKeyEncryptor(String algorithm, String keyField, String iv) {
        if(algorithm != 'AES128' && algorithm != 'AES192' && algorithm != 'AES256') {
            throw new SecurityException('Algorithm must be one of: AES128, AES192, AES256');
        }
        this.algorithm = algorithm;

        this.iv = Blob.valueOf(iv);
        if(this.iv.size() != 16) {
            throw new SecurityException('Provided IV must be of length 16.');
        }

        try {
            this.key = EncodingUtil.base64Decode(Database.query('SELECT '+keyField+' FROM csuoee__OEE_Keys__c LIMIT 1', AccessLevel.SYSTEM_MODE).get(0).get(keyField).toString());
        } catch(Exception e) {
            throw new QueryException('Valid value not found for given key field name.');
        }
    }

    @NamespaceAccessible
    public Blob encrypt(Blob input) {
        return Crypto.encrypt(this.algorithm, this.key, this.iv, input);
    }

    @NamespaceAccessible
    public Blob decrypt(Blob input) {
        return Crypto.decrypt(this.algorithm, this.key, this.iv, input);
    }
    
}