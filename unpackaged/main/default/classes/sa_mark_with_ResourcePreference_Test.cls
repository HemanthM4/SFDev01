@isTest
public class sa_mark_with_ResourcePreference_Test {

    static testmethod void testResourcePref() {
        
        
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
        cct.Call_Out_Fee__c = 0;
        insert cct;
        
        WorkOrder wo = new WorkOrder();
                wo.Job__c = job.Id;
                //wo.Online_Booking__c = bb.Id;
                wo.WorkTypeId = wt.Id;//Id input from the form submitted online
                wo.Description = 'Blah blah';
                //wo.Requested_Date__c = dd2.Preferred_date__c;
                //wo.Arrival_Window_Start__c = OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0]));
               // wo.Arrival_Window_End__c = OnlineBookingProcessHelper.formatTime(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1]); 
                //wo.Access_Details__c = dd2.Property_access_details__c;
                wo.ContactId = con.Id;
                wo.AccountId = acc.Id;
                wo.Site__c = site.Id;
                wo.Duration = wt.EstimatedDuration;
                wo.country = 'United Kingdom';
        wo.Scope_of_Works_Amended_by_Operative__c = 'test';
        wo.Arrival_Window_Start_Date_Time__c = system.now();
        wo.Arrival_Window_End_Date_Time__c = system.now();
        wo.Scope_of_Works_2__c = 'a';
        wo.Scope_of_Works_3__c = 'a';
        
                wo.Costs_and_Charges__c = cct.Id;
                //wo.Arrival_Window_Start_Date_Time__c = Datetime.newInstance(dd2.Preferred_date__c.year(), dd2.Preferred_date__c.month(), dd2.Preferred_date__c.day(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0])).hour(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[0])).minute(), 0);
                //wo.Arrival_Window_End_Date_Time__c = Datetime.newInstance(dd2.Preferred_date__c.year(), dd2.Preferred_date__c.month(), dd2.Preferred_date__c.day(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1])).hour(), OnlineBookingProcessHelper.formatTime(String.valueOf(dd2.Preferred_arrival_time_slot__c.Split(' - ')[1])).minute(), 0);
        //wo.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('WorkOrder','Reactive');     
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
        
        
        /////////

        sa.ParentRecordId = wo.Id;
        sa.ContactId = con.Id;
        sa.Contact_Email__c = acc.Email__c;
        
        sa.EarliestStartTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 7,0, 0);
        sa.DueDate = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 8, 0, 0);
        sa.SchedStartTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 7, 0, 0);
        sa.SchedEndTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), 8, 0, 0);
        
        sa.Duration = 1;
        sa.Status = 'New';
 
        //////////        

        insert sa;
        
        sa_mark_with_ResourcePreference.updateWOSAsLabel(wo.id);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        User u1 = new User(Alias = 'stand1', Email='standarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='wt_list_test_1@testorg.com');
        insert u1;
        
        ServiceResource sr1 = new ServiceResource();

        sr1.RelatedRecordId = u1.Id;
        sr1.Name = 'test 01res';
        sr1.FirstName__c = 'test';
        sr1.LastName__c = '01res';
        sr1.IsActive = True;
        sr1.ResourceType = 'T';
        sr1.Engineer_Role__c = 'Service_Resource';
        sr1.Rate_of_Pay_Tier__c = 'Tier 2';
        sr1.Estimate_Limit__c = 1000;
        
        insert sr1;
        
        
        ResourcePreference rpref = new ResourcePreference();
        rpref.RelatedRecordId = wo.id;
        rpref.PreferenceType = 'Required';
        rpref.ServiceResourceId = sr1.id;
        
        insert rpref;
        
        delete rpref;
        
        
        
    }
    
}