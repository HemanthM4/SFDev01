/*
* Class  : BuyapowaRefReconciliationMockHttep
* Use    : This MockResponse class is written to get coverage for class BuyapowaReferralReconciliationAPI .
* Auther : Bharat Vyas, 3/10/2022
*/
@isTest
public class BuyapowaRefReconciliationMockHttep implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String fakeResp = '{"order" : {"order_number" : "J-00001","status" : "confirmed"}}';
        res.setBody(fakeResp);
        res.setStatusCode(200);
        return res;
    }
}