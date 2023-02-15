public class job_sum_payments_controller {


    public static void job_sum_payments(id job_id) {

        Decimal total_payments = 0;
        for ( Customer_Invoice__c ci:[
            SELECT Sum_of_Payments__c 
            FROM Customer_Invoice__c 
            WHERE Job__c = :job_id 
        ]) 
        {
            if(ci.Sum_of_Payments__c != NULL) 
            {
                total_payments += ci.Sum_of_Payments__c;
            }
        }
        Job__c job = [SELECT Payment_Value__c FROM Job__c WHERE id=:job_id ];
        job.Payment_Value__c = total_payments;
        update job;

    }

}