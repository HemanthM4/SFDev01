/*
* Class  : TrustpilotFeedbackReply_Test
* Use    : This test class is written to get coverage for class TrustpilotFeedbackReply .
* Auther : Bharat Vyas, 18/5/2022
*/

@isTest
private class TrustpilotFeedbackReply_Test {

     @isTest static void testCallout() {
        // Set mock callout class 
        HttpRequest request = new HttpRequest();
        request.setBody('{"links":[{"href":"https://api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/reviews?perPage=100&page=16&orderBy=createdat.desc&includeBrandReviews=true","method":"GET","rel":"next-page"},{"href":"https://api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/reviews?perPage=100&page=14&orderBy=createdat.desc&includeBrandReviews=true","method":"GET","rel":"prev-page"},{"href":"https://api.trustpilot.com/v1/business-units/4d943fa800006400050f4ed6","method":"GET","rel":"business-units"}],"reviews":[{"links":[{"href":"https://api.trustpilot.com/v1/reviews/618e72d3fb38891f5f09bd65","method":"GET","rel":"reviews"},{"href":"https://api.trustpilot.com/v1/reviews/618e72d3fb38891f5f09bd65/web-links","method":"GET","rel":"reviews-web-links"},{"href":"https://api.trustpilot.com/v1/resources/images/stars/5","method":"GET","rel":"resources-images-stars"}],"id":"618e72d3fb38891f5f09bd65","consumer":{"links":[{"href":"https://api.trustpilot.com/v1/consumers/618e72d1dda2f800123c9a28","method":"GET","rel":"consumers"}],"id":"618e72d1dda2f800123c9a28","displayName":"Fergus","displayLocation":null,"numberOfReviews":1},"businessUnit":{"links":[{"href":"https://api.trustpilot.com/v1/business-units/4d943fa800006400050f4ed6","method":"GET","rel":"business-units"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/57x43.png","method":"GET","rel":"profile-image-small"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/118x89.png","method":"GET","rel":"profile-image-medium"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/198x149.png","method":"GET","rel":"profile-image-large"}],"id":"4d943fa800006400050f4ed6","identifyingName":"aspect.co.uk","displayName":"Aspect"},"stars":5,"title":"Professionalandtidyworkquicklydone","text":"Professionalandtidyworkquicklydone","language":"en","location":null,"createdAt":"2021-11-12T13:57:39Z","updatedAt":null,"referralEmail":"fergus.mooney@outlook.com","referenceId":"J-024047","source":"InvitationApi","companyReply":{"text":"Thatsexactlywhatweliketohear!Thanks,Fergus,fortakingthetimetoleaveyourlovelyfeedback.","authorBusinessUserId":"606d7bb8f3ca310020e27949","authorBusinessUserName":"IsabelleChadwick","createdAt":"2021-11-15T10:09:18Z","updatedAt":null},"tags":[{"group":"generic","value":"Roof_Gutter_Cleaning_209"}],"numberOfLikes":0,"findReviewer":{"isEligible":false,"requests":[]},"isVerified":true,"status":"active","reportData":null,"countsTowardsTrustScore":true,"countsTowardsLocationTrustScore":null,"invitation":{"businessUnitId":"4d943fa800006400050f4ed6"},"businessUnitHistory":[],"reviewVerificationLevel":"verified"}]}');
        TrustpilotJSON2Apex trustpilotData = TrustpilotJSON2Apex.parse(request.getBody());
    }
    
    @isTest static void createAndUpdateCF(){
        
        Account acc = AspectTestDataFactory.createAccount();
        Contact cont = AspectTestDataFactory.createContact(acc);
        Site__c site = AspectTestDataFactory.createSite(acc, Cont);
        WorkType wType = AspectTestDataFactory.createWorkType();
        Job__c job = AspectTestDataFactory.createJob(acc, wType, site);
        
        Customer_Feedback__c custFeedback = new Customer_Feedback__c();
        custFeedback.Review_Id__c = '12345';
        custFeedback.Stars__c = 5;
        custFeedback.Manual__c = false;
        custFeedback.Review_Text__c = 'Good company, with good people';
        custFeedback.Title__c = 'Experts';
        custFeedback.Reference_Job__c = job.Id;
        custFeedback.Referral_Email__c  = 'bharat.vyas@aspect.co.uk';
        custFeedback.Is_verified__c  = true;
        custFeedback.Review_Verification_Level__c  = 'verified';
        custFeedback.Source__c = 'TestClass';
        custFeedback.Review_CreatedAt__c = System.now();
        custFeedback.Review_UpdatedAt__c = System.now();
        custFeedback.Referece_Id_Text__c  = '12345';
        custFeedback.Customer_Display_Name__c = 'Bharat Vyas';
        custFeedback.Customer_Trustpilot_Id__c = '12345';
        custFeedback.Number_of_Reviews_by_Customer__c = 3; 
        insert custFeedback;
        
        custFeedback.Aspect_Reply__c = 'Thanks for such a lovely feedback';
        custFeedback.Reply_CreatedAt__c = System.now();
        custFeedback.Reply_UpdatedAt__c = System.now();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForTrustpilotAuth()); 
        update custFeedback;
        
        TrustpilotFeedbackReply.CustomerFeedbackData feedbackData = new TrustpilotFeedbackReply.CustomerFeedbackData();
        feedbackData.custFeedback = custFeedback;
        feedbackData.jobNumber = job.Name;
        List<TrustpilotFeedbackReply.CustomerFeedbackData> custFeedbackDataList = new List<TrustpilotFeedbackReply.CustomerFeedbackData>();
        custFeedbackDataList.add(feedbackData);
        TrustpilotFeedbackReply.postReplyToCustomer(custFeedbackDataList);

        
    }
}