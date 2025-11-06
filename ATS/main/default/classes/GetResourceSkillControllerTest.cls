@IsTest
public class GetResourceSkillControllerTest {
   
    @IsTest
    public static void oneJobPostingWithTwoResources() {
        User adminUser = createAdminUser('Admin', 'User');
        insert adminUser;
        
        assignPermissionSetForAdmin(adminUser);
        
        System.runAs(adminUser) {
            Client__c client = createClient();
            insert client;
           
            Job_Posting__c jobPost = createJobPosting(client.Id);
            insert jobPost;
           
            Skill__c skill1 = createSkill('SAP MM');
            Skill__c skill2 = createSkill('Windchill SAP');
            Skill__c skill3 = createSkill('.Net Developer');
            insert new List<Skill__c>{ skill1, skill2, skill3 };
               
            Resource__c resource1 = createResource();
            Resource__c resource2 = createResource();
            Resource__c resource3 = createResource();
            insert new List<Resource__c>{ resource1, resource2, resource3 };
               
            Skill_Resource__c skillRes1 = createSkillResource(resource1.Id, skill1.Id);
            Skill_Resource__c skillRes2 = createSkillResource(resource2.Id, skill2.Id);
            Skill_Resource__c skillRes3 = createSkillResource(resource3.Id, skill3.Id);
            insert new List<Skill_Resource__c>{ skillRes1, skillRes2, skillRes3 };

            Test.startTest();
            List<ATSWrapper> myResult = GetResourceSkillController.fetchResources(jobPost.Id);
            Test.stopTest();
           
            System.assertNotEquals(null, myResult, 'Result should not be null');
            System.assertEquals(2, myResult.size(), 'Expected 2 matching resources');
        }
    }

    @IsTest
    public static void oneJobPostingWithNoResource() {
        User adminUser = createAdminUser('Admin', 'User');
        insert adminUser;
        
        assignPermissionSetForAdmin(adminUser);

        System.runAs(adminUser) {
            Client__c clientS2 = createClient();
            insert clientS2;
           
            Job_Posting__c jobPostS2 = createJobPosting(clientS2.Id);
            insert jobPostS2;
           
            Skill__c skill1S2 = createSkill('SAP MM');
            Skill__c skill2S2 = createSkill('Windchill SAP');
            Skill__c skill3S2 = createSkill('.Net Developer');
            insert new List<Skill__c>{ skill1S2, skill2S2, skill3S2 };
               
            Test.startTest();
            List<ATSWrapper> myResult = GetResourceSkillController.fetchResources(jobPostS2.Id);
            Test.stopTest();
           
            System.assertEquals(null, myResult, 'myResult should be null when no resources match');
        }
    }

    // ---------- Helper Methods ----------

    private static Client__c createClient() {
        return new Client__c(
            Name = 'Test Company ' + DateTime.now().format('hh.mm.ss.SSS'),
            Email__c = 'Companyemail@' + DateTime.now().format('hh.mm.ss.SSS') + '.com',
            Phone_Number__c = '1234567895',
            Website__c = 'www.TestCompany.com',
            City__c = 'Columbus',
            Country__c = 'USA'
        );
    }
   
    private static Resource__c createResource() {
        return new Resource__c(
            Name = 'Test Resource ' + DateTime.now().format('hh.mm.ss.SSS'),
            Phone_Number__c = '1234567898',
            Primary_Email__c = 'testresourceemail@' + DateTime.now().format('hh.mm.ss.SSS'),
            Source__c = 'Dice',
            City__c = 'San Antonio, TX',
            Country__c = 'USA'
        );
    }
   
    private static Job_Posting__c createJobPosting(Id clientId) {
        return new Job_Posting__c(
            Job_Title__c = 'Test Job Title',
            Client__c = clientId,
            Job_Status__c = 'Open',
            Min_Experience__c = 2,
            Max_Experience__c = 4,
            Job_Description__c = 'Test Job Description',
            Salary_Range__c = '200K to 300K',
            Work_Hours__c = '8 hours',
            Skills__c = 'SAP MM; Windchill SAP',
            Client_Job_Id__c = '1234'
        );
    }
   
    private static Skill__c createSkill(String name) {
        return new Skill__c(Name = name);
    }
   
    private static Skill_Resource__c createSkillResource(Id resourceId, Id skillId) {
        return new Skill_Resource__c(
            Resource__c = resourceId,
            Skill__c = skillId,
            Level_of_Experience__c = 'Beginner',
            Experience__c = '1 year 2 months'
        );
    }

    private static User createAdminUser(String firstName, String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        return new User(
            Email = 'testEmail@' + Datetime.now().format('hh.mm.ss.SSS') + '.com',
            ProfileId = p.Id,
            Username = 'testUserName' + Datetime.now().format('hh.mm.ss.SSS') + '@testmail.com',
            Alias = 'abcd',
            CommunityNickname = 'nickName' + Datetime.now().format('hh.mm.ss.SSS'),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            FirstName = firstName,
            LastName = lastName,
            Phone = '9876543210'
        );
    }

    private static void assignPermissionSetForAdmin(User u) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ATS_App_Permission_set_new' LIMIT 1];
        insert new PermissionSetAssignment(
            PermissionSetId = ps.Id,
            AssigneeId = u.Id
        );
    }
}
