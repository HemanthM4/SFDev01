@isTest
public class PORTAL_PayDataNewControllerTest {
    static testMethod void paidThisMonth(){
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        // wtyp.Trade__c = 'General Building & Multi Trade Skills';
        insert wtyp;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusersai@testorg.com');
        insert u;
        System.runAs(u){
            ServiceResource sr = new ServiceResource();
            sr.AccountId = acc.Id;
            sr.Name = 'test 01res';
            sr.FirstName__c = 'test';
            sr.LastName__c = '01res';
            sr.IsActive = True;
            sr.RelatedRecordId = u.Id;
            sr.ResourceType = 'T';
            sr.Engineer_Role__c = 'Service_Resource';
            sr.Rate_of_Pay_Tier__c = 'Tier 2';
            sr.Email__c = 'dasfrog.web@gmail.com';
            sr.Estimate_Limit__c  =10;
            insert sr;
            
            OperatingHours opHrs = new OperatingHours();
            opHrs.Name = 'DUmmy Hrs';
            opHrs.TimeZone = string.valueOf(UserInfo.getTimeZone());
            insert opHrs;
            
            ServiceTerritory st = new ServiceTerritory();
            st.name = 'OP COVER REQUIRED - New01';
            st.IsActive = TRUE;
            st.OperatingHoursId = opHrs.Id;
            insert st;
            
            ServiceTerritoryMember stMem = new ServiceTerritoryMember();
            stMem.ServiceResourceId = sr.Id;
            stMem.ServiceTerritoryId = st.Id;
            stMem.TerritoryType = 'P';
            stMem.EffectiveStartDate = system.today() - 1;
            stMem.EffectiveEndDate = system.today() + 80;
            insert stMem;
            
            Job__c jobrec = new Job__c();
            jobrec.Site__c = site.id;
            jobrec.Account__c = acc.Id;
            insert jobrec;
            
            Costs_and_Charges__c cct = new Costs_and_Charges__c();
            cct.Job__c = jobrec.Id;
            cct.Record_Type__c = 'F';
            cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
            cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
            cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
            cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
            insert cct;
            
            
            WorkOrder wo = new WorkOrder();
            wo.Job__c = jobrec.Id;
            //wo.Online_Booking__c = bb.Id;
            wo.WorkTypeId = wtyp.Id;//Id input from the form submitted online
            wo.Description = 'Blah blah';
            wo.Requested_Date__c = system.today();
            //wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
            //wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
            wo.Access_Details__c = 'test';
            wo.ContactId = con.Id;
            wo.AccountId = acc.Id;
            wo.Site__c = site.Id;
            wo.Street = 'test1';
            wo.city = 'London';
            wo.country = 'United Kingdom';
            wo.postalCode = 'TW106DG';
            wo.Costs_and_Charges__c = cct.Id;
            //wo.Arrival_Window_Start_Date_Time__c = system.today();
            //wo.Arrival_Window_End_Date_Time__c = system.today();
            insert wo;
            
            Customer_Invoice__c cusInv = new Customer_Invoice__c();
            cusInv.Date__c = date.valueOf(system.today())-10;
            cusInv.CurrencyIsoCode = 'GBP';
            cusInv.Account__c = acc.Id;
            cusInv.Job__c = jobrec.id;
            insert cusInv;
            
            Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
            epr.Job__c = jobrec.id;
            epr.Status__c = 'New';
            epr.CurrencyIsoCode = 'GBP';
            epr.Service_Resource__c = sr.id;
            epr.Work_Order__c = wo.Id;
            epr.Customer_Invoice__c = cusInv.Id;
            epr.Payroll_month__c = system.today()+1;
            insert epr;
            
            Deduction__c dd = new Deduction__c();
            dd.Service_Resource__c = sr.Id;
            dd.Status__c = 'New';
            dd.Amount__c = 2.0;
            dd.CurrencyIsoCode = 'GBP';
            dd.Payroll_month__c = system.today()-1;
            insert dd;
            
            Deduction__c dd1 = new Deduction__c();
            dd1.Service_Resource__c = sr.Id;
            dd1.Status__c = 'New';
            dd1.Amount__c = 3.0;
            dd1.CurrencyIsoCode = 'GBP';
            dd1.Payroll_month__c = system.today();
            insert dd1;
            PORTAL_PayDataNewCOntroller.fetchEnginnerPaytest('Paid','This Month');
        }
    }
    
