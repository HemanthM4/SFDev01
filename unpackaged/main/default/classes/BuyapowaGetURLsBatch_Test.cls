/*
* Class  : BuyapowaGetURLsBatch_Test
* Use    : This test class is written to get test coverage of BuyapowaGetURLsBatch class.
* Auther : Bharat Vyas, 21/7/2022
*/
@isTest
public class BuyapowaGetURLsBatch_Test {
    
    static testMethod void testMethodForGetURLs() 
    {
        List<Account> lstAccount= new List<Account>();
        
        Account acc = new Account(
            Name = 'Account Test1',
            Email__c = 'test_here1@gmail.com',
            Pending_Referrer__c = true,
            Account_Type__c = 'Cash',
            Account_Status__c = 'Open',
            BillingStreet = '8 Allington way',
            BillingCity = 'Swanley',
            BillingCountry = 'United Kingdom',
            BillingPostalCode = 'BR8 8FG',
            Access_Details__c = '2333'
        );
        lstAccount.add(acc);
        acc = new Account(
            Name = 'Account Test2',
            Email__c = 'test_here2@gmail.com',
            Pending_Referrer__c = false,
            Account_Type__c = 'Cash',
            Account_Status__c = 'Open',
            BillingStreet = '8 Allington way',
            BillingCity = 'Swanley',
            BillingCountry = 'United Kingdom',
            BillingPostalCode = 'BR8 8FG',
            Access_Details__c = '2333'
        );
        lstAccount.add(acc);
        
        insert lstAccount;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForBuyapowaGetURLsBatch());
        String CRON_EXP = '0 15 * * * ? 2022';
        String jobId = System.schedule('buyapowaGetURLsBatch', CRON_EXP, new BuyapowaGetURLsBatch());
        Test.stopTest();
    }
}