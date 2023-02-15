public class SupplierInvoice_GL_Controller {

    
    public static void stampGL(id si_id)
    {

        try {

            Supplier_Invoice__c si = [
                SELECT id,  Purchase_Order__r.Work_Order__c 
                FROM Supplier_Invoice__c
                WHERE id = :si_id
                LIMIT 1
            ];
            
            WorkOrder wo = [
                SELECT id, WorkType.Trade__c, Account.Account_Type__c, Account.Record_Type_Name__c, Record_Type_Name__c
                FROM WorkOrder
                WHERE id = :si.Purchase_Order__r.Work_Order__c
            ];

            General_Ledger_Code__c glc = [
                SELECT id, Exchequer_GL_Code__c
                FROM General_Ledger_Code__c
                WHERE Ledger_Type__c = 'Purchases'
                AND Job_Type__c = :wo.Record_Type_Name__c
                AND Payment_Type__c = :wo.Account.Account_Type__c
                AND Trade__c = :wo.WorkType.Trade__c
                AND Client_Type__c = :wo.Account.Record_Type_Name__c
            ];
            
            si.GL_Code__c = glc.id;
            si.Exchequer_General_Ledger_Code__c = glc.Exchequer_GL_Code__c;
            update si;
        } catch (Exception e) {
            
        }

    }
    
}