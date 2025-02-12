global without sharing class HierarchyNode {

    @AuraEnabled
    @InvocableVariable(Required=true Label='ParentField' Description='Field that was set as the hierarchical relationship field.')
    global String parentRelationship;
    @AuraEnabled
    @InvocableVariable(Required=false Label='SObject' Description='The actual SObject represented by this node.')
    global SObject node = null;
    @AuraEnabled
    @InvocableVariable(Required=false Label='ChildNodes' Description='Collection of SObjects that are children. NULL or Empty if no children.')
    global List<HierarchyNode> children = null;

    global HierarchyNode(){}
    global HierarchyNode(SObject node) {
        this.node = node;
    }

    global void addChild(HierarchyNode child) {
        if(children == null) children = new List<HierarchyNode>();
        children.add(child);
    }

    global List<HierarchyNode> getChildren() {
        return children;
    }

}