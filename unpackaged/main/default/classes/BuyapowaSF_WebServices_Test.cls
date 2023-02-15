/*
* Class  : BuyapowaSF_WebServices_Test
* Use    : This Test class is written to get test coverage of BuyapowaSF_WebServices main class.
* Auther : Bharat Vyas, 2/8/2022
*/
@IsTest
private class BuyapowaSF_WebServices_Test {

    @isTest static void testVerifyCustomer() {

        Account acc = AspectTestDataFactory.createAccount();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/customer';
        request.httpMethod = 'GET';
        request.addParameter('email', acc.Email__c);
        RestContext.request = request;
        // Call the method to test
        BuyapowaSF_WebServices.verifyCustomer();
        
        acc.Pending_Referrer__c = True;
        update acc;
        
        RestContext.request = request;
        // Call the method to test again
        BuyapowaSF_WebServices.verifyCustomer();
        
    }
}