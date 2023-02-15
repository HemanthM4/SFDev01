/*
* Class  : FeedbackFromTrustpilot_Test
* Use    : This test class is written to get coverage for class FeedbackFromTrustpilot .
* Auther : Bharat Vyas, 20/5/2022
*/

@isTest
private class FeedbackFromTrustpilot_Test {

     @isTest static void testCallout() {
        // Set mock callout class 
        HttpRequest request = new HttpRequest();
        request.setBody('{"links":[{"href":"https://api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/reviews?perPage=100&page=16&orderBy=createdat.desc&includeBrandReviews=true","method":"GET","rel":"next-page"},{"href":"https://api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/reviews?perPage=100&page=14&orderBy=createdat.desc&includeBrandReviews=true","method":"GET","rel":"prev-page"},{"href":"https://api.trustpilot.com/v1/business-units/4d943fa800006400050f4ed6","method":"GET","rel":"business-units"}],"reviews":[{"links":[{"href":"https://api.trustpilot.com/v1/reviews/618e72d3fb38891f5f09bd65","method":"GET","rel":"reviews"},{"href":"https://api.trustpilot.com/v1/reviews/618e72d3fb38891f5f09bd65/web-links","method":"GET","rel":"reviews-web-links"},{"href":"https://api.trustpilot.com/v1/resources/images/stars/5","method":"GET","rel":"resources-images-stars"}],"id":"618e72d3fb38891f5f09bd65","consumer":{"links":[{"href":"https://api.trustpilot.com/v1/consumers/618e72d1dda2f800123c9a28","method":"GET","rel":"consumers"}],"id":"618e72d1dda2f800123c9a28","displayName":"Fergus","displayLocation":null,"numberOfReviews":1},"businessUnit":{"links":[{"href":"https://api.trustpilot.com/v1/business-units/4d943fa800006400050f4ed6","method":"GET","rel":"business-units"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/57x43.png","method":"GET","rel":"profile-image-small"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/118x89.png","method":"GET","rel":"profile-image-medium"},{"href":"https://s3-eu-west-1.amazonaws.com/tpd/screenshotlogo-domain/4d943fa800006400050f4ed6/198x149.png","method":"GET","rel":"profile-image-large"}],"id":"4d943fa800006400050f4ed6","identifyingName":"aspect.co.uk","displayName":"Aspect"},"stars":5,"title":"Professionalandtidyworkquicklydone","text":"Professionalandtidyworkquicklydone","language":"en","location":null,"createdAt":"2021-11-12T13:57:39Z","updatedAt":null,"referralEmail":"fergus.mooney@outlook.com","referenceId":"J-024047","source":"InvitationApi","companyReply":{"text":"Thatsexactlywhatweliketohear!Thanks,Fergus,fortakingthetimetoleaveyourlovelyfeedback.","authorBusinessUserId":"606d7bb8f3ca310020e27949","authorBusinessUserName":"IsabelleChadwick","createdAt":"2021-11-15T10:09:18Z","updatedAt":null},"tags":[{"group":"generic","value":"Roof_Gutter_Cleaning_209"}],"numberOfLikes":0,"findReviewer":{"isEligible":false,"requests":[]},"isVerified":true,"status":"active","reportData":null,"countsTowardsTrustScore":true,"countsTowardsLocationTrustScore":null,"invitation":{"businessUnitId":"4d943fa800006400050f4ed6"},"businessUnitHistory":[],"reviewVerificationLevel":"verified"}]}');
        TrustpilotJSON2Apex trustpilotData = TrustpilotJSON2Apex.parse(request.getBody());
    }
    
    @isTest static void testMethodForScheduleJob(){
        
        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(
            'https://api.trustpilot.com/v1/oauth/oauth-business-users-for-applications/accesstoken',
            'TrustpilotAuthMockResponse');
        DateTime todayDate = DateTime.now();
        String dateTemp = todayDate.addDays(-1).format('yyyy-MM-dd');
        String yesterdayStartTime = dateTemp+'T'+'01:00:00';
        String yesterdayEndTime = dateTemp+'T'+'23:59:59';
        multimock.setStaticResource(
            'https://api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/reviews?perPage=100&startDateTime='+yesterdayStartTime+'&endDateTime='+yesterdayEndTime, 
            'TrustpilotFeedbackMockResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
        
        String CRON_EXP = '0 0 0 30 5 ? 2022'; 
        String jobId = System.schedule('ScheduledApexTestTP', CRON_EXP, new FeedbackFromTrustpilot());
        Test.stopTest();
        
    }
}