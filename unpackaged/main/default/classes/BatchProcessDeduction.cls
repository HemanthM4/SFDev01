Global class BatchProcessDeduction Implements Database.batchable<sobject>{
    global final string query;
    global final date payrollDate;
    global BatchProcessDeduction(string payrollQuery,Date payrollDate){
        query = payrollQuery;
        payrollDate = payrollDate;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Deduction__c> procesDed){
        System.debug('eprs'+procesDed);
        System.debug('eprs.szie'+procesDed.size());
        list<Deduction__c> procesDeds = new List<Deduction__c>();
        if(procesDed.size()!=0){
            for(Deduction__c pd:procesDed){
                pd.Status__c = 'Paid'; 
                pd.Payroll_Month__c = payrollDate; 
                procesDeds.add(pd);
            }
        }
        if(procesDeds.size()!=0){
            Database.UpsertResult[] records =Database.upsert(procesDeds,false);
            string header = ' Details  \n';
            string finalstr = header ;
            Boolean hasError = false;
            for(Integer i = 0 ; i<records.size();i++){
                Database.UpsertResult record =records.get(i);
                Map<String,Object> recordMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(record));
                Boolean isSUccess = record.isSuccess();
                if(!isSUccess){
                    String recordDetails = JSON.serialize(recordMap);
                    string recordString = recordDetails +'\n';
                    System.debug('recordDetails'+recordDetails);
                    finalstr = finalstr +recordString;
                    hasError = true;
                }
            }
            if(hasError){
                sendEmailCLass.sendEmail(finalstr,'Process deduction');
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
    
}

/*String keyStatus = 'New';
String accQuery = 'SELECT CreatedDate,Id,Name,Payroll_month__c,Scheduled_Date__c,Status__c FROM Engineer_Pay_Requisition__c WHERE  Scheduled_Date__c >= 2021-06-26 AND Scheduled_Date__c <= 2022-04-03 AND Service_Resource__r.IsActive = TRUE AND Status__c = \''+keyStatus+'\'';
BatchMssUpdateEpr bdt = new BatchMssUpdateEpr(accQuery);
dataBase.executeBatch(bdt);
*/