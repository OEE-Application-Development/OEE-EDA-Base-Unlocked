global without sharing class IsCollectionEmpty {
    
    @InvocableMethod(Label='IsCollectionEmpty' Description = 'Evaluates if a given collection is empty.' Category = 'OEE Util')
    global static List<Boolean> isCollectionEmpty(List<List<SObject>> sobjectLists) {
        List<Boolean> results = new List<Boolean>();
        for(List<SObject> sobjectList : sobjectLists) {
            if(sobjectList == null) {
                results.add(true);
            } else {
                results.add(sobjectList.isEmpty());
            }
        }
        return results;
    }

}