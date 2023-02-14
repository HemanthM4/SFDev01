trigger SupplierInvoice on Supplier_Invoice__c (after insert) 
{
    for(Supplier_Invoice__c si : Trigger.new ) 
    {
        SupplierInvoice_GL_Controller.stampGL(Trigger.newMap.get(si.ID).id);
    }    
}