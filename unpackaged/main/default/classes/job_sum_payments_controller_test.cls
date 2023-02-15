@isTest
public class job_sum_payments_controller_test {

    static testmethod void sum_payment_test() {
        
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
        
        insert new asp04__AsperatoOneSettings__c(asp04__Customer_ID__c = '1');
        
         asp04__Authorisation__c auth = new asp04__Authorisation__c();
            auth.asp04__Account_Name__c = acc.Name;
            auth.Customer__c = acc.Id;
            auth.asp04__First_Name__c = acc.First_Name__c;
            auth.asp04__Last_Name__c = acc.Last_Name__c;
            auth.asp04__Email__c = acc.Email__c;
            auth.Online_Booking__c = FALSE;
            auth.asp04__Status__c = 'In Force';
            auth.Send_Email__c = TRUE;
            auth.Customer_Email__c = acc.Email__c;
            auth.asp04__Billing_Address_Street__c = acc.BillingStreet;
            auth.asp04__Billing_Address_City__c = acc.BillingCity;
            auth.asp04__Billing_Address_Country__c = acc.BillingCountry;
            auth.asp04__Billing_Address_PostalCode__c = acc.BillingPostalCode;
        insert auth;
        
        Job__c job = new Job__c();
        job.Account__c = acc.id;
        job.Job_Type__c = wt.id;
        Job.Site__c = site.id;
        insert job;
        
        
        Customer_Invoice__c inv = new Customer_Invoice__c();
        inv.RecordTypeID = Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosByName().get('Cancellation Invoice').getRecordTypeId();
        inv.Job__c = job.Id;
        
                   
        inv.Account__c = acc.id;
        inv.Date__c = DATE.today();
        inv.Account_Email_Address__c = acc.Invoicing_Email_Address__c;//'matthew.radoja@aspect.co.uk';//(string) cct.Job__r.Account__r.get('Invoicing_Email_Address__c');
        inv.Authorisation__c = auth.id;
        inv.Sum_of_Payments__c = 0;  
        inv.Job_Contact__c = job.Job_Raised_by__c;
        inv.Job_Description__c = job.Combined_Scope_of_Works_for_All_WOs__c;
        insert inv;
        
        
        Customer_Invoice_Line_Item__c ciliM = new Customer_Invoice_Line_Item__c();
                       
    
        ciliM.Customer_Invoice__c = inv.id;
        ciliM.Charge_Category__c = 'Labour';
        ciliM.Charge_Net__c = 100;
        ciliM.VAT_Rate__c = '20';
        //ciliM.Work_Order__c = wo.id;
        
        insert ciliM;
        
        inv.Sum_of_Payments__c = 10;
        update inv;
        
        //job_sum_payments_controller.job_sum_payments(job.id);
        
        Test.startTest();
        
        System.assertEquals(NULL, job.Payment_Value__c);
        
        
        Test.stopTest();
        
    }
    
}