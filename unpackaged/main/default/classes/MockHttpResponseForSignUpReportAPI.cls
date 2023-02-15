/*
* Class  : MockHttpResponseForSignUpReportAPI
* Use    : This MockResponse class is written to get coverage for class BuyapowaSignupReportAPI .
* Auther : Bharat Vyas, 10/8/2022
*/
@isTest
public class MockHttpResponseForSignUpReportAPI implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String fakeResp = 'Marketing Opt-in,Join Date/Time,First Name,Last Name,Email,Share URL\n"No","2021-12-21 21:22:56.344472","John","Doe","test_here@gmail.com","https://referme.to/johnd-1234"';
        res.setBody(fakeResp);
        res.setStatusCode(200);
        return res;
    }
}