@isTest
public class UpdateCustomerInvoicesBatch_ScheduleTest {
    public static testMethod void testschedule() {
        Test.StartTest();
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        
        Rate_Card_Trade__c rct = new Rate_Card_Trade__c();
        rct.Rate_Card__c = rcaStand.Id;
        rct.Trade__c = tradeRec.Id;
        rct.Charge_R1__c = 10;rct.Charge_R2__c = 20;rct.Charge_R3__c= 30;
        rct.Pay_Tier_1__c = 4;rct.Pay_Tier_2__c = 4;
        rct.Pay_Tier_3__c= 5;rct.Pay_Tier_4__c = 6;
        rct.Pay_Tier_5__c = 3;rct.Pay_Tier_6__c = 7;
        rct.Pay_Tier_7__c = 21;rct.Pay_Tier_8__c = 9;
        rct.Pay_Tier_9__c = 25;rct.Pay_Tier_10__c = 12;
        insert rct;
        
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
        
        
        String wt_trade = (WorkType.Trade__c.getDescribe().getPicklistValues())[0].getLabel();
        
        WorkType wt = new WorkType();
        wt.DurationType = 'Hours';
        wt.EstimatedDuration = 2;
        wt.Name = 'tmp';
        wt.Trade__c = wt_trade;
        insert wt;
        /*
Rate_Cards__c rc = new Rate_Cards__c();  
rc.Account__c = acc.Id;
rc.Trade__c = wt_trade;
insert rc;
*/      
        
        
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
        wo.Trade_Rate__c= rct.Id;
        insert wo;
        
        
        job.Generate_Deposit_Invoice__c = TRUE;
        update job;
        
        job.Generate_Invoice__c = TRUE;
        update job; 
        
        List<Customer_Invoice__c> cirec = [select id,Exchequer_Export__c from Customer_Invoice__c  where Job__c =:  job.id limit 1];
        List<Customer_Invoice__c> cireclist = new List<Customer_Invoice__c>();
        for(Customer_Invoice__c ciinv : cirec ){
            ciinv.Exchequer_Export__c = 'Not Sent';
            //ciinv.Sent_to_Exchequer__c = FALSE;
            cireclist.add(ciinv); 
        }
        update cireclist; 
        
        UpdateCustomerInvoicesBatch_Schedule sh = new UpdateCustomerInvoicesBatch_Schedule();
        sh.execute(null);  
        Test.stopTest();        
    }
    
}