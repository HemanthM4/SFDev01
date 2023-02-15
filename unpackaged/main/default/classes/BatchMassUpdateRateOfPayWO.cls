Global class BatchMassUpdateRateOfPayWO Implements Database.batchable<sobject>{
     global final string query;
     global BatchMassUpdateRateOfPayWO(string q){
          query=q;
     }
     global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
     }
     global  void execute(Database.BatchableContext BC,List<WorkOrder> Wos){
         List<WorkOrder> WOsDML = new List<WOrkOrder>();
         if(Wos.size()!=0){
             for(WorkOrder Wo: Wos){
                 if(Wo.Rate_of_Pay__c != null){
                     Wo.Rate_Of_Pay_Percent__c = Wo.Rate_of_Pay__c;
                     WOsDML.add(Wo);
                 }
             }
         }
         if(WOsDML.size()!=0){
             update WOsDML;
         }
    
    }
    global void finish(Database.BatchableContext BC){
    }

 }
/*
String accQuery = 'SELECT id,Rate_of_Pay__c,Rate_Of_Pay_Percent__c from WorkOrder where  Rate_of_Pay__c !=null';
BatchMassUpdateRateOfPayWO bdt = new BatchMassUpdateRateOfPayWO(accQuery);
dataBase.executeBatch(bdt);
*/