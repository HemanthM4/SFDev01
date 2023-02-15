public class BatchCreateUser Implements Database.batchable<sobject>,Database.Stateful{
    public  string query;
    public  String serviceResourceIdSet;
    public  Contact cont;
    public  Boolean hasError  = false;
    public  String userId  ;
    public BatchCreateUser(String ServiceResourceId, Contact con){
        cont = new Contact();
        cont = con;
        serviceResourceIdSet = ServiceResourceId;
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String conId = cont.id;
        query='SELECT id,Existing_Inactive_Contact__c,Related_Inactive_User_Id__c,Related_Inactive_User_Id__r.UserName,Related_Inactive_User_Id__r.FirstName,Related_Inactive_User_Id__r.LastName,Related_Inactive_User_Id__r.Alias,Related_Inactive_User_Id__r.email,Related_Inactive_User_Id__r.TimeZoneSidKey,Related_Inactive_User_Id__r.LocaleSidKey,Related_Inactive_User_Id__r.EmailEncodingKey,Related_Inactive_User_Id__r.LanguageLocaleKey,Related_Inactive_User_Id__r.id from Contact where id =: conId';
        return Database.getQueryLocator(query);//Related_Inactive_User_Id__r
    }
    public void execute(Database.BatchableContext BC,List<Contact> Cons   ){
        hasError = false;
        Profile cp=[Select Id from Profile where Name='Customer Community Login User' LIMIT 1];
        List<User> usrstoInsert = new List<USer>();
        Integer randomNumber  = Math.round((Math.random() * (900000) + 100000));
        for(Contact con :Cons){
            User u = New User(
                UserName = con.Related_Inactive_User_Id__r.UserName+''+randomNumber,
                FirstName =con.Related_Inactive_User_Id__r.FirstName,
                LastName = con.Related_Inactive_User_Id__r.LastName +'-Former',
                Alias =con.Related_Inactive_User_Id__r.Alias,
                email = con.Related_Inactive_User_Id__r.email,
                ProfileID = cp.Id,
                isActive = true,
                TimeZoneSidKey = con.Related_Inactive_User_Id__r.TimeZoneSidKey,
                LocaleSidKey = con.Related_Inactive_User_Id__r.LocaleSidKey,
                EmailEncodingKey = con.Related_Inactive_User_Id__r.EmailEncodingKey,
                LanguageLocaleKey =con.Related_Inactive_User_Id__r.LanguageLocaleKey,
                Inactive_user_Id__c =con.Related_Inactive_User_Id__r.id,
                contactId = con.Id
            );
            usrstoInsert.add(u);
            String err = 'Successful';
            if(usrstoInsert.size() !=0 ){
                Database.UpsertResult[] records =Database.upsert(usrstoInsert,false);
                string header = ' Details  \n';
                string finalstr = header ;
                Boolean hasErrorforUser = false;
                for(Integer i = 0 ; i<records.size();i++){
                    Database.UpsertResult record =records.get(i);
                    Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                    Boolean isSUccess = record.isSuccess();
                    if(!isSUccess){
                        String recordDetails = JSON.serialize(recordMap);
                        string recordString = recordDetails +'\n';
                        System.debug('recordDetails'+recordDetails);
                        finalstr = finalstr +recordString;
                        hasErrorforUser = true;
                    }
                }
                if(hasErrorforUser){
                    sendEmailCLass.sendEmail(finalstr,'Clone User Creation');
                    if(!Test.isRunningTest())
                        Delete Cons;
                    hasError = true;
                } else{
                    userId = records[0].id;
                }
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        if(hasError == false){
            SYstem.debug(serviceResourceIdSet+'-'+userId);
            BatchModifySA bdt = new BatchModifySA(serviceResourceIdSet,userId);
            dataBase.executeBatch(bdt);
        }
    }
}