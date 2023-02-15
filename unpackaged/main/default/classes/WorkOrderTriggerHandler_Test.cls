@istest
public class WorkOrderTriggerHandler_Test {
	
    static testmethod void updateWorkOrder(){
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        
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
        
        String wt_trade = tradeRec.Name;
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Electrical';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        wtyp.Trade__c = wt_trade;
        insert wtyp;
        
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
        List<SelectOption> options = getServiResourRateOfPay();
        sr.Rate_of_Pay_Tier__c = options.get(1).getValue();
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
        cct.Hourly_Charge_R1__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R2__c = 80;//onb.Hourly_rate__c
        cct.Hourly_Charge_R3__c = 80;//onb.Hourly_rate__c
        cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
        insert cct;
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;//*********************
        dd2.Existing_Customer__c = 'Yes';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 02';
        dd2.Account__c = acc.Account_Reference__c;
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = ''+(System.now().hour()-4)+':00 - '+(System.now().hour()-2)+':00';
        dd2.Preferred_date__c = system.today()+10;
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        insert dd2;
        
        WorkOrder wo = new WorkOrder();
        wo.Job__c = jobrec.Id;
        //wo.Online_Booking__c = bb.Id;
        wo.WorkTypeId = wtyp.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.Requested_Date__c = dd2.Preferred_date__c;
        wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
        wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
        wo.Access_Details__c = dd2.Property_access_details__c;
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        if(dd2.Address_line_2__c != null){
            wo.Street = dd2.Address_line_1__c + dd2.Address_line_2__c;
        }else{
            wo.Street = dd2.Address_line_1__c;
        }
        wo.Duration = wtyp.EstimatedDuration;
        wo.city = dd2.TownCity__c;
        wo.country = 'United Kingdom';
        wo.postalCode = dd2.Postcode__c;
        wo.Costs_and_Charges__c = cct.Id;
        wo.Arrival_Window_Start_Date_Time__c = Datetime.newInstance(dd2.Preferred_date__c.year(), dd2.Preferred_date__c.month(), dd2.Preferred_date__c.day(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0])).hour(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0])).minute(), 0);
        wo.Arrival_Window_End_Date_Time__c = Datetime.newInstance(dd2.Preferred_date__c.year(), dd2.Preferred_date__c.month(), dd2.Preferred_date__c.day(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1])).hour(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1])).minute(), 0);
        wo.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('WorkOrder','Reactive');      
        insert wo;
    }
    
    public Static List<SelectOption> getServiResourRateOfPay(){
        List<SelectOption> RateOfPayList= new List<SelectOption>{new SelectOption('None', '--None--')};
            Schema.DescribeFieldResult rateofpayDescription = ServiceResource.Rate_of_Pay_Tier__c.getDescribe();
        List<Schema.PicklistEntry> rateofPayPicklistValuesList = rateofpayDescription .getPicklistValues();
        for(Schema.PicklistEntry rateOfPayPicklistValue : rateofPayPicklistValuesList ){
            RateOfPayList.add(new SelectOption(rateOfPayPicklistValue.getLabel(), rateOfPayPicklistValue.getValue()));
        }
        return RateOfPayList;
    }
    
    public Static void createAsperatoSetup(){
        asp04__AsperatoOneSettings__c test = new asp04__AsperatoOneSettings__c();
        test.asp04__Customer_ID__c = '377733';
        insert test;
    }
}