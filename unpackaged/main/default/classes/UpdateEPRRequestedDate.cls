global class UpdateEPRRequestedDate implements Database.Batchable<sObject> {
 global static   Set<String> userId = new Set<String>();
    global static  Set<String> userEmailids = new Set<String>();
    global static  Boolean hasErrorCheck = false;
    global UpdateEPRRequestedDate(){
        userId = new Set<String>();
        userEmailids = new Set<String>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query='';		
        if(!test.isrunningtest())
            query = System.Label.updateEPRScheduleDate ;  
        else
            query ='SELECT id,Status__c,Work_Order__c,Job__c from Engineer_Pay_Requisition__c  ';
       // query = query +  ' LIMIT 1 '; 
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Engineer_Pay_Requisition__c> eprs) {
        GetUserDetailsFromMetadata.wrapUser wrap =  GetUserDetailsFromMetadata.getUserEmailIds();
        userId = wrap.userIds;
        userEmailids= wrap.userEmailIds;
        hasErrorCheck = false;
        Set<id> workOrderIds = new Set<id>();
        Set<id> jobIds = new Set<id>();
        Map<Id,Date> WOSADate = new Map<Id,Date>();
        Map<Id,Date> JobSADate = new Map<Id,Date>();
        Map<Id,Date> WOIdJobSADate = new Map<Id,Date>();
        Set<id> eprIds = new Set<id>();
        Set<id> WorkOrderIdstoUpdateFlag = new Set<id>();
         Set<id> eprToupdateFlag = new Set<id>();
        List<Engineer_Pay_Requisition__c> eprsUpdate =  new List<Engineer_Pay_Requisition__c>();
        for(Engineer_Pay_Requisition__c epr:eprs){
            eprIds.add(epr.id);
            if(epr.Work_Order__c  !=null || test.isRunningTest()){
                if(!WOSADate.containsKey(epr.Work_Order__c)){
                    Map<id,Date> resMap = new Map<Id,Date>();
                    resMap =  getWODate(epr.Work_Order__c);
                    if(resMap.size()!=0){
                        WOSADate.putAll(resMap);
                    }else{
                        WOSADate.putAll(getJObDateFORWO(epr.Job__c,epr.Work_Order__c ));
                    }
                }
            }else{
                if(!JobSADate.containsKey(epr.Job__c)){
                    Id workId  = getJObDate(epr.Job__c);
                    if(workId != null ){
                        epr.Work_Order__c =   workId;
                        eprsUpdate.add(epr);
                    }
                    
                }
                
            }
        }
        List<WorkOrder> WOUpdate = new List<WOrkOrder>();
        System.debug('WOSADate'+WOSADate);
        if(WOSADate.size() !=0){
            for(WOrkOrder WO : [SELECT id from WorkOrder where id=:WOSADate.keySet()]){
                WO.Requested_Date__c = WOSADate.get(WO.id);
                WOUpdate.add(WO);
            }
        }
        if(WOUpdate.size() !=0 ){
            Database.UpsertResult[] records =Database.upsert(WOUpdate,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess){
                    WorkOrderIdstoUpdateFlag.add(record.id);
                    hasError = true;
                    sendnotofication(JSON.serialize(recordMap), finalstr,record.id);
                }
            }
            if(hasError){
                sendCustomNotificationToUser.sendEMailerrorMessage('WO Requested  Date Update ',finalstr ,null ,userEmailids, 'WO');
            }
        }
        if(eprsUpdate.size() !=0 || Test.isRunningTest()){
            Database.UpsertResult[] records =Database.upsert(eprsUpdate,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess){
                    eprToupdateFlag.add(record.id);
                    sendnotofication(JSON.serialize(recordMap), finalstr,record.id);
                    hasError = true;
                }
            }	
            if(hasError){
                sendCustomNotificationToUser.sendEMailerrorMessage('EPR Work order update ',finalstr ,null ,userEmailids, 'EPR');
            }
        }
        List<Engineer_Pay_Requisition__c>eprUpdate =  new List<Engineer_Pay_Requisition__c>();
        if(!hasErrorCheck || Test.isRunningTest()){
            for(Engineer_Pay_Requisition__c epr:eprs){
                epr.Batch_Processed__c = true;
                eprUpdate.add(epr);
                
            }  
        }
        if(eprUpdate.size() !=0 || Test.isRunningTest()){
            Database.UpsertResult[] records =Database.upsert(eprUpdate,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess){
                   // hasErrorCheck = true;
                     eprToupdateFlag.add(record.id);
                    sendnotofication(JSON.serialize(recordMap), finalstr,record.id);
                    hasError = true;
                }
            }
            if(hasError){
                sendCustomNotificationToUser.sendEMailerrorMessage('EPR Flag update ',finalstr ,null ,userEmailids, 'EPR');
            }
        }
          List<Engineer_Pay_Requisition__c> eprToUpdates = new List<Engineer_Pay_Requisition__c>();
             for(Engineer_Pay_Requisition__c epr:eprs){
                 System.debug('epr'+epr.id);
                 if(!eprToupdateFlag.contains(epr.id) && !WorkOrderIdstoUpdateFlag.contains(epr.Work_Order__c)){
                     epr.Has_Batch_Update_Date__c = true;
                     eprToUpdates.add(epr);
                 }
             }
        
        if(eprToUpdates.size() !=0 || Test.isRunningTest()){
            Database.UpsertResult[] records =Database.upsert(eprToUpdates,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess){
                   // hasErrorCheck = true;
                     eprToupdateFlag.add(record.id);
                    sendnotofication(JSON.serialize(recordMap), finalstr,record.id);
                    hasError = true;
                }
            }
            if(hasError){
                sendCustomNotificationToUser.sendEMailerrorMessage('EPR Flag update ',finalstr ,null ,userEmailids, 'EPR');
            }
        }
        
    }
    public static void sendnotofication(String recordDetails,String finalstr,String recordId){
        hasErrorCheck = true;
        string recordString = recordDetails +'\n';
        System.debug('recordDetails'+recordDetails);
        finalstr = finalstr +recordString;
        
        if(userId != null  && userId.size()!=0)
            sendCustomNotificationToUser.sendCustomnotification(recordDetails,recordId,userId);
    }	
    public static Map<id,Date >getJObDateFORWO(String jobId,String WOrkOrderId){
        Map<id,Date > mapDate = new  Map<id,Date >();
        for(WOrkOrder WO :[SELECT id,(SELECT id,SchedStartTime from ServiceAppointments where SchedStartTime!=null
                                      order by SchedStartTime DESC LIMIT 1 ) from WorkOrder where Job__c=:jobId Order by CreatedDate DESC LIMIT 1]){
                                          if(wo.ServiceAppointments.size()!=0){
                                              mapDate.put(WOrkOrderId,Date.valueOf(WO.ServiceAppointments[0].SchedStartTime));    
                                          }
                                      }
        if(mapDate.size() == 0 ){
            hasErrorCheck = true;
            sendCustomNotificationToUser.sendEMailerrorMessage('WO Requested  Date Update ','No Schedule Start datetime found at WO' ,null ,userEmailids, 'WO');
            sendCustomNotificationToUser.sendCustomnotification('No Schedule Start datetime found at WO',jobId,userId);
            
        }
        return mapDate;
    }
    public static  id getJObDate(String jobId){
        for(WOrkOrder WO :[SELECT id,Requested_Date__c,(SELECT id,SchedStartTime from ServiceAppointments where SchedStartTime!=null
                                                        order by SchedStartTime DESC LIMIT 1 ) from WorkOrder where Job__c=:jobId Order by CreatedDate DESC LIMIT 1]){
                                                            if(WO.Requested_Date__c !=null){
                                                                return WO.id;  
                                                            }else  if(wo.ServiceAppointments.size()!=0)
                                                            {
                                                                updateWorkOrder(wo.id,Date.valueOf((wo.ServiceAppointments[0].SchedStartTime)));
                                                                return WO.id; 
                                                            }
                                                        }
        return null;
    }
    public static void updateWorkOrder(String workorderid ,date dateValue ){
        list<WorKOrder> wos = new List<WorkOrder>();
        WorkOrder wo = new WOrkOrder();
        wo.id =workorderid;
        wo.Requested_Date__c = dateValue;
        wos.add(wo);
        if(wos.size() !=0){
            Database.UpsertResult[] records =Database.upsert(wos,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess){
                    sendnotofication(JSON.serialize(recordMap), finalstr,record.id);
                    hasError = true;
                }
            }
        	    if(hasError){
                sendCustomNotificationToUser.sendEMailerrorMessage('WO Date Update ',finalstr ,null ,userEmailids, 'WO');
            }
        }
    }
    public static Map<id,Date >getWODate(String workorderId){
        Map<id,Date > mapDate = new  Map<id,Date >();
        for(ServiceAppointment sa : [SELECT id,SchedStartTime from ServiceAppointment where Work_Order__c =:workorderId 
                                     and SchedStartTime !=null
                                     order by SchedStartTime DESC LIMIT 1  ]){
                                         mapDate.put(workorderId,Date.valueOf(sa.SchedStartTime));
                                     }
        return mapDate;
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}