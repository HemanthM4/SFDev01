/*
Author: Pradeep Kumar on 05/09/2022
Purpose: This is trigger for GSR_Submission__c object.

Modification Log: 

*/
trigger GSRSubmissionTrigger on GSR_Submission__c (After update) {
	
    GSRSubmissionTriggerHandler obj = new GSRSubmissionTriggerHandler();
    ID networkId = Network.getNetworkId();
    
    if(Trigger.IsAfter && Trigger.Isupdate){
        for(GSR_Submission__c rec: trigger.new){
            if(rec.Completed_Date_Time__c != NULL && rec.Report_Received_By_Type__c != NULL 
               && rec.Generate_GSR_Submission_Report__c == FALSE){
                obj.generatePDFForGSRSubmission(rec, networkId);
            }
        }
    }
}