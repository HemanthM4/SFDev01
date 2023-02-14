@IsTest
public class EprDataControllerTest {
    @isTest
    public static void runDeduction(){
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
            EprDataController.processDedcutionMethod(System.today());
        }
    }
    @IsTest
    Public static void runBatch(){
        Epr_History_log__c epr  = new Epr_History_log__c();
        epr.Start_Date__c= system.today();
        epr.End_Date__c= system.today()+1;
        epr.Job_TypeMP__c='Reactive' ;
        epr.Status__c='New' ;
        epr.Account_TypeMP__c='Cash' ;
        epr.Comment__c = 'Test';
        insert epr;
        EprJobFailureBatchEmail__c eprcus = new EprJobFailureBatchEmail__c();
        eprcus.User_Email_Id__c = 'test@gmail.com';
        insert  eprcus;
        
        Epr_History_log__c epr1  = new Epr_History_log__c();
        epr1.Start_Date__c= system.today();
        epr1.End_Date__c= system.today()+1;
        epr1.Job_TypeMP__c='Reactive' ;
        epr1.Status__c='New' ;
        epr1.Account_TypeMP__c='Cash' ;
        epr1.Comment__c = 'Test';
        insert epr1;
        list<EprDataController.wrapAccount> caseWrapList = new List<EprDataController.wrapAccount>();
        EprDataController.wrapAccount s6 = new EprDataController.wrapAccount();
        s6.recid = epr.id;
        s6.comment = 'test';
        caseWrapList.add(s6);
        List<String>  s8 = new  List<String>();
        s8.add('Cash');
        List<String>  s9 = new  List<String>();
        s9.add('Reactive');
        Test.startTest();
        EprDataController.wrapAccountNew eprsWrap =EprDataController.getallEpr();
        List<String> s1 = EprDataController.getjobPiklistValues();
        List<String> s2 = EprDataController.getAccountPickLIst();
        list<EprDataController.wrapAccount> wrapAcc = EprDataController.retrieveRecordsofEPRonSearchApex('Test');
        Epr_History_log__c s3 = EprDataController.prepopulateValues(epr.id);
        Boolean s4 = EprDataController.runBatchMethod(epr.id,System.today());
        List<EprDataController.wrapAccount> s5 =EprDataController.updateEPRList(caseWrapList);
        EprDataController.eprWrap s7 = EprDataController.checkEprRecords(System.today(),System.today()+1,s8,'New',s9);
        List<EprDataController.wrapAccount> s10 =  EprDataController.getallEprforShow1(caseWrapList);
        List<EprDataController.wrapAccount> s11 =  EprDataController.getallEprforShow2(caseWrapList);
        EprDataController.getAllEPrsforCmp s13 = EprDataController.getALEPS();
        List<EprDataController.wrapAccount> s12 = EprDataController.checkExistingRecord(System.today(),System.today()+1,s8,'New',s9);
        Test.stopTest();
        
    }
}