    static testMethod void paidLastMonth(){
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        //wtyp.Trade__c = 'General Building & Multi Trade Skills';
        insert wtyp;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusersai@testorg.com');
        insert u;
        
        ServiceResource sr = new ServiceResource();
        sr.AccountId = acc.Id;
        sr.Name = 'test 01res';
        sr.FirstName__c = 'test';
        sr.LastName__c = '01res';
        sr.IsActive = True;
        sr.RelatedRecordId = u.Id;
        sr.ResourceType = 'T';
        sr.Engineer_Role__c = 'Service_Resource';
        sr.Rate_of_Pay_Tier__c = 'Tier 2';
        sr.Email__c = 'dasfrog.web@gmail.com';
        sr.Estimate_Limit__c  =10;
        insert sr;
        
        OperatingHours opHrs = new OperatingHours();
        opHrs.Name = 'DUmmy Hrs';
        opHrs.TimeZone = string.valueOf(UserInfo.getTimeZone());
        insert opHrs;
        
        ServiceTerritory st = new ServiceTerritory();
        st.name = 'OP COVER REQUIRED - New01';
        st.IsActive = TRUE;
        st.OperatingHoursId = opHrs.Id;
        insert st;
        
        ServiceTerritoryMember stMem = new ServiceTerritoryMember();
        stMem.ServiceResourceId = sr.Id;
        stMem.ServiceTerritoryId = st.Id;
        stMem.TerritoryType = 'P';
        stMem.EffectiveStartDate = system.today() - 1;
        insert stMem;
        
        Job__c jobrec = new Job__c();
        jobrec.Site__c = site.id;
        jobrec.Account__c = acc.Id;
        insert jobrec;
        
        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = jobrec.Id;
        cct.Record_Type__c = 'F';
        cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
        cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
        insert cct;
        
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = jobrec.Id;
        //wo.Online_Booking__c = bb.Id;
        wo.WorkTypeId = wtyp.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.Requested_Date__c = system.today();
        //wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
        //wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
        wo.Access_Details__c = 'test';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Street = 'test1';
        wo.city = 'London';
        wo.country = 'United Kingdom';
        wo.postalCode = 'TW106DG';
        wo.Costs_and_Charges__c = cct.Id;
        //wo.Arrival_Window_Start_Date_Time__c = system.today();
        //wo.Arrival_Window_End_Date_Time__c = system.today();
        insert wo;
        
        Customer_Invoice__c cusInv = new Customer_Invoice__c();
        cusInv.Date__c = date.valueOf(system.today())-10;
        cusInv.CurrencyIsoCode = 'GBP';
        cusInv.Account__c = acc.Id;
        cusInv.Job__c = jobrec.id;
        insert cusInv;
        
        Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
        epr.Job__c = jobrec.id;
        epr.Status__c = 'Paid';
        epr.CurrencyIsoCode = 'GBP';
        epr.Service_Resource__c = sr.id;
        epr.Work_Order__c = wo.Id;
        epr.Customer_Invoice__c = cusInv.Id;
        epr.Payroll_month__c = system.today()-1;
        insert epr;
        
        Deduction__c dd = new Deduction__c();
        dd.Service_Resource__c = sr.Id;
        dd.Status__c = 'New';
        dd.Amount__c = 2.0;
        dd.CurrencyIsoCode = 'GBP';
        dd.Payroll_month__c = system.today()-1;
        insert dd;
        
        Deduction__c dd1 = new Deduction__c();
        dd1.Service_Resource__c = sr.Id;
        dd1.Status__c = 'New';
        dd1.Amount__c = 3.0;
        dd1.CurrencyIsoCode = 'GBP';
        dd1.Payroll_month__c = system.today();
        insert dd1;
        System.runAs(u){
            PORTAL_PayDataNewCOntroller.fetchEnginnerPaytest('Paid','Last Month');
        }
    }
    static testMethod void paidAllTime(){
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        //    wtyp.Trade__c = 'General Building & Multi Trade Skills';
        insert wtyp;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusersai@testorg.com');
        insert u;
        
        ServiceResource sr = new ServiceResource();
        sr.AccountId = acc.Id;
        sr.Name = 'test 01res';
        sr.FirstName__c = 'test';
        sr.LastName__c = '01res';
        sr.IsActive = True;
        sr.RelatedRecordId = u.Id;
        sr.ResourceType = 'T';
        sr.Engineer_Role__c = 'Service_Resource';
        sr.Rate_of_Pay_Tier__c = 'Tier 2';
        sr.Email__c = 'dasfrog.web@gmail.com';
        sr.Estimate_Limit__c  =10;
        insert sr;
        
        OperatingHours opHrs = new OperatingHours();
        opHrs.Name = 'DUmmy Hrs';
        opHrs.TimeZone = string.valueOf(UserInfo.getTimeZone());
        insert opHrs;
        
        ServiceTerritory st = new ServiceTerritory();
        st.name = 'OP COVER REQUIRED - New01';
        st.IsActive = TRUE;
        st.OperatingHoursId = opHrs.Id;
        insert st;
        
        ServiceTerritoryMember stMem = new ServiceTerritoryMember();
        stMem.ServiceResourceId = sr.Id;
        stMem.ServiceTerritoryId = st.Id;
        stMem.TerritoryType = 'P';
        stMem.EffectiveStartDate = system.today() - 1;
        insert stMem;
        
        Job__c jobrec = new Job__c();
        jobrec.Site__c = site.id;
        jobrec.Account__c = acc.Id;
        insert jobrec;
        
        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = jobrec.Id;
        cct.Record_Type__c = 'F';
        cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
        cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
        insert cct;
        
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = jobrec.Id;
        //wo.Online_Booking__c = bb.Id;
        wo.WorkTypeId = wtyp.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.Requested_Date__c = system.today();
        //wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
        //wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
        wo.Access_Details__c = 'test';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Street = 'test1';
        wo.city = 'London';
        wo.country = 'United Kingdom';
        wo.postalCode = 'TW106DG';
        wo.Costs_and_Charges__c = cct.Id;
        //wo.Arrival_Window_Start_Date_Time__c = system.today();
        //wo.Arrival_Window_End_Date_Time__c = system.today();
        insert wo;
        
        Customer_Invoice__c cusInv = new Customer_Invoice__c();
        cusInv.Date__c = date.valueOf(system.today())-10;
        cusInv.CurrencyIsoCode = 'GBP';
        cusInv.Account__c = acc.Id;
        cusInv.Job__c = jobrec.id;
        insert cusInv;
        
        Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
        epr.Job__c = jobrec.id;
        epr.Status__c = 'Paid';
        epr.CurrencyIsoCode = 'GBP';
        epr.Service_Resource__c = sr.id;
        epr.Work_Order__c = wo.Id;
        epr.Customer_Invoice__c = cusInv.Id;
        epr.Payroll_month__c = system.today()-1;
        insert epr;
        
        Engineer_Pay_Requisition__c epr1 = new Engineer_Pay_Requisition__c();
        epr1.Job__c = jobrec.id;
        epr1.Status__c = 'New';
        epr1.CurrencyIsoCode = 'GBP';
        epr1.Service_Resource__c = sr.id;
        epr1.Work_Order__c = wo.Id;
        epr1.Customer_Invoice__c = cusInv.Id;
        epr1.Payroll_month__c = system.today()+20;
        insert epr1;
        
        Deduction__c dd = new Deduction__c();
        dd.Service_Resource__c = sr.Id;
        dd.Status__c = 'New';
        dd.Amount__c = 2.0;
        dd.CurrencyIsoCode = 'GBP';
        dd.Payroll_month__c = system.today()-1;
        insert dd;
        
        Deduction__c dd1 = new Deduction__c();
        dd1.Service_Resource__c = sr.Id;
        dd1.Status__c = 'New';
        dd1.Amount__c = 3.0;
        dd1.CurrencyIsoCode = 'GBP';
        dd1.Payroll_month__c = system.today()+1;
        insert dd1;
        System.runAs(u){
            PORTAL_PayDataNewCOntroller.fetchEnginnerPaytest('Paid','All Time');
        }
    }
    
