/*
Author: Pradeep Kumar on 15/08/2022
Purpose: This is trigger for Customer_Credit_Note__c object.

Modification Log: 

*/

trigger CustomerCreditNoteTrigger on Customer_Credit_Note__c (after insert) {
	
    CustomerCreditNoteTriggerHandler obj = new CustomerCreditNoteTriggerHandler();
    ID networkId = Network.getNetworkId();
    
    if(Trigger.IsAfter && Trigger.IsInsert){
        obj.attachPDFToNoteAndAttachment(trigger.new, networkId);
    }
}