@isTest
public class MockHttpResponseForTrustpilotAuth implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"refresh_token_expires_in" : "7779999","refresh_token_status" : "approved","api_product_list" : "[trustpilot-client-api, public_data]","app_enduser" : "62616c359ac888bcab224999","api_product_list_json" : [ "trustpilot-client-api", "public_data" ],"organization_name" : "trustpilot","developer.email" : "dev.accounts+developerapps@trustpilot.com","token_type" : "BearerToken","issued_at" : "1653294821628","client_id" : "hrDLx20iGRpLxEAmBIGSKaggusb7qZNQ","access_token" : "MAeiR38M8QK4dbk2bWNcibG42GKM","refresh_token" : "2rxUYAoDTLULzHaadm8k5MKLYRjjDr2P","application_name" : "d2fb5c6e-1b34-459a-8fc9-aff0e9a32256","scope" : "","refresh_token_issued_at" : "1653294821628","expires_in" : "359999","refresh_count" : "0","status" : "approved"}');
        res.setStatusCode(200);
        return res;
    }
}