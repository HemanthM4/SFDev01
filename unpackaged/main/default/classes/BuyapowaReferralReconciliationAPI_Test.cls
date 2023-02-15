/*
* Class  : BuyapowaReferralReconciliationAPI_Test
* Use    : This test class is written to get coverage for class BuyapowaReferralReconciliationAPI.
* Auther : Bharat Vyas, 18/5/2022.
*/

@isTest
private class BuyapowaReferralReconciliationAPI_Test {

     @isTest static void testCallout() {
        
        Account acc = AspectTestDataFactory.createAccount();
        Contact cont = AspectTestDataFactory.createContact(acc);
        Site__c site = AspectTestDataFactory.createSite(acc, Cont);
        WorkType wType = AspectTestDataFactory.createWorkType();
        Job__c job = AspectTestDataFactory.createJob(acc, wType, site);
        
        List<BuyapowaReferralReconciliationAPI.orderDetails> orderDetailList = new List<BuyapowaReferralReconciliationAPI.orderDetails>();
        BuyapowaReferralReconciliationAPI.orderDetails ordrDetail = new BuyapowaReferralReconciliationAPI.orderDetails();
        ordrDetail.jobId = job.Id;
        ordrDetail.jobName = job.Name;
        ordrDetail.jobStatus = 'Confirmed';
         orderDetailList.add(ordrDetail);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BuyapowaRefReconciliationMockHttep()); 
        BuyapowaReferralReconciliationAPI.getOrderDetails(orderDetailList);
        Test.stopTest();
    }
}