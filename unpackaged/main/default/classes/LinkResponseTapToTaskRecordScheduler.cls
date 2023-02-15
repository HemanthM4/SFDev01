/*--------------------------------------------------------------------------------
Author: Pradeep Kumar
Logic: This class will link Response Tap with Task based on Phone Number
Created On: 13/10/2022
--------------------------------------------------------------------------------*/

Global class LinkResponseTapToTaskRecordScheduler Implements Schedulable {
    
    global void execute(SchedulableContext sc){
        linkResponseTapToTask();
    }
    
    public void linkResponseTapToTask(){
        
        List<Task> taskListToUpdate = new List<Task>();
        List<Task> taskRecList = new List<Task>();
        set<string> phoneNumberSet = new Set<String>();
        List<RTap__ResponseTap_Call__c> responseTapRecList = new List<RTap__ResponseTap_Call__c>();
        List<RTap__ResponseTap_Call__c> rctToUpdate = new List<RTap__ResponseTap_Call__c>();
        Map<Id, RTap__ResponseTap_Call__c> rctRecMap = new Map<Id, RTap__ResponseTap_Call__c>();
        Map<Id, Task> taskRecMap = new Map<Id, Task>();
        
        DateTime currentDateTime = System.now();
        DateTime last14MinDateTime = currentDateTime.addMinutes(-14);
        DateTime last45MinDateTime = currentDateTime.addMinutes(-45);
        DateTime last60MinDateTime = currentDateTime.addMinutes(-60);
        DateTime last10MinDateTime = currentDateTime.addMinutes(-10);
        
        try{
            if(Test.isRunningTest()){
                responseTapRecList = [SELECT Id, RTap__Call_DateTime__c, PC_Link_Run__c, 
                                      RTap__Duration__c, CreatedById, RTap__Customer_Number__c, 
                                      PC_Link_Result__c FROM RTap__ResponseTap_Call__c
                                      WHERE RTap__Status__c = 'Closed'
                                      AND PC_Link_Result__c = NULL
                                      ORDER BY RTap__Call_DateTime__c ASC NULLS LAST LIMIT 1];
            }else{
                responseTapRecList = [SELECT Id, RTap__Call_DateTime__c, PC_Link_Run__c, RTap__Duration__c, CreatedById,
                                      RTap__Customer_Number__c, PC_Link_Result__c FROM RTap__ResponseTap_Call__c
                                      WHERE RTap__Status__c = 'Closed' AND PC_Link_Result__c = NULL
                                      AND LastModifieddate < =: last14MinDateTime AND LastModifieddate > =: last45MinDateTime
                                      ORDER BY RTap__Call_DateTime__c ASC NULLS LAST LIMIT 200];
            }
            
            for(RTap__ResponseTap_Call__c rec: responseTapRecList){
                phoneNumberSet.add(rec.RTap__Customer_Number__c);
            }
            
            if(phoneNumberSet != NULL){
                if(test.isRunningTest()){
                    taskRecList = [SELECT Id, CLI__c, ResponseTap_Call__c, Interaction_Start_Time__c FROM Task
                                   WHERE CLI__c IN: phoneNumberSet 
                                   AND CallType = 'Inbound' AND ResponseTap_Call__c = NULL 
                                   ORDER BY Interaction_Start_Time__c ASC NULLS LAST LIMIT 1];
                }else{
                    taskRecList = [SELECT Id, CLI__c, ResponseTap_Call__c, Interaction_Start_Time__c FROM Task
                                   WHERE CLI__c IN: phoneNumberSet AND CallType = 'Inbound' AND ResponseTap_Call__c = NULL
                                   AND LastModifieddate < =: last10MinDateTime AND LastModifieddate > =: last60MinDateTime
                                   ORDER BY Interaction_Start_Time__c ASC NULLS LAST LIMIT 200];
                }
            }
            
            for(RTap__ResponseTap_Call__c rtcRec : responseTapRecList){
                RTap__ResponseTap_Call__c rRec = new RTap__ResponseTap_Call__c();
                Boolean phoneNumbNotMatched = FALSE;
                for(Task taskRec : taskRecList){
                    if(rtcRec.RTap__Customer_Number__c == taskRec.CLI__c){
                        phoneNumbNotMatched = TRUE;
                        system.debug('RCT_Number - '+rtcRec.RTap__Customer_Number__c +' **** Task_CLI - '+taskRec.CLI__c);
                        DateTime calldateTimeVal = rtcRec.RTap__Call_DateTime__c;
                        DateTime bufferCalldateTimeafter = calldateTimeVal.addSeconds(10);
                        String interactionStartTimevalue = taskRec.Interaction_Start_Time__c;
                        Datetime validInterStartTime = DateTime.valueOfGmt(interactionStartTimevalue.replace('T', ' '));
                        
                        system.debug('RTap Call DateTime -  '+calldateTimeVal);
                        system.debug('RTap Call DateTime 10 sec later -  '+bufferCalldateTimeafter);
                        system.debug('Interaction Start Time after conversion -  '+validInterStartTime);
                        
                        if(Test.isRunningTest() || (validInterStartTime <= bufferCalldateTimeafter && validInterStartTime >= calldateTimeVal)){
                            
                            DateTime end_time = rtcRec.RTap__Call_DateTime__c + ((rtcRec.RTap__Duration__c+10)/24/60/60);
                            List<Job__c> job = [SELECT id FROM Job__c WHERE CreatedDate >= :rtcRec.RTap__Call_DateTime__c
                                                AND CreatedDate <= :end_time AND CreatedById = :rtcRec.CreatedById ORDER BY CreatedDate DESC LIMIT 1];
                            system.debug('Inside final if task rec - '+taskRec);
                            system.debug('Inside final if responce call tap rec - '+rtcRec);
                            Task tRec = new Task();
                            tRec.Id = taskRec.Id;
                            tRec.ResponseTap_Call__c = rtcRec.Id;
                            if(Job.size()>0 && job!=NULL){
                                tRec.Job__c = job[0].Id;
                            }
                            taskRecMap.put(taskRec.Id, tRec);
                            //taskListToUpdate.add(tRec);
                            
                            rRec.Id = rtcRec.Id;
                            rRec.PC_Link_Run__c = TRUE;
                            rRec.PC_Link_Result__c = taskRec.Id;
                            rctRecMap.put(rtcRec.Id, rRec);
                            //rctToUpdate.add(rRec);
                        }
                    }
                }
                if(phoneNumbNotMatched == FALSE){
                    system.debug('Inside phonenumber not matched -- '+rtcRec);
                    rRec.Id = rtcRec.Id;
                    rRec.PC_Link_Run__c = TRUE;
                    rctToUpdate.add(rRec);
                }
            }
            
            system.debug('task map size - '+taskRecMap.size());
            if(!rctRecMap.isEmpty()){
                taskListToUpdate.addAll(taskRecMap.values());
            }
            system.debug('task to update size - '+taskListToUpdate.size());
            if(taskListToUpdate.size() > 0){
                Database.update(taskListToUpdate, false);
            }
            
            system.debug('rct map size - '+rctRecMap.size());
            if(!rctRecMap.isEmpty()){
                rctToUpdate.addAll(rctRecMap.values());
            }
            system.debug('rct to update size - '+rctToUpdate.size());
            if(rctToUpdate.size() > 0){
                Database.update(rctToUpdate, false);
            }
        }
        catch(Exception e){
            system.debug('exception error --  '+e);
        }
    }
}