    static testMethod void paidMonthWise(){
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        //  wtyp.Trade__c = 'General Building & Multi Trade Skills';
        insert wtyp;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusersai@testorg.com');
        insert u;
        
        ServiceResource sr = new ServiceResource();
        sr.AccountId = acc.Id;
        sr.Name = 'test 01res';
        sr.FirstName__c = 'test';
        sr.LastName__c = '01res';
        sr.IsActive = True;
        sr.RelatedRecordId = u.Id;
        sr.ResourceType = 'T';
        sr.Engineer_Role__c = 'Service_Resource';
        sr.Rate_of_Pay_Tier__c = 'Tier 2';
        sr.Email__c = 'dasfrog.web@gmail.com';
        sr.Estimate_Limit__c  =10;
        insert sr;
        
        OperatingHours opHrs = new OperatingHours();
        opHrs.Name = 'DUmmy Hrs';
        opHrs.TimeZone = string.valueOf(UserInfo.getTimeZone());
        insert opHrs;
        
        ServiceTerritory st = new ServiceTerritory();
        st.name = 'OP COVER REQUIRED - New01';
        st.IsActive = TRUE;
        st.OperatingHoursId = opHrs.Id;
        insert st;
        
        ServiceTerritoryMember stMem = new ServiceTerritoryMember();
        stMem.ServiceResourceId = sr.Id;
        stMem.ServiceTerritoryId = st.Id;
        stMem.TerritoryType = 'P';
        stMem.EffectiveStartDate = system.today() - 1;
        insert stMem;
        
        Job__c jobrec = new Job__c();
        jobrec.Site__c = site.id;
        jobrec.Account__c = acc.Id;
        insert jobrec;
        
        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = jobrec.Id;
        cct.Record_Type__c = 'F';
        cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
        cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
        insert cct;
        
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = jobrec.Id;
        //wo.Online_Booking__c = bb.Id;
        wo.WorkTypeId = wtyp.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.Requested_Date__c = system.today();
        //wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
        //wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
        wo.Access_Details__c = 'test';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Street = 'test1';
        wo.city = 'London';
        wo.country = 'United Kingdom';
        wo.postalCode = 'TW106DG';
        wo.Costs_and_Charges__c = cct.Id;
        //wo.Arrival_Window_Start_Date_Time__c = system.today();
        //wo.Arrival_Window_End_Date_Time__c = system.today();
        insert wo;
        
        Customer_Invoice__c cusInv = new Customer_Invoice__c();
        cusInv.Date__c = date.valueOf(system.today())-10;
        cusInv.CurrencyIsoCode = 'GBP';
        cusInv.Account__c = acc.Id;
        cusInv.Job__c = jobrec.id;
        insert cusInv;
        
        Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
        epr.Job__c = jobrec.id;
        epr.Status__c = 'Paid';
        epr.CurrencyIsoCode = 'GBP';
        epr.Service_Resource__c = sr.id;
        epr.Work_Order__c = wo.Id;
        epr.Customer_Invoice__c = cusInv.Id;
        epr.Payroll_month__c = system.today()-1;
        insert epr;
        
        
        
        Deduction__c dd = new Deduction__c();
        dd.Service_Resource__c = sr.Id;
        dd.Status__c = 'New';
        dd.Amount__c = 2.0;
        dd.CurrencyIsoCode = 'GBP';
        dd.Payroll_month__c = system.today()-1;
        insert dd;
        
        Deduction__c dd1 = new Deduction__c();
        dd1.Service_Resource__c = sr.Id;
        dd1.Status__c = 'New';
        dd1.Amount__c = 3.0;
        dd1.CurrencyIsoCode = 'GBP';
        dd1.Payroll_month__c = system.today();
        insert dd1;
        
        DateTime dt = Datetime.now()-1;
        System.debug('year ===> '+dt.year());
        System.debug('Month Name  ===> '+dt.format('MMMM'));
        System.runAs(u){
            PORTAL_PayDataNewCOntroller.fetchEnginnerPaytest('Paid',dt.format('MMMM')+'-'+dt.year());
            PORTAL_PayDataNewCOntroller.paySummaryTotal();
        }
    }
    
