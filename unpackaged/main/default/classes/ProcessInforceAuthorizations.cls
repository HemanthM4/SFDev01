public class ProcessInforceAuthorizations {
    
    
  @InvocableMethod
    public static void processInforceAuthorizations(List<Id> authinforceId){
        
        OnlineBookingProcessHelper.accountWorkOrderMap = new Map<Id,list<WorkOrder>>();
        List<Job__c> joblist = new List<Job__c>();
        List<asp04__Authorisation__c> authlist = new List<asp04__Authorisation__c>();
        List<WorkOrder> woList = new List<WorkOrder>();
        List<Id> receivedwoList = new List<Id>();
        List<Id> serviceAppwoList = new List<Id>();
        List<Id> woListToProcess = new List<Id>();
        
        for(asp04__Authorisation__c authrec : [select id,Online_Booking__c from asp04__Authorisation__c where Id in: authinforceId]){
            authrec.Online_Booking__c = FALSE;
            authlist.add(authrec);
        }
        update authlist;
        
        for(Job__c jobrec : [select id,Authorisation__c,Account__c from Job__c where Authorisation__c in: authinforceId]){
            joblist.add(jobrec);
        }
        
        for(WorkOrder wo : [select id from WorkOrder where Job__c in: joblist]){
            receivedwoList.add(wo.Id);
        }
        
        //checking if any workorders have previous service appointments
        for(ServiceAppointment sa : [select id,Work_Order__c from ServiceAppointment where Work_Order__c in: receivedwoList]){
            serviceAppwoList.add(sa.Work_Order__c);
        }
        
        //Create a list of new WorkOrder to process
        for(Id woId : receivedwoList){
            if(!serviceAppwoList.contains(woId)){
               woListToProcess.add(woId);   
            }
          }
        
        for(WorkOrder wo : [select id,Job__c,Schedule_Slot_Start__c,Schedule_Slot_End__c,Duration,WorkTypeId,Description,Requested_Date__c,Arrival_Window_Start__c,Arrival_Window_End__c,Access_Details__c,ContactId,AccountId,Costs_and_Charges__c,Arrival_Window_Start_Date_Time__c,Arrival_Window_End_Date_Time__c from WorkOrder where Id in: woListToProcess]){
            
            if(OnlineBookingProcessHelper.accountWorkOrderMap.containsKey(wo.AccountId)) {
                      List<WorkOrder> wolistexist = OnlineBookingProcessHelper.accountWorkOrderMap.get(wo.AccountId);
                      wolistexist.add(wo);
                      OnlineBookingProcessHelper.accountWorkOrderMap.put(wo.AccountId, wolistexist);
                }else{
                        List<WorkOrder> wolistnew = new List<WorkOrder>();
                        wolistnew.add(wo);
                        OnlineBookingProcessHelper.accountWorkOrderMap.put(wo.AccountId, wolistnew);
                 } 
        }
        system.debug('size' + OnlineBookingProcessHelper.accountWorkOrderMap.keySet());
        OnlineBookingProcessHelper.createServiceAppointments(OnlineBookingProcessHelper.accountWorkOrderMap.KeySet());
    }
}