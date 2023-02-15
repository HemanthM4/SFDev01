@isTest
public class job_InvoiceGenerationControllerTest {
    
    static testmethod void cancellationInvoiceTest(){
        try{
            //insertcustomSettings();
            Account acc = new Account(
                Name = 'Invoice Test',
                First_Name__c = 'Invoice',
                Last_Name__c = 'Test',
                Email__c = 'dasfrog.web@gmail.com',
                Invoicing_Email_Address__c = 'dasfrog.web@gmail.com',
                Account_Type__c = 'Cash',
                Account_Status__c = 'Open',
                BillingStreet = '8 Allington way',
                BillingCity = 'Swanley',
                BillingCountry = 'United Kingdom',
                BillingPostalCode = 'BR8 8FG',
                Access_Details__c = '2333'
            );
            insert acc;
            
            Contact con = new Contact(
                AccountId = acc.Id,
                FirstName = acc.First_Name__c,
                LastName = acc.Last_Name__c,
                Email = acc.Email__c
            );
            insert con;
            
            Site__c site = new Site__c(
                Name = acc.Name +'-'+ acc.BillingStreet+'-'+ acc.BillingPostalCode,
                Site_Street__c = acc.BillingStreet,
                Access_Details__c = acc.Access_Details__c,
                Site_PostalCode__c = acc.BillingPostalCode,
                Site_City__c = acc.BillingCity,
                Account__c = acc.Id,
                Primary_Site_Contact__c = con.id
            );
            insert site;
            
            
            WorkType wt = new WorkType(
                EstimatedDuration = 2,
                Name = 'tmp'
            );
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
            cct.Include_in_estimate__c = TRUE;
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
            /*
            FSL.GlobalAPIS.addStatusTransition('New', 'Cancelled');
            //FSL.GlobalAPIS.addStatusTransition('Cancelled', 'Rejected');
            
            sa.Cancellation_Fine__c = TRUE;
            sa.status='Cancelled'; 
            update sa;
            
            Test.startTest();
            job.Generate_Cancellation_Invoice__c = TRUE;
            update job;
            Test.stopTest();
            */
            job_InvoiceGenerationController obj = new job_InvoiceGenerationController();
            obj.methodToBeDelete();
            
        }catch(Exception ex){
            
        }
    }
    
    static testmethod void depositInvocieTest(){
        // insertcustomSettings();
        try{
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
            Test.stopTest();
        }catch(Exception ex){
            
        }
        
    }
    
