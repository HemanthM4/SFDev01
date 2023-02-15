@isTest
public class Phase_2_SR_activation_change_triggerTest {
   static testmethod void  triggerTest(){
                    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        User u1 = new User(Alias = 'stand1', Email='standarduser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='wt_list_test_1@testorg.com');
        insert u1;
        
        ServiceResource sr1 = new ServiceResource();

        sr1.RelatedRecordId = u1.Id;
        sr1.Name = 'test 01res';
        sr1.FirstName__c = 'test';
        sr1.LastName__c = '01res';
        sr1.IsActive = True;
        sr1.ResourceType = 'T';
        sr1.Engineer_Role__c = 'Service_Resource';
        sr1.Rate_of_Pay_Tier__c = 'Tier 2';
        sr1.Estimate_Limit__c = 1000;
        
        insert sr1;
          
        
        
        WorkType wt = new WorkType();
        wt.DurationType = 'Hours';
        wt.EstimatedDuration = 2;
        wt.Name = 'tmp';
        wt.Qualified_Resource_Count__c = 0;
        wt.Qualified_Inactive_Resource_Count__c = 0;
        insert wt;
        
        List<Skill> skills = [SELECT id FROM Skill LIMIT 2 ];
        
        SkillRequirement sreq = new SkillRequirement();
        sreq.RelatedRecordId = wt.id;
        sreq.SkillId = skills[0].id;
        insert sreq;
        
        
        ServiceResourceSkill srskill1 = new ServiceResourceSkill();
        srskill1.ServiceResourceId = sr1.id;
        srskill1.SkillId = skills[0].id;
        srskill1.EffectiveStartDate = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
         
        Test.startTest();
        decimal actual, expected;

        
        insert srskill1;
        actual = [SELECT id, Qualifying_WTs_Count__c FROM ServiceResource WHERE Name='test 01res' LIMIT 1 ].Qualifying_WTs_Count__c;
        System.assertEquals(1, actual);
        ServiceResourceSkill srskill2 = new ServiceResourceSkill();
        srskill2.ServiceResourceId = sr1.id;
        srskill2.SkillId = skills[1].id;
        srskill2.EffectiveStartDate = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
        insert srskill2;
        

        sr1.IsActive = FALSE;
        update sr1;
        actual = [SELECT id, Qualified_Resource_Count__c FROM WorkType WHERE Name = 'tmp' LIMIT 1 ].Qualified_Resource_Count__c;
        System.assertEquals(0, actual);
            
            
        sr1.IsActive = TRUE;
        update sr1;
        actual = [SELECT id, Qualified_Resource_Count__c FROM WorkType WHERE Name = 'tmp' LIMIT 1 ].Qualified_Resource_Count__c;
        System.assertEquals(1, actual);
        
        SkillRequirement sreq2 = new SkillRequirement();
        sreq2.RelatedRecordId = wt.id;
        sreq2.SkillId = skills[0].id;
      //  insert sreq2;
         



        
        Test.stopTest();
    }
}