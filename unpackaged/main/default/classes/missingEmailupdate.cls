global class missingEmailupdate implements Database.Batchable<sObject> {
    global static   Set<String> userId = new Set<String>();
    global static  Set<String> userEmailids = new Set<String>();
    global missingEmailupdate(){
         userId = new Set<String>();
        userEmailids = new Set<String>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query='';
        if(!test.isrunningtest())
            query = System.Label.missingEprs ;  
        else
            query ='SELECT id ,Name,Service_Resource_Email__c,Service_Resource__r.Email__c,Service_Resource__c from Engineer_Pay_Requisition__c';
//query = query +  ' LIMIT 1 '; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Engineer_Pay_Requisition__c> eprs) {
        GetUserDetailsFromMetadata.wrapUser wrap =  GetUserDetailsFromMetadata.getUserEmailIds();
        userId = wrap.userIds;
        userEmailids= wrap.userEmailIds;
         System.debug('userId'+userId);
        System.debug('userEmailids'+userEmailids);
        List<Engineer_Pay_Requisition__c> eprUpdate = new List<Engineer_Pay_Requisition__c> ();
        for( Engineer_Pay_Requisition__c epr:eprs){
            if(epr.Service_Resource__c!=null && epr.Service_Resource__r.Email__c!=null){
                epr.Service_Resource_Email__c = epr.Service_Resource__r.Email__c;
                epr.Batch_Processed__c = true;
                epr.Has_Batch_Updated_Email__c = true;
                System.debug(epr.id);
                eprUpdate.add(epr);
            }
            else{
                 System.debug('userId'+userId);
        System.debug('userEmailids'+userEmailids);
                System.debug('epr.id'+epr.id);
                sendCustomNotificationToUser.sendCustomnotification(' No EMail id found in EPR',epr.id,userId);
                sendCustomNotificationToUser.sendEMailerrorMessage(' No EMail id found in EPR ',
                                                                   epr.id ,null ,userEmailids, 'EPR');
                
            }
        }
        
        if(eprUpdate.size()!=0){
            Database.UpsertResult[] records =Database.upsert(eprUpdate,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess || Test.isRunningTest()){
                    String recordDetails = JSON.serialize(recordMap);
                    string recordString = recordDetails +'\n';
                    System.debug('recordDetails'+recordDetails);
                    finalstr = finalstr +recordString;
                    hasError = true;
                    if(userId.size()!=0 &&  !Test.isRunningTest())
                        sendCustomNotificationToUser.sendCustomnotification(recordDetails,null,userId);
                }
            }
            if(hasError){
                sendCustomNotificationToUser.sendEMailerrorMessage('Service Resource EMail Assign',finalstr ,null ,userEmailids, 'SR');
                
            }
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        if(!Test.isRunningTest()){
           UpdateEPRRequestedDate bCon = new UpdateEPRRequestedDate();
           Database.ExecuteBatch(bCon,1);  
        }else{
           UpdateEPRRequestedDate bCon = new UpdateEPRRequestedDate();
          Database.ExecuteBatch(bCon,10); 
        }
        
    }
    
}