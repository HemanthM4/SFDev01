public class BatchFireOfSACtrller {
    @AuraEnabled
    public static string createUserOfSA(String recordId){
        String errormessage = 'Suceess'; Set<Id> userId = new Set<Id>(); List<Contact> cons = new List<Contact>();  Boolean hasNoCommunity = false; String hasNoContact = '';
        try{
            for(ServiceResource sr: [SELECT id,RelatedRecordId from serviceResource where id =:recordId]){ userId.add(sr.RelatedRecordId);
            }
            
            for(User usr: [SELECT id,ContactId,Contact.LastName,Contact.CurrencyIsoCode,CurrencyIsoCode,LastName,
                           Contact.AccountId from User where Id =:userId]){
                               if(usr.ContactId != null){  cons = createContact(usr,false);
                               }else{ cons = createContact(usr,true);
                               }
                           }
            if(cons.size() !=0 ){ upsert cons; }
        }catch(Exception ex){ errormessage = ex.getMessage(); }
        if(errormessage == 'Suceess'){
            if(!test.isRunningTest()){ BatchCreateUser bdt = new BatchCreateUser(recordId,cons[0]);  dataBase.executeBatch(bdt);
            }
        }
        return errormessage;
    }  
    Public static List<contact> createContact(User usr,Boolean hasContact){
        List<contact> cons = new List<Contact>();
        Contact con  = new Contact();
        if(hasContact ==  false){
            con.Existing_Inactive_Contact__c = usr.ContactId; con.LastName =usr.Contact.LastName;
            con.CurrencyIsoCode	 =usr.Contact.CurrencyIsoCode; con.AccountId	 =usr.Contact.AccountId;
            con.Related_Inactive_User_Id__c = usr.id; 
        }else{
            Account acc = [SELECT id ,Name from Account where Name  =  'Crystal Tax'];
            con.LastName =usr.LastName; con.CurrencyIsoCode	 = usr.CurrencyIsoCode;
            con.AccountId	 =acc.id;  con.Related_Inactive_User_Id__c = usr.id;  
        }
        cons.add(con);
        return cons;
    }
    @auraEnabled
    public static boolean getUserProfile(){
        Service_USer_Deatcivate_Profile__mdt[] InActiveEmailRecords = [Select Custom_Profile__c from Service_USer_Deatcivate_Profile__mdt];
        Set<String> userProfile = new Set<String>();
        if(InActiveEmailRecords.size() != 0 ){
            if(InActiveEmailRecords[0].Custom_Profile__c !=  null){
                List<String> lstProfile = InActiveEmailRecords[0].Custom_Profile__c.split(',');  userProfile.addAll(lstProfile);
            }
        }
        User usr =[SELECT id,Profile.Name from user  where Id =: UserInfo.getUserId()];
        for(String s1 : userProfile){
            if(s1 == usr.Profile.Name){
                 return true;
            }
        }
        return false;
    }
}