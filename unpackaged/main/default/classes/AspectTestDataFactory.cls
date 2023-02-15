@isTest
public class AspectTestDataFactory {
    
    
    public static Account createAccount(){
        
        Account acc = new Account(
            Name = 'Account Test',
            First_Name__c = 'Account',
            Last_Name__c = 'Test',
            Email__c = 'dasfrog.web@gmail.com',
            Invoicing_Email_Address__c = 'dasfrog.web@gmail.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial').getRecordTypeId(),
            Account_Type__c = 'Cash',
            Account_Status__c = 'Open',
            BillingStreet = '8 Allington way',
            BillingCity = 'Swanley',
            BillingCountry = 'United Kingdom',
            BillingPostalCode = 'BR8 8FG',
            Access_Details__c = '2333'
        );
        insert acc;
        return acc;
    }
    public static Contact createContact(Account acc){ 
        Contact con = new Contact(
            AccountId = acc.Id,
            FirstName = acc.First_Name__c,
            LastName = acc.Last_Name__c,
            Email = acc.Email__c
        );
        insert con;
        return con;
    }   
    public static Site__c createSite(Account acc, Contact con){
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
        return site;
        
    }
    public static WorkType createWorkType(){
        WorkType wt = new WorkType(
            EstimatedDuration = 2,
            Name = 'tmp'
        );
        insert wt;
        return wt;
    }   
    public static Job__c createJob(Account acc, WorkType wType, Site__c site){    
        Job__c job = new Job__c();
        job.Account__c = acc.id;
        job.Job_Type__c = WType.id;
        Job.Site__c = site.id;
        insert job;
        return job;
    }  
    public static WorkOrder createWO(Job__c job, WorkType wType, Costs_and_Charges__c cAndC){    
        WorkOrder workOdr = new WorkOrder();
        workOdr.Job__c = job.id;
        workOdr.WorkTypeId = WType.id;
        workOdr.Costs_and_Charges__c = cAndC.id;
        insert workOdr;
        return workOdr;
    }  
    public static Costs_and_Charges__c createCandC(Job__c job){      
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
        return cct;
    } 
    public static Customer_Invoice__c createCustInvoice(Account acc, Job__c job){  
        Customer_Invoice__c invoice = new Customer_Invoice__c();
        invoice.Account__c = acc.Id;
        invoice.Account_Email_Address__c = 'chumley.testing@aspect.co.uk';
        invoice.Job__c = job.Id;
        insert invoice;
        return invoice;
    }
    public static Customer_Credit_Note__c createCustCreditNote(Account acc, Customer_Invoice__c invoice){
        Customer_Credit_Note__c  crNote = new Customer_Credit_Note__c ();
        crNote.Account_Details__c  = acc.Id;
        crNote.Customer_Invoice__c = invoice.Id;
        crNote.Amount__c = 100;
        crNote.Account_Email__c = 'test@gmail.com';
        insert crNote;
        return crNote;
    }
    public static asp04__Payment__c createPayment(Account acc, Customer_Invoice__c invoice){
        insert new asp04__AsperatoOneSettings__c(asp04__Customer_ID__c = '1');
        asp04__Payment__c payment = new asp04__Payment__c();
        payment.Customer_Invoice__c = invoice.Id;
        payment.Customer__c = acc.Id;
        payment.asp04__Amount__c = 100;
        payment.asp04__Payment_Route_Selected__c = 'Card';
        payment.asp04__Payment_Stage__c = 'Collected from customer';
        payment.Is_SRI_Candidate__c = FALSE;
        insert payment;
        return payment;
    }  
    public static Purchase_Order__c createPurchaseOrder(Site__c site){
        Purchase_Order__c purOrder = new Purchase_Order__c();
        purOrder.Supplier_Site__c = site.Id;
        purOrder.Supplier_Account__c = site.Account__c;
        purOrder.Delivery_Options__c = 'Engineer to Collect';
        insert purOrder;
        return purOrder;
    }
    public static Supplier_Invoice__c createSuppInvoice(Site__c site){
        Supplier_Invoice__c suppInvoice = new Supplier_Invoice__c();
        suppInvoice.Purchase_Order__c = createPurchaseOrder(site).Id;
        suppInvoice.Invoice_Date__c = System.today();
        insert suppInvoice;
        return suppInvoice;
    }
    public static Supplier_Credit_Note__c createSuppCrNote(Supplier_Invoice__c suppInvoice){
        Supplier_Credit_Note__c suppCreditNote = new Supplier_Credit_Note__c();
        suppCreditNote.Supplier_Invoice__c = suppInvoice.Id;
        insert suppCreditNote;
        return suppCreditNote;
    }
    public static asp04__Refund__c createRefund(asp04__Payment__c payment, Customer_Invoice__c invoice){
        asp04__Refund__c refund = new asp04__Refund__c();
        refund.asp04__Payment__c = payment.Id;
        refund.Account__c = invoice.Account__c;
        refund.Customer_Invoice__c = invoice.Id;
        insert refund;
        return refund;
    }
}