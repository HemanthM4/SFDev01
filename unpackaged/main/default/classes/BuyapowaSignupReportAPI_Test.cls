/*
* Class  : BuyapowaSignupReportAPI_Test
* Use    : This test class is written to get coverage for class BuyapowaSignupReportAPI .
* Auther : Bharat Vyas, 10/8/2022
*/
@isTest
public class BuyapowaSignupReportAPI_Test {

    @isTest static void testSingnupAPI(){
        
        Account acc = new Account(
            Name = 'Account Test',
            First_Name__c = 'Account',
            Last_Name__c = 'Test',
            Email__c = 'test_here@gmail.com',
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
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForSignUpReportAPI()); 
        String CRON_EXP = '0 20 10 * * ? 2022'; 
        String jobId = System.schedule('ScheduledSignupReportAPI', CRON_EXP, new BuyapowaSignupReportAPI());
        Test.stopTest();
    }
}