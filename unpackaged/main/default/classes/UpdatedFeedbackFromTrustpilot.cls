/*
* Class  : UpdatedFeedbackFromTrustpilot
* Use    : This class is written to fecth updated Trustpilot reviews for Aspect.
* Auther : Bharat Vyas, 7/6/2022
*/


public class UpdatedFeedbackFromTrustpilot implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        FetchCustomerFeedbacks(); 
    }
    
    
    public static String getAuthToken(){
        system.debug('In UpdatedFeedbackFromTrustpilot.getAuthToken ');
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
    public static void FetchCustomerFeedbacks(){ 
        system.debug('In UpdatedFeedbackFromTrustpilot.FetchCustomerFeedbacks ');
        
        String token = getAuthToken();
        if(!String.isBlank(token)){
            
            
            List<Customer_Feedback__c> custFeedbckList = new List<Customer_Feedback__c>();
            
            Trustpilot_Integration_Details__mdt TPReviewsDetail = Trustpilot_Integration_Details__mdt.getInstance('Reviews_Credentials');            
            
            
            DateTime todayDate = DateTime.now();
            Integer days = TPReviewsDetail.Days__c.intValue();
			String dateTempStart = todayDate.addDays(-days).format('yyyy-MM-dd');
 			String dateTempEnd = todayDate.addDays(-1).format('yyyy-MM-dd');
            String daysStartTime = dateTempStart+'T'+'00:00:01';
            String dayEndTime = dateTempEnd+'T'+'23:59:59';
            
            System.debug('daysStartTime >'+daysStartTime);
            System.debug('dayEndTime >'+dayEndTime);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TPReviewsDetail.Endpoint__c+'&startDateTime='+daysStartTime+'&endDateTime='+dayEndTime);
            request.setMethod(TPReviewsDetail.Method__c);
            request.setHeader('Content-Type', TPReviewsDetail.Content_Type__c); 
            request.setHeader('Authorization','Bearer '+token);
            request.setHeader('apikey',TPReviewsDetail.Client_ID__c);
            HttpResponse response = http.send(request);
            Set<String> jsonReviewIdSet = new Set<String>();
            
            TrustpilotJSON2Apex trustpilotData = TrustpilotJSON2Apex.parse(response.getBody()); 
            List<TrustpilotJSON2Apex.Reviews> allCustReviewsList = trustpilotData.Reviews;
            List<TrustpilotJSON2Apex.Reviews> TBUCustReviewsList = new List<TrustpilotJSON2Apex.Reviews>();
            
            System.debug('allCustReviewsList.size() >>> '+allCustReviewsList.size());
            
            DateTime last24HoursStart = DateTime.newInstanceGmt(todayDate.year(), todayDate.month(), todayDate.day()-1,0, 0, 1);
            DateTime last24HoursEnd = DateTime.newInstanceGmt(todayDate.year(), todayDate.month(), todayDate.day()-1,23, 59, 59);
            System.debug('last24HoursStart >'+last24HoursStart);
            System.debug('last24HoursEnd >'+last24HoursEnd);
            
            for(TrustpilotJSON2Apex.Reviews reviewTemp : allCustReviewsList){
                if(reviewTemp.updatedAt != null){
                    DateTime reviewUpdatedAt = (DateTime)JSON.deserialize('"' + reviewTemp.updatedAt + '"', DateTime.class);
                    if(!String.isBlank(reviewTemp.referenceId) && 
                       reviewUpdatedAt >= last24HoursStart && reviewUpdatedAt <= last24HoursEnd){
                           System.debug('reviewUpdatedAt Yesterday >'+reviewUpdatedAt);
                           jsonReviewIdSet.add(reviewTemp.Id); 
                           TBUCustReviewsList.add(reviewTemp);
                       }
                }
            }
            system.debug('jsonReviewIdSet >>> '+jsonReviewIdSet);
            
            Map<String, Customer_Feedback__c> custFeedMap = new Map<String, Customer_Feedback__c>();
            for (Customer_Feedback__c custFeedback : [SELECT Id, Name, Reference_Job__c, Reference_Job__r.Name, Review_Id__c, 
                                                      createdDate FROM Customer_Feedback__c WHERE Review_Id__c IN : jsonReviewIdSet 
                                                      order by createdDate desc LIMIT 1 ]){
                    System.debug('custFeedback in loop '+custFeedback);                                      
                 custFeedMap.put(custFeedback.Review_Id__c, custFeedback);                     
                                                          
            }
            if(!custFeedMap.isEmpty()){
                System.debug('custFeedMap is not Empty '+custFeedMap);
                for(TrustpilotJSON2Apex.Reviews reviewTemp : TBUCustReviewsList){
                    
                    Customer_Feedback__c tempFeedback = custFeedMap.get(reviewTemp.Id);
                    Customer_Feedback__c custFeedback = new Customer_Feedback__c();
                    custFeedback.Reference_Job__c = tempFeedback.Reference_Job__c;
                    custFeedback.Master_Feedback__c = tempFeedback.Id;
                    custFeedback.Review_Id__c = reviewTemp.id;
                    custFeedback.Referece_Id_Text__c = reviewTemp.referenceId;
                    custFeedback.Stars__c = reviewTemp.stars;
                    custFeedback.Review_Text__c = reviewTemp.text1;
                    custFeedback.Title__c = reviewTemp.title;
                    custFeedback.Referral_Email__c  = reviewTemp.referralEmail;
                    custFeedback.Is_verified__c  = reviewTemp.isVerified;
                    custFeedback.Review_Verification_Level__c  = reviewTemp.reviewVerificationLevel;
                    custFeedback.Source__c = reviewTemp.source;
                    custFeedback.Review_CreatedAt__c = (DateTime)JSON.deserialize('"' + reviewTemp.createdAt + '"', DateTime.class);
                    
                    if(reviewTemp.updatedAt != null)
                        custFeedback.Review_UpdatedAt__c = (DateTime)JSON.deserialize('"' + reviewTemp.updatedAt + '"', DateTime.class); 
                    
                    if(reviewTemp.CompanyReply != null){
                        custFeedback.Aspect_Reply__c  = reviewTemp.CompanyReply.text1;
                        custFeedback.Reply_CreatedAt__c = (DateTime)JSON.deserialize('"' + reviewTemp.CompanyReply.createdAt + '"', DateTime.class);
                        if(reviewTemp.CompanyReply.updatedAt != null)
                            custFeedback.Reply_UpdatedAt__c = (DateTime)JSON.deserialize('"' + reviewTemp.CompanyReply.updatedAt + '"', DateTime.class);
                    }
                    if(reviewTemp.consumer != null){
                        custFeedback.Customer_Display_Name__c = reviewTemp.consumer.displayName;
                        custFeedback.Customer_Trustpilot_Id__c = reviewTemp.consumer.id;
                        custFeedback.Number_of_Reviews_by_Customer__c = reviewTemp.consumer.numberOfReviews; 
                    }
                    
                    System.debug('custFeedback >>>> '+custFeedback);
                    custFeedbckList.add(custFeedback);       
                }
                if(!custFeedbckList.isEmpty()){
                    Database.insert(custFeedbckList,false); 
                    system.debug('Inserted Customer Feedback total records :'+custFeedbckList.size());
                }
            }
        }
        else{
            system.debug('FetchCustomerFeedbacks > Issue in Token generation.Please contact with Admin');
        }
    } 
    
}