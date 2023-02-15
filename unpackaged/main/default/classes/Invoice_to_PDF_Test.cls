@isTest
public class Invoice_to_PDF_Test {
    
    public static testmethod void methodOneTest(){
        
        ID networkId = Network.getNetworkId();
        
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
        acc.DRC_Applies__c = TRUE;
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
        wo.WorkTypeId = wt.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Duration = wt.EstimatedDuration;
        wo.country = 'United Kingdom';
        wo.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('WorkOrder','Reactive');     
        wo.Costs_and_Charges__c = cct.id;
        insert wo;
        
        Test.startTest();
        job.Generate_Deposit_Invoice__c = TRUE;
        update job;
        
        job.Generate_Invoice__c = TRUE;
        update job; 
        
        List<Id> ids = InvoiceController.getGLC('Fixed Price',job.Account__r.Account_Type__c,job.Job_Type__r.Trade__c,job.Account__r.RecordType.name);
        Customer_Invoice__c inv = InvoiceController.createInvoice(job,ids,'Deposit');
        insert inv;
        
        Invoice_to_PDF.genPDF(inv.Id, 0, networkId);Invoice_to_PDF.genPDF(inv.Id, 1, networkId);
        Invoice_to_PDF.genPDF(inv.Id, 2, networkId);Invoice_to_PDF.genPDF(inv.Id, 3, networkId);
        Invoice_to_PDF.genPDF(inv.Id, 4, networkId);Invoice_to_PDF.genPDF(inv.Id, 5, networkId);
        Invoice_to_PDF.genPDF(inv.Id, 6, networkId);Invoice_to_PDF.genPDF(inv.Id, 7, networkId);
        Invoice_to_PDF.genPDF(inv.Id, 8, networkId);Invoice_to_PDF.genPDF(inv.Id, 9, networkId);
    }
}