    static testMethod void statusNone(){
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        // wtyp.Trade__c = 'General Building & Multi Trade Skills';
        insert wtyp;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusersai@testorg.com');
        insert u;
        
        ServiceResource sr = new ServiceResource();
        sr.AccountId = acc.Id;
        sr.Name = 'test 01res';
        sr.FirstName__c = 'test';
        sr.LastName__c = '01res';
        sr.IsActive = True;
        sr.RelatedRecordId = u.Id;
        sr.ResourceType = 'T';
        sr.Engineer_Role__c = 'Service_Resource';
        sr.Rate_of_Pay_Tier__c = 'Tier 2';
        sr.Email__c = 'dasfrog.web@gmail.com';
        sr.Estimate_Limit__c  =10;
        insert sr;
        
        OperatingHours opHrs = new OperatingHours();
        opHrs.Name = 'DUmmy Hrs';
        opHrs.TimeZone = string.valueOf(UserInfo.getTimeZone());
        insert opHrs;
        
        ServiceTerritory st = new ServiceTerritory();
        st.name = 'OP COVER REQUIRED - New01';
        st.IsActive = TRUE;
        st.OperatingHoursId = opHrs.Id;
        insert st;
        
        ServiceTerritoryMember stMem = new ServiceTerritoryMember();
        stMem.ServiceResourceId = sr.Id;
        stMem.ServiceTerritoryId = st.Id;
        stMem.TerritoryType = 'P';
        stMem.EffectiveStartDate = system.today() - 1;
        insert stMem;
        
        Job__c jobrec = new Job__c();
        jobrec.Site__c = site.id;
        jobrec.Account__c = acc.Id;
        insert jobrec;
        
        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = jobrec.Id;
        cct.Record_Type__c = 'F';
        cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
        cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
        insert cct;
        
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = jobrec.Id;
        //wo.Online_Booking__c = bb.Id;
        wo.WorkTypeId = wtyp.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.Requested_Date__c = system.today();
        //wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
        //wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
        wo.Access_Details__c = 'test';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Street = 'test1';
        wo.city = 'London';
        wo.country = 'United Kingdom';
        wo.postalCode = 'TW106DG';
        wo.Costs_and_Charges__c = cct.Id;
        //wo.Arrival_Window_Start_Date_Time__c = system.today();
        //wo.Arrival_Window_End_Date_Time__c = system.today();
        insert wo;
        
        Customer_Invoice__c cusInv = new Customer_Invoice__c();
        cusInv.Date__c = date.valueOf(system.today())-10;
        cusInv.CurrencyIsoCode = 'GBP';
        cusInv.Account__c = acc.Id;
        cusInv.Job__c = jobrec.id;
        insert cusInv;
        
        Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
        epr.Job__c = jobrec.id;
        epr.Status__c = 'Paid';
        epr.CurrencyIsoCode = 'GBP';
        epr.Service_Resource__c = sr.id;
        epr.Work_Order__c = wo.Id;
        epr.Customer_Invoice__c = cusInv.Id;
        epr.Payroll_month__c = system.today()-1;
        insert epr;
        
        Engineer_Pay_Requisition__c epr1 = new Engineer_Pay_Requisition__c();
        epr1.Job__c = jobrec.id;
        epr1.Status__c = 'New';
        epr1.CurrencyIsoCode = 'GBP';
        epr1.Service_Resource__c = sr.id;
        epr1.Work_Order__c = wo.Id;
        epr1.Customer_Invoice__c = cusInv.Id;
        epr1.Payroll_month__c = system.today()+20;
        insert epr1;
        
        Deduction__c dd = new Deduction__c();
        dd.Service_Resource__c = sr.Id;
        dd.Status__c = 'New';
        dd.Amount__c = 2.0;
        dd.CurrencyIsoCode = 'GBP';
        dd.Payroll_month__c = system.today()-1;
        insert dd;
        
        Deduction__c dd1 = new Deduction__c();
        dd1.Service_Resource__c = sr.Id;
        dd1.Status__c = 'Approved';
        dd1.Amount__c = 3.0;
        dd1.CurrencyIsoCode = 'GBP';
        dd1.Payroll_month__c = system.today();
        insert dd1;
        System.runAs(u){
            PORTAL_PayDataNewCOntroller.fetchEnginnerPaytest('None','All Time');
        }
    }
    
