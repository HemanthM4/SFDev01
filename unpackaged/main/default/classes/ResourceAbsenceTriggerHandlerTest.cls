@isTest
public class ResourceAbsenceTriggerHandlerTest {
    Static testmethod void insertuodate(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u){
            String RecordTypeIdContact = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            ServiceResource SR = new ServiceResource();
            SR.Email__c = ' Test@gmail.com';
            SR.Engineer_Role__c ='Service_Resource';
            SR.ResourceType = 'T';
            SR.Rate_of_Pay_Tier__c = 'Tier 2';
            SR.RelatedRecordId =u.id;
            SR.Estimate_Limit__c =100;
            SR.Name ='Test';
            insert SR;
            SR.IsActive = true;
            Update SR;
            OperatingHours oh = new OperatingHours();
            oh.Name = 'Day';
            insert oh;
            
            OperatingHours oh1 = new OperatingHours();
            oh1.Name = 'Aspect Operating Hours (24/7/365)';
            insert oh1;
            
            ResourceAbsence ra = new ResourceAbsence();
            ra.Type ='Meeting';
            
            ra.Start = SYstem.today();
            ra.End = System.today()+1;
            ra.ResourceId =SR.id;
            ra.Status__c ='Approved';
            insert ra;
            
            ResourceAbsence ra1 = new ResourceAbsence();
            ra1.Type ='Meeting';
            
            ra1.Start = SYstem.today();
            ra1.End = System.today()+1;
            ra1.ResourceId =SR.id;
            ra1.Status__c ='Not yet Approved';
            ra1.FSL__Approved__c = true;
            insert ra1;
            ra1.FSL__Approved__c = false;
            update ra1;
            ra1.FSL__Approved__c = true;
            update ra1;
            
            
            ResourceAbsence ra2 = new ResourceAbsence();
            ra2.Type ='Meeting';
            
            ra2.Start = SYstem.today();
            ra2.End = System.today()+4;
            ra2.ResourceId =SR.id;
            ra2.Status__c ='Rejected';
            
            insert ra2;
        }
    }
    
}