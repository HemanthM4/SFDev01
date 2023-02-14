trigger erp_create_edit_delete_trigger on Engineer_Pay_Requisition__c (after insert, after update, after delete) {

   
    if(Trigger.isDelete) {
        for(Engineer_Pay_Requisition__c epr : Trigger.old ) {
                epr_create_edit_delete_controller.updateJob(Trigger.oldMap.get(epr.ID).Job__c, Trigger.oldMap.get(epr.ID).Work_Order__c);
        }
    }
    if(Trigger.isUpdate)  
    {    
        for(Engineer_Pay_Requisition__c epr : Trigger.new ) {
            if(Trigger.oldMap.get(epr.ID).Pay_Total__c != Trigger.newMap.get(epr.ID).Pay_Total__c)
            {
                epr_create_edit_delete_controller.updateJob(Trigger.newMap.get(epr.ID).Job__c,Trigger.newMap.get(epr.ID).Work_Order__c);
            }
        }
    }
    if(Trigger.isInsert) 
    {    
        for(Engineer_Pay_Requisition__c epr : Trigger.new ) {
            if(Trigger.newMap.get(epr.ID).Auto_Generated__c == FALSE )
            {
                epr_create_edit_delete_controller.updateJob(Trigger.newMap.get(epr.ID).Job__c,Trigger.newMap.get(epr.ID).Work_Order__c);
            }
        }
    }
   
}