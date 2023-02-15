/*
* Class  : SendReviewEmailInvitationTrustpilot
* Use    : This class is written to call Trustpilot API which send review invitation email from 
		   Trustpilot platform whenever any job get SMS feedback > 7 in MC.
* Auther : Bharat Vyas, 15/06/2022
*/

public class SendReviewEmailInvitationTrustpilot {

    @InvocableMethod(label='Get Json for Trustpilot review invitation API call ') 
    public static void emailIntegration(List<String> jsonString){
        
        System.debug('jsonString >>>'+jsonString);
        for(String jsonData : jsonString ){
            SendReviewEmailInvitation(jsonData);
        }
    }
    
   public static String getAuthToken(){
        system.debug('In SendReviewEmailInvitationTrustpilot.getAuthToken');
        Trustpilot_Integration_Details__mdt  TPAuthDetail = Trustpilot_Integration_Details__mdt.getInstance('Auth_Credentials');
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(TPAuthDetail.Endpoint__c);
        request.setMethod(TPAuthDetail.Method__c);
        Blob clientIdSecret = Blob.valueOf(TPAuthDetail.Client_ID__c+':'+TPAuthDetail.Client_Secret__c);
        request.setHeader('Content-Type', TPAuthDetail.Content_Type__c); 
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(clientIdSecret));
        request.setBody('grant_type=password&username='+TPAuthDetail.Username__c+'&password='+TPAuthDetail.Password__c);
        HttpResponse response = http.send(request);
        // Deserializes the JSON string into collections of primitive data types.
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        System.debug('access_token '+results.get('access_token'));
        System.debug('expires_in '+results.get('expires_in'));
        System.debug('token_type '+results.get('token_type'));
        System.debug('responsebody >'+response.getBody());
        return String.valueOf(results.get('access_token'));
    }  
    
    @future(callout = true)
    public static void SendReviewEmailInvitation(String jsonString){ 
        system.debug('In SendReviewEmailInvitationTrustpilot.SendReviewEmailInvitation');
        String token = getAuthToken();
        if(!String.isBlank(token)){
            
            Trustpilot_Integration_Details__mdt EmailReviewDetail = Trustpilot_Integration_Details__mdt.getInstance('Email_Review_Invitation');            
            system.debug('EmailReviewDetail >>>'+EmailReviewDetail);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(EmailReviewDetail.Endpoint__c);
            request.setMethod(EmailReviewDetail.Method__c);
            request.setHeader('Content-Type', EmailReviewDetail.Content_Type__c); 
            request.setHeader('Authorization','Bearer '+token);
            request.setHeader('apikey',EmailReviewDetail.Client_ID__c);
            request.setBody(jsonString);
            System.debug('request.setBody >>> '+request.getBody());
            HttpResponse response = http.send(request);
            System.debug('response.Header >>> '+response.toString());
           // Success Response  - Status=Accepted, StatusCode=202
            if(response.getStatusCode() == 202){  
                System.debug('Sent Review Invitation to Trustpilot successfully.');
            }
            else{
                System.debug(response.toString());
            }
		
        }
    }
}