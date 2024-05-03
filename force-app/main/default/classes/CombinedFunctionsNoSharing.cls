global without sharing class CombinedFunctionsNoSharing {

    global static Map<Id, String> convertToPublicUrls(List<SObject> objects, String fileRefField) {
        Map<Id, String> urlMap = new Map<Id, String>();
        Map<String, Id> contentIds = new Map<String, Id>();
        for(SObject obj : objects) {
            String ref = (String)obj.get(fileRefField);
            if(ref == null || ref == '') continue;

            contentIds.put(ref, obj.Id);
        }
        for(ContentDistribution dist : [SELECT Id, ContentVersion.ContentDocumentId, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersion.ContentDocumentId IN :contentIds.keySet() AND ContentVersion.IsLatest = true]) {
            urlMap.put(contentIds.get(String.valueOf(dist.ContentVersion.ContentDocumentId)), dist.DistributionPublicUrl);
        }
        return urlMap;
    }
}