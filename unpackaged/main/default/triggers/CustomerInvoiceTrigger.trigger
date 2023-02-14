trigger CustomerInvoiceTrigger on Customer_Invoice__c (after update) {

    for(Customer_Invoice__c ci : Trigger.new ) {
        if(
            Trigger.oldMap.get(ci.ID).Sum_of_Payments__c != Trigger.newMap.get(ci.ID).Sum_of_Payments__c 
            &&
//            recordtypeMap.get(ci.recordTypeID).getName().containsIgnoreCase('Consolidated Invoice')
            Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosById().get(ci.recordtypeid).getname() == 'Consolidated Invoice'
        ) 
        {
          //  job_sum_payments_controller.job_sum_payments(Trigger.oldMap.get(ci.ID).Job__c);
        }
              
    }    
}