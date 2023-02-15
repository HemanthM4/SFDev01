/*
* Class  : FinanceImportFiles
* Use    : This class is written to get test coverage of class FinanceImportFiles.
* Auther : Bharat Vyas, 31/10/2022
*/

@isTest
public class FinanceImportFiles_Test {

    @isTest static void createDummyData() {
        
        Exchequer_Export_Job__c  exportJob = new Exchequer_Export_Job__c ();
        exportJob.Name = 'S101';
        exportJob.Start_Date__c = System.today() - 30;
        exportJob.End_Date__c = system.today();
        insert exportJob;
        
        Account acc = AspectTestDataFactory.createAccount();
        Contact cont = AspectTestDataFactory.createContact(acc);
        Site__c site = AspectTestDataFactory.createSite(acc, Cont);
        WorkType wType = AspectTestDataFactory.createWorkType();
        Job__c job = AspectTestDataFactory.createJob(acc, wType, site);
        Costs_and_Charges__c cAndC = AspectTestDataFactory.createCandC(job);
        WorkOrder workOdr = AspectTestDataFactory.createWO(job, wType, cAndC);
        Customer_Invoice__c custInvoice = AspectTestDataFactory.createCustInvoice(acc, job);
        Customer_Credit_Note__c crNotes = AspectTestDataFactory.createCustCreditNote(acc, custInvoice);
        asp04__Payment__c payment = AspectTestDataFactory.createPayment(acc, custInvoice);
		Supplier_Invoice__c suppInvoice = AspectTestDataFactory.createSuppInvoice(site);
		Supplier_Credit_Note__c suppCrNote = AspectTestDataFactory.createSuppCrNote(suppInvoice);
        asp04__Refund__c refund = AspectTestDataFactory.createRefund(payment, custInvoice);
        
        FinanceImportFiles.csvObjectWrapper1 csvWrap = new FinanceImportFiles.csvObjectWrapper1();
        
        List<Account> accList = [SELECT Id, Name, Account_Reference__c, BillingStreet, BillingCity, BillingState, 
                                 BillingCountry, BillingPostalCode, Email__c, Phone, Account_Status__c, Account_Type__c, 
                                 CurrencyIsoCode, VAT_Registration_Number__c, Credit_Limit__c FROM Account WHERE
                                 Id =: acc.Id];
        
        List<Customer_Credit_Note__c> crNotesList = [SELECT Id, Name, Invoice_Number__c, Account_Number__c,
                                                     Date__c, Billing_Address_Street__c, Billing_Address_City__c,
                                                     Billing_Address_Country__c, Billing_Address_Postcode__c,
                                                     Charge_Net__c, Charge_Gross__c, Customer_Record_Type__c,
                                                     Gl_Code_Number__c FROM Customer_Credit_Note__c WHERE 
                                                     Id =:crNotes.Id];
        
        List<Customer_Invoice__c> custInvoiceList = [SELECT Id, Name, Exchequer_Account_Reference__c, Account_Number__c,
                                                      Date__c, Job_Number__c, Billing_Street__c, Billing_Town__c,
                                                      Billing_Country__c, Billing_Postcode__c, Charge_Net__c,
                                                      Charge_Gross__c, Account_Record_Type_Name__c, Exchequer_General_Ledger_Code_Number__c
                                                      FROM Customer_Invoice__c WHERE Id =: custInvoice.Id];
        
        List<Supplier_Invoice__c> suppInvoiceList = [SELECT Id, Name, Account_Reference__c, Invoice_Date__c, Supplier_Invoice_Number__c,
                                                     Supplier_Street__c, Supplier_City__c, Supplier_County__c, Supplier_Postal_Code__c,
                                                     Invoice_Value_NET__c, Invoice_Value_VAT__c, Invoice_Value_Gross__c,Purchase_Order_Number__c,
                                                     Exchequer_Department_Ref__c, Exchequer_General_Ledger_Code_Number__c FROM Supplier_Invoice__c
                                                     WHERE Id =: suppInvoice.Id];
        
        List<asp04__Payment__c> paymentList = [SELECT Id, Name, Customer_Invoice_Name__c, asp04__Payment_Date__c, Account_Number__c, asp04__Due_Date__c,
                                               asp04__Billing_Address_Street__c, asp04__Billing_Address_City__c, asp04__Billing_Address_Country__c,
                                               asp04__Billing_Address_PostalCode__c, asp04__Amount__c, asp04__PSP_Reference__c, Job_Number__c,
                                               Customer_Record_Type__c, asp04__Card_Type__c, Customer_Invoice__r.Name, Customer_Invoice__r.Account_Number__c, 
                                               Customer_Invoice__r.Date__c, Customer_Invoice__r.Job_Number__c, Customer_Invoice__r.Billing_Street__c, 
                                               Customer_Invoice__r.Billing_Town__c, Customer_Invoice__r.Billing_Country__c, Customer_Invoice__r.Billing_Postcode__c,
                                               Customer_Invoice__r.Charge_Gross__c, Customer_Invoice__r.Charge_Net__c, Customer_Invoice__r.Account_Record_Type_Name__c, 
                                               Customer_Invoice__r.Exchequer_General_Ledger_Code_Number__c FROM asp04__Payment__c WHERE Id =: payment.Id];
       
        List<Supplier_Credit_Note__c> suppCrNoteList = [SELECT Id, Name, Account_Code__c, Credit_Value_Gross__c, Credit_Value_NET__c,Supplier_Credit_Note_Date__c,
                                                        Credit_Value_VAT__c, GL_Code_Number__c, Supplier_Address_City__c, Supplier_Address_Country__c,
                                                        Supplier_Address_Postcode__c, Supplier_Address_Street__c, Supplier_Credit_Note_Number__c,
                                                        Supplier_Invoice__r.Name FROM Supplier_Credit_Note__c WHERE Id =: suppCrNote.Id];
        
        List<asp04__Refund__c> refundList = [SELECT Id, Name, Account_Number__c,asp04__Payment_Date__c,Job_Number__c,
                                             Billing_Address_Street__c, Billing_Address_City__c, Billing_Address_Country__c,
                                             Billing_Address_Postcode__c, asp04__Amount__c, PSP_Reference__c, 
                                             Customer_Record_Type__c, Card_Type__c FROM asp04__Refund__c WHERE Id =: refund.Id];
        
        csvWrap.excJobRecId = exportJob.Id;
        csvWrap.accList = accList;
        csvWrap.custInvoiceList = custInvoiceList;
        csvWrap.custCreditNoteList = crNotesList;
        csvWrap.paymentList = paymentList;
        csvWrap.MatchedInvoiceList = paymentList;
        csvWrap.suppInvoiceList = suppInvoiceList;
        csvWrap.suppCreditNoteList = suppCrNoteList;
        csvWrap.refundList = refundList;
        
		List<FinanceImportFiles.csvObjectWrapper1> csvObjectWrapperList = new List<FinanceImportFiles.csvObjectWrapper1>();
        csvObjectWrapperList.add(csvWrap);
            
        System.enqueueJob(new FinanceImportFiles(csvObjectWrapperList));    
     }
}