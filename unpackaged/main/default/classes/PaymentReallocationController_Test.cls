@isTest
public class PaymentReallocationController_Test {
    
    static testmethod void paymentInsertTest(){
	/*
    Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
	*/        
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
        //acc.Rate_Card__c = rcaStand.Id;
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
        job.Job_Raised_by__c = con.Id;
        insert job;
        
        Customer_Invoice__c custInvoice = new Customer_Invoice__c();
        custInvoice.Job__c = job.Id;
        custInvoice.Account__c = acc.Id;
        custInvoice.Date__c = DATE.today();
        custInvoice.Account_Email_Address__c = 'test@test.com';
        custInvoice.Sum_of_Payments__c = 50;
        custInvoice.Job_Contact__c = job.Job_Raised_by__c;
        custInvoice.Status__c = 'Outstanding';
        custInvoice.Exchequer_Export__c = 'Not Sent';
        insert custInvoice;
        
        Customer_Invoice__c custInvoice1 = new Customer_Invoice__c();
        custInvoice1.Job__c = job.Id;
        custInvoice1.Account__c = acc.Id;
        custInvoice1.Date__c = DATE.today();
        custInvoice1.Account_Email_Address__c = 'test@test.com';
        custInvoice1.Sum_of_Payments__c = 50;
        custInvoice1.Job_Contact__c = job.Job_Raised_by__c;
        custInvoice1.Status__c = 'Outstanding';
        custInvoice1.Exchequer_Export__c = 'Not Sent';
        insert custInvoice1;
        
        insert new asp04__AsperatoOneSettings__c(asp04__Customer_ID__c = '1');
        List<asp04__Payment__c> paymentListInsert = new List<asp04__Payment__c>();
        List<asp04__Payment__c> paymentListUpdate = new List<asp04__Payment__c>();
        
        asp04__Payment__c payRec = new asp04__Payment__c();
        payRec.Customer_Invoice__c = custInvoice.Id;
        payRec.asp04__Amount__c = 100;
        payRec.asp04__Payment_Route_Selected__c = 'Card';
        payRec.asp04__Payment_Stage__c = 'Collected from customer';
        payRec.Is_SRI_Candidate__c = FALSE;
        paymentListInsert.add(payRec);
        
        asp04__Payment__c payRec1 = new asp04__Payment__c();
        payRec1.Customer_Invoice__c = custInvoice.Id;
        payRec1.asp04__Amount__c = 100;
        payRec1.asp04__Payment_Route_Selected__c = 'Card';
        payRec1.asp04__Payment_Stage__c = 'Collected from customer';
        payRec1.Is_SRI_Candidate__c = FALSE;
        paymentListInsert.add(payRec1);
        
        asp04__Payment__c payRec2 = new asp04__Payment__c();
        payRec2.Customer_Invoice__c = custInvoice.Id;
        payRec2.asp04__Amount__c = 50;
        payRec2.asp04__Payment_Route_Selected__c = 'Card';
        payRec2.asp04__Payment_Stage__c = 'Collected from customer';
        payRec2.Is_SRI_Candidate__c = FALSE;
        paymentListInsert.add(payRec2);
        
        asp04__Payment__c payRec3 = new asp04__Payment__c();
        payRec3.Customer_Invoice__c = custInvoice.Id;
        payRec3.asp04__Amount__c = 50;
        payRec3.asp04__Payment_Route_Selected__c = 'Card';
        payRec3.asp04__Payment_Stage__c = 'Collected from customer';
        payRec3.Is_SRI_Candidate__c = FALSE;
        paymentListInsert.add(payRec3);
        
        insert paymentListInsert;

        payRec2.asp04__Amount__c = 200;
        paymentListUpdate.add(payRec2);
        
        payRec.Customer_Invoice__c = custInvoice1.Id;
        paymentListUpdate.add(payRec);
        
        payRec1.asp04__Payment_Stage__c = 'Failed';
        paymentListUpdate.add(payRec1);
        
        update paymentListUpdate;
    }
}