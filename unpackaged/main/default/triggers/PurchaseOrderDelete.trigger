trigger PurchaseOrderDelete on Purchase_Order__c (before delete) {
    for(Purchase_Order__c po : Trigger.old ) {
        Flow.Interview.FL_Update_CandCs_with_PO_Value_Aspect_or_Engineer_System myFlow = 
            new Flow.Interview.FL_Update_CandCs_with_PO_Value_Aspect_or_Engineer_System(
                new map<String,Object>{'var_DeletedPOID' => po.id} 
            );
        myFlow.start();       
    }    
}