    static testMethod void payrollMonth(){
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        //  wtyp.Trade__c = 'General Building & Multi Trade Skills';
        insert wtyp;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusersai@testorg.com');
        insert u;
        
        ServiceResource sr = new ServiceResource();
        sr.AccountId = acc.Id;
        sr.Name = 'test 01res';
        sr.FirstName__c = 'test';
        sr.LastName__c = '01res';
        sr.IsActive = True;
        sr.RelatedRecordId = u.Id;
        sr.ResourceType = 'T';
        sr.Engineer_Role__c = 'Service_Resource';
        sr.Rate_of_Pay_Tier__c = 'Tier 2';
        sr.Email__c = 'dasfrog.web@gmail.com';
        sr.Estimate_Limit__c  =10;
        insert sr;
        
        OperatingHours opHrs = new OperatingHours();
        opHrs.Name = 'DUmmy Hrs';
        opHrs.TimeZone = string.valueOf(UserInfo.getTimeZone());
        insert opHrs;
        
        ServiceTerritory st = new ServiceTerritory();
        st.name = 'OP COVER REQUIRED - New01';
        st.IsActive = TRUE;
        st.OperatingHoursId = opHrs.Id;
        insert st;
        
        ServiceTerritoryMember stMem = new ServiceTerritoryMember();
        stMem.ServiceResourceId = sr.Id;
        stMem.ServiceTerritoryId = st.Id;
        stMem.TerritoryType = 'P';
        stMem.EffectiveStartDate = system.today() - 1;
        insert stMem;
        
        Job__c jobrec = new Job__c();
        jobrec.Site__c = site.id;
        jobrec.Account__c = acc.Id;
        insert jobrec;
        
        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = jobrec.Id;
        cct.Record_Type__c = 'F';
        cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
        cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
        insert cct;
        
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = jobrec.Id;
        //wo.Online_Booking__c = bb.Id;
        wo.WorkTypeId = wtyp.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.Requested_Date__c = system.today();
        //wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
        //wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
        wo.Access_Details__c = 'test';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Street = 'test1';
        wo.city = 'London';
        wo.country = 'United Kingdom';
        wo.postalCode = 'TW106DG';
        wo.Costs_and_Charges__c = cct.Id;
        //wo.Arrival_Window_Start_Date_Time__c = system.today();
        //wo.Arrival_Window_End_Date_Time__c = system.today();
        insert wo;
        
        Customer_Invoice__c cusInv = new Customer_Invoice__c();
        cusInv.Date__c = date.valueOf(system.today())-10;
        cusInv.CurrencyIsoCode = 'GBP';
        cusInv.Account__c = acc.Id;
        cusInv.Job__c = jobrec.id;
        insert cusInv;
        
        Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
        epr.Job__c = jobrec.id;
        epr.Status__c = 'Paid';
        epr.CurrencyIsoCode = 'GBP';
        epr.Service_Resource__c = sr.id;
        epr.Work_Order__c = wo.Id;
        epr.Customer_Invoice__c = cusInv.Id;
        epr.Payroll_month__c = system.today()-100;
        insert epr;
        
        Engineer_Pay_Requisition__c epr1 = new Engineer_Pay_Requisition__c();
        epr1.Job__c = jobrec.id;
        epr1.Status__c = 'Paid';
        epr1.CurrencyIsoCode = 'GBP';
        epr1.Service_Resource__c = sr.id;
        epr1.Work_Order__c = wo.Id;
        epr1.Customer_Invoice__c = cusInv.Id;
        epr1.Payroll_month__c = system.today()+50;
        insert epr1;
        
        Deduction__c dd = new Deduction__c();
        dd.Service_Resource__c = sr.Id;
        dd.Status__c = 'New';
        dd.Amount__c = 2.0;
        dd.CurrencyIsoCode = 'GBP';
        dd.Payroll_month__c = system.today()-1;
        insert dd;
        
        Deduction__c dd1 = new Deduction__c();
        dd1.Service_Resource__c = sr.Id;
        dd1.Status__c = 'New';
        dd1.Amount__c = 3.0;
        dd1.CurrencyIsoCode = 'GBP';
        dd1.Payroll_month__c = system.today()+100;
        insert dd1;
        System.runAs(u){
            PORTAL_PayDataNewCOntroller.paySummaryTotal();
        }
    }
}