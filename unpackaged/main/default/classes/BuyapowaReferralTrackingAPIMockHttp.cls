/*
* Class  : BuyapowaReferralTrackingAPIMockHttp
* Use    : This MockResponse class is written to get coverage for class BuyapowaReferralTrackingAPI.
* Auther : Bharat Vyas, 5/10/2022
*/
@isTest
public class BuyapowaReferralTrackingAPIMockHttp implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String fakeResp = '{"order" : {"referrer_email" : "test@gmail.com","voucher_code" : "Test_30OFF","full_name" : " , Luiza","email_address" : "demo@gmail.com","marketing_opt_in" : "true","order_number" : "J-00001","order_timestamp" : "1321009871"}}';
        res.setBody(fakeResp);
        res.setStatusCode(200);
        return res;
    }
}