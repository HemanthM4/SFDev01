public class Phase_2_Estimate_Clone {
    @AuraEnabled
    public static String clone_job(id job_id) {

        Job__c in_job = [
            SELECT
            id,
            Earliest_Work_Order_by_Requested_Date__c,
            Site__c,
            Account__c,
            Status__c,
            Customer_Facing_Description__c,
            Authorisation__c,
            Job_Raised_by__c,
            Raised_by_Service_Resource__c,
            Contact_Email_who_Raised_Job__c,
            Type__c,
            Job_Type__c
            FROM Job__c
            WHERE id = :job_id
        ];
        Job__c out_job = in_job.clone(false,true,false, false);
        insert out_job;

        out_job.Status__c = 'New';
        out_job.Cloned_Job__c = true;
        update out_job;

        out_job.Earliest_Work_Order_by_Requested_Date__c =in_job.Earliest_Work_Order_by_Requested_Date__c;
        update out_job;

        List<Costs_and_Charges__c> in_ccts = [SELECT id,
            Record_Type__c,
            Cost_Collection_Fee__c,
            Cost_Lead_Fee__c,
            Cost_Other_Item__c,
            Cost_ULEZ__c,
            Call_Out_Fee__c,
            Charge_Collection_Fee__c,
            Charge_List_Price_Services__c,
            Charge_Other_Item__c,
            Charge_ULEZ__c,
            Chargeable_Duration_R1__c,
            Chargeable_Duration_R2__c,
            Chargeable_Duration_R3__c,
            Hourly_Charge_R1__c,
            Hourly_Charge_R2__c,
            Hourly_Charge_R3__c,
            Materials_Collection_Charge__c,
            Rate_of_Charge__c,
            Rate_of_Pay__c,
                   Charge_Total_PO_Product_Required__c ,  Charge_Total_Van_Stock_Product_Required__c ,Charge_Total_Scaffold_Product_Required__c                          
            FROM Costs_and_Charges__c
            WHERE Job__c = :in_job.id
        ];

        Map<id,Costs_and_Charges__c> map_ccts = new Map<id,Costs_and_Charges__c>();
        List<WorkOrder> in_wos = [
            SELECT
            id,
            Arrival_Window_End__c,
            Arrival_Window_Start__c,
            Subject,
            Preferred_Arrival_Window__c,
            RecordTypeId,
            Status,
            DurationType,
            CurrencyIsoCode,
            WorkTypeId,
            Confirmed_Work_Type__c,
            Site__c,
            ContactId,
            AccountId,
            Other_Charges_Description__c,
            Short_Summary_of_Further_Works_Required__c,
            Access_Details__c,
            Description,
            Arrival_Window_End_Date_Time__c,
            Arrival_Window_Start_Date_Time__c,
            Preferred_Date__c,
            Requested_Date__c,
            Address,
            Costs_and_Charges__c,
            Scope_of_Works_Amended_by_Operative__c,
            Scope_of_Works_2__c,
            Scope_of_Works_3__c
            FROM WorkOrder
            WHERE Job__c = :in_job.id
        ];
        Set<id> wo_ids = new Set<id>();
        Map<id,id> map_wos = new Map<id,id>();

        for (Costs_and_Charges__c in_cct:in_ccts) {
            Costs_and_Charges__c out_cct = in_cct.clone(false,true,false,false);
            out_cct.Job__c = out_job.id;
            insert out_cct;
            map_ccts.put(in_cct.id,out_cct);
        }

        for (WorkOrder in_wo:in_wos) {
            wo_ids.add(in_wo.id);
            WorkOrder out_wo = in_wo.clone(false,true,false,false);
            out_wo.Job__c = out_job.id;
            if(map_ccts.containskey(in_wo.Costs_and_Charges__c))
            out_wo.Costs_and_Charges__c = map_ccts.get(in_wo.Costs_and_Charges__c).id;
            out_wo.Status ='Pending';
            insert out_wo;
        //  out_wo.Service_Appointment_Status__c= '';
        //  update out_wo;
            map_wos.put(in_wo.id, out_wo.id);
        }

        List<ProductRequired> in_preqs = [
            SELECT id, ParentRecordId, Product2Id, QuantityRequired, Product_Cost__c,
            Product_Category__c,
            Full_Description__c,
            Supplier_Name__c,
            Supplier_Details__c,
            Charge__c,
            Override_Mark_ups__c
            FROM ProductRequired
            WHERE ParentRecordId IN :wo_ids
        ];

        for (ProductRequired in_preq:in_preqs) {
             String strId = '';
            ProductRequired out_preq = in_preq.clone(false,true,false,false);
             ID new_wo_id =null;
            if(map_wos.containsKey(in_preq.ParentRecordId))
             new_wo_id = map_wos.get(in_preq.ParentRecordId);
            if(new_wo_id!=null){
             strId = Id.valueOf(new_wo_id);
            out_preq.ParentRecordId = strId; //map_wos.get(in_preq.ParentRecordId);
            }
            insert out_preq;
        }
return out_job.id;
    }

    @InvocableMethod(label='Clone Job with 10% discount')
    public static void clone_job_with_10_percent_discount(List<Id> job_ids) {
        List<Job__c> in_jobs = [
            SELECT
                id,
                Earliest_Work_Order_by_Requested_Date__c,
                Site__c,
                Account__c,
                Status__c,
                Customer_Facing_Description__c,
                Authorisation__c,
                Job_Raised_by__c,
                Raised_by_Service_Resource__c,
                Contact_Email_who_Raised_Job__c,
                Type__c,
                Job_Type__c,
                Already_duplicated_Job_for_Pending_Est__c
            FROM Job__c
            WHERE id IN :job_ids
        ];

        List<Job__c> out_jobs = new List<Job__c>();
        for (Job__c in_job : in_jobs) {
            Job__c out_job = in_job.clone(false,true,false, false);
            out_job.Status__c = 'For Client Approval';
            out_job.Cloned_Job__c = true;
            out_job.Already_duplicated_Job_for_Pending_Est__c = true;
            out_job.Earliest_Work_Order_by_Requested_Date__c =in_job.Earliest_Work_Order_by_Requested_Date__c;
            out_job.Cloned_From_Job__c = in_job.Id;

            out_jobs.add(out_job);
        }
        insert out_jobs;

        List<Costs_and_Charges__c> in_ccts = [
            SELECT
                id,
                Record_Type__c,
                Cost_Collection_Fee__c,
                Cost_Lead_Fee__c,
                Cost_Other_Item__c,
                Cost_ULEZ__c,
                Call_Out_Fee__c,
                Job__c,
                Charge_Collection_Fee__c,
                Charge_List_Price_Services__c,
                Charge_Other_Item__c,
                Charge_ULEZ__c,
                Chargeable_Duration_R1__c,
                Chargeable_Duration_R2__c,
                Chargeable_Duration_R3__c,
                Hourly_Charge_R1__c,
                Hourly_Charge_R2__c,
                Hourly_Charge_R3__c,
                Materials_Collection_Charge__c,
                Rate_of_Charge__c,
                Rate_of_Pay__c,
                Discount_Manual_Percentage__c
            FROM Costs_and_Charges__c
            WHERE Job__c =: in_jobs
        ];

        Map<id,Costs_and_Charges__c> map_ccts = new Map<id,Costs_and_Charges__c>();
        List<WorkOrder> in_wos = [
            SELECT
                id,
                Arrival_Window_End__c,
                Arrival_Window_Start__c,
                Subject,
                Preferred_Arrival_Window__c,
                RecordTypeId,
                Status,
                DurationType,
                CurrencyIsoCode,
                WorkTypeId,
                Confirmed_Work_Type__c,
                Site__c,
                Job__c,
                ContactId,
                AccountId,
                Other_Charges_Description__c,
                Short_Summary_of_Further_Works_Required__c,
                Access_Details__c,
                Description,
                Arrival_Window_End_Date_Time__c,
                Arrival_Window_Start_Date_Time__c,
                Preferred_Date__c,
                Requested_Date__c,
                Address,
            	Country,
            	City,
            	State,
            	Street,
            	PostalCode,
                Costs_and_Charges__c,
                Scope_of_Works_Amended_by_Operative__c,
                Scope_of_Works_2__c,
                Scope_of_Works_3__c
            FROM WorkOrder
            WHERE Job__c =: in_jobs
        ];
        Set<id> wo_ids = new Set<id>();
        Map<id,id> map_wos = new Map<id,id>();

        List<Costs_and_Charges__c> ccts_for_insert = new List<Costs_and_Charges__c>();
        for (Costs_and_Charges__c in_cct:in_ccts) {
            for (Job__c out_job: out_jobs) {
                if (in_cct.Job__c == out_job.Cloned_From_Job__c) {
                    Costs_and_Charges__c out_cct = in_cct.clone(false,true,false,false);
                    out_cct.Job__c = out_job.id;
                    out_cct.Discount_Manual_Percentage__c = 10;
                    ccts_for_insert.add(out_cct);
                    map_ccts.put(in_cct.id,out_cct);
                }
            }
        }
        insert ccts_for_insert;

        List<WorkOrder> wo_for_insert = new List<WorkOrder>();
        for (WorkOrder in_wo:in_wos) {
            for (Job__c out_job: out_jobs) {
                if (in_wo.Job__c == out_job.Cloned_From_Job__c) {
                    wo_ids.add(in_wo.id);
                    WorkOrder out_wo = in_wo.clone(false,true,false,false);
                    out_wo.Job__c = out_job.id;
                    if(map_ccts.containskey(in_wo.Costs_and_Charges__c))
                    out_wo.Costs_and_Charges__c = map_ccts.get(in_wo.Costs_and_Charges__c).id;
                    out_wo.Status ='Pending';
                    out_wo.Country = in_wo.Country;
                    out_wo.State = in_wo.State;
                    out_wo.City = in_wo.City;
                    out_wo.Street = in_wo.Street;
                    out_wo.PostalCode = in_wo.PostalCode;
                    wo_for_insert.add(out_wo);
                }
            }
        }
        insert wo_for_insert;

        for (WorkOrder in_wo : in_wos) {
            for(WorkOrder out_wo : wo_for_insert) {
                if (in_wo.id == out_wo.getCloneSourceId()) {
                    map_wos.put(in_wo.id, out_wo.id);
                }
            }
        }

        List<ProductRequired> in_preqs = [
            SELECT
                id,
                ParentRecordId,
                Product2Id,
                QuantityRequired,
                Product_Cost__c,
                Product_Category__c,
                Full_Description__c,
                Supplier_Name__c,
                Supplier_Details__c,
                Charge__c,
                Override_Mark_ups__c
            FROM ProductRequired
            WHERE ParentRecordId IN :wo_ids
        ];

        List<ProductRequired> preq_for_insert = new List<ProductRequired>();
        for (ProductRequired in_preq : in_preqs) {
            String strId = '';
            ProductRequired out_preq = in_preq.clone(false,true,false,false);
            ID new_wo_id = null;
            if (map_wos.containsKey(in_preq.ParentRecordId))
                new_wo_id = map_wos.get(in_preq.ParentRecordId);
            if (new_wo_id != null) {
                strId = Id.valueOf(new_wo_id);
                out_preq.ParentRecordId = strId;
            }
            preq_for_insert.add(out_preq);
        }
        insert preq_for_insert;
    }
}