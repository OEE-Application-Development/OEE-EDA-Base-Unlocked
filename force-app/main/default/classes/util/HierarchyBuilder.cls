global with sharing class HierarchyBuilder {
    
    Schema.SObjectType type;
    private String selectClause = 'SELECT ', parentField, childRelationshipName, initialWhereClause;
    private Map<String, Object> initalBind;

    global HierarchyBuilder(Schema.SObjectType type, String parentField, String childRelationshipName, List<String> fields, Map<String, Object> initialFieldFilters) {
        this.type = type;        
        this.parentField = parentField;
        this.childRelationshipName = childRelationshipName;
        this.initalBind = initialFieldFilters;
        
        selectClause += 'Id,Name,'+String.escapeSingleQuotes(parentField);
        for(String field : fields) {
            if(field.equalsIgnoreCase('Name') || field.equalsIgnoreCase(parentField)) continue;

            selectClause += ','+String.escapeSingleQuotes(field);
        }

        Set<String> initialFields = initialFieldFilters.keySet();
        if(initialFields.isEmpty()) throw new IllegalArgumentException('No initial filter set. Refusing to overload our query limits.');
        Boolean first = true;
        for(String initialFilterKey : initialFieldFilters.keySet()) {
            if(first) {
                first = false;

                initialWhereClause = initialFilterKey + ' = :' + initialFilterKey;
            } else {
                initialWhereClause += ' AND ' + initialFilterKey + ' = :' + initialFilterKey;
            }
        }
    }

    global HierarchyNode getFullHierarchy() {
        return getHierarchy(-1);
    }

    global HierarchyNode getHierarchy(Integer depth) {
        List<SObject> queryResults = initialQuery();
        Map<Id, HierarchyNode> recurseMissing = new Map<Id, HierarchyNode>();
        
        HierarchyNode resultTopNode = new HierarchyNode();
        resultTopNode.parentRelationship = parentField;

        buildNodes(0, resultTopNode, queryResults, recurseMissing);
        while(!recurseMissing.isEmpty()) {
            // Copy & Clear map so we can try again.
            Map<Id, HierarchyNode> copyMap = new Map<Id, HierarchyNode>(recurseMissing);
            recurseMissing.clear();
            // If Map of missing recurse isn't empty, go through it.
            Map<Id, List<SObject>> recurseChildren = recurseDepth(copyMap.keySet());
            for(Id parentId : recurseChildren.keySet()) {
                // Work in child cohorts
                buildNodes(0, copyMap.get(parentId), recurseChildren.get(parentId), recurseMissing);
            }
        }
        return resultTopNode;
    }

    // Run the initial query, may or may not need to recurse past this.
    private List<SObject> initialQuery() {
        String query = buildSelectClause();

        // Start WHERE
        query += ' WHERE ' + initialWhereClause;

        //TODO: Get ORDER in there
        return Database.queryWithBinds(query, initalBind, AccessLevel.USER_MODE);
    }

    // Max Depth e.g. [SELECT Id, Name, (SELECT Id, Name, (SELECT Id, Name, (SELECT Id, Name, (SELECT Id, Name FROM ChildAccounts) FROM ChildAccounts) FROM ChildAccounts) FROM ChildAccounts) FROM Account WHERE ParentId IN (:parentIds)]
    private Map<Id, List<SObject>> recurseDepth(Set<Id> parentIds) {
        String query = buildSelectClause();

        // Start WHERE - recurse ORDER BY starts with parentId, allows cohort of children building
        query += ' WHERE '+ parentField + ' IN :parentIds ORDER BY ' + parentField + ' ASC';

        Map<Id, List<SObject>> childCohorts = new Map<Id, List<SObject>>();
        
        Id runningParentId = null;
        List<SObject> runningList = new List<SObject>();
        for(SObject result : Database.queryWithBinds(query, (new Map<String, Object>{'parentIds' => parentIds}), AccessLevel.USER_MODE)) {
            Id currentParentId = (Id)result.get(parentField);
            if(runningParentId != currentParentId) {
                // New parent
                childCohorts.put(runningParentId, runningList);
                
                // Reset values
                runningParentId = currentParentId;
                runningList = new List<SObject>();
            }
            runningList.add(result);
        }
        childCohorts.put(runningParentId, runningList);
        return childCohorts;
    }

    private String buildSelectClause() {
        String query = selectClause+', '; // Start w/ basic select
        
        // Spin out sub-queries
        for(Integer i=1;i<=3;i++) {
            query += '('+selectClause+', ';
        }
        query += '('+selectClause;
        // Close sub-queries
        for(Integer i=1;i<=4;i++) {
            query += ' FROM '+childRelationshipName+')';
        }

        // Finish the FROM
        query += ' FROM ' + type.getDescribe().getName();
        return query;
    }

    private void buildNodes(Integer currentLevel, HierarchyNode parentNode, List<SObject> queryResults, Map<Id, HierarchyNode> recurseMissing) {
        for(SObject queryResult : queryResults) {
            // Create Node & Add to Parent
            HierarchyNode child = new HierarchyNode(queryResult);
            parentNode.addChild(child);

            if(currentLevel == 4) {
                // We're at our recurse limit, add this node to be recursed.
                recurseMissing.put(queryResult.Id, child);
            } else {
                // Check for children
                List<SObject> subChildren = (List<SObject>)queryResult.getSObjects(childRelationshipName);
                if(subChildren != null && !subChildren.isEmpty()) {
                    // Children exist & not at recurse limit.
                    buildNodes(currentLevel+1, child, subChildren, recurseMissing);
                }
            }
        }
    }

}