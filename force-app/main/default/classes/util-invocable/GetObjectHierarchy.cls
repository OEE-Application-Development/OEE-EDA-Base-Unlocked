global without sharing class GetObjectHierarchy {
    
    @InvocableMethod(Label='GetObjectHierarchy' Description = 'Get a hierarchy of results for an object type.' Category = 'OEE Util')
    global static List<HierarchyNode> getObjectHierarchy(List<GetObjectHierarchyRequest> requests) {
        List<HierarchyNode> results = new List<HierarchyNode>();
        for(GetObjectHierarchyRequest request : requests) {
            Schema.DescribeSObjectResult describeResult = Schema.describeSObjects(new List<String>{request.resultClassName}).get(0);
            HierarchyBuilder builder = new HierarchyBuilder(describeResult.getSObjectType(), request.hierarchyField, request.childRelationship, request.fields, new Map<String, Object>{request.parentField => request.parentId});
            results.add(builder.getFullHierarchy());
        }
        return results;
    }

    global class GetObjectHierarchyRequest {
        @InvocableVariable(Required=true Label='ResultClassName' Description='The name of the SObject type to be queried.')
        global String resultClassName;
        @InvocableVariable(Required=true Label='ParentField' Description='Should be lookup to a parent object.')
        global String parentField;
        @InvocableVariable(Required=true Label='ParentId' Description='The Id of the object owning the hierarchy.')
        global Id parentId;
        @InvocableVariable(Required=true Label='HierarchyField' Description='The name of the field that is a self lookup.')
        global String hierarchyField;
        @InvocableVariable(Required=true Label='ChildRelationshipName' Description='The name of the child relationship (should appear on the HierarchyField description).')
        global String childRelationship;
        @InvocableVariable(Required=true Label='Fields' Description='The fields to query - do not include Id or HierarchyField')
        global List<String> fields;
    }

}