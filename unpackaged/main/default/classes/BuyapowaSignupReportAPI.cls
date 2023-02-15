/*
* Class  : BuyapowaSignupReportAPI
* Use    : This class is written to fetch activated/sign up customer on Buyapowa server and their share URL.
* Auther : Bharat Vyas, 8/8/2022
*/

global class BuyapowaSignupReportAPI implements Schedulable {
    
    public class reportAPIResponse{
        public String email;
        public boolean optIn;
        public String shareURL;
        public String joinTime;
    }
    global void execute(SchedulableContext SC) {
        manageReportAPI();
    }
    @future(callout = true)
    public static void manageReportAPI(){
                Buyapowa_Integration_Details__mdt  signUpReportAPIDetail = Buyapowa_Integration_Details__mdt.getInstance('Buyapowa_Signup_Report_API');
        List<Account> accList = new List<Account>();
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('auth_id', signUpReportAPIDetail.Auth_Id__c);
        req.setHeader('auth_token', signUpReportAPIDetail.Auth_Token__c);
        req.setEndpoint(signUpReportAPIDetail.Endpoint__c+'/'+signUpReportAPIDetail.Campaign_Slug__c);
        req.setMethod(signUpReportAPIDetail.Method__c);
        HttpResponse response = http.send(req);
        
        System.debug('response >>> '+response.getBody());
        String contents = response.getBody().remove('"');
        List<String> headers = new List<String>();
        headers = contents.split('\n');
        System.debug('headers >>> '+headers[0]);
        List<String> fields = new List<String>();
        fields = headers[0].split(',');
        System.debug('fields >>> '+fields);
        Integer indexOptIn;
        Integer indexEmail;
        Integer indexShareURL;
        Integer indexJoinTime;
        for(Integer i = 0; i < fields.size(); i++){
            if(fields[i] == 'Marketing Opt-in'){
                indexOptIn = i;
            }
            if(fields[i] == 'Email'){
                indexEmail = i;
            }
            if(fields[i] == 'Share URL'){
                indexShareURL = i;
            }
             if(fields[i] == 'Join Date/Time'){
                indexJoinTime = i;
            }
        }
        System.debug('indexOptIn >>> '+indexOptIn);
        System.debug('indexEmail >>> '+indexEmail);
        System.debug('indexShareURL >>> '+indexShareURL);
        System.debug('indexJoinTime >>> '+indexJoinTime);
        
        Map<String, reportAPIResponse> emailWithURL = new Map<String, reportAPIResponse>();
        for(Integer i = 1; i < headers.size(); i++){
            fields = headers[i].split(',');
            reportAPIResponse reportResp = new reportAPIResponse();
            if(fields[indexOptIn].contains('No')){
                system.debug('No');
                reportResp.optIn = true;}
            if(fields[indexOptIn].contains('Yes')){
                 system.debug('Yes');
                reportResp.optIn = false;}
            reportResp.email = fields[indexEmail];
            reportResp.shareURL = fields[indexShareURL];
            reportResp.joinTime = fields[indexJoinTime];
            emailWithURL.put(fields[indexEmail], reportResp);
        }
        System.debug('emailWithURL >>> '+emailWithURL);
        if(!emailWithURL.isEmpty()){
            System.debug('in emailWithURL.keySet() >>> '+emailWithURL.keySet());
            for (Account acc : [SELECT ID, Email__c, Pending_Referrer__c , Confirmed_Referrer__c, Buyapowa_Share_URL__c FROM Account WHERE Pending_Referrer__c  = true AND Email__c IN :emailWithURL.keySet()]) {
                reportAPIResponse apiResp = emailWithURL.get(acc.Email__c);
                acc.Buyapowa_Share_URL__c =  apiResp.shareURL;
                if(apiResp.joinTime != null){
                    acc.Confirmed_Referrer__c = apiResp.optIn;
                } 
               acc.Referrer_Join_Date_Time__c = Datetime.valueOf(apiResp.joinTime);
                accList.add(acc);
                System.debug('acc >>> '+acc);
            }
            
        }
        if(!accList.isEmpty()){
            System.debug('accList >>> '+accList);
            update accList;
        }
    }
    
}