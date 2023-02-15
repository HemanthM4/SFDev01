@isTest
public class epr_create_edit_delete_controller_test {
    
    static testmethod void erp_test(){
        

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
        
                
        Account acc = new Account();
        acc.Name = 'Invoice Test';
        acc.First_Name__c = 'Invoice';
        acc.Last_Name__c = 'Test';
        acc.Email__c = 'dasfrog.web@gmail.com';
        acc.Invoicing_Email_Address__c = 'dasfrog.web@gmail.com';
        acc.Account_Type__c = 'Cash';
        acc.Account_Status__c = 'Open';
        acc.BillingStreet = '8 Allington way';
        acc.BillingCity = 'Swanley';
        acc.BillingCountry = 'United Kingdom';
        acc.BillingPostalCode = 'BR8 8FG';
        acc.Access_Details__c = '2333';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = acc.First_Name__c;
        con.LastName = acc.Last_Name__c;
        con.Email = acc.Email__c;
        insert con;
        
        Site__c site = new Site__c();
        site.Name = acc.Name +'-'+ acc.BillingStreet+'-'+ acc.BillingPostalCode;
        site.Site_Street__c = acc.BillingStreet;
        site.Access_Details__c = acc.Access_Details__c;
        site.Site_PostalCode__c = acc.BillingPostalCode;
        site.Site_City__c = acc.BillingCity;
        site.Account__c = acc.Id;
        site.Primary_Site_Contact__c = con.id;
        insert site;

        
        WorkType wt = new WorkType();
        wt.DurationType = 'Hours';
        wt.EstimatedDuration = 2;
        wt.Name = 'tmp';
        insert wt;
        
        Job__c job = new Job__c();
        job.Account__c = acc.id;
        job.Job_Type__c = wt.id;
        Job.Site__c = site.id;
        insert job;
        
       	Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = job.Id;
        cct.Record_Type__c = 'F';
        cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
        cct.Chargeable_Duration_R1__c = 1;
        cct.Chargeable_Duration_R2__c = 1;
        cct.Chargeable_Duration_R3__c = 1;
        cct.Call_Out_Fee__c = 0;
        cct.Charge_List_Price_Services__c = 1000;
        cct.Rate_of_Pay__c = 99;
        cct.Discount_Manual_Percentage__c = 0;
        insert cct;
        
        cct.Discount_Manual_Percentage__c = 5;
        update cct;
        
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = job.Id;
        wo.WorkTypeId = wt.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Duration = wt.EstimatedDuration;
        wo.country = 'United Kingdom';
        wo.Scope_of_Works_Amended_by_Operative__c = 'test';
        wo.Arrival_Window_Start_Date_Time__c = system.now();
        wo.Arrival_Window_End_Date_Time__c = system.now();
        wo.Costs_and_Charges__c = cct.id;
        insert wo;
        
        Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
        epr.Service_Resource__c = sr1.id;
        epr.Job__c = job.id;
        epr.Work_Order__c = wo.id;
        epr.Chargeable_Units_R1__c = 1;
        epr.Rate_of_Charge_R1__c = 100;
        epr.Pay_Materials__c = 0;
        epr.Pay_Fixed_Price__c = 50;
        epr.Status__c = 'New';
        insert epr;
        
        epr.Pay_Materials__c = 10;
        update epr;
        
        delete epr;
    }

}