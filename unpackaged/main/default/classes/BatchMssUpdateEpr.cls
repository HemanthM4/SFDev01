Global class BatchMssUpdateEpr Implements Database.batchable<sobject>{
    global final string query;
    global final date schDate;
    global BatchMssUpdateEpr(string q,Date scheduledDate){
        query=q;
        schDate =scheduledDate;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Engineer_Pay_Requisition__c> eprs){
        System.debug('eprs'+eprs);
        System.debug('eprs.szie'+eprs.size());
        List<EPRStatusandPayrollObj__c> mcs = [SELECT Payroll_Month__c,Status__c, id from EPRStatusandPayrollObj__c ];
        list<Engineer_Pay_Requisition__c> eprReocrds = new List<Engineer_Pay_Requisition__c>();
        if(eprs.size()!=0){
            Date payroll_date = Date.newInstance(2022,02,28);
            for(Engineer_Pay_Requisition__c epr:eprs){
                System.debug('epr'+epr.id);
                System.debug('epr old'+epr.Status__c);
                epr.Status__c = getStatus(epr.Status__c);
                epr.Has_Run_Batch_Status__c = true;
                epr.Payroll_Month__c = schDate;
                System.debug('epr new'+epr.Status__c);
                eprReocrds.add(epr);
            }
        }
        if(eprReocrds.size()!=0){
            Database.UpsertResult[] records =Database.upsert(eprReocrds,false);
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
                sendEmailCLass.sendEmail(finalstr,'EPR');
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :BC.getJobId()];        
        EprJobFailureBatchEmail__c mcs =[SELECT User_Email_Id__c, id from EprJobFailureBatchEmail__c];
        List<String> toAddress = new List<String>();
        if (mcs.User_Email_Id__c != null  &&  mcs.User_Email_Id__c != '') {
            if( mcs.User_Email_Id__c.contains(',')){
                toAddress = mcs.User_Email_id__c.split(',');
            }else{
                toAddress.add(mcs.User_Email_id__c);
            }
        }
        if(a.Status == 'Completed' && toAddress.size() !=0) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Send the email to the job submitter
            // String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddress);
            mail.setSenderDisplayName('EPR Creation Batch Success');
            mail.setSubject('  Status: ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                                  ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);
            
            // Add your attachment to the email.
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }else if( toAddress.size() !=0){
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Send the email to the job submitter
            // String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddress);
            mail.setSenderDisplayName('EPR Creation Batch '+a.Status);
            mail.setSubject('  Status: ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                                  ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);
            
            // Add your attachment to the email.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    public static string getStatus(String status){
        String statusnew  = '';
        if(status == 'New'){
            statusnew =  'Approved';
        }else if(status == 'FOC'){
            statusnew ='Approved';
        }else if(status == 'Approved'){
            statusnew ='Processed';
        }else if(status == 'Processed'){
            statusnew = 'Paid';
        }
        return statusnew;
    }
    
}

/*String keyStatus = 'New';
String accQuery = 'SELECT CreatedDate,Id,Name,Payroll_month__c,Scheduled_Date__c,Status__c FROM Engineer_Pay_Requisition__c WHERE  Scheduled_Date__c >= 2021-06-26 AND Scheduled_Date__c <= 2022-04-03 AND Service_Resource__r.IsActive = TRUE AND Status__c = \''+keyStatus+'\'';
BatchMssUpdateEpr bdt = new BatchMssUpdateEpr(accQuery);
dataBase.executeBatch(bdt);
*/