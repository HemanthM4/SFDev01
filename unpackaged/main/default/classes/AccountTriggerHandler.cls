/*
Author: Pradeep Kumar on 22/07/2022
Purpose: This is trigger handler class created to handle all the logic related to Account Object.

Modification Log: 123

*/
public class AccountTriggerHandler {
    
    public void assignAccRateCard(List<Account> accRecList){
        
        List<Rate_Card_Account__c> acrRec = [SELECT Id,Standard__c FROM Rate_Card_Account__c WHERE Standard__c = TRUE LIMIT 1];
        
        if(acrRec.Size() > 0){
            for(Account acc : accRecList){
                if(acc.Rate_Card__c == NULL){
                    system.debug('acrRec.Id -- '+acrRec[0].Id);
                    acc.Rate_Card__c = acrRec[0].Id;
                }
            }
        }
    }
}