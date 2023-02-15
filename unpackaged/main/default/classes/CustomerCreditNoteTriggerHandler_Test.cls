@isTest
public class CustomerCreditNoteTriggerHandler_Test {
    
    static testmethod void creditNoteInsertTest(){
        
        ID networkId = Network.getNetworkId();
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Account acc = new Account();
        acc.Name = 'CreditNote Test';
        acc.First_Name__c = 'creditNote';
        acc.Last_Name__c = 'Test';
        acc.Email__c = 'test@gmaill.com';
        acc.Invoicing_Email_Address__c = 'test@gmaill.com';
        acc.Account_Type__c = 'Cash';
        acc.Account_Status__c = 'Open';
        acc.BillingStreet = '8 Allington way';
        acc.BillingCity = 'Swanley';
        acc.BillingCountry = 'United Kingdom';
        acc.BillingPostalCode = 'BR8 8FG';
        acc.Access_Details__c = '2333';
        acc.DRC_Applies__c = TRUE;
        acc.Rate_Card__c = rcaStand.Id;
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
        wt.Trade__c = (WorkType.Trade__c.getDescribe().getPicklistValues())[0].getLabel();
        insert wt;
        
        Job__c job = new Job__c();
        job.Account__c = acc.id;
        job.Job_Type__c = wt.id;
        Job.Site__c = site.id;
        job.Job_Raised_by__c = con.Id;
        insert job;
        
        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = job.Id;
        cct.Record_Type__c = 'F';
        cct.Hourly_Charge_R1__c = 80;
        cct.Hourly_Charge_R2__c = 80;
        cct.Hourly_Charge_R3__c = 80;
        cct.Chargeable_Duration_R1__c = 1;
        cct.Chargeable_Duration_R2__c = 1;
        cct.Chargeable_Duration_R3__c = 1;
        cct.Call_Out_Fee__c = 10;
        cct.Charge_List_Price_Services__c = 1000;
        cct.Rate_of_Pay__c = 99;
        cct.Discount_Manual_Percentage__c = 5;
        cct.Charge_Total_Van_Stock_Product_Required__c = 10;
        cct.Charge_ULEZ__c = 5;
        cct.Charge_Other_Item__c = 12;
        cct.Include_in_estimate__c = TRUE;
        cct.Discount_Manual_Override__c = TRUE;
        cct.Charge_Collection_Fee__c = 30;
        insert cct;
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = job.Id;
        wo.WorkTypeId = wt.Id;
        wo.Description = 'Blah blah';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Duration = wt.EstimatedDuration;
        wo.country = 'United Kingdom';
        wo.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('WorkOrder','Reactive');     
        wo.Costs_and_Charges__c = cct.id;
        insert wo;
        
        Customer_Invoice__c custInvoice = new Customer_Invoice__c();
        custInvoice.Job__c = job.Id;
        custInvoice.Account__c = acc.Id;
        custInvoice.Date__c = DATE.today();
        custInvoice.Account_Email_Address__c = 'test@test.com';
        custInvoice.Sum_of_Payments__c = 50;
        custInvoice.Job_Contact__c = job.Job_Raised_by__c;
        custInvoice.Status__c = 'Outstanding';
        custInvoice.Exchequer_Export__c = 'Not Sent';
        insert custInvoice;
        
        Customer_Credit_Note__c ccn = new Customer_Credit_Note__c();
        ccn.Account_Details__c = acc.Id;
        ccn.Account_Email__c = 'test@test.com';
        ccn.Amount__c = 20;
        ccn.Date__c = DATE.today();
        ccn.Customer_Invoice__c = custInvoice.Id;
        insert ccn;
    }
}