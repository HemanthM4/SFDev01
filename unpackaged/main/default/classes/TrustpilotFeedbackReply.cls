/*
* Class  : TrustpilotFeedbackReply
* Use    : This class is written to post Trustpilot review's reply from Salesforce.
* Auther : Bharat Vyas, 15/5/2022
*/


public class TrustpilotFeedbackReply {
    
    public class CustomerFeedbackData{
        
        @InvocableVariable
        public Customer_Feedback__c custFeedback;
        
        @InvocableVariable
        public String jobNumber;
        
    }
    
    @InvocableMethod(label='Post reply to Customer Review in Trustpilot') 
    public static void postReplyToCustomer(List<CustomerFeedbackData> CustomerFeedbackDataList){
        system.debug('In postReplyToCustomer '+CustomerFeedbackDataList[0].custFeedback.Aspect_Reply__c);
        replyToCustomerReview(CustomerFeedbackDataList[0].custFeedback.Review_Id__c, 
                              CustomerFeedbackDataList[0].jobNumber,
                              CustomerFeedbackDataList[0].custFeedback.Id,
                              CustomerFeedbackDataList[0].custFeedback.Aspect_Reply__c);
    }
    
    public static String getAuthToken(){
        system.debug('In getAuthToken ');
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
        
        return String.valueOf(results.get('access_token'));
    }  
    
    @future(callout = true)
    public static void replyToCustomerReview(String tpReviewId, String referenceId, String recordId, String tpAspectReply){
        
        system.debug('In replyToCustomerReview '+tpReviewId);
        String token = getAuthToken();       
        if(!String.isBlank(token)){
            
            Trustpilot_Integration_Details__mdt TPReplyDetail = Trustpilot_Integration_Details__mdt.getInstance('Reply_Credentials');            
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TPReplyDetail.Endpoint__c+tpReviewId+'/reply');
            request.setMethod(TPReplyDetail.Method__c);
            request.setHeader('Content-Type', TPReplyDetail.Content_Type__c); 
            request.setHeader('Authorization','Bearer '+token);
            request.setHeader('apikey',TPReplyDetail.Client_ID__c);
            request.setBody('{"message":"'+tpAspectReply+'"}');
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 201){
                
                System.debug('Review reply is posted successfully.');
                Customer_Feedback__c custFeedback = [Select Id, Reply_CreatedAt__c, Reply_UpdatedAt__c From 
                                                     Customer_Feedback__c Where Id  =: recordId];
                if(custFeedback != null){
                    custFeedback.Manual__c = true;
                    if(custFeedback.Reply_CreatedAt__c == null){
                        custFeedback.Reply_CreatedAt__c = System.now();
                    }
                    else{
                        custFeedback.Reply_UpdatedAt__c = System.now();
                    }
                    update custFeedback;
                }
            }
            else{
                System.debug(response.getBody());
            }
        }
        else{
            system.debug('replyToCustomerReview > Issue in Token generation.Please contact with Admin');
        }
        
    }
                
}