/*
Author: Pradeep Kumar on 22/07/2022
Purpose: This is trigger Class for Account object.

Modification Log: 

*/

trigger AccountTrigger on Account (before insert) {
	
    AccountTriggerHandler obj = new AccountTriggerHandler();
    if(Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate)){
        obj.assignAccRateCard(trigger.new);
    }
}