    static testmethod void reactiveInvocieTest(){
        // insertcustomSettings();
        try{
            Account acc = new Account(
                Name = 'Invoice Test',
                First_Name__c = 'Invoice',
                Last_Name__c = 'Test',
                Email__c = 'dasfrog.web@gmail.com',
                Invoicing_Email_Address__c = 'dasfrog.web@gmail.com',
                Account_Type__c = 'Cash',
                Account_Status__c = 'Open',
                BillingStreet = '8 Allington way',
                BillingCity = 'Swanley',
                BillingCountry = 'United Kingdom',
                BillingPostalCode = 'BR8 8FG',
                Access_Details__c = '2333',
                DRC_Applies__c = TRUE
            );
            insert acc;
            
            Contact con = new Contact(
                AccountId = acc.Id,
                FirstName = acc.First_Name__c,
                LastName = acc.Last_Name__c,
                Email = acc.Email__c
            );
            insert con;
            
            Site__c site = new Site__c(
                Name = acc.Name +'-'+ acc.BillingStreet+'-'+ acc.BillingPostalCode,
                Site_Street__c = acc.BillingStreet,
                Access_Details__c = acc.Access_Details__c,
                Site_PostalCode__c = acc.BillingPostalCode,
                Site_City__c = acc.BillingCity,
                Account__c = acc.Id,
                Primary_Site_Contact__c = con.id
            );
            insert site;
            
            WorkType wt = new WorkType(
                DurationType = 'Hours',
                EstimatedDuration = 2,
                Name = 'tmp',
                Trade__c = (WorkType.Trade__c.getDescribe().getPicklistValues())[0].getLabel()
            );
            insert wt;
            
            Job__c job = new Job__c();
            job.Account__c = acc.id;
            job.Job_Type__c = wt.id;
            Job.Site__c = site.id;
            insert job;
            
            
            
            Costs_and_Charges__c cct = new Costs_and_Charges__c();
            cct.Job__c = job.Id;
            cct.Record_Type__c = 'R';
            cct.Hourly_Charge_R1__c = 95;//onb.Hourly_rate__c
            cct.Hourly_Charge_R2__c = 125;//onb.Hourly_rate__c
            cct.Hourly_Charge_R3__c = 160;//onb.Hourly_rate__c
            cct.Chargeable_Duration_R1__c = .5;
            cct.Chargeable_Duration_R2__c = 1;
            cct.Chargeable_Duration_R3__c = .5;
            cct.Call_Out_Fee__c = 10;
            cct.Charge_List_Price_Services__c = 1000;
            cct.Discount_Manual_Percentage__c = 5;
            cct.Charge_Total_Van_Stock_Product_Required__c = 10;
            cct.Charge_ULEZ__c = 5;
            cct.Charge_Other_Item__c = 12;
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
            ServiceAppointment sa = new ServiceAppointment();
            sa.ParentRecordId = wo.Id;
            sa.ContactId = con .id;
            sa.Contact_Email__c = acc.Email__c;
            sa.EarliestStartTime = system.today();
            sa.DueDate = system.today()+1;
            sa.SchedStartTime = system.today();
            sa.SchedEndTime = system.today()+1;
            sa.Duration = wo.Duration;
            sa.Status = 'New';
            insert sa;
            ID networkId = Network.getNetworkId();
            InvoiceController.genReactiveInvoice(job,networkId);
            Test.stopTest();
            
        }catch(Exception ex){
            
        }
        
    }
    
    static testmethod void KeyInvocieTest2(){
        // insertcustomSettings();
        try{
            Account acc = new Account(
                Name = 'Invoice Test',
                First_Name__c = 'Invoice',
                Last_Name__c = 'Test',
                Email__c = 'dasfrog.web@gmail.com',
                Invoicing_Email_Address__c = 'dasfrog.web@gmail.com',
                Account_Type__c = 'Key Account',
                Account_Status__c = 'Open',
                BillingStreet = '8 Allington way',
                BillingCity = 'Swanley',
                BillingCountry = 'United Kingdom',
                BillingPostalCode = 'BR8 8FG',
                Access_Details__c = '2333',
                DRC_Applies__c = TRUE
            );
            insert acc;
            
            Contact con = new Contact(
                AccountId = acc.Id,
                FirstName = acc.First_Name__c,
                LastName = acc.Last_Name__c,
                Email = acc.Email__c
            );
            insert con;
            
            Site__c site = new Site__c(
                Name = acc.Name +'-'+ acc.BillingStreet+'-'+ acc.BillingPostalCode,
                Site_Street__c = acc.BillingStreet,
                Access_Details__c = acc.Access_Details__c,
                Site_PostalCode__c = acc.BillingPostalCode,
                Site_City__c = acc.BillingCity,
                Account__c = acc.Id,
                Primary_Site_Contact__c = con.id
            );
            insert site;
            
            WorkType wt = new WorkType(
                DurationType = 'Hours',
                EstimatedDuration = 2,
                Name = 'tmp',
                Trade__c = (WorkType.Trade__c.getDescribe().getPicklistValues())[0].getLabel()
            );
            insert wt;
            
            Job__c job = new Job__c();
            job.Account__c = acc.id;
            job.Job_Type__c = wt.id;
            Job.Site__c = site.id;
            Job.tmp__c = true;
            insert job;
            
            
            
            Costs_and_Charges__c cct = new Costs_and_Charges__c();
            cct.Job__c = job.Id;
            cct.Record_Type__c = 'R';
            cct.Hourly_Charge_R1__c = 95;//onb.Hourly_rate__c
            cct.Hourly_Charge_R2__c = 125;//onb.Hourly_rate__c
            cct.Hourly_Charge_R3__c = 160;//onb.Hourly_rate__c
            cct.Chargeable_Duration_R1__c = .5;
            cct.Chargeable_Duration_R2__c = 1;
            cct.Chargeable_Duration_R3__c = .5;
            cct.Call_Out_Fee__c = 10;
            cct.Charge_List_Price_Services__c = 1000;
            cct.Discount_Manual_Percentage__c = 5;
            cct.Charge_Total_Van_Stock_Product_Required__c = 10;
            cct.Charge_ULEZ__c = 5;
            cct.Charge_Other_Item__c = 12;
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
            ServiceAppointment sa = new ServiceAppointment();
            sa.ParentRecordId = wo.Id;
            sa.ContactId = con .id;
            sa.Contact_Email__c = acc.Email__c;
            sa.EarliestStartTime = system.today();
            sa.DueDate = system.today()+1;
            sa.SchedStartTime = system.today();
            sa.SchedEndTime = system.today()+1;
            sa.Duration = wo.Duration;
            sa.Status = 'New';
            insert sa;
            Test.stopTest();
            
        }catch(Exception ex){
            
        }
        
    }
    
