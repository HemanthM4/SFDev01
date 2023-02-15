@IsTest
public class job_LabourRequisitionsController_Test {
	
    @IsTest
    public static void testmethods(){
        
        Map <Costs_and_Charges__c,List<ServiceAppointment>> sas = new Map <Costs_and_Charges__c,List<ServiceAppointment>>();
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Flooring';
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
        
        String wt_trade = tradeRec.Name;
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        wtyp.Trade__c = wt_trade;
        insert wtyp;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
        acc.Email__c = 'dasfrog.web@gmail.com';
        acc.Invoicing_Email_Address__c = 'dasfrog.web@gmail.com';
        acc.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('Account','Domestic');
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
        //List<SelectOption> options = getServiResourRateOfPay();
        sr.Rate_of_Pay_Tier__c = 'Tier 8';
        sr.Email__c = 'dasfrog.web@gmail.com';
        sr.Auto_Booking_Resource__c = True;
        sr.Estimate_Limit__c = 1000;
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
        cct.Chargeable_Duration_R1__c = 1;
        cct.Chargeable_Duration_R2__c = 1;
        cct.Chargeable_Duration_R3__c = 1;
        cct.Charge_Collection_Fee__c = 10;
        cct.Call_out_fee__c = 10;
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
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.country = 'United Kingdom';
        wo.Costs_and_Charges__c = cct.Id;
        wo.Trade_Rate__c = rct.Id;
        insert wo;
        
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = wo.id;
        sa.ContactId = con.id;
        sa.Allocated_Engineer__c = sr.Id;
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
        
        List<ServiceAppointment> sApp = new List<ServiceAppointment>();
        sApp.add(sa);
        sas.put(cct, sApp);
        
        job_LabourRequisitionsController obj = new job_LabourRequisitionsController();
        job_LabourRequisitionsController.genReqs(jobrec);
    }
}