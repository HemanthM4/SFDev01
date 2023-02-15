@isTest
public class PORTAL_WorkOrderSearchCtrlTest {
    static testMethod void workTest(){
           Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u){
            Account acc = new Account();
            acc.name =' test';
            acc.BillingStreet = 'Second street'; 
            insert acc;
            
            Contact con = new Contact();
            con.LastName = 'Peter';
            insert con;
            
            String RecordTypeIdContact = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            ServiceResource SR = new ServiceResource();
            SR.Email__c = ' Test@gmail.com';
            SR.Estimate_Limit__c = 100; 
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
            
            //  String RecordTypeIdWorkType = Schema.SObjectType.WorkType.getRecordTypeInfosByName().get('Reactive').getRecordTypeId();
            WorkType WT = new WorkType();
            WT.Name = 'Test';
            WT.EstimatedDuration = 2;
            insert WT;
            
            Case cs = new Case();
            cs.Status = 'Complaint';
            cs.Description = 'anything';
            cs.ContactId = con.Id;
            cs.Origin = 'Community';
            insert cs;
            
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
            
             Engineer_Pay_Requisition__c EPR1 = new Engineer_Pay_Requisition__c();
            EPR1.Job__c = job.Id;
            EPR1.Pay_Fixed_Price__c = 10;
            EPR1.Pay_Materials__c = 20;
            EPR1.Pay_Lead_Fee__c = 30;
            EPR1.Rate_of_Pay__c = 10;
            EPR1.Status__c = 'New';
            EPR1.Discount_Value__c = 5;
            EPR1.Chargeable_Units_R1__c = 1;
            EPR1.Chargeable_Units_R2__c = 2;
            EPR1.Chargeable_Units_R3__c = 3;
            EPR1.Rate_of_Charge_R1__c = 4;
            EPR1.Rate_of_Charge_R2__c = 5;
            EPR1.Rate_of_Charge_R3__c = 6;
            EPR1.Service_Resource__c = SR.Id;
            insert EPR1;
            
            ServiceAppointment SA = new ServiceAppointment();
            SA.Status	 ='Visit Complete';
            SA.ParentRecordId = WO.id;
            SA.SchedStartTime = System.today();
            SA.SchedEndTime = System.today()+1;
            SA.Allocated_Engineer__c =SR.id;
            SA.Engineer_Pay_Requisition__c =EPR1.id;
          //  SA.AccountId = acc.id;
            insert SA;
        Test.startTest();
        List<Account> w1 = PORTAL_WorkOrderSearchController.searchRecordsId(acc.id);
        List<ServiceAppointment> w2 = PORTAL_WorkOrderSearchController.searchRecords('');
        Test.Stoptest();
    }
    }
}