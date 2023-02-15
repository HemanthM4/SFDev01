@isTest
public class ScheduleAccountUpdateTest {
    static testMethod void createAccount() {
        Account acc = new Account();
        acc.Name ='Test';
        acc.Account_Type__c = 'Key Account';
        acc.Client_Alert__c ='Test';
        acc.Client_Alert_1__c ='Test';
        acc.Client_Alert_2__c ='Test';
        acc.Account_Type__c = 'Cash';
        insert acc;
        
        Customer_Invoice__c customer = new Customer_Invoice__c();
        customer.Account__c = acc.id;
        insert  customer;
        Account acc1 = new Account();
        acc1.Name ='Test';
        acc1.Account_Type__c = 'Key Account';
        acc1.Client_Alert__c ='Test';
        acc1.Client_Alert_1__c ='Test';
        acc1.Client_Alert_2__c ='Test';
        acc1.Account_Type__c = 'Cash';
        insert acc1;
        
        Customer_Invoice__c customer1 = new Customer_Invoice__c();
        customer1.Account__c = acc1.id;
        insert  customer1;
        
        Customer_Invoice_Line_Item__c cusInvoice = new Customer_Invoice_Line_Item__c();
        cusInvoice.Customer_Invoice__c = customer1.id;
        cusInvoice.Charge_Net__c =100.00;
        cusInvoice.VAT_Rate__c ='5';
        insert  cusInvoice;
        
        Test.startTest();
        ScheduleAccountUpdate sh1 = new ScheduleAccountUpdate();
        
        String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        ScheduleBatchAccountUpdate.sendEMail('Test','Account');
        Test.stopTest();
    }
}