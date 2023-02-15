@isTest
public class FileUploadControllerTest {
static testMethod void calendarMethod(){
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u){
            Account acc = new Account();
            acc.name =' test';
            acc.BillingStreet = 'First street'; 
            insert acc;
            
            Contact con = new Contact();
            con.LastName = 'John';
            insert con;
            
            String RecordTypeIdContact = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            ServiceResource SR = new ServiceResource();
            SR.Email__c = ' Test@gmail.com';
            SR.Estimate_Limit__c =100; 
            SR.Engineer_Role__c ='Service_Resource';
            SR.ResourceType = 'T';
            SR.Rate_of_Pay_Tier__c = 'Tier 2';
            SR.RelatedRecordId =u.id;
            
            SR.Name ='Test';
            insert SR;
            
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
            
            Costs_and_Charges__c costs = new Costs_and_Charges__c();
            costs.Job__c = job.id;
            insert costs;
            
            //String RecordTypeIdWorkType = Schema.SObjectType.WorkType.getRecordTypeInfosByName().get('Reactive').getRecordTypeId();
            WorkType WT = new WorkType();
            WT.Name = 'Test';
            WT.EstimatedDuration = 2;
            insert WT;
            
            
            
            String RecordTypeIdWorkOrder = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Reactive').getRecordTypeId();
            WorkOrder WO = new WorkOrder();
            WO.Subject = 'Testing';
            WO.Status = 'Pending';
            WO.AccountId = acc.id;
            WO.Costs_and_Charges__c = costs.id;
            WO.Job__c = job.id;
            WO.WorkTypeId = WT.id;
            WO.Priority = 'Low';
            WO.Service_Appointment_Status__c = 'Dispatched';
            WO.ContactId = con.id;
            WO.Service_Resource__c = SR.id;
            WO.Duration = 2.00;
            WO.Description = 'Test'; 
            WO.Access_Details__c = 'code 1245';
            WO.Requested_Date__c = System.today();
            WO.RecordTypeId =RecordTypeIdWorkOrder;
            insert WO;
            
            ServiceAppointment SA = new ServiceAppointment();
            SA.Status	 ='Visit Complete';
            SA.ParentRecordId = WO.id;
            SA.SchedStartTime = System.today();
            SA.SchedEndTime = System.today()+1;
            SA.Allocated_Engineer__c =SR.id;
            insert SA;
            Test.startTest();
            String s = FileUploadController.saveFile(null,'Test','fsdsgfdgdfbgfngfn','','',SA.id);
            Test.stopTest();
        }
}
}