trigger PaymentTrigger on asp04__Payment__c (before insert, before update, before delete, 
                                             after insert, after update, after delete, after undelete)
{
    // BaseTriggerHandler.process('PaymentHandler');

     if(Trigger.isInsert && Trigger.isBefore)  
    {
        for(asp04__Payment__c p : Trigger.new ) 
        {
            if(p.asp04__Payment_Route_Selected__c == 'Card'){
                String merchant = 'cybersource_test';
                try{
                    merchant = [
                    Select id, asp04__Merchant_Group__c 
                    FROM asp04__Authorisation__c 
                    WHERE id = :p.asp04__Authorisation__c
                ].asp04__Merchant_Group__c;
                } catch (Exception e) {}
                p.asp04__Merchant_Group__c = merchant;
            }
        }
    }
    
    if(Trigger.isInsert && Trigger.isAfter)  
    {
        for(asp04__Payment__c p : Trigger.new ) 
        {
            if(p.asp04__Payment_Route_Selected__c == 'Card'){
                Map<String, Object> params = new Map<String, Object>();
                String paymentId = p.id;
                params.put('paymentId', p.Id);
                Flow.Interview calcFlow = new Flow.Interview.asp04.Process_Immediate_Payment(params);
                calcFlow.start();
            }
        }
    }
    
    // if payment has been reallocated, recalcualted values on both invoices.
    
    if(Trigger.isUpdate && Trigger.isAfter)  
    {
        for(asp04__Payment__c p : Trigger.new )
        {
            if( Trigger.oldMap.get(p.ID).Customer_Invoice__c != Trigger.newMap.get(p.ID).Customer_Invoice__c){
                if( Trigger.oldMap.get(p.ID).Customer_Invoice__c != NULL){
                    PaymentReallocationController.recalcInvoice(Trigger.oldMap.get(p.ID).Customer_Invoice__c);
                }
                if( Trigger.newMap.get(p.ID).Customer_Invoice__c != NULL){
                    PaymentReallocationController.recalcInvoice( Trigger.newMap.get(p.ID).Customer_Invoice__c);
                }
            }
            if(p.asp04__Payment_Stage__c == 'Failed' && Trigger.newMap.get(p.ID).Customer_Invoice__c != NULL){
                PaymentReallocationController.recalcInvoice(Trigger.newMap.get(p.ID).Customer_Invoice__c);
            }
        }
        
        // Created by pradeep for Finance App project
        PaymentReallocationController.updateSRICandidateValue(Trigger.new);
    }           
}