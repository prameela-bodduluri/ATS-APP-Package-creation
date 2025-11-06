public with sharing class SkillResourceController {
    
    @AuraEnabled(cacheable=true)
    public static List<Skill_Resource__c> getSkillResources(Id resourceId) {
        List<Skill_Resource__c> skillResources = new List<Skill_Resource__c>();
        
        if (Skill_Resource__c.SObjectType.getDescribe().isAccessible()) {
            skillResources = [
                SELECT
                    Id,
                    Skill__c,
                    Start_date__c,
                    Resource__c,
                    End_date__c,
                    Version_Release__c,
                    Experience__c,
                    Experience_Formula__c,
                    Level_of_Experience__c
                FROM Skill_Resource__c
                WHERE Resource__c = :resourceId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate ASC
            ];
        }
        return skillResources; 
    }

    @AuraEnabled
    public static void updateSkillResourceRecords(String jsonData, List<String> recToDelete) {
        // Deserialize records
        List<Skill_Resource__c> skillResources = new List<Skill_Resource__c>();
        if (jsonData != null) {
            skillResources = (List<Skill_Resource__c>) JSON.deserialize(jsonData, List<Skill_Resource__c>.class);
        }

        // ✅ Check permissions before upsert
        if (!skillResources.isEmpty()) {
            if (Schema.sObjectType.Skill_Resource__c.isCreateable() || Schema.sObjectType.Skill_Resource__c.isUpdateable()) {
                Database.upsert(skillResources, AccessLevel.USER_MODE); // Safe option
            } else {
                throw new System.NoAccessException('You do not have permission to modify Skill_Resource__c records.');
            }
        }

        // ✅ Check permissions before delete
        if (recToDelete != null && !recToDelete.isEmpty()) {
            if (Schema.sObjectType.Skill_Resource__c.isDeletable()) {
                List<Skill_Resource__c> toDelete = [
                    SELECT Id FROM Skill_Resource__c WHERE Id IN :recToDelete WITH SECURITY_ENFORCED
                ];
                Database.delete(toDelete, AccessLevel.USER_MODE);
            } else {
                throw new System.NoAccessException('You do not have permission to delete Skill_Resource__c records.');
            }
        }
    }
}
