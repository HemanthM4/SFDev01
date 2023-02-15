/*
* Class  : BuyapowaFriendVouDistriReportAPI_Test
* Use    : This test class is written to get test coverage of BuyapowaGetURLsBatch class.
* Auther : Bharat Vyas, 21/7/2022
*/
@isTest
public class BuyapowaFriendVouDistriReportAPI_Test {

    @isTest static void testSingnupAPI(){
        
        Account acc = new Account(
            Name = 'Account Test',
            First_Name__c = 'Account',
            Last_Name__c = 'Test',
            Email__c = 'john@doe.com',
            Pending_Referrer__c = true,
            Account_Type__c = 'Cash',
            Account_Status__c = 'Open',
            BillingStreet = '8 Allington way',
            BillingCity = 'Swanley',
            BillingCountry = 'United Kingdom',
            BillingPostalCode = 'BR8 8FG',
            Access_Details__c = '2333'
        );
        insert acc;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForFriendVouAPI()); 
        String CRON_EXP = '0 0 10 * * ? 2022'; 
        String jobId = System.schedule('ScheduledBuyapowaFriendVoDistriReportAPI', CRON_EXP, new BuyapowaFriendVoucherDistriReportAPI());
        Test.stopTest();
    }    
}