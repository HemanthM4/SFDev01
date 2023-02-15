/*
* Class  : UpdateFeedbackFromTrustpilot_Test
* Use    : This test class is written to get coverage for class FeedbackFromTrustpilot .
* Auther : Bharat Vyas, 20/5/2022
*/
@isTest
private class UpdateFeedbackFromTrustpilot_Test {

     @isTest static void testCallout() {
        // Set mock callout class 
        HttpRequest request = new HttpRequest();
        request.setBody('{"links":[{"href":"https://api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/reviews?endDateTime=2022-05-10T23%3A59%3A59&startDateTime=2022-05-10T00%3A00%3A01&page=2&perPage=20&orderBy=createdat.desc&includeBrandReviews=true","method":"GET","rel":"next-page"},{"href":"https://api.trustpilot.com/v1/business-units/4d943fa800006400050f4ed6","method":"GET","rel":"business-units"}],"reviews":[{"links":[{"href":"https://api.trustpilot.com/v1/reviews/628bb0a3045d025d3a9c4a3a","method":"GET","rel":"reviews"},{"href":"https://api.trustpilot.com/v1/reviews/628bb0a3045d025d3a9c4a3a/web-links","method":"GET","rel":"reviews-web-links"},{"href":"https://api.trustpilot.com/v1/resources/images/stars/5","method":"GET","rel":"resources-images-stars"}],"id":"628bb0a3045d025d3a9c4a3a","consumer":{"links":[{"href":"https://api.trustpilot.com/v1/consumers/628bb0a15bff530013cb2c73","method":"GET","rel":"consumers"}],"id":"628bb0a15bff530013cb2c73","displayName":"Sarah","displayLocation":null,"numberOfReviews":1},"businessUnit":{"links":[{"href":"https://api.trustpilot.com/v1/business-units/4d943fa800006400050f4ed6","method":"GET","rel":"business-units"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/57x43.png","method":"GET","rel":"profile-image-small"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/118x89.png","method":"GET","rel":"profile-image-medium"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/198x149.png","method":"GET","rel":"profile-image-large"}],"id":"4d943fa800006400050f4ed6","identifyingName":"aspect.co.uk","displayName":"Aspect"},"stars":5,"title":"Fantasticengineerwhoexplainedâ€¦","text":"FantasticengineerwhoexplainedeverythingCouldnottfaulttheserviceIreceivedtodaytheengineerwasamazing,veryhelpfulandevenhelpedmebyputtingtheovenbackwhenIcouldnotdoonmyown.","language":"en","location":null,"createdAt":"2022-05-23T18:04:51Z","updatedAt":"2022-06-08T18:04:51Z","referralEmail":"saramartin05@hotmail.com","referenceId":"J-061955","source":"InvitationApi","companyReply":null,"tags":[],"numberOfLikes":0,"findReviewer":{"isEligible":false,"requests":[]},"isVerified":true,"status":"active","reportData":null,"countsTowardsTrustScore":true,"countsTowardsLocationTrustScore":null,"invitation":{"businessUnitId":"4d943fa800006400050f4ed6"},"businessUnitHistory":[],"reviewVerificationLevel":"verified"}]}');
        TrustpilotJSON2Apex trustpilotData = TrustpilotJSON2Apex.parse(request.getBody());
    }
    
      
    @isTest static void testMethodForScheduleJob(){
        
        Test.startTest();
        Account acc = AspectTestDataFactory.createAccount();
        Contact cont = AspectTestDataFactory.createContact(acc);
        Site__c site = AspectTestDataFactory.createSite(acc, Cont);
        WorkType wType = AspectTestDataFactory.createWorkType();
        Job__c job = AspectTestDataFactory.createJob(acc, wType, site);
        
        Customer_Feedback__c custFeedback = new Customer_Feedback__c();
        custFeedback.Review_Id__c = '628bb0a3045d025d3a9c4a3a';
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
        custFeedback.Referece_Id_Text__c  = '628bb0a3045d025d3a9c4a3a';
        custFeedback.Customer_Display_Name__c = 'Bharat Vyas';
        custFeedback.Customer_Trustpilot_Id__c = '12345';
        custFeedback.Number_of_Reviews_by_Customer__c = 3; 
        insert custFeedback;
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(
            'https://api.trustpilot.com/v1/oauth/oauth-business-users-for-applications/accesstoken',
            'TrustpilotAuthMockResponse');
        
        	DateTime todayDate = DateTime.now();
			String dateTempStart = todayDate.addDays(-30).format('yyyy-MM-dd');
 			String dateTempEnd = todayDate.addDays(-1).format('yyyy-MM-dd');
            String daysStartTime = dateTempStart+'T'+'00:00:01';
            String dayEndTime = dateTempEnd+'T'+'23:59:59';
        multimock.setStaticResource(
            'https://api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/reviews?perPage=100&startDateTime='+daysStartTime+'&endDateTime='+dayEndTime, 
            'TrustpilotFeedbackMockResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        String CRON_EXP = '0 0 0 30 6 ? 2022'; 
        String jobId = System.schedule('ScheduledApexTestTPUpdate', CRON_EXP, new UpdatedFeedbackFromTrustpilot());

        Test.stopTest();
        
    }
}