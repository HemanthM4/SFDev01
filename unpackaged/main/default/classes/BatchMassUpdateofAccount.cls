Global class BatchMassUpdateofAccount Implements Database.batchable<sobject>{
    global final string query;
    global BatchMassUpdateofAccount(string q){
        query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global  void execute(Database.BatchableContext BC,List<Account> accs){
        List<Account> accsRecord = new List<Account>();
        for(Account acc : accs){
            String clientalert = '';
            Boolean hasValue = false;
            if(acc.Client_Alert__c != null && acc.Client_Alert__c !=''){
                clientalert = acc.Client_Alert__c ;
                hasValue = true;
            }
            if(acc.Client_Alert_1__c != null && acc.Client_Alert_1__c !=''){
                if(hasValue){
                    clientalert +=   '\n\n -------- ';
                    clientalert +='\n'+acc.Client_Alert_1__c;
                    
                }else{
                    clientalert =  acc.Client_Alert_1__c;
                }
                hasValue = true;
            }
            if(acc.Client_Alert_2__c != null && acc.Client_Alert_2__c !=''){
                if(hasValue){
                    clientalert +=   '\n\n -------- ';
                    clientalert +='\n'+acc.Client_Alert_2__c;
                }else{
                    clientalert =  acc.Client_Alert_2__c;
                }
            }
            acc.Client_Alert__c = clientalert;
            acc.Client_Alert_1__c = '';
            acc.Client_Alert_2__c = '';
            accsRecord.add(acc);
        }
        if(accsRecord.size()!=0){
            update accsRecord;
        }
        
    }
    global void finish(Database.BatchableContext BC){
    }
    
}
/*
 * //test with particular record id
 * String recId = '0013L00000AKAFvQAP';
String accQuery = 'SELECT id,Name,Client_Alert__c,Client_Alert_1__c,Client_Alert_2__c,OwnerId,Owner.Name,CreatedDate from Account where id =\''+recId+'\'';
BatchMassUpdateofAccount bdt = new BatchMassUpdateofAccount(accQuery);
dataBase.executeBatch(bdt);


//test with all accounts
String accQuery = 'SELECT id,Name,Client_Alert__c,Client_Alert_1__c,Client_Alert_2__c,OwnerId,Owner.Name,CreatedDate from Account';
BatchMassUpdateofAccount bdt = new BatchMassUpdateofAccount(accQuery);
dataBase.executeBatch(bdt);

*/