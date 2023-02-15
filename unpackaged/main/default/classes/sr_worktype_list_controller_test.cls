@istest
public class sr_worktype_list_controller_test {

    static testmethod void sr_worktype_list_test(){
        
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
          
     
        ServiceResourceSkill srskill1 = new ServiceResourceSkill();

        srskill1.ServiceResourceId = sr1.id;
        srskill1.SkillId = '0C50N000000fxpMSAQ';
        srskill1.EffectiveStartDate = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
         
        insert srskill1;
        
        
        WorkType wt = new WorkType();
        wt.DurationType = 'Hours';
        wt.EstimatedDuration = 2;
        wt.Name = 'tmp';
        insert wt;
        
        
                SkillRequirement sreq = new SkillRequirement();
        
        sreq.RelatedRecordId = wt.id;
        sreq.SkillId = '0C50N000000fxpMSAQ';

        insert sreq;

        
        Test.startTest();
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(sr1);
  		//myControllerExtension testAccPlan = new myControllerExtension(sc);

  		PageReference pageRef = Page.Phase_2_sr_worktype_list_page; // Add your VF page Name here
  		pageRef.getParameters().put('id', String.valueOf(sr1.Id));
  		Test.setCurrentPage(pageRef);

        sr_worktype_list_controller sr_controller = new sr_worktype_list_controller();
               
        

       

        
   		Test.setCurrentPage(pageRef);

        wt_resources_list_controller wt_controller2 = new wt_resources_list_controller();
               
        Test.stopTest();
        
           
        
    }
    
}