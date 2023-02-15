/*
* Class  : BuyapowaReferralReconciliationAPI
* Use    : This class is written to send Information of Friend's Job to Buyapowa such as confirmed/Failed.
* Auther : Bharat Vyas, 29/9/2022
*/
public class BuyapowaReferralReconciliationAPI {
    
     public class orderDetails{
        
        @InvocableVariable
        public String jobId;
         
        @InvocableVariable
        public String jobName;
         
        @InvocableVariable
        public String jobStatus;
        
    }
    
    @InvocableMethod(label='Send referral job status to Buyapowa') 
    public static void getOrderDetails(List<orderDetails> orderDetailsList){
         //We will single record as consideration but as Invocable can not except a record so we are using List and iterating it
        for(orderDetails oderDetl : orderDetailsList){
            system.debug('In BuyapowaReferralReconciliationAPI.getOrderDetails '+oderDetl);
            sendReferralStatusToBuyapowa(oderDetl.jobName, oderDetl.jobStatus, oderDetl.jobId);
        }
    }
    
    @future(callout = true)
    public static void sendReferralStatusToBuyapowa(String jobName, String jobStatus, String jobId){
        Buyapowa_Integration_Details__mdt  referralReconcil = Buyapowa_Integration_Details__mdt.getInstance('Buyapowa_Referral_Reconciliation_API');
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(referralReconcil.Endpoint__c);
        request.setMethod(referralReconcil.Method__c);
        request.setHeader('Content-Type', referralReconcil.Content_Type__c);
        request.setHeader('auth_id', referralReconcil.Auth_Id__c);
        request.setHeader('auth_token', referralReconcil.Auth_Token__c);
        request.setBody('{"order" : {"order_number" : "'+jobName+'","status" : "'+jobStatus+'"}}');
        System.debug('request >>> '+request.getBody());
        HttpResponse response = http.send(request);
        System.debug('response >>> '+response.getBody());
        Job__c job = new Job__c(Id = jobId);
        job.Referral_Status_After_Payment__c = response.getBody();
        if(!Test.isRunningTest())
          update job;
    }
}