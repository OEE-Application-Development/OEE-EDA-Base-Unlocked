global with sharing class PlanCompletionComparison {
    //private static final Map<Integer, String> RequirementStatus = new Map<Integer, String> {1 => 'Incomplete', 2 => 'In Progress', 3 => 'Complete'};
    
    @AuraEnabled
    global RequirementContainer Result;

    global PlanCompletionComparison(hed__Program_Plan__c plan) {
        this.Result = new RequirementContainer(plan);
    }

    global void addRequirements(List<hed__Plan_Requirement__c> requirements) {
        for(hed__Plan_Requirement__c req : requirements) {
            RequirementContainer container = Result.locateContainer(req.hed__Plan_Requirement__c);
            if(container != null)container.addRequirement(req);
        }
    }

    global List<Id> getUncheckedContainers() {
        List<Id> toReturn = new List<Id>();
        Result.getUncheckedContainers(toReturn);
        return toReturn;
    }

    global void evaluateProgramStatus(List<hed__Course_Enrollment__c> enrollments) {
        Set<Id> enrollmentUsage = new Set<Id>();
        Result.evalueCourseRequirements(enrollmentUsage, enrollments);
        Result.evalueSubjectRequirements(enrollmentUsage, enrollments);

        Result.rollUpEarnedCredits();
    }

    global class RequirementContainer {
        @AuraEnabled
        global Id RequirementId; // For child lookups.

        @AuraEnabled
        global Integer TotalCredits;
        @AuraEnabled
        global Integer EarnedCredits = 0;
        @AuraEnabled
        global Double CompletionPct;
        @AuraEnabled
        global String Status = 'Incomplete';

        Boolean checked = false;

        global RequirementContainer(hed__Program_Plan__c plan) {
            this.RequirementId = plan.Id;
            this.TotalCredits = Integer.valueOf(plan.hed__Total_Required_Credits__c);

            for(hed__Plan_Requirement__c req : plan.hed__Plan_Requirements__r) {
                addRequirement(req);
            }
            this.checked = true;
        }

        global RequirementContainer(hed__Plan_Requirement__c containerRequirement) {
            this.RequirementId = containerRequirement.Id;
            this.TotalCredits = Integer.valueOf(containerRequirement.hed__Credits__c);

            for(hed__Plan_Requirement__c req : containerRequirement.hed__Plan_Requirements__r) {
                addRequirement(req);
                this.checked = true;
            }
        }

        global void addRequirement(hed__Plan_Requirement__c req) {
            if('Course_Requirement'.equals(req.RecordType.DeveloperName)) {
                this.CourseRequirements.add(new CourseRequirement(req));
                return;
            }
            if('Subject_Requirement'.equals(req.RecordType.DeveloperName)) {
                this.SubjectRequirements.add(new SubjectRequirement(req));
                return;
            }
            if('Requirement_Container'.equals(req.RecordType.DeveloperName)) {
                this.ChildContainers.add(new RequirementContainer(req));
                return;
            }
        }

        global RequirementContainer locateContainer(Id parentId) {
            if(this.RequirementId == parentId) return this;

            for(RequirementContainer container : this.ChildContainers) {
                RequirementContainer parent = container.locateContainer(parentId);
                if(parent != null) return parent;
            }

            return null;
        }

        global void getUncheckedContainers(List<Id> results) {
            if(this.checked == false) {
                results.add(this.RequirementId);
                this.checked = true;
            }

            for(RequirementContainer container : ChildContainers) {
                container.getUncheckedContainers(results);
            }
        }

        @AuraEnabled
        global List<RequirementContainer> ChildContainers = new List<RequirementContainer>();

        @AuraEnabled
        global List<CourseRequirement> CourseRequirements = new List<CourseRequirement>();
        @AuraEnabled
        global List<SubjectRequirement> SubjectRequirements = new List<SubjectRequirement>();

        global void evalueCourseRequirements(Set<Id> enrollmentUsage, List<hed__Course_Enrollment__c> enrollments) {
            for(CourseRequirement req : CourseRequirements) {
                for(hed__Course_Enrollment__c enrollment : enrollments) {
                    if(!enrollmentUsage.contains(enrollment.Id) && enrollment.hed__Course_Offering__r.hed__Course__c == req.CourseId) {
                        if(enrollment.hed__Credits_Earned__c > 0) {
                            req.EarnedCredits = Integer.valueOf(enrollment.hed__Credits_Earned__c);
                            req.Status = 'Complete';
                        } else {
                            hed__Term__c current = QueryEnrollments.getCurrentTerm();
                            if(current != null && current.Id == enrollment.hed__Course_Offering__r.hed__Term__c) {
                                req.Status = 'In Progress';
                            }
                        }
                        enrollmentUsage.add(enrollment.Id);
                        break;
                    }
                }
            }

            for(RequirementContainer container : ChildContainers) {
                container.evalueCourseRequirements(enrollmentUsage, enrollments);
            }
        }

        global void evalueSubjectRequirements(Set<Id> enrollmentUsage, List<hed__Course_Enrollment__c> enrollments) {
            for(SubjectRequirement req : SubjectRequirements) {
                for(hed__Course_Enrollment__c enrollment : enrollments) {
                    if(!enrollmentUsage.contains(enrollment.Id) && enrollment.hed__Course_Offering__r.hed__Course__r.csuoee__Course_Code__c.startsWithIgnoreCase(req.Subject+' ')) {
                        req.EarnedCredits = Integer.valueOf(enrollment.hed__Credits_Earned__c);
                        enrollmentUsage.add(enrollment.Id);
                        break;
                    }
                }
            }

            for(RequirementContainer container : ChildContainers) {
                container.evalueSubjectRequirements(enrollmentUsage, enrollments);
            }
        }

        global Integer rollUpEarnedCredits() {
            for(RequirementContainer container : ChildContainers) {
                this.EarnedCredits += container.rollUpEarnedCredits();
            }

            for(CourseRequirement req : CourseRequirements) {
                this.EarnedCredits += req.EarnedCredits;
            }

            for(SubjectRequirement req : SubjectRequirements) {
                this.EarnedCredits += req.EarnedCredits;
            }

            this.CompletionPct = Double.valueOf(this.EarnedCredits) / Double.valueOf(this.TotalCredits);
            return this.EarnedCredits;
        }

    }

    global class CourseRequirement {

        @AuraEnabled
        global Id CourseId;
        @AuraEnabled
        global Integer TotalCredits;

        Integer DefaultEarnedCredits; // Fallback
        @AuraEnabled
        global Integer EarnedCredits = 0;
        @AuraEnabled
        global String Status = 'Incomplete';

        global CourseRequirement(hed__Plan_Requirement__c req) {
            this.CourseId = req.hed__Course__c;
            this.TotalCredits = Integer.valueOf(req.hed__Credits__c);
            this.DefaultEarnedCredits = Integer.valueOf(req.hed__Course__r.hed__Credit_Hours__c);
        }

    }

    global class SubjectRequirement {

        @AuraEnabled
        global String Subject;
        @AuraEnabled
        global Integer TotalCredits;
        @AuraEnabled
        global String Status = 'Incomplete';
        
        @AuraEnabled
        global Integer EarnedCredits = 0;

        global SubjectRequirement(hed__Plan_Requirement__c req) {
            this.Subject = req.Name;
            this.TotalCredits = Integer.valueOf(req.hed__Credits__c);
        }

    }
    
}