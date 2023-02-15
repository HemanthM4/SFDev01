global class UpdateCustomerInvoices_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = System.Label.CIBatchCriteria;  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Customer_Invoice__c> invlist) {
        
        
            System.debug('Total invoice size==='+invlist.size());
            for(Customer_Invoice__c invrec : invlist){
                //invrec.Status__c = 'Ready to Send';
                // MR - changed outbound maessage trigger
                invrec.Exchequer_Export__c = 'Ready to Send';
            }  
          try{
              system.debug('updating the invoice');
              //system.debug('status'+invlist[0].Status__c);
              system.debug('status'+invlist[0].Exchequer_Export__c);
              update invlist;
          }catch(Exception e){system.debug('BatchFailure : '+e);}
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
}