/*
* Class  : MockHttpResponseForBuyapowaGetURLsBatch
* Use    : This MockResponse class is written to get coverage for class BuyapowaGetURLsBatch .
* Auther : Bharat Vyas, 12/8/2022
*/
@isTest
public class MockHttpResponseForBuyapowaGetURLsBatch implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String fakeResp = '{"email":"test_here1@gmail.com","first_name":"Account","last_name":"Test1","share_url":"https://refer.aspect.co.uk/xjEOhgx","dashboard_url":"http://aspect.co-buying.com/tests/invite-a-friend.html?bp_p=%2Fiaf%2Faspect_raf1%3Fauth_token%3DWY4Bb6yyJ-xSAn5zvyuZ\u0026locale=en\u0026slug=aspect_raf1","status":"already_signed_up_to_campaign","custom_field_value":"0013H00000Qt09rQAB","locale":"en"}';
        res.setBody(fakeResp);
        res.setStatusCode(200);
        return res;
    }
}