@isTest
public class GSRSubmissionTriggerHandler_Test {
    
    static testmethod void gsrSubmissionTest(){
        
        ID networkId = Network.getNetworkId();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        
        String wt_trade = tradeRec.Name;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Trade__c rct2 = new Rate_Card_Trade__c();
        rct2.Rate_Card__c = rcaStand.Id;
        rct2.Trade__c = tradeRec.Id;
        rct2.Charge_R1__c = 10;rct2.Charge_R2__c = 20;rct2.Charge_R3__c= 30;
        rct2.Pay_Tier_1__c = 4;rct2.Pay_Tier_2__c = 4;
        rct2.Pay_Tier_3__c= 5;rct2.Pay_Tier_4__c = 6;
        rct2.Pay_Tier_5__c = 3;rct2.Pay_Tier_6__c = 7;
        rct2.Pay_Tier_7__c = 21;rct2.Pay_Tier_8__c = 9;
        rct2.Pay_Tier_9__c = 25;rct2.Pay_Tier_10__c = 12;
        insert rct2;
        
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
        wt.Trade__c = wt_trade;
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
        wo.Trade_Rate__c = rct2.Id;
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = wo.id;
        sa.ContactId = con.id;
        sa.Duration = 1;
        sa.Contact_Email__c= 'test.email@asepct.co.uk';
        sa.EarliestStartTime = system.now();
        sa.DueDate = system.now()+1;
        sa.SchedStartTime = system.now();
        sa.SchedEndTime =system.now()+1;
        sa.status='New';                
        sa.Contact_Email__c = acc.Email__c;
        sa.EarliestStartTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 7,0, 0);
        sa.DueDate = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 8, 0, 0);
        sa.SchedStartTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 7, 0, 0);
        sa.SchedEndTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 8, 0, 0);
        sa.Cancellation_Invoice_Raised__c = FALSE;
        sa.SA_Status_Cancelled_Customer_Email_Sent__c = TRUE;
        insert sa;
        
        GSR_Submission__c gsrSub = new GSR_Submission__c();
        gsrSub.Work_Order_Lookup__c = wo.Id;
        gsrSub.Service_Appointment_Lookup__c = sa.Id;
		insert gsrSub;
        
        GSR_Appliance_Results__c gsrAppRes = new GSR_Appliance_Results__c();
        gsrAppRes.GSR_Submission__c = gsrSub.Id;
        insert gsrAppRes;
        
        GSR_Installation_Fault__c gasrInstFault = new GSR_Installation_Fault__c();
        gasrInstFault.GSR_Submission__c = gsrSub.Id;
        insert gasrInstFault;
        
        gsrSub.Completed_Date_Time__c = System.today() + 1;
        gsrSub.Report_Received_By_Type__c = 'Agent';
        update gsrSub;
    }
}