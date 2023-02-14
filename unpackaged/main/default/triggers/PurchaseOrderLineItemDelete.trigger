trigger PurchaseOrderLineItemDelete on Purchase_Order_Line_Item__c (before delete) {
    for(Purchase_Order_Line_Item__c poli : Trigger.old ) {
        Flow.Interview.FL_Update_CandCs_with_PO_Value_Aspect_or_Engineer_System myFlow = 
            new Flow.Interview.FL_Update_CandCs_with_PO_Value_Aspect_or_Engineer_System(
                new map<String,Object>{'var_DeletedPOLineItemID' => poli.id} 
            );
        //if (Test.isRunningTest()) {
	        myFlow.start();               
        //}
    }    
}