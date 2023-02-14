/*
Modification Log: 
1) 16/08/2022 - By Pradeep Kumar for removal of job_InvoiceGenerationController for Rate and Rate Card restructure

*/
trigger JobTrigger on Job__c (before update, after insert) {
    
    JobTriggerHandler obj = new JobTriggerHandler();
    if (Trigger.isBefore && Trigger.isUpdate && !TriggerStopper.stopJobTrigger) {
        obj.beforeUpdateMethod(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isInsert && !TriggerStopper.stopJobTrigger) {
        obj.afterInsertMethod(Trigger.new);
    }
}