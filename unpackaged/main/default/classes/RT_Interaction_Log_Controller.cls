public class RT_Interaction_Log_Controller 
{
    public static void stamp_related_info(Task t)
    {
        
        //check if the user created a job record
        
        t.Postcode__c = '';
        t.Work_Type__c = NULL;
        t.Related_Type__c = '';

        if (t.whatId != NULL)    
        {
            t.Related_Type__c = t.whatId.getSObjectType().getDescribe().getName();
    
            switch on t.whatId.getSObjectType().getDescribe().getName()
            {
                when 'Account'
                {
                    t.Postcode__c = [SELECT BillingPostalCode FROM Account WHERE id = :t.whatId].BillingPostalCode;
                }
                when 'Site__c' 
                {
                    t.Postcode__c = [SELECT Site_PostalCode__c FROM Site__c WHERE id = :t.whatId].Site_PostalCode__c;
                }
                when 'Job__c'
                {
                    Job__c j = [
                        SELECT Site__r.Site_PostalCode__c, Job_Type__c, Job_Gross_Profit_Amount__c
                        FROM Job__c WHERE id = :t.whatId
                    ];
                    t.Postcode__c = j.Site__r.Site_PostalCode__c;
                    t.Work_Type__c = j.Job_Type__c;
                    t.NET_Job_Profit__c =  j.Job_Gross_Profit_Amount__c;
                    t.Job__c = t.whatID;
                }
                when 'WorkOrder'
                {
                    WorkOrder wo = [
                        SELECT Site__r.Site_PostalCode__c, WorkTypeId, Job__r.Job_Gross_Profit_Amount__c
                        FROM WorkOrder WHERE id = :t.whatId 
                    ];
                    t.Postcode__c = wo.Site__r.Site_PostalCode__c;
                    t.Work_Type__c = wo.WorkTypeId;
                    t.NET_Job_Profit__c =  wo.Job__r.Job_Gross_Profit_Amount__c;
                }
            }          
        }
    }
    
    /*
    public static void link_rt_to_pc(RTap__ResponseTap_Call__c rtc)
    {
        rtc.PC_Link_Run__c = TRUE;      
        try 
        {
            DateTime end_time = rtc.RTap__Call_DateTime__c + ((rtc.RTap__Duration__c+10) / 24 / 60 / 60);
            Task t = [
                SELECT id, ResponseTap_Call__c, CreatedById
                FROM Task
                WHERE CLI__c = :rtc.RTap__Customer_Number__c
                AND CreatedDate >= :rtc.RTap__Call_DateTime__c
                AND CreatedDate <= :end_time 
                AND ResponseTap_Call__c = NULL
                ORDER BY Name__c DESC NULLS LAST 
                LIMIT 1
            ];
            t.ResponseTap_Call__c = rtc.id;
            rtc.PC_Link_Result__c = t.id;    
            try {	
                Job__c job = [ 
                    SELECT id, Name 
                    FROM Job__c
                    WHERE CreatedDate >= :rtc.RTap__Call_DateTime__c
                    AND CreatedDate <= :end_time 
                    AND CreatedById = :rtc.CreatedById
                    ORDER BY CreatedDate DESC NULLS LAST 
                    LIMIT 1
                ];
                t.Job__c = job.id;
            } 
            catch (Exception e) { }
            update t;
        }
        catch (Exception e) 
        {
            rtc.PC_Link_Result__c = 'Failed';
        }
    }
    */
}