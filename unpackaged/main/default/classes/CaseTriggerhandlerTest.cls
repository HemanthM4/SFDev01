@isTest
public class CaseTriggerhandlerTest 
{
    static testMethod void CaseTriggerTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u) {
            
              
     //   EmailTemplate e = new EmailTemplate (developerName = 'CaseCreation', FolderId = u.Id,  TemplateType= 'Text', Name = 'Case Creation'); // plus any other fields that you want to set

//insert e;
           Account acc = new Account();
           acc.name =' test';
           acc.BillingStreet = 'First street'; 
           insert acc;
            
            Account acc1 = new Account();
           acc1.name =' Use For Cases';
           acc1.BillingStreet = 'First street'; 
           insert acc1;
            
             Contact con = new Contact();
            con.LastName = 'One';
            insert con;
            
            Contact con1 = new Contact();
            con1.LastName = 'Use This For Cases';
            insert con1;
            
            Site__c site = new Site__c();
            site.Account__c  = acc.id;
            site.Name = 'test';
            site.Site_Street__c ='Test';
            site.Site_PostalCode__c ='12345';
            Site.Site_Country__c ='Uk';  
             site.Primary_Site_Contact__c =con.id;
            insert site; 
            
            Job__c job = new Job__c();
            Job.Account__c = acc.id;
            Job.Site__c =site.id;
            insert Job;
               
            String RecordTypeIdContact = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            ServiceResource SR = new ServiceResource();
            SR.Email__c = ' Test@gmail.com';
            SR.Engineer_Role__c ='Service_Resource';
            SR.ResourceType = 'T';
            SR.Rate_of_Pay_Tier__c = 'Tier 2';
            SR.RelatedRecordId =u.id;
            SR.Name ='Test';
            insert SR;
        
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
            Case cs = new Case();
            cs.Status = 'Complaint';
            cs.Description = 'anything';
            cs.ContactId = con.Id;
            cs.Origin = 'Community';
            cs.SuppliedEmail = u.Email;
            cs.RecordTypeId =devRecordTypeId;
            cs.Job__c = Job.id;
             cs.Assigned_to__c = u.id;
           //  cs.Subject_Category__c = 'a';
           // insert cs; 
            
            Case cs1 = new Case();
            cs1.Status = 'Complaint';
            cs1.Description = '@-@EmailtoCase /-/';
            cs1.Subject = '@-@EmailtoCase /-/';
            cs1.ContactId = con.Id;
            cs1.Origin = 'Community';
            cs1.SuppliedEmail = u.Email;
            cs1.Service_Resource__c =SR.Id;
             cs1.Service_Resource__c =SR.Id;
             cs1.RecordTypeId =devRecordTypeId;
             cs1.Job__c = Job.id;
          //  cs1.Subject_Category__c = 'a';
            insert cs1;
            cs1.Status = 'Closed';
            cs1.Assigned_to__c = u.id;
            update cs1;
            
              
          
            
              Case cs12 = new Case();
            cs12.Status = 'Complaint';
            cs12.Description = ' Test @-@EmailtoCase /-/ Service Appointment';
            cs12.Subject = 'Test @-@EmailtoCase /-/ '+SR.id;
            cs12.ContactId = con.Id;
            cs12.Origin = 'Community';
            cs12.SuppliedEmail = u.Email;
            cs12.Service_Resource__c =SR.Id;
            cs12.RecordTypeId =devRecordTypeId;
            cs12.Job__c = Job.id;
           //  cs12.Subject_Category__c = 'a';
            insert cs12;
            
            Case cs123 = new Case();
            cs123.Status = 'Complaint';
            cs123.Description = '@-@EmailtoCase /-/';
            cs123.Subject = '@-@EmailtoCase /-/';
            cs123.ContactId = con.Id;
            cs123.Origin = 'Community';
            cs123.SuppliedEmail = u.Email;
            cs123.Service_Resource__c =SR.Id;
            cs123.RecordTypeId =devRecordTypeId;
            cs123.Job__c = Job.id;
           //  cs123.Subject_Category__c = 'a';
            insert cs123;
            
            CaseTriggerhandler.sendCustomnotification(cs123.id,'Case is CLosed');
            delete cs123;
        }
    }
}