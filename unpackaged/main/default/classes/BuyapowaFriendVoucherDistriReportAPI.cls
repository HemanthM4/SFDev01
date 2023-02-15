/*
* Class  : BuyapowaFriendVoucherDistriReportAPI
* Use    : This class is written to fetch friend_voucher_distribution and store it against Account.
* Auther : Bharat Vyas, 6/9/2022
*/

global class BuyapowaFriendVoucherDistriReportAPI implements Schedulable {
    
    public class reportAPIResponse{
        public String friendEmail;
        public String friendPhone;
        public String friendName;
        public String voucherCode;
        public String friendVouchDistAt;
        public String referringEmail;
        public String referringName;
        public boolean optIn;
    }
    global void execute(SchedulableContext SC) {
        manageReportAPI();
    }
    @future(callout = true)
    public static void manageReportAPI(){
                Buyapowa_Integration_Details__mdt  friendVoucherAPIDetail = Buyapowa_Integration_Details__mdt.getInstance('Buyapowa_Friend_Voucher_Dist_Report_API');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('auth_id', friendVoucherAPIDetail.Auth_Id__c);
        req.setHeader('auth_token', friendVoucherAPIDetail.Auth_Token__c);
        req.setEndpoint(friendVoucherAPIDetail.Endpoint__c+'/'+friendVoucherAPIDetail.Campaign_Slug__c);
        req.setMethod(friendVoucherAPIDetail.Method__c);
        HttpResponse response = http.send(req);
        
        System.debug('response >>> '+response.getBody());
        String contents = response.getBody().remove('"');
        List<String> headers = new List<String>();
        headers = contents.split('\n');
        System.debug('headers >>> '+headers[0]);
        List<String> fields = new List<String>();
        fields = headers[0].split(',');
        System.debug('fields >>> '+fields);
        Integer indexFriendVo;
        Integer indexFriendEmail;
        Integer indexFriendName;
        Integer indexFriendPhone;
        Integer indexReferName;
        Integer indexReferEmail;
        Integer indexVouchDist;//voucher_distributed_at
        Integer indexOptIn;
        for(Integer i = 0; i < fields.size(); i++){
            if(fields[i] == 'voucher_code'){
                indexFriendVo = i;
            }
            if(fields[i] == 'voucher_distributed_at'){
                indexVouchDist = i;
            }
            if(fields[i] == 'friend_email'){
                indexFriendEmail = i;
            }
            if(fields[i] == 'friend_name'){
                indexFriendName = i;
            }
            if(fields[i] == 'referred_friend_phone_number'){ // Friend_Phone
                indexFriendPhone = i;
            }
            if(fields[i] == 'referring_customer_name'){
                indexReferName = i;
            }
            if(fields[i] == 'referring_customer_email'){
                indexReferEmail = i;
            }
            if(fields[i] == 'friend_marketing_opt_in'){
                indexOptIn = i;
            }
        }
        
        Map<String, reportAPIResponse> emailWithDetails = new Map<String, reportAPIResponse>();
        Map<String, reportAPIResponse> referEmailWithDetails = new Map<String, reportAPIResponse>();
        for(Integer i = 1; i < headers.size(); i++){
            fields = headers[i].split(',');
            reportAPIResponse reportResp = new reportAPIResponse();
            reportResp.friendEmail = fields[indexFriendEmail];
            reportResp.voucherCode = fields[indexFriendVo];
            reportResp.friendVouchDistAt = fields[indexVouchDist];
            reportResp.friendPhone = fields[indexFriendPhone];
            reportResp.friendName = fields[indexFriendName];
            reportResp.referringEmail = fields[indexReferEmail];
            reportResp.referringName = fields[indexReferName];
            System.debug('fields[indexOptIn] '+fields[indexOptIn]);
            if(fields[indexOptIn].contains('f')){
                system.debug('False');
                reportResp.optIn = false;}
            if(fields[indexOptIn].contains('t')){
                 system.debug('True');
                reportResp.optIn = true;}
            emailWithDetails.put(fields[indexFriendEmail], reportResp);
            referEmailWithDetails.put(fields[indexReferEmail], reportResp);
        }
        System.debug('emailWithDetails >>> '+emailWithDetails);
        Map<String, Account> accMap = new Map<String, Account>();
        Map<String, Contact> contMap = new Map<String, Contact>();
        Map<String, Account> existingAcc = new Map<String, Account>();
        Map<String, Account> referringAcc = new Map<String, Account>();
        if(!emailWithDetails.isEmpty()){
            
            // Logic to find Duplicate friend Account
            for (Account acc : [SELECT ID, Email__c, Invoicing_Email_Address__c FROM Account WHERE Email__c IN :emailWithDetails.keySet() OR Invoicing_Email_Address__c  IN :emailWithDetails.keySet()]) {
                if(emailWithDetails.containsKey(acc.Email__c)){
                    existingAcc.put(acc.Email__c, acc);
                }
                else{
                    existingAcc.put(acc.Invoicing_Email_Address__c, acc);
                }
                System.debug('existingAcc >>> '+existingAcc);
            }
            ///////
            
            // Logic to find Referring Account
            for (Account acc : [SELECT ID, Email__c, Invoicing_Email_Address__c FROM Account WHERE Email__c IN :referEmailWithDetails.keySet() OR Invoicing_Email_Address__c  IN :referEmailWithDetails.keySet()]) {
                if(referEmailWithDetails.containsKey(acc.Email__c)){
                    referringAcc.put(acc.Email__c, acc);
                }
                else{
                    referringAcc.put(acc.Invoicing_Email_Address__c, acc);
                }
                System.debug('referringAcc >>> '+referringAcc);
            }
            ///////
            for(String key : emailWithDetails.keySet()){
                
                if(existingAcc.get(key) == null){
    
                    reportAPIResponse apiResp = emailWithDetails.get(key);
                    System.debug('Friend record to be created >>>'+apiResp);
                    Contact cont = new Contact(Email = apiResp.friendEmail, Phone  = apiResp.friendPhone);
                    String[] contName = apiResp.friendName.split(' ');
                    if(contName.size() > 1){
                        cont.FirstName = contName[0];
                        cont.LastName = contName[1];
                    }
                    else
                        cont.LastName = apiResp.friendName;
                    cont.Is_Primary_Contact__c = True;
                    contMap.put(apiResp.friendEmail, cont);
                    Account parentAcc = new Account(
                        Name= apiResp.friendName, First_Name__c = cont.FirstName, Last_Name__c = cont.LastName, 
                        Email__c = apiResp.friendEmail, Voucher_Code__c = apiResp.voucherCode, 
                        Referral_Opt_In_Time__c  = Datetime.valueOf(apiResp.friendVouchDistAt),
                        AccountSource  = 'Buyapowa Referal', Phone = apiResp.friendPhone, 
                        Confirmed_Referrer__c = apiResp.optIn);
                    parentAcc.RecordTypeId = getRecordTypeIdbyName('Account','Domestic');
                    if(existingAcc.get(apiResp.friendEmail) != null)
                        parentAcc.Duplicate_Account_Id__c = existingAcc.get(apiResp.friendEmail).Id;
                    if(referringAcc.get(apiResp.referringEmail) != null){
                        parentAcc.Referral_notes__c = String.valueOf(referringAcc.get(apiResp.referringEmail).Id +','+apiResp.referringEmail);
                    }
                    accMap.put(apiResp.friendEmail, parentAcc);
                }
            } 
            System.debug('contMap '+contMap);
            System.debug('accMap '+accMap);
        }
        if(!accMap.isEmpty()){
             insert accMap.values();
             System.debug('after insert accMap '+accMap);
            for(String contEmail : contMap.keySet()){
                contMap.get(contEmail).AccountId = accMap.get(contEmail).Id;
            }
            insert contMap.values();
            System.debug('after insert contMap '+contMap);
        } 
    }
    
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    
}