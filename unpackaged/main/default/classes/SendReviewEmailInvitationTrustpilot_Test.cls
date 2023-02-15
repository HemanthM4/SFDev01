/*
* Class  : SendReviewEmailInvitationTrustpilot_Test
* Use    : This test class is written to get coverage for class SendReviewEmailInvitationTrustpilot .
* Auther : Bharat Vyas, 21/6/2022
*/

@isTest
private class SendReviewEmailInvitationTrustpilot_Test {
    
    @isTest static void testMethodForSendReviewInvitation(){
        
        Test.startTest();
        List<String> jsonString = new List<String>();
        jsonString.add('{"replyTo":"aspect.comms@aspect.co.uk","senderName":"Aspect","senderEmail": "noreply.invitations@trustpilotmail.com","referenceNumber":"J-00000","consumerName":"Test","consumerEmail":"Test@gmail.com","serviceReviewInvitation":{"templateId": "5c9e44462a543100011ad555","redirectUri": "http://trustpilot.com"}}');
        SendReviewEmailInvitationTrustpilot.emailIntegration(jsonString);
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(
            'https://api.trustpilot.com/v1/oauth/oauth-business-users-for-applications/accesstoken',
            'TrustpilotAuthMockResponse');
        
        multimock.setStaticResource(
            'https://invitations-api.trustpilot.com/v1/private/business-units/4d943fa800006400050f4ed6/email-invitations', 
            'TrustpilotReviewInvitationMockResponse');
        multimock.setStatusCode(202);
        multimock.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, multimock);
          
        Test.stopTest();
    }
    
}