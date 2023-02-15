global class ScheduleBatchAccountToCheckbox implements Database.Batchable<SObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String accountType = 'credit';
        String accQuery = 'SELECT Comms_Control_Credit_Note__c,Comms_Control_Estimate_Emails__c,Comms_Control_Invoice_Job_complete__c,Comms_Control_In_transit_text__c,Comms_Control_Online_Booking__c,Comms_Control_Receipt_of_pay__c,Comms_Control_Refund_Confirmation__c,Comms_Control_Request_of_pay__c,id,Name from Account where Account_Type__c =\''+accountType+'\'';
        return database.getquerylocator(accQuery);
    }
    
    // The batch job executes and operates on records of a max size of 200
    global void execute(Database.BatchableContext BC, List<Account> accs) { 
        List<Account> accRecords = new List<Account>();
        
        
        for(Account acc :accs){
            acc.Comms_Control_Credit_Note__c = true;
            acc.Comms_Control_Estimate_Emails__c = true;
            acc.Comms_Control_Invoice_Job_complete__c = true;
            acc.Comms_Control_In_transit_text__c = true;
            acc.Comms_Control_Online_Booking__c = true;
            acc.Comms_Control_Receipt_of_pay__c = true;
            acc.Comms_Control_Refund_Confirmation__c = true;
            acc.Comms_Control_Request_of_pay__c = true;
            accRecords.add(acc);
        }
        if(accRecords.size()!=0 || Test.isRunningTest()){
            Database.UpsertResult[] records =Database.upsert(accRecords,false);
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
                    finalstr = finalstr +recordString;
                    hasError = true;
                }
            }
            if(hasError){
                sendEMail(finalstr,'Account');
            }
        }
    }
    public static void sendEMail(String finalstr,String sobj){
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= sobj +' Error.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'Hemanth.methukumalli@aspect.co.uk'};
            String subject ='Account CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Account CSV ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
    // Finish runs at the end
    global void finish(Database.BatchableContext BC) { 
        System.debug('ScheduleBatchAccountToCheckbox Batch job completed successfully.');
    }
}

/*
ScheduleBatchAccountToCheckbox bdt = new ScheduleBatchAccountToCheckbox();
dataBase.executeBatch(bdt);
*/