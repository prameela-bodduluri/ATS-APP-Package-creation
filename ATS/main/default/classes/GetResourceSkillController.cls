public with sharing class GetResourceSkillController {
    @AuraEnabled(cacheable=true)
    public static List<ATSWrapper> fetchResources(Id jobId) {
        List<ATSWrapper> wrapperList = new List<ATSWrapper>();
        Job_Posting__c jobPosting;

        // Cache describe results correctly
        Schema.DescribeSObjectResult jobPostDesc = Job_Posting__c.SObjectType.getDescribe();
        Schema.DescribeFieldResult jobSkillFieldDesc = Job_Posting__c.Skills__c.getDescribe();

        try {
            if (jobPostDesc.isAccessible() && jobSkillFieldDesc.isAccessible()) {
                jobPosting = [
                    SELECT Skills__c
                    FROM Job_Posting__c
                    WHERE Id = :jobId
                    WITH SECURITY_ENFORCED
                ];
            }
        } catch (Exception e) {
            System.debug('Error fetching Job Posting: ' + e.getMessage());
        }

        List<Skill_Resource__c> skillResources = getSkillResources(jobPosting);
        Map<Id, List<Skill_Resource__c>> resourceToSkillsMap = new Map<Id, List<Skill_Resource__c>>();

        if (!skillResources.isEmpty()) {
            for (Skill_Resource__c skillResource : skillResources) {
                if (!resourceToSkillsMap.containsKey(skillResource.Resource__c)) {
                    resourceToSkillsMap.put(skillResource.Resource__c, new List<Skill_Resource__c>());
                }
                resourceToSkillsMap.get(skillResource.Resource__c).add(skillResource);
            }

            for (Id resourceId : resourceToSkillsMap.keySet()) {
                ATSWrapper wrapper = new ATSWrapper();
                List<String> skillNames = new List<String>();
                List<Skill_Resource__c> skillsForResource = resourceToSkillsMap.get(resourceId);

                if (skillsForResource != null) {
                    for (Skill_Resource__c skill : skillsForResource) {
                        if (wrapper.getResourceName() == null &&
                            wrapper.getEmail() == null &&
                            wrapper.getPhoneNumber() == null) {
                            wrapper.setResourceName(skill.Resource__r.Name);
                            wrapper.setEmail(skill.Resource__r.Primary_Email__c);
                            wrapper.setPhoneNumber(skill.Resource__r.Phone_Number__c);
                            wrapper.setResourceId(skill.Resource__c);
                            wrapper.setResourceURL('/lightning/r/Resource__c/' + skill.Resource__c + '/view');
                        }
                        skillNames.add(skill.Skill__r.Name);
                    }
                    wrapper.setSkillList(skillNames);
                }
                wrapperList.add(wrapper);
            }
        }

        return (wrapperList.size() > 0) ? wrapperList : null;
    }

    private static List<Skill_Resource__c> getSkillResources(Job_Posting__c jobPosting) {
        if (jobPosting == null || String.isBlank(jobPosting.Skills__c)) {
            return new List<Skill_Resource__c>();
        }

        List<String> skills = jobPosting.Skills__c.split(';');
        List<Skill_Resource__c> finalSkillResources = new List<Skill_Resource__c>();

        // Cache describe results properly
        Schema.DescribeSObjectResult skillResDesc = Skill_Resource__c.SObjectType.getDescribe();
        Schema.DescribeFieldResult resFieldDesc = Skill_Resource__c.Resource__c.getDescribe();
        Schema.DescribeSObjectResult resDesc = Resource__c.SObjectType.getDescribe();
        Schema.DescribeFieldResult resNameDesc = Resource__c.Name.getDescribe();
        Schema.DescribeFieldResult resEmailDesc = Resource__c.Primary_Email__c.getDescribe();
        Schema.DescribeFieldResult resPhoneDesc = Resource__c.Phone_Number__c.getDescribe();
        Schema.DescribeSObjectResult skillDesc = Skill__c.SObjectType.getDescribe();
        Schema.DescribeFieldResult skillNameDesc = Skill__c.Name.getDescribe();

        try {
            if (skillResDesc.isAccessible() && resFieldDesc.isAccessible() &&
                resDesc.isAccessible() && resNameDesc.isAccessible() &&
                resEmailDesc.isAccessible() && resPhoneDesc.isAccessible() &&
                skillDesc.isAccessible() && skillNameDesc.isAccessible()) {

                List<Skill_Resource__c> skillResources = [
                    SELECT Resource__c
                    FROM Skill_Resource__c
                    WHERE Skill_Name__c IN :skills
                    WITH SECURITY_ENFORCED
                ];

                if (!skillResources.isEmpty()) {
                    Set<Id> resourceIds = new Set<Id>();
                    for (Skill_Resource__c sr : skillResources) {
                        resourceIds.add(sr.Resource__c);
                    }

                    finalSkillResources = [
                        SELECT
                            Resource__c,
                            Resource__r.Name,
                            Resource__r.Primary_Email__c,
                            Resource__r.Phone_Number__c,
                            Skill__r.Name
                        FROM Skill_Resource__c
                        WHERE Resource__c IN :resourceIds
                        WITH SECURITY_ENFORCED
                    ];
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching skill resources: ' + e.getMessage());
        }

        return finalSkillResources;
    }
}
