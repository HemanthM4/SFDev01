@istest
public class wt_resources_list_controller_test {

    static testmethod void wt_resource_list_test(){
        
        
        WorkType wt = new WorkType();
        wt.DurationType = 'Hours';
        wt.EstimatedDuration = 2;
        wt.Name = 'tmp';
        wt.Qualified_Resource_Count__c = 0 ;
        wt.Qualified_Inactive_Resource_Count__c = 0;
        insert wt;
        
        
        Test.startTest();
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(wt);
  		//myControllerExtension testAccPlan = new myControllerExtension(sc);

  		PageReference pageRef = Page.Phase_2_wt_resource_list_page; // Add your VF page Name here
  		pageRef.getParameters().put('id', String.valueOf(wt.Id));
  		Test.setCurrentPage(pageRef);

        wt_resources_list_controller wt_controller = new wt_resources_list_controller();
               
        
        SkillRequirement sreq = new SkillRequirement();
        
        sreq.RelatedRecordId = wt.id;
        sreq.SkillId = '0C50N000000fxpMSAQ';

        insert sreq;

       
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        User u1 = new User(Alias = 'stand1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='wt_list_test_1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'stand2', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='wt_list_test_2@testorg.com');
        insert u2;
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
        
        
        ServiceResource sr2 = new ServiceResource();
        sr2.RelatedRecordId = u2.Id;
        sr2.Name = 'test 01res';
        sr2.FirstName__c = 'test';
        sr2.LastName__c = '01res';
        sr2.IsActive = True;
        sr2.ResourceType = 'T';
        sr2.Engineer_Role__c = 'Service_Resource';
        sr2.Rate_of_Pay_Tier__c = 'Tier 2';
        sr2.Estimate_Limit__c = 1000;

        insert sr1;
        insert sr2;



        
        
        
        ServiceResourceSkill srskill2 = new ServiceResourceSkill();

        ServiceResourceSkill srskill1 = new ServiceResourceSkill();

        srskill1.ServiceResourceId = sr1.id;
        srskill1.SkillId = sreq.SkillId;
        srskill1.EffectiveStartDate = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
        
        
        srskill2.ServiceResourceId = sr2.id;
        srskill2.SkillId = sreq.SkillId;
        srskill2.EffectiveStartDate = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
        

        insert srskill1;
        insert srskill2;
        
   		Test.setCurrentPage(pageRef);

        wt_resources_list_controller wt_controller2 = new wt_resources_list_controller();

        sr2.IsActive = FALSE;       
        update sr2;

        sr2.IsActive = TRUE;       
        update sr2;

        delete srskill2;
        delete sreq;

        Test.stopTest();
        
           
        
    }
    
}