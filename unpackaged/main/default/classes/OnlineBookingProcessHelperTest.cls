@istest
public class OnlineBookingProcessHelperTest {
    
    // Utility method that can be called by Apex tests to create price book entries.
    static testmethod void addNewUserBookingEntries() {
        
        createAsperatoSetup();
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysAd = new User(Alias = 'standt', Email='sysAdminuser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=uniqueUserName);
        
        WorkType wtyp = new worktype();
        System.runAs(sysAd) {
            wtyp.Name = 'Building Online Booking';
            wtyp.EstimatedDuration = 1.00;
            wtyp.DurationType = 'Hours';
            //wtyp.Trade__c = 'General Building & Multi Trade';
            wtyp.Trade__c = wt_trade;
            insert wtyp;
            
            Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
            rcaStand.Description__c = 'test';
            rcaStand.Standard__c = TRUE;            
            insert rcaStand;
            
            Rate_Card_Account__c rca = new Rate_Card_Account__c();
            rca.Description__c = 'test';
            rca.Standard__c = TRUE;
            insert rca;
            /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
            createRates(rca.Id, tradeRec.Id);
        }
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>(); 
        
        Account acc = new Account();
        acc.Name = 'Ram John1';
        acc.First_Name__c = 'Ram';
        acc.Last_Name__c = 'John1';
        acc.Voucher_Code__c = 'TEST_1234';
        acc.Referral_notes__c = 'testId,dasfrog.web@gmail.com';
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
        insert acc;
        
        Contact cont = new Contact();
        cont.LastName = 'John1';
        cont.firstName = 'Ram';
        cont.AccountId = acc.Id;
        insert cont;
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'No';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 100';
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Voucher_Code__c = 'TEST_1234';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today();
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        insert ddlist; 
        Map<String, List<Online_Bookings__c>> testMap = new Map<String, List<Online_Bookings__c>>();
        testMap.put(acc.Email__c, ddlist);
        OnlineBookingProcessHelper.UpdateAccContForRef(testMap);
    }
    
    static testmethod void addExistingUserNoEmailBookingEntries() {
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        createAsperatoSetup();
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Electrical';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        wtyp.Trade__c = wt_trade;
        insert wtyp;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        //Rate_Cards__c rtc = new Rate_Cards__c();
        //rtc.Trade__c = wt_trade;
        //rtc.CurrencyIsoCode = 'GBP';
        //insert rtc;
        createRates(rca.Id, tradeRec.Id);
        
        Account acc = new Account();
        acc.Name = 'Ram John';
        acc.First_Name__c = 'Ram';
        acc.Last_Name__c = 'John';
        acc.Voucher_Code__c = 'TEST_123';
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
        insert acc;
        
        Contact cont = new Contact();
        cont.LastName = 'John';
        cont.firstName = 'Ram';
        cont.AccountId = acc.Id;
        insert cont;
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'No';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 100';
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        
        Online_Bookings__c dd3 = new Online_Bookings__c();
        dd3.Work_Type__c = wtyp.Id;
        dd3.Existing_Customer__c = 'Yes';
        dd3.Customer_first_name__c = 'Flying';
        dd3.Customer_last_name__c = 'Jack 100';
        dd3.Address_line_1__c = '8 Allington way';
        dd3.TownCity__c = 'Swanley';
        dd3.Postcode__c = 'BR8 8FG';
        dd3.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd3.Preferred_date__c = system.today()-2;
        dd3.Hourly_rate__c = 90.00;
        dd3.Customer_email__c= 'dasfrog1.web@gmail.com';
        dd3.Property_access_details__c = '2333';
        ddlist.add(dd3);
        test.startTest();
        insert ddlist;
        test.stopTest();
    }
    
    static testmethod void addExistingUserWithEmailBookingEntries1() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysAd = new User(Alias = 'standt', Email='sysAdminuser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=uniqueUserName);
        
        WorkType wtyp = new worktype();
        System.runAs(sysAd) {
            
            wtyp.Name = 'Electrical';
            wtyp.EstimatedDuration = 1.00;
            wtyp.DurationType = 'Hours';
            wtyp.Trade__c = wt_trade;
            insert wtyp;
        }
        
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
        acc.Voucher_Code__c = 'TEST@123';
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        Profile pr = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pr.Id, 
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
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'Yes';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 02';
        dd2.Account_Number__c = acc.Account_Reference__c;
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        test.startTest();
        insert ddlist;
        Map<Account,list<Online_Bookings__c>> accBookMap = new Map<Account,list<Online_Bookings__c>>();
        accBookMap.put(acc,ddlist);
        Set<id> accId = new Set<id>();
        try{
            
            accId.add(acc.id);
            OnlineBookingProcessHelper.createServiceAppointments(accId);
            
        }catch(Exception ex){
            
        }
        
        test.stopTest();
        
        
        
        
    }
    
    static testmethod void addExistingUserWithEmailBookingEntries2() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysAd = new User(Alias = 'standt', Email='sysAdminuser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=uniqueUserName);
        
        WorkType wtyp = new worktype();
        System.runAs(sysAd) {
            
            wtyp.Name = 'Electrical';
            wtyp.EstimatedDuration = 1.00;
            wtyp.DurationType = 'Hours';
            wtyp.Trade__c = wt_trade;
            insert wtyp;
        }
        
        
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        Profile pr = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pr.Id, 
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
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'Yes';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 02';
        dd2.Account_Number__c = acc.Account_Reference__c;
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        test.startTest();
        insert ddlist;
        Map<Account,list<Online_Bookings__c>> accBookMap = new Map<Account,list<Online_Bookings__c>>();
        accBookMap.put(acc,ddlist);
        Set<id> accId = new Set<id>();
        try{
            
            accId.add(acc.id);
            OnlineBookingProcessHelper.mapExistingAccountswithBookings(accBookMap); 
            
        }catch(Exception ex){
            
        }
        
        test.stopTest();
        
        
        
        
    }
    
    static testmethod void addExistingUserWithEmailBookingEntries() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysAd = new User(Alias = 'standt', Email='sysAdminuser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=uniqueUserName);
        
        WorkType wtyp = new worktype();
        System.runAs(sysAd) {
            
            wtyp.Name = 'Electrical';
            wtyp.EstimatedDuration = 1.00;
            wtyp.DurationType = 'Hours';
            wtyp.Trade__c = wt_trade;
            insert wtyp;
        }
        
        
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        Profile pr = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pr.Id, 
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
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'Yes';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 02';
        dd2.Account_Number__c = acc.Account_Reference__c;
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        test.startTest();
        insert ddlist;
        Map<Account,list<Online_Bookings__c>> accBookMap = new Map<Account,list<Online_Bookings__c>>();
        accBookMap.put(acc,ddlist);
        Set<id> accId = new Set<id>();
        try{
            accId.add(acc.id);
            OnlineBookingProcessHelper.checkAuthorization(accBookMap); 
        }catch(Exception ex){
        }
        test.stopTest(); 
    }
    
    static testmethod void addExistingUserWithnoINFORceAuth() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Account_Number__c = acc.Account_Reference__c;
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
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
        
        wo.city = dd2.TownCity__c;
        wo.country = 'United Kingdom';
        wo.postalCode = dd2.Postcode__c;
        wo.Costs_and_Charges__c = cct.Id;
        wo.Arrival_Window_Start_Date_Time__c = Datetime.newInstance(dd2.Preferred_date__c.year(), dd2.Preferred_date__c.month(), dd2.Preferred_date__c.day(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0])).hour(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0])).minute(), 0);
        wo.Arrival_Window_End_Date_Time__c = Datetime.newInstance(dd2.Preferred_date__c.year(), dd2.Preferred_date__c.month(), dd2.Preferred_date__c.day(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1])).hour(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1])).minute(), 0);
        insert wo;
        
        asp04__Authorisation__c auth = new asp04__Authorisation__c();
        auth.asp04__Account_Name__c = acc.Name;
        auth.Customer__c = acc.Id;
        auth.asp04__First_Name__c = acc.First_Name__c;
        auth.asp04__Last_Name__c = acc.Last_Name__c;
        auth.asp04__Email__c = acc.Email__c;
        auth.Online_Booking__c = FALSE;
        auth.asp04__Status__c = 'Pending';
        auth.Send_Email__c = TRUE;
        auth.Customer_Email__c = acc.Email__c;
        auth.asp04__Billing_Address_Street__c = acc.BillingStreet;
        auth.asp04__Billing_Address_City__c = acc.BillingCity;
        auth.asp04__Billing_Address_Country__c = acc.BillingCountry;
        auth.asp04__Billing_Address_PostalCode__c = acc.BillingPostalCode;
        insert auth;
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        Online_Bookings__c dd3 = new Online_Bookings__c();
        dd3.Work_Type__c = wtyp.Id;
        dd3.Existing_Customer__c = 'Yes';
        dd3.Customer_first_name__c = 'Flying';
        dd3.Customer_last_name__c = 'Jack 02';
        dd3.Address_line_1__c = '8';
        dd3.Account_Number__c = acc.Account_Reference__c;
        dd3.Address_line_2__c = 'Allington way';
        dd3.TownCity__c = 'Swanley';
        dd3.Postcode__c = 'BR8 8FG';
        dd3.Preferred_arrival_time_slot__c = '09:00 - 12:00';
        dd3.Preferred_date__c = system.today();
        dd3.Customer_email__c= 'dasfrog.web@gmail.com';
        dd3.Property_access_details__c = '2333';
        ddlist.add(dd3);
        test.startTest();
        insert ddlist;
        test.stopTest();
        
        
    }
    
    static testmethod void addExistingUserWithEmailBookingEntries3() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysAd = new User(Alias = 'standt', Email='sysAdminuser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=uniqueUserName);
        
        WorkType wtyp = new worktype();
        System.runAs(sysAd) {
            
            wtyp.Name = 'Electrical';
            wtyp.EstimatedDuration = 1.00;
            wtyp.DurationType = 'Hours';
            wtyp.Trade__c = wt_trade;
            insert wtyp;
        }
        
        
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        Profile pr = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standardusersai@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pr.Id, 
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
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'Yes';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 02';
        dd2.Account_Number__c = acc.Account_Reference__c;
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        test.startTest();
        insert ddlist;
        Map<Account,list<Online_Bookings__c>> accBookMap = new Map<Account,list<Online_Bookings__c>>();
        accBookMap.put(acc,ddlist);
        List<id> accId = new List<id>();
        try{
            
            accId.add(dd2.id);
            OnlineBookingProcessHelper.deleteONBrecords(accId); 
            
        }catch(Exception ex){
            
        }
        
        test.stopTest();
        
        
        
        
    }
    
    static testmethod void addExistingUserWithNoRateBookingEntries() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'Yes';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Account_Number__c = acc.Account_Reference__c;
        dd2.Customer_last_name__c = 'Jack 02';
        dd2.Address_line_1__c = '8';
        dd2.Address_line_2__c = 'Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        test.startTest();
        insert ddlist;
        test.stopTest();
        
        
    }
    
    static testmethod void addExistingUserWithINFORceAuth() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        dd2.Account_Number__c = acc.Account_Reference__c;
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
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
        
        asp04__Authorisation__c authToUpdate = new asp04__Authorisation__c();
        authToUpdate.asp04__Status__c = 'In Force';
        authToUpdate.Id = auth.Id;
        update authToUpdate;
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        
        
        Online_Bookings__c dd3 = new Online_Bookings__c();
        dd3.Work_Type__c = wtyp.Id;
        dd3.Existing_Customer__c = 'Yes';
        dd3.Customer_first_name__c = 'Flying';
        dd3.Customer_last_name__c = 'Jack 02';
        dd3.Account_Number__c = acc.Account_Reference__c;
        dd3.Address_line_1__c = '8';
        dd3.Address_line_2__c = 'Allington way';
        dd3.TownCity__c = 'Swanley';
        dd3.Postcode__c = 'BR8 8FG';
        dd3.Preferred_arrival_time_slot__c = '09:00 - 12:00';
        dd3.Preferred_date__c = system.today();
        dd3.Customer_email__c= 'dasfrog.web@gmail.com';
        dd3.Property_access_details__c = '2333';
        ddlist.add(dd3);
        test.startTest();
        DateTime dt = OnlineBookingProcessHelper.calculateSchedule_Slot(Wo,'Start',2);
        insert ddlist;
        test.stopTest();
    }
    
    static testmethod void addExistingUserWithEmailBookingEntries5(){
        
        Id RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Reactive').getRecordTypeId();
        
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
            wo.RecordTypeId = RecordTypeId;
            wo.Trade_Rate__c = rct.Id;
            insert wo;
            
            ServiceAppointment sa = new ServiceAppointment();
            sa.ParentRecordId = wo.Id;
            sa.ContactId = con.id;
            sa.Contact_Email__c = acc.Email__c;
            sa.EarliestStartTime = system.now();
            sa.DueDate = system.now();
            sa.SchedStartTime = system.now();
            sa.SchedEndTime = system.now()+1;
            sa.Duration = wo.Duration;
            sa.Status = 'New';
            insert sa;
            
            ServiceAppointment sa1 = new ServiceAppointment();
            sa1.ParentRecordId = wo.Id;
            sa1.ContactId = con.id;
            sa1.Contact_Email__c = acc.Email__c;
            sa1.EarliestStartTime = system.now();
            sa1.DueDate = system.now();
            sa1.SchedStartTime = system.now();
            sa1.SchedEndTime = system.now()+1;
            sa1.Duration = wo.Duration;
            sa1.Status = 'New';
            try{
               // insert sa1;
            }catch(exception ex){
            }
            Test.startTest();
            List<ServiceAppointment> serv = new List<ServiceAppointment>();
            serv.add(sa);
            try{
                OnlineBookingProcessHelper.createAssignedResource(serv); 
            }catch(Exception ex){}
            
            Test.stopTest();
        }
    }
    
    static testmethod void addExistingUserWithINFORceAuthFutureDate() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        dd2.Address_line_1__c = '8 Allington way';
        dd2.Account__c = acc.Account_Reference__c;
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '08:00 - 12:00';
        dd2.Preferred_date__c = system.today()-2;
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
        
        asp04__Authorisation__c auth = new asp04__Authorisation__c();
        auth.asp04__Account_Name__c = acc.Name;
        auth.Customer__c = acc.Id;
        auth.asp04__First_Name__c = acc.First_Name__c;
        auth.asp04__Last_Name__c = acc.Last_Name__c;
        auth.asp04__Email__c = acc.Email__c;
        auth.Online_Booking__c = FALSE;
        auth.Send_Email__c = TRUE;
        auth.Customer_Email__c = acc.Email__c;
        auth.asp04__Billing_Address_Street__c = acc.BillingStreet;
        auth.asp04__Billing_Address_City__c = acc.BillingCity;
        auth.asp04__Billing_Address_Country__c = acc.BillingCountry;
        auth.asp04__Billing_Address_PostalCode__c = acc.BillingPostalCode;
        insert auth;
        
        asp04__Authorisation__c authToUpdate = new asp04__Authorisation__c();
        authToUpdate.asp04__Status__c = 'In Force';
        authToUpdate.Id = auth.Id;
        update authToUpdate;
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        
        
        Online_Bookings__c dd3 = new Online_Bookings__c();
        dd3.Work_Type__c = wtyp.Id;
        dd3.Existing_Customer__c = 'Yes';
        dd3.Customer_first_name__c = 'Flying';
        dd3.Customer_last_name__c = 'Jack 02';
        dd3.Address_line_1__c = '8';
        dd3.Account__c = acc.Account_Reference__c;
        dd3.Address_line_2__c = 'Allington way';
        dd3.TownCity__c = 'Swanley';
        dd3.Postcode__c = 'BR8 8FG';
        dd3.Preferred_arrival_time_slot__c = '09:00 - 12:00';
        dd3.Preferred_date__c = system.today()+1;
        dd3.Customer_email__c= 'dasfrog.web@gmail.com';
        dd3.Property_access_details__c = '2333';
        ddlist.add(dd3);
        test.startTest();
        insert ddlist;
        Integer rec = OnlineBookingProcessHelper.getWorkOrdersDuration(Wo);
        test.stopTest();
        
    }
    
    static testmethod void addExistingUserWithINFORceAuthPastDate() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
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
        insert acc;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
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
        
        asp04__Authorisation__c auth = new asp04__Authorisation__c();
        auth.asp04__Account_Name__c = acc.Name;
        auth.Customer__c = acc.Id;
        auth.asp04__First_Name__c = acc.First_Name__c;
        auth.asp04__Last_Name__c = acc.Last_Name__c;
        auth.asp04__Email__c = acc.Email__c;
        auth.Online_Booking__c = FALSE;
        auth.Send_Email__c = TRUE;
        auth.Customer_Email__c = acc.Email__c;
        auth.asp04__Billing_Address_Street__c = acc.BillingStreet;
        auth.asp04__Billing_Address_City__c = acc.BillingCity;
        auth.asp04__Billing_Address_Country__c = acc.BillingCountry;
        auth.asp04__Billing_Address_PostalCode__c = acc.BillingPostalCode;
        insert auth;
        
        asp04__Authorisation__c authToUpdate = new asp04__Authorisation__c();
        authToUpdate.asp04__Status__c = 'In Force';
        authToUpdate.Id = auth.Id;
        update authToUpdate;
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>();
        
        
        
        Online_Bookings__c dd3 = new Online_Bookings__c();
        dd3.Work_Type__c = wtyp.Id;
        dd3.Existing_Customer__c = 'Yes';
        dd3.Customer_first_name__c = 'Flying';
        dd3.Customer_last_name__c = 'Jack 02';
        dd3.Address_line_1__c = '8';
        dd3.Account__c = acc.Account_Reference__c;
        dd3.Address_line_2__c = 'Allington way';
        dd3.TownCity__c = 'Swanley';
        dd3.Postcode__c = 'BR8 8FG';
        dd3.Preferred_arrival_time_slot__c = ''+(System.now().hour())+':00 - '+(System.now().hour()+3)+':00';
        dd3.Preferred_date__c = system.today()-5;
        dd3.Customer_email__c= 'dasfrog.web@gmail.com';
        dd3.Property_access_details__c = '2333';
        ddlist.add(dd3);
        test.startTest();
        insert ddlist;
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
    
    static testmethod void addNewUserNinepmtoSevenam() {
        
        createAsperatoSetup();
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        String wt_trade = tradeRec.Name;
        
        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        
        WorkType wtyp = new worktype();
        wtyp.Name = 'Building Online Booking';
        wtyp.EstimatedDuration = 1.00;
        wtyp.DurationType = 'Hours';
        wtyp.Trade__c = wt_trade;
        insert wtyp;
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        /*
Rate_Cards__c rtc = new Rate_Cards__c();
rtc.Trade__c = wt_trade;
rtc.CurrencyIsoCode = 'GBP';
insert rtc;
*/
        createRates(rca.Id, tradeRec.Id);
        
        list<Online_Bookings__c> ddlist = new list<Online_Bookings__c>(); 
        
        Online_Bookings__c dd2 = new Online_Bookings__c();
        dd2.Work_Type__c = wtyp.Id;
        dd2.Existing_Customer__c = 'No';
        dd2.Customer_first_name__c = 'Flying';
        dd2.Customer_last_name__c = 'Jack 100';
        dd2.Address_line_1__c = '8 Allington way';
        dd2.TownCity__c = 'Swanley';
        dd2.Postcode__c = 'BR8 8FG';
        dd2.Preferred_arrival_time_slot__c = '21:00 - 07:00';
        dd2.Preferred_date__c = system.today();
        dd2.Hourly_rate__c = 90.00;
        dd2.Customer_email__c= 'dasfrog.web@gmail.com';
        dd2.Property_access_details__c = '2333';
        ddlist.add(dd2);
        test.startTest();
        insert ddlist;
        test.stopTest();
    }
    
    public static void createRates(Id rcaId, Id tradeId){
        
        Trade__c tradeRec = new Trade__c();
        tradeRec.Name = 'Roofing';
        insert tradeRec;
        
        Rate_Card_Trade__c rct = new Rate_Card_Trade__c();
        rct.Rate_Card__c = rcaId;
        rct.Trade__c = tradeId;
        rct.Charge_R1__c = 10;rct.Charge_R2__c = 20;rct.Charge_R3__c= 30;
        rct.Pay_Tier_1__c = 4;rct.Pay_Tier_2__c = 4;
        rct.Pay_Tier_3__c= 5;rct.Pay_Tier_4__c = 6;
        rct.Pay_Tier_5__c = 3;rct.Pay_Tier_6__c = 7;
        rct.Pay_Tier_7__c = 21;rct.Pay_Tier_8__c = 9;
        rct.Pay_Tier_9__c = 25;rct.Pay_Tier_10__c = 12;
        insert rct;
        
        Rate_Card_Trade__c rct2 = new Rate_Card_Trade__c();
        rct2.Rate_Card__c = rcaId;
        rct2.Trade__c = tradeId;
        rct2.Charge_R1__c = 10;rct2.Charge_R2__c = 20;rct2.Charge_R3__c= 30;
        rct2.Pay_Tier_1__c = 4;rct2.Pay_Tier_2__c = 4;
        rct2.Pay_Tier_3__c= 5;rct2.Pay_Tier_4__c = 6;
        rct2.Pay_Tier_5__c = 3;rct2.Pay_Tier_6__c = 7;
        rct2.Pay_Tier_7__c = 21;rct2.Pay_Tier_8__c = 9;
        rct2.Pay_Tier_9__c = 25;rct2.Pay_Tier_10__c = 12;
        insert rct2;
    } 
}