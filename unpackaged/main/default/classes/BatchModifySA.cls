public class BatchModifySA Implements Database.batchable<sobject>,Database.Stateful{
 public  string query;
     public  String serviceResourceIdValue  ;
     public  String UserIdValue  ;
     public  String ExistingUserId  ;
    public  Boolean hasError = false  ;
      public BatchModifySA(String ServiceResourceId, String userid){
          serviceResourceIdValue = ServiceResourceId;
          UserIdValue = userid;
      }
      public Database.QueryLocator start(Database.BatchableContext BC){
        query='SELECT id,RelatedRecordId from ServiceResource where id =: serviceResourceIdValue';
        return Database.getQueryLocator(query);//Related_Inactive_User_Id__r
    }
    public void execute(Database.BatchableContext BC,List<ServiceResource> SRs   ){
        hasError = false;
        List<ServiceResource> srrecords = new List<ServiceResource>();
        for(ServiceResource sr: SRs){
            ExistingUserId =   sr.RelatedRecordId ;
            sr.RelatedRecordId = UserIdValue;
            srrecords.add(sr);
        }
        if(srrecords.size()!=0){
            
             String err = 'Successful';
            if(srrecords.size() !=0 ){
                Database.UpsertResult[] records =Database.upsert(srrecords,false);
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
        
    }
    public void finish(Database.BatchableContext BC){
        if(hasError == false){
              BatchModifyDeactiveUser bdt = new BatchModifyDeactiveUser(ExistingUserId);
            dataBase.executeBatch(bdt);
        }
        
    }
}