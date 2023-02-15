/*
* Class  : FeedbackFromTrustpilot
* Use    : This class is written to fecth Trustpilot reviews for Aspect.
* Auther : Bharat Vyas, 15/5/2022
*/


public class FeedbackFromTrustpilot implements Schedulable {
    
    public void execute(SchedulableContext SC) {
      FetchCustomerFeedbacks(); 
   }
    
    
    public static String getAuthToken(){
        system.debug('In FeedbackFromTrustpilot.getAuthToken ');
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
        system.debug('In FeedbackFromTrustpilot.FetchCustomerFeedbacks ');
        
        String token = getAuthToken();
        if(!String.isBlank(token)){
            
            
            List<Customer_Feedback__c> custFeedbckList = new List<Customer_Feedback__c>();
            
            Trustpilot_Integration_Details__mdt TPReviewsDetail = Trustpilot_Integration_Details__mdt.getInstance('Reviews_Credentials');            
            
            
            DateTime todayDate = DateTime.now();
            String dateTemp = todayDate.addDays(-1).format('yyyy-MM-dd');
            String yesterdayStartTime = dateTemp+'T'+'01:00:00';
            String yesterdayEndTime = dateTemp+'T'+'23:59:59';
            
            System.debug('dateTimeTemp >'+dateTemp);
            System.debug('yesterdayStartTime >'+yesterdayStartTime);
            System.debug('yesterdayEndTime >'+yesterdayEndTime);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TPReviewsDetail.Endpoint__c+'&startDateTime='+yesterdayStartTime+'&endDateTime='+yesterdayEndTime);
            request.setMethod(TPReviewsDetail.Method__c);
            request.setHeader('Content-Type', TPReviewsDetail.Content_Type__c); 
            request.setHeader('Authorization','Bearer '+token);
            request.setHeader('apikey',TPReviewsDetail.Client_ID__c);
            HttpResponse response = http.send(request);
            Set<String> jsonJobIdSet = new Set<String>();
            
            TrustpilotJSON2Apex trustpilotData = TrustpilotJSON2Apex.parse(response.getBody()); 
            List<TrustpilotJSON2Apex.Reviews> custReviews = trustpilotData.Reviews;
            
            System.debug('custReviews.size() >>> '+custReviews.size());
            
            for(TrustpilotJSON2Apex.Reviews reviewTemp : custReviews){
                String refJobId = reviewTemp.referenceId;
                if(!String.isBlank(refJobId))
                    jsonJobIdSet.add(reviewTemp.referenceId); 
            }
            system.debug('jsonJobIdSet >>> '+jsonJobIdSet);
            Map<String, String> jobWithNameMap = new Map<String, String>();
            for (Job__c JobData :[SELECT Id, Name  FROM Job__c WHERE Name IN : jsonJobIdSet]){
                jobWithNameMap.put(JobData.Name, JobData.Id);
            }
            for(TrustpilotJSON2Apex.Reviews reviewTemp : custReviews){
                String refJobId = reviewTemp.referenceId;
                if(String.isNotBlank(refJobId)){
                    
                    Customer_Feedback__c custFeedback = new Customer_Feedback__c();
                    if(jobWithNameMap.get(reviewTemp.referenceId) != null){
                        custFeedback.Reference_Job__c = jobWithNameMap.get(reviewTemp.referenceId);
                    }
                    else{
                        custFeedback.Reference_Job__c = Label.Trustpilot_Generic_Job_Id;
                        custFeedback.Referece_Id_Text__c  = reviewTemp.referenceId;
                    }
                    custFeedback.Review_Id__c = reviewTemp.id;
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
            }
            if(!custFeedbckList.isEmpty()){
                Database.insert(custFeedbckList,false); 
                system.debug('Inserted Customer Feedback total records :'+custFeedbckList.size());
            }
        }
        else{
            system.debug('FetchCustomerFeedbacks > Issue in Token generation.Please contact with Admin');
        }
    } 
    
}