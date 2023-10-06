global with sharing class GetFirstItemFromCollection {

    @InvocableMethod(Label='GetFirstItemFromCollection' Description = 'Get first SObject from a record collection.' Category = 'OEE Util')
    global static List<SObject> getFirstItemFromCollection(List<List<SObject>> recordCollections) {
        List<SObject> results = new List<SObject>();
        for(List<SObject> recordCollection : recordCollections) {
            if(recordCollection.isEmpty()) {
                results.add(null);
            } else {
                results.add(recordCollection.get(0));
            }
        }
        return results;
    }
    
}