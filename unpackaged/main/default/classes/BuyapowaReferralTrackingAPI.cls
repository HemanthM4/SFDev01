/*
* Class  : BuyapowaReferralTrackingAPI
* Use    : This class is written to send Referral Tracking to Buyapowa.
* Auther : Bharat Vyas, 28/9/2022
*/
public class BuyapowaReferralTrackingAPI {

        
     public class orderDetails{
        
        @InvocableVariable
        public String jobId;
         
        @InvocableVariable
        public String referrerEmail;
         
        @InvocableVariable
        public String voucherCode;
         
        @InvocableVariable
        public String firstName;
         
        @InvocableVariable
        public String lastName;
         
        @InvocableVariable
        public String email;
         
        @InvocableVariable
        public String jobName;
         
        @InvocableVariable
        public Datetime jobCreatedTime;
        
    }
    
    @InvocableMethod(label='Send referral Tracking to Buyapowa') 
    public static void getOrderDetails(List<orderDetails> orderDetailsList){
        system.debug('In BuyapowaReferralTrackingAPI.getOrderDetails '+orderDetailsList);
        //We will single record as consideration but as Invocable can not except a record so we are using List and iterating it
        for(orderDetails oderDetl : orderDetailsList){
        String referEmail = oderDetl.referrerEmail;
        referEmail = referEmail.split(',')[1];
        trackBuyapowaReferral(referEmail, oderDetl.voucherCode,
                              oderDetl.firstName+', '+oderDetl.lastName, oderDetl.email, 
                              oderDetl.jobName, ''+oderDetl.jobCreatedTime.getTime(), oderDetl.jobId);
        }
    }
    
    
    @future(callout = true)
    public static void trackBuyapowaReferral(String referrerEmail, String voucherCode, String fullName, String email, String jobName, String jobCreatedDate, String jobId){
        
     Buyapowa_Integration_Details__mdt  referralTracking = Buyapowa_Integration_Details__mdt.getInstance('Buyapowa_Referral_Tracking_API');
            
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(referralTracking.Endpoint__c);
                request.setMethod(referralTracking.Method__c);
                request.setHeader('Content-Type', referralTracking.Content_Type__c);
                request.setHeader('auth_id', referralTracking.Auth_Id__c);
                request.setHeader('auth_token', referralTracking.Auth_Token__c);
        		// Removing Name and Email of Friend as suggested by Buyapowa, as they will get this details from frontend.
        		//request.setBody('{"order" : {"referrer_email" : "'+referrerEmail+'","voucher_code" : "'+voucherCode+'","full_name" : "'+fullName+'","email_address" : "'+email+'","order_number" : "'+jobName+'","order_timestamp" : "'+jobCreatedDate+'"}}');
                request.setBody('{"order" : {"referrer_email" : "'+referrerEmail+'","voucher_code" : "'+voucherCode+'","order_number" : "'+jobName+'","order_timestamp" : "'+jobCreatedDate+'"}}');
        		System.debug('request >>> '+request.getBody());
                HttpResponse response = http.send(request);
                System.debug('response >>> '+response.getBody());
        		Job__c job = new Job__c(Id = jobId);
        		job.Referral_Status_Before_Payment__c = response.getBody();
                if(!Test.isRunningTest())
                  update job;
    }
}