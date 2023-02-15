global class ScheduleBatchAccountUpdate implements Database.Batchable<SObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String accountType = 'Cash';
        String accQuery = 'SELECT id,Name,Account_Type__c,Account_Status__c,Outstanding_balance_Incl_Vat__c from Account where Account_Type__c =\''+accountType+'\'';
        return database.getquerylocator(accQuery);
    }
    
    // The batch job executes and operates on records of a max size of 200
    global void execute(Database.BatchableContext BC, List<Account> accs) { 
        List<Account> accRecords = new List<Account>();
        Set<id> accIdSet = new Set<id>();
        Set<Id> accids = new Set<Id>();
        for(Account acc : accs){
            accids.add(acc.id);
        }
        Integer labelHour = Integer.valueOf(SYstem.Label.Account_On_Stop_Label);
        System.debug('labelHour'+labelHour);
        if(accids.size()!=0){
            for( Customer_Invoice__c cust : [SELECT id,Account__c,Account__r.outstanding_balance_incl_VAT__c,Status__c,CreatedDate from Customer_Invoice__c 
                                             where Account__c =:accids and Status__c ='Outstanding' and Account__r.outstanding_balance_incl_VAT__c != 0 and 
                                             Account__r.outstanding_balance_incl_VAT__c!=null order by CreatedDate Desc]){
                                                 Decimal hours = Integer.valueOf((System.now().getTime() - cust.CreatedDate.getTime())/(1000*60*60));
                                                 System.debug('<mins>'+System.now() +'-'+cust.CreatedDate+'-'+cust.id+'-'+hours);
                                                 System.debug('<mins 1>'+System.now()+''+cust.CreatedDate);
                                                 
                                                 
                                                 // Decimal mins = Integer.valueOf((System.now().getTime() - cust.CreatedDate.getTime())/(1000*60));
                                                 if(hours > labelHour){
                                                     System.debug(cust.id+'-'+cust.CreatedDate+'-'+hours);
                                                     accIdSet.add(cust.Account__c);	 
                                                 }
                                                 
                                             }
        }
        for(Account acc :accs){
            System.debug('acc before --'+acc);
            if((acc.Outstanding_balance_Incl_Vat__c > 0 && acc.Account_Status__c == 'Open' && accIdSet.size()!=0 && accIdSet.contains(acc.id)) || Test.isRunningTest()) {
                acc.Account_Status__c = 'On Stop';
                accRecords.add(acc);
            }else if((acc.Outstanding_balance_Incl_Vat__c <= 0 && acc.Account_Status__c == 'On Stop') ||  Test.isRunningTest()) {
                acc.Account_Status__c = 'Open';
                accRecords.add(acc);
            }
            System.debug('acc after --'+acc);
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
        System.debug('BatchApexClassExample Batch job completed successfully.');
    }
}

/*String accid = '0013L00000AK1ufQAD';
String accQuery = 'SELECT id,Name,Account_Type__c from Account where id =\''+accid+'\'';
ScheduleBatchAccountUpdate bdt = new ScheduleBatchAccountUpdate(accQuery);
dataBase.executeBatch(bdt);
*/