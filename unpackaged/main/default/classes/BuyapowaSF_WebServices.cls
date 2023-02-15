/*
* Class  : BuyapowaSF_WebServices
* Use    : This web service is written to help Buyapowa to verify valid customer for Aspect campaign.
* Auther : Bharat Vyas, 1/8/2022
*/

@RestResource(urlMapping='/api/customer/*')
global with sharing class BuyapowaSF_WebServices {
    
    global class verifyResponse {
        global Boolean customerFound = false;
        global Integer code = 404;
        global String errorMessage;
    }
    
    @HttpGet
    global static verifyResponse verifyCustomer() {
        
        verifyResponse response = new verifyResponse();  
        String email = RestContext.request.params.get('email');
        System.debug('Customer email >>> '+email);
        
        if(!String.isBlank(email)){
            
            List<Account> accList = [Select ID, Name, Email__c, Pending_Referrer__c FROM Account WHERE Email__c =: email AND Pending_Referrer__c = True];
            if(!accList.isEmpty()){
                response.customerFound = true;
                response.code = 200;
            }
            else{
                response.errorMessage = 'No customer is found by this email.';
            }
        }
        else{
            response.errorMessage = 'Email is missing in the parameter.';
        }
        
        return response;
    }
}