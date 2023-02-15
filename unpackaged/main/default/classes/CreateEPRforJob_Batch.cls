global class CreateEPRforJob_Batch implements Database.Batchable<sObject> {
    global static   Set<String> userId  ;
    global static  Set<String> userEmailids;
    global CreateEPRforJob_Batch( ){
        userId =  new Set<String>();
        userEmailids =  new Set<String>();
        
        System.debug('userId'+userId);
        System.debug('userEmailids'+userEmailids);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug('userId'+userId);
        System.debug('userEmailids'+userEmailids);
        String query='';
        if(!test.isrunningtest())
            query = System.Label.JobEPRCreationQuery ;  
        else
            query ='SELECT id, CreatedDate, Temp_Key_Account_Req_Tracking__c,Status__c, Type__c, Account__r.Account_Type__c , Name, (SELECT Status FROM Work_Orders__r), (SELECT Name FROM Engineer_Pay_Requisitions__r), All_Work_Order_in_Status_of_Complete__c FROM Job__c';
      //  query = query +  ' LIMIT 1 '; 
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Job__c> Jobs) {
        GetUserDetailsFromMetadata.wrapUser wrap =  GetUserDetailsFromMetadata.getUserEmailIds();
        userId = wrap.userIds;
        userEmailids= wrap.userEmailIds;
        System.debug('userId'+userId);
        System.debug('userEmailids'+userEmailids);
        List<Job__c> jobRecord = new List<Job__c>();
        string header = 'Job Name with Error Message \n';
        string finalstr = header ;
        Boolean hasError = false;
        for(Job__c job:jobs)
        {
            if(job.Engineer_Pay_Requisitions__r.size()==0 ){
                System.debug('job'+job.id);
                try{
                    job_LabourRequisitionsController.genReqs(job);     
                }
                catch(Exception ex){
                    if(userId.size()!=0)
                        sendCustomNotificationToUser.sendCustomnotification(ex.getMessage(),job.id,userId);
                    if(userEmailids.size()!=0)
                        sendCustomNotificationToUser.sendEMailerrorMessage('EPR Creation Section ',
                                                                           ex.getMessage(),job.id,userEmailids,
                                                                           'EPR');
                }
                
                job.Temp_Key_Account_Req_Tracking__c = TRUE;
                jobRecord.add(job);
                System.debug('success on job '+job.id+' ('+job.name+')');
            }
        }
        
        Set<String> errMessage = new Set<String>();
        if(jobRecord.size()!=0){
            List<Database.upsertResult> jobUpdations = Database.upsert(jobRecord,false);
            for(Integer i=0;i<jobUpdations.size();i++){
                Database.UpsertResult result = jobUpdations.get(i);
                Job__c jobRec = jobRecord.get(i);
                Boolean isSuccess =  result.isSuccess();
                String statusKey = isSuccess ?'success':'failed';
                if(!isSuccess   )
                {
                    string recordString = 'Job Id :' +result.id+'  '+'Error Message :'+result.getErrors().get(0).getMessage()+'\n';
                    finalstr = finalstr +recordString;
                    hasError = true;
                    if(userId.size()!=0   )
                        sendCustomNotificationToUser.sendCustomnotification(recordString,jobRec.id,userId);
                }
            }
        }
        if(hasError && userEmailids.size()!=0 || test.isrunningtest()){
            sendCustomNotificationToUser.sendEMailerrorMessage('JOb Update Temp_Key_Account_Req_Tracking__c Section '
                                                               ,finalstr ,null ,userEmailids, 'Job');
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        updateEprStatusApproved bCon = new updateEprStatusApproved();
        Database.ExecuteBatch(bCon,10);
    }
}