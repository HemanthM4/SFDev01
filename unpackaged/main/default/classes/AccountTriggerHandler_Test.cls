@istest
public class AccountTriggerHandler_Test{
	
    static testmethod void createAccAndAssociateRC(){
        
        Rate_Card_Account__c rcaStand = new Rate_Card_Account__c();
        rcaStand.Description__c = 'test';
        rcaStand.Standard__c = TRUE;            
        insert rcaStand;
        
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 05';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 05';
        acc.Email__c = 'dasfrog.web@gmaill.com';
        acc.Invoicing_Email_Address__c = 'dasfrog.web@gmaill.com';
        acc.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('Account','Domestic');
        acc.Account_Type__c = 'Cash';
        acc.Account_Status__c = 'Open';
        acc.BillingStreet = '8 Allington way';
        acc.BillingCity = 'Swanley';
        acc.BillingCountry = 'United Kingdom';
        acc.BillingPostalCode = 'BR8 8FG';
        acc.Access_Details__c = '2333';
        //acc.Rate_Card__c = rcaStand.id;
        insert acc;

        system.assertEquals(acc.Rate_Card__c, null);
    }
}