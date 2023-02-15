/*
* Class  : MockHttpResponseForFriendVouAPI
* Use    : This MockResponse class is written to get coverage for class BuyapowaFriendVoucherDistriReportAPI .
* Auther : Bharat Vyas, 10/8/2022
*/
@isTest
public class MockHttpResponseForFriendVouAPI implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
		String fakeResp = 'voucher_code,friend_name,friend_email,referred_friend_phone_number,friend_marketing_opt_in,voucher_distributed_at,referring_customer_name,referring_customer_email,referring_customer_account_id\n "FRIEND30_58","Mark Smith","marksmith@gmail.com","","f","2022-09-02 09:51:22","john doe","john@doe.com","123242"';
        res.setBody(fakeResp);
        res.setStatusCode(200);
        return res;
    }
}