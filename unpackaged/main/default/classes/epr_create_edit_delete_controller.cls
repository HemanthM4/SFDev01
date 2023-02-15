public class epr_create_edit_delete_controller {

    public static void updateJob( id job_id, id wo_id )
    {
        Decimal job_total_pay = 0;
        Decimal wo_labour_pay = 0;
        Decimal wo_material_pay = 0;
        Decimal wo_other_pay = 0;
        Decimal wo_total_pay = 0;
        
        //
        // get all eprs on this job and total them
        //
        List<Engineer_Pay_Requisition__c> eprs = [
            SELECT Pay_Labour_Total__c, Pay_Materials__c, Pay_Fixed_Price__c, Pay_Total__c, Work_Order__c 
            FROM Engineer_Pay_Requisition__c 
            WHERE Job__c = :job_Id 
        ];
        for (Engineer_Pay_Requisition__c epr : eprs )
        {
            job_total_pay+=epr.Pay_Total__c;
            if (epr.Work_Order__c == wo_id )
            {
                if (epr.Pay_Labour_Total__c != NULL)
                {
                    wo_labour_pay += epr.Pay_Labour_Total__c;
                } 
                if (epr.Pay_Materials__c != NULL) 
                {
                    wo_material_pay += epr.Pay_Materials__c;
                } 
                if (epr.Pay_Fixed_Price__c != NULL)
                {
                    wo_other_pay += epr.Pay_Fixed_Price__c;
                } 
                if (epr.Pay_Total__c != NULL)
                {
                    wo_total_pay += epr.Pay_Total__c;
                }
            }
        }

        if (wo_id != NULL )
        {
            
            WorkOrder wo = [SELECT id FROM WorkOrder WHERE id=:wo_id LIMIT 1];
            wo.Requisition_Labour__c = wo_labour_pay;
            wo.Requisition_Materials__c = wo_material_pay;
            wo.Requisition_Other__c = wo_other_pay;
            wo.Requisition_Total__c = wo_total_pay;
            update wo;
        }
        Job__c job = [SELECT id FROM Job__c WHERE id = :job_id];
        job.Requisition_total_pay__c = job_total_pay;
        update job;
    }

    public static void markEPRsApproved(id job_id)
    {
        List<Engineer_Pay_Requisition__c> eprs = [
            SELECT id 
            FROM Engineer_Pay_Requisition__c
            WHERE Job__c = :job_id 
            AND Status__c = 'New'
        ];
        for(Engineer_Pay_Requisition__c epr:eprs)
        {
            epr.Status__c = 'Approved';
        }
        update eprs;
    }
    
}