global class UpdateCustomerInvoicesBatch_Schedule implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        
        UpdateCustomerInvoices_Batch ci = new UpdateCustomerInvoices_Batch();
        Database.executeBatch(ci,50);
    }
    
}