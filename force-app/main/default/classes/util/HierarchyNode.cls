global without sharing class HierarchyNode {
    
    @InvocableVariable(Required=false Label='ParentNode' Description='ParentNode for this SObject - NULL if top of tree.')
    global HierarchyNode parent = null;
    @InvocableVariable(Required=false Label='ChildNodes' Description='Collection of SObjects that are children. NULL or Empty if no children.')
    global List<HierarchyNode> children = null;
    @InvocableVariable(Required=false Label='SObject' Description='The actual SObject represented by this node.')
    global SObject node = null;

    global HierarchyNode() {}
    global HierarchyNode(HierarchyNode parent, SObject node) {
        this.node = node;
    }

    global void addChild(HierarchyNode child) {
        if(children == null) children = new List<HierarchyNode>();
        children.add(child);
    }

}