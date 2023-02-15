/*
Author: Pradeep Kumar on 25/07/2022
Purpose: This is trigger handler class created to handle all the logic related to WorkOrder Object.

Modification Log: 

*/
public class WorkOrderTriggerHandler {
    
    public void assignTradeRateCard(List<WorkOrder> woRecList){
        
        Set<string> tradeNameSet = new Set<string>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> accRateIdSet = new Set<Id>();
        List<Rate_Card_Trade__c> trcRecList = new List<Rate_Card_Trade__c>();
        List<Account> accRecList = new List<Account>();
        Map<String, List<WorkOrder>> tradeWOMap = new Map<String, List<WorkOrder>>();
        
        for(WorkOrder woRec: woRecList){
            if(woRec.Trade__c != NULL){
                tradeNameSet.add(woRec.Trade__c);
                accIdSet.add(woRec.AccountId);
            }
            if(tradeWOMap.containsKey(woRec.Trade__c)){
                List<WorkOrder> woList = new List<WorkOrder>();
                woList = tradeWOMap.get(woRec.Trade__c); woList.add(woRec);
                tradeWOMap.put(woRec.Trade__c, woList);
            }else{
                tradeWOMap.put(woRec.Trade__c, new List<WorkOrder>{woRec});
            }
        }
        
        List<Rate_Card_Account__c> acrRec = [SELECT Id,Standard__c FROM Rate_Card_Account__c 
                                             WHERE Standard__c = TRUE LIMIT 1];
        
        if(accIdSet != NULL){
            accRecList = [SELECT Id, Rate_Card__c FROM Account WHERE Id IN: accIdSet];
        }
        
        if(accRecList.size() > 0){
            for(Account accRec: accRecList){
                accRateIdSet.add(accRec.Rate_Card__c);
            }
        }
        
        if(tradeNameSet.size() > 0 && accRateIdSet.size() > 0){
            trcRecList = [SELECT Id,Trade_Name__c,Rate_Card__c FROM Rate_Card_Trade__c 
                          WHERE Trade_Name__c IN:tradeNameSet AND Rate_Card__c IN: accRateIdSet];
        }
        else if(tradeNameSet.size() > 0 && accRateIdSet == NULL && acrRec != NULL){
             trcRecList = [SELECT Id,Trade_Name__c,Rate_Card__c FROM Rate_Card_Trade__c WHERE Trade_Name__c IN:tradeNameSet 
                           AND Rate_Card__c =: acrRec[0].Id];
        }
        
        if(trcRecList.size() > 0){
            for(Rate_Card_Trade__c trcRec: trcRecList){
                if(tradeWOMap.containsKey(trcRec.Trade_Name__c)){
                    for(WorkOrder woRec: tradeWOMap.get(trcRec.Trade_Name__c)){
                        if(woRec.Trade_Rate__c == NULL){
                            woRec.Trade_Rate__c = trcRec.Id;
                        }
                    } 
                }
            } 
        }
        TriggerStopper.stopWOTrigger = TRUE;
    }
}