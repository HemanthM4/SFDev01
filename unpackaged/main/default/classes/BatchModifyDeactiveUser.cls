public class BatchModifyDeactiveUser Implements Database.batchable<sobject>,Database.Stateful{
    public  string query;
    public  String UserIdValue  ;
    public  Boolean hasError = false  ;
    public BatchModifyDeactiveUser( String userid){
        UserIdValue = userid;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        query='SELECT id,isactive,UserName from User where id =: UserIdValue and isactive = true';
        return Database.getQueryLocator(query);//Related_Inactive_User_Id__r
    }
    public void execute(Database.BatchableContext BC,List<User> usrs  ){
        hasError = false;
          Integer randomNumber  = Math.round((Math.random() * (900000) + 100000));
        List<User> users = new List<User>();
        for(User usr: usrs){
            usr.isactive = false;
            usr.UserName = usr.UserName+''+randomNumber ;
            usr.Deactivated_Date__c = System.today();
            users.add(usr);
        }
        if(users.size() != 0){
            String err = 'Successful';
            Database.UpsertResult[] records =Database.upsert(users,false);
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
                hasError = true;
            }
        }
        
        
    }
    public void finish(Database.BatchableContext BC){
        
        
    }
}