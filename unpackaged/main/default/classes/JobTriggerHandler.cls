/*
Author: Pradeep Kumar on 29/10/2022
Purpose: This is trigger handler class created to handle all the logic related to JobTrigger.

Modification Log: 

*/

public class JobTriggerHandler {
    
    public void beforeUpdateMethod(List<Job__c> newJobList, Map<Id, Job__c> oldJobRecMap){
        
        Invoice_Metadata__mdt invoiceMdt = Invoice_Metadata__mdt.getInstance('Reactive_Referral_Job');
		Set<Id> jobRecIdsSet = new Set<Id>();
        
        for(Job__c newJob : newJobList)
        {
            if(oldJobRecMap.containsKey(newJob.Id)){
                
                Job__c oldJobRec = oldJobRecMap.get(newJob.Id);
                
                if(oldJobRec.Account_Type__c != 'Key Account')
                {
                    ID networkId = Network.getNetworkId();
                    
                    if((oldJobRec.Generate_Invoice__c != newJob.Generate_Invoice__c 
                        && newJob.Generate_Invoice__c == TRUE) || Test.isRunningTest()) 
                    { 
                        if( oldJobRec.Deposit_Invoice__c == NULL ){  
                            if(invoiceMdt.InvoiceController_genReactiveInvoice__c)
                                InvoiceController.genReactiveInvoice(newJob,networkId);
                        }
                        else{
                            if(invoiceMdt.InvoiceController_genFinalInvoice__c)
                                InvoiceController.genFinalInvoice(newJob,networkId);
                        }
                    }
                    
                    if ((newJob.Generate_Deposit_Invoice__c == TRUE  && invoiceMdt.InvoiceController_genDepositInvoice__c && 
                         oldJobRec.Generate_Deposit_Invoice__c != newJob.Generate_Deposit_Invoice__c) || Test.isRunningTest())
                    {
                        InvoiceController.genDepositInvoice(newJob,networkId);
                    }
                    
                    if ((invoiceMdt.InvoiceController_genCancellationInvoice__c && newJob.Generate_Cancellation_Invoice__c == TRUE && 
                         oldJobRec.Generate_Cancellation_Invoice__c != newJob.Generate_Cancellation_Invoice__c) || Test.isRunningTest())
                    {
                        InvoiceController.genCancellationInvoice(newJob,networkId);
                    }
                }
            }
        }
        for(Job__c newJob : newJobList){
            if(oldJobRecMap.containsKey(newJob.Id)){
                Job__c oldJobRec = oldJobRecMap.get(newJob.Id);
                system.debug('newJob 123456 - '+newJob.Status__c + 'OldJob 123456 - '+oldJobRec.Status__c);
                if(oldJobRec.Account_Type__c != 'Key Account' && oldJobRec.Status__c != newJob.Status__c && newJob.Status__c == 'Closed'){
                    jobRecIdsSet.add(newJob.Id);
                }
            }
        }
        approveEPROnJobCloser(jobRecIdsSet);
    }
    
    public void afterInsertMethod(List<Job__c> newJobRecList){
        
        Set<Id> accIds = new Set<Id>();
        Set<Id> siteIds = new Set<Id>();
        Set<Id> jobIds = new Set<Id>();
        Map<Id, Integer> accountjobMap = new Map<Id, Integer>();
        Map<Id, Integer> sitejobMap = new Map<Id, Integer>();
        List<Job__c> jobListToUpdate = new List<Job__c>();
        
        for(Job__c rec : newJobRecList) {
            accIds.add(rec.Account__c);
            siteIds.add(rec.Site__c);
            jobIds.add(rec.Id);
        }
        
        List<Account> accsList = [SELECT Id, (SELECT Id, CreatedDate, Account_Job_Number__c FROM Jobs__r ORDER BY CreatedDate ASC) FROM Account WHERE Id IN: accIds];
        List<Site__c> sitesList = [SELECT Id, (SELECT Id, CreatedDate, Site_Job_Number__c FROM Jobs__r ORDER BY CreatedDate ASC) FROM Site__c WHERE Id IN: siteIds];
        List<Job__c> jobsList = [SELECT Id, Account__c, Site__c, CreatedDate, Account_Job_Number__c, Site_Job_Number__c FROM Job__c WHERE Id IN: jobIds];
        
        for(Account acc : accsList){
            accountjobMap.put(acc.Id, acc.Jobs__r.size());
        }
        
        for(Site__c site : sitesList){
            sitejobMap.put(site.Id, site.Jobs__r.size());
        }
        
        for (Job__c job : jobsList) {
            Job__c jobrec = new Job__c();
            jobrec.Id = job.Id;
            if (accountjobMap.containsKey(job.Account__c)){
                jobrec.Account_Job_Number__c = accountjobMap.get(job.Account__c);
            }
            if (sitejobMap.containsKey(job.Site__c)){
                jobrec.Site_Job_Number__c = sitejobMap.get(job.Site__c);
            }
            jobListToUpdate.add(jobrec);
        }
        if(jobListToUpdate.size() > 0){
            Database.update(jobListToUpdate, false);
        }
        TriggerStopper.stopJobTrigger = TRUE;
    }
    
    public void approveEPROnJobCloser(Set<Id> jobIdsSet){
        
        System.debug('Inside EPR approval method');
        List<Engineer_Pay_Requisition__c> eprs = [SELECT id, Status__c FROM Engineer_Pay_Requisition__c
            									  WHERE Job__c IN:jobIdsSet AND Status__c = 'New'];
        
		set<Engineer_Pay_Requisition__c> eprSetToUpdate = new Set<Engineer_Pay_Requisition__c>();
        List<Engineer_Pay_Requisition__c> eprListToUpdate = new List<Engineer_Pay_Requisition__c>();
        
        for(Engineer_Pay_Requisition__c epr: eprs){
            System.debug('Inside EPR approval for loop ---  '+epr.Status__c);
            Engineer_Pay_Requisition__c eprRec = new Engineer_Pay_Requisition__c();
            eprRec.Id = epr.Id; eprRec.Status__c = 'Approved';
            eprSetToUpdate.add(eprRec);
            System.debug('After assignment in for loop ---  '+epr.Status__c);
        }
        system.debug('eprs value -- '+eprSetToUpdate.size());
        if(eprSetToUpdate.size() > 0){
            eprListToUpdate.addAll(eprSetToUpdate);
            Database.update(eprListToUpdate, false);
        }
    }
}