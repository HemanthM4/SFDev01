/*
* Class  : BuyapowaReferralReconciliationAPI_Test
* Use    : This test class is written to get coverage for class BuyapowaReferralReconciliationAPI.
* Auther : Bharat Vyas, 5/10/2022
*/

@isTest
private class BuyapowaReferralTrackingAPI_Test {

     @isTest static void testCallout() {
        
        Account acc = AspectTestDataFactory.createAccount();
        Contact cont = AspectTestDataFactory.createContact(acc);
        Site__c site = AspectTestDataFactory.createSite(acc, Cont);
        WorkType wType = AspectTestDataFactory.createWorkType();
        Job__c job = AspectTestDataFactory.createJob(acc, wType, site);		
        
        acc.Referral_notes__c = 'testinghere,test@gmail.com';
        update acc;
         
        List<BuyapowaReferralTrackingAPI.orderDetails> orderDetailList = new List<BuyapowaReferralTrackingAPI.orderDetails>();
        BuyapowaReferralTrackingAPI.orderDetails ordrDetail = new BuyapowaReferralTrackingAPI.orderDetails();
        ordrDetail.referrerEmail = acc.Referral_notes__c;
        ordrDetail.voucherCode = job.Promo_Code__c;
        ordrDetail.firstName = acc.First_Name__c;
        ordrDetail.lastName = acc.Last_Name__c;
        ordrDetail.email = acc.Email__c;
        ordrDetail.jobId = job.Id;
        ordrDetail.jobName = job.Name;
        ordrDetail.jobCreatedTime = System.today();
        orderDetailList.add(ordrDetail);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BuyapowaReferralTrackingAPIMockHttp()); 
        BuyapowaReferralTrackingAPI.getOrderDetails(orderDetailList);
        Test.stopTest();
    }
}