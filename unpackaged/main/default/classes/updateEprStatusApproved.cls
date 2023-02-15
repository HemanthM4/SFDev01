global class updateEprStatusApproved implements Database.Batchable<sObject> {
    global static   Set<String> userId = new Set<String>();
    global static  Set<String> userEmailids = new Set<String>();
    global updateEprStatusApproved(){
        userId = new Set<String>();
        userEmailids = new Set<String>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query='';
        if(!test.isrunningtest())
            query = System.Label.updateEprStatusApproved ;  
        else
            query ='SELECT id,Status__c from Engineer_Pay_Requisition__c  ';
      //  query = query +  ' LIMIT 1 '; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Engineer_Pay_Requisition__c> eprs) {
        GetUserDetailsFromMetadata.wrapUser wrap =  GetUserDetailsFromMetadata.getUserEmailIds();
        userId = wrap.userIds;
        userEmailids= wrap.userEmailIds;
        List<Engineer_Pay_Requisition__c> eprRecord = new List<Engineer_Pay_Requisition__c>();
        for(Engineer_Pay_Requisition__c epr:eprs)   
        {  
            epr.Has_Batch_Update_Status__c = true;
            epr.Batch_Processed__c = true;
            epr.Status__c = 'Approved'; 
            System.debug('epr'+epr.id);
            eprRecord.add(epr);
        }   
        if(eprRecord.size()!=0){
            Database.UpsertResult[] records =Database.upsert(eprRecord,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess){
                    String recordDetails = JSON.serialize(recordMap);
                    string recordString = recordDetails +'\n';
                    System.debug('recordDetails'+recordDetails);
                    finalstr = finalstr +recordString;
                    hasError = true;
                    if(userId.size()!=0 && !test.isRunningtest())
                        sendCustomNotificationToUser.sendCustomnotification(recordDetails,record.id,userId);
                }
            }
            if(hasError){
                sendCustomNotificationToUser.sendEMailerrorMessage('EPR Update Approved Section ',finalstr ,null ,userEmailids, 'EPR');
            }
        }
        
    }
    global void finish(Database.BatchableContext BC) {
       missingEmailupdate bCon = new missingEmailupdate();
      Database.ExecuteBatch(bCon,10);
    }
}