@istest
public class AccountStatementControllerTest {

    static testmethod void wt_resource_list_test(){
        
        
        Account acc = new Account(
                Name = 'Invoice Test',
                First_Name__c = 'Invoice',
                Last_Name__c = 'Test',
                Email__c = 'dasfrog.web@gmail.com',
                Invoicing_Email_Address__c = 'dasfrog.web@gmail.com',
                Account_Type__c = 'Cash',
                Account_Status__c = 'Open',
                BillingStreet = '8 Allington way',
                BillingCity = 'Swanley',
                BillingCountry = 'United Kingdom',
                BillingPostalCode = 'BR8 8FG',
                Access_Details__c = '2333'
            );
            insert acc;
        
        Customer_Invoice__c inv =   new Customer_Invoice__c(
            Account__c = acc.id,
            Date__c = DATE.today()-31,
            Sum_of_Payments__c = 0,
            RecordTypeID = Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosByName().get('Deposit').getRecordTypeId()
        );
        insert inv;
    	insert new Customer_Invoice_Line_Item__c(
            Customer_Invoice__c = inv.id,
            Charge_Net__c = 100,
            VAT_Rate__c = '20'
        );
   
             Customer_Invoice__c inv2 =   new Customer_Invoice__c(
            Account__c = acc.id,
            Date__c = DATE.today()-61,
            Sum_of_Payments__c = 0,
            RecordTypeID = Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosByName().get('Deposit').getRecordTypeId()
        );
        insert inv2;
    	insert new Customer_Invoice_Line_Item__c(
            Customer_Invoice__c = inv2.id,
            Charge_Net__c = 100,
            VAT_Rate__c = '20'
        );
                Customer_Invoice__c inv3 =   new Customer_Invoice__c(
            Account__c = acc.id,
            Date__c = DATE.today()-91,
            Sum_of_Payments__c = 0,
            RecordTypeID = Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosByName().get('Deposit').getRecordTypeId()
        );
        insert inv3;
    	insert new Customer_Invoice_Line_Item__c(
            Customer_Invoice__c = inv3.id,
            Charge_Net__c = 100,
            VAT_Rate__c = '20'
        );
                Customer_Invoice__c inv4 =   new Customer_Invoice__c(
            Account__c = acc.id,
            Date__c = DATE.today()-121,
            Sum_of_Payments__c = 0,
            RecordTypeID = Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosByName().get('Deposit').getRecordTypeId()
        );
        insert inv4;
    	insert new Customer_Invoice_Line_Item__c(
            Customer_Invoice__c = inv4.id,
            Charge_Net__c = 100,
            VAT_Rate__c = '20'
        );
        
        
        ///////////////////////////////////
        Test.startTest();
        
        //ApexPages.StandardController sc = new ApexPages.StandardController(acc);
  		//myControllerExtension testAccPlan = new myControllerExtension(sc);

  		PageReference pageRef = Page.Account_Statement_Page; // Add your VF page Name here
  		pageRef.getParameters().put('id', String.valueOf(acc.Id));
        
        
        Test.setCurrentPage(pageRef);
        AccountStatementController wt_controller = new AccountStatementController();
  
        Test.stopTest();
        
    }
    
}