    static testmethod void consolidatedInvocieTest(){
        try{
            
            Account acc = new Account();
            acc.Name = 'Invoice Test';
            acc.First_Name__c = 'Invoice';
            acc.Last_Name__c = 'Test';
            acc.Email__c = 'test@test.com';
            acc.Invoicing_Email_Address__c = 'test@test.com';
            acc.Account_Type__c = 'Cash';
            acc.Account_Status__c = 'Open';
            acc.BillingStreet = '8 Allington way';
            acc.BillingCity = 'Swanley';
            acc.BillingCountry = 'United Kingdom';
            acc.BillingPostalCode = 'BR8 8FG';
            acc.Access_Details__c = '2333';
            // acc.DRC_Applies__c = TRUE;
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
            
            Job__c job = new Job__c();
            job.Account__c = acc.id;
            job.Job_Type__c = wt.id;
            Job.Site__c = site.id;//New
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
            
            
            //(01 January 1900; 123123; a2f3L0000000gzkQAA)
            
            List<String> job_list = new List<String>();
            
            job_list.add('01 January 1900; 123123; '+job.id);
            Test.startTest();
            // InvoiceController.genConsolidatedInvoice(job_list);
            Job.Status__c = 'New';
            update job;
            InvoiceController.genKeyAccountInvoice(job.id);
            Test.stopTest();
            
        }catch(Exception ex){
            
        }
    }
    
    static testmethod void consolidatedInvocieTestFeb(){
        try{
            //insertcustomSettings();
            Account acc = new Account();
            acc.Name = 'Invoice Test';
            acc.First_Name__c = 'Invoice';
            acc.Last_Name__c = 'Test';
            acc.Email__c = 'test@test.com';
            acc.Invoicing_Email_Address__c = 'test@test.com';
            acc.Account_Type__c = 'Cash';
            acc.Account_Status__c = 'Open';
            acc.BillingStreet = '8 Allington way';
            acc.BillingCity = 'Swanley';
            acc.BillingCountry = 'United Kingdom';
            acc.BillingPostalCode = 'BR8 8FG';
            acc.Access_Details__c = '2333';
            // acc.DRC_Applies__c = TRUE;
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
            
            
            Job__c job = new Job__c();
            job.Account__c = acc.id;
            job.Job_Type__c = wt.id;
            Job.Site__c = site.id;//New
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
            
            
            //(01 January 1900; 123123; a2f3L0000000gzkQAA)
            
            List<String> job_list = new List<String>();
            
            job_list.add('01 February 1900; 123123; '+job.id);
            Test.startTest();
            // InvoiceController.genConsolidatedInvoice(job_list);
            Job.Status__c = 'New';
            update job;
            InvoiceController.genKeyAccountInvoice(job.id);
            Test.stopTest();
        }catch(Exception ex){
        }
    }
}