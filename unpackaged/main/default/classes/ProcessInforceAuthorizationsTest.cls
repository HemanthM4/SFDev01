/*

Modification Log:
1) 8/7/2022 - Mofified by Pradeep for Rate Cards and Rate restructure

*/

@isTest
public class ProcessInforceAuthorizationsTest {
    static testmethod void processdataafterINforce() {
        
        createAsperatoSetup();
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile pr = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysAd = new User(Alias = 'standt', Email='sysAdminuser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = pr.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=uniqueUserName);
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Flooring';
        insert tradeRec;
        
        // String wt_trade = (WorkType.Trade__c.getDescribe().getPicklistValues())[0].getLabel();
        WorkType wtyp = new worktype();
        System.runAs(sysAd) {
            wtyp.Name = 'Building Online Booking';
            wtyp.EstimatedDuration = 1.00;
            wtyp.DurationType = 'Hours';
            wtyp.Trade__c = tradeRec.Name;
            insert wtyp;
        }
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        
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
        acc.Rate_Card__c = rca.Id;
        insert acc;
        
        OnlineBookingProcessHelperTest.createRates(rca.id, tradeRec.Id);
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
rtc.account__c = acc.id;
insert rtc;
OnlineBookingProcessHelperTest.createRates(rtc.id);

Rate_Cards__c rtc1 = new Rate_Cards__c();
rtc1.Trade__c = wt_trade;
rtc1.CurrencyIsoCode = 'GBP';
insert rtc1;
OnlineBookingProcessHelperTest.createRates(rtc1.id);
*/
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
        st.name = 'OP COVER REQUIRED';
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
        cct.Record_Type__c = 'R';
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
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()+1;
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
        wo.RecordTypeId = getRecordTypeIdbyName('WorkOrder','Reactive');
        insert wo;
        
        asp04__Authorisation__c auth = new asp04__Authorisation__c();
        auth.asp04__Account_Name__c = acc.Name;
        auth.Customer__c = acc.Id;
        auth.asp04__First_Name__c = acc.First_Name__c;
        auth.asp04__Last_Name__c = acc.Last_Name__c;
        auth.asp04__Email__c = acc.Email__c;
        auth.Online_Booking__c = TRUE;
        auth.Send_Email__c = TRUE;
        auth.Customer_Email__c = acc.Email__c;
        auth.asp04__Billing_Address_Street__c = acc.BillingStreet;
        auth.asp04__Billing_Address_City__c = acc.BillingCity;
        auth.asp04__Billing_Address_Country__c = acc.BillingCountry;
        auth.asp04__Billing_Address_PostalCode__c = acc.BillingPostalCode;
        insert auth;
        
        Job__c jobrecd = new Job__c();
        jobrecd.Id = jobrec.id;
        jobrecd.Authorisation__c = auth.Id;
        update jobrecd;
        
        asp04__Authorisation__c authToUpdate = new asp04__Authorisation__c();
        authToUpdate.asp04__Status__c = 'In Force';
        authToUpdate.Id = auth.Id;
        update authToUpdate;
        
        
        List<id> idList = new List<Id>();
        idList.add(authToUpdate.id);
        test.startTest();
        ProcessInforceAuthorizations.ProcessInforceAuthorizations(idList);
        test.stopTest();
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
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}