/*

Modification Log: 
1. 25/07/2022 - Updated by Pradeep
*/

trigger WorkOrder on WorkOrder (before insert, before update, before delete, 
                                after insert, after update, after delete, after undelete) 
{
    Id userId = Label.Exclude_User;  
    String uId = userId;
    System.debug('user Id: '  +uId);
    System.debug('usr idd : ' +UserInfo.getUserId());
    if(uId != UserInfo.getUserId()){
        BaseTriggerHandler.process('WorkOrderHandler');                                                  
    }
    
    WorkOrderTriggerHandler obj = new WorkOrderTriggerHandler();
    
    if(Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate))
    {
        List<WorkOrder> newWORecList = new List<WorkOrder>();
        for(WorkOrder woRec: trigger.new){
            if(woRec.Trade_Rate__c == null){
                newWORecList.add(woRec);
            }
        }
        if(newWORecList.size() > 0){
            obj.assignTradeRateCard(newWORecList);
        }
    }
}