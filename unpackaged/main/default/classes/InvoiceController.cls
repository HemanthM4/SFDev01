public class InvoiceController {
    
    private static List <Costs_and_Charges__c> ccts {get;set;}
    
    private static Job__c getJob(id jid){
        return [ 
            SELECT Account__c, Status__c, Authorisation__c, Job_Raised_by__c, Job_Type__r.Trade__c, 
            Charge_Net__c, Deposit_Invoice__r.Charge_Net__c,Raised_by_Service_Resource__c,
            Raised_by_Service_Resource__r.Email__c,Requisition_Total_Pay__c, Combined_Scope_of_Works_for_All_WOs__c,
            Account__r.DRC_Applies__c, Account__r.Invoicing_Email_Address__c,Attendance_Report_for_Customer__c,
            Customer_Facing_Description__c,Account__r.Account_Type__c, Account__r.RecordTypeID, Account__r.RecordType.name
            FROM Job__c WHERE id = :jid 
        ];
    }
    
    private static List<WorkOrder> getWOs(Job__c j){
        return [ 
            SELECT id, WorkOrderNumber, Record_Type_Name__c,
            Confirmed_Work_Type__r.Trade__c, WorkType.Trade__c,
            Costs_and_Charges__r.Charge_List_Price_Services__c, 
            Costs_and_Charges__r.Charge_Materials__c,
            Costs_and_Charges__r.Charge_Collection_Fee__c,
            Costs_and_Charges__r.Charge_Other_Item__c,
            Costs_and_Charges__r.Call_out_fee__c,
            Costs_and_Charges__r.Charge_ULEZ__c, 
            Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c,
            Costs_and_Charges__r.Discount_Value__c,
            Costs_and_Charges__r.Materials_Expense_wout_receipt_no_markup__c,
            Costs_and_Charges__r.Charge_labour__c,
            Costs_and_Charges__r.Chargeable_Duration_R1__c, 
            Costs_and_Charges__r.Chargeable_Duration_R2__c, 
            Costs_and_Charges__r.Chargeable_Duration_R3__c,
            Costs_and_Charges__r.Hourly_Charge_R1__c,
            Costs_and_Charges__r.Hourly_Charge_R2__c,
            Costs_and_Charges__r.Hourly_Charge_R3__c,
            Costs_and_Charges__r.Discount_Manual_Percentage__c,
            Costs_and_Charges__r.Discount_PL__c,
            Costs_and_Charges__r.Discount_Code__c
            FROM WorkOrder 
            WHERE Job__c = :j.ID
            AND Costs_and_Charges__r.Include_in_estimate__c = TRUE 
        ];
    }
    
    private static List<ServiceAppointment> getSAs(Job__c j){
        return [
            SELECT id, ParentRecordId, Work_Order__r.WorkOrderNumber,
            Status, Cancellation_Fine__c, Cancellation_Invoice_Raised__c 
            FROM ServiceAppointment WHERE ParentRecordId IN (
                SELECT id FROM WorkOrder WHERE Job__c = :j.id 
            ) AND Status = 'Cancelled'
            AND Cancellation_Fine__c = TRUE
            AND Cancellation_Invoice_Raised__c = FALSE ];
    }
    
    public static List<Id> getGLC(String job, String payment, String trade, String client ){
        List<Id> ids = new List<Id>();
        try {
            General_Ledger_Code__c glc = [
                SELECT id , Exchequer_GL_Code__c
                FROM General_Ledger_Code__c 
                WHERE Ledger_Type__c = 'Sales'
                AND Job_Type__c = :job
                AND Payment_Type__c = :payment
                AND Trade__c = :trade
                AND Client_Type__c = :client
                LIMIT 1
            ];
            ids.add(glc.id);
            ids.add(glc.Exchequer_GL_Code__c);
        } catch (QueryException e) {
            System.debug('\n\n\n-----------------------------\n\n');
            System.debug('no gl code found');
            System.debug('\n\n\n-----------------------------\n\n');
            ids.add(NULL);
            ids.add(NULL);
        }
        return ids;
    }
    
    public static Customer_Invoice__c createInvoice(Job__c j, List<Id> ids, String record_type){
        return new Customer_Invoice__c(
            Job__c = j.Id,
            Account__c = j.Account__c,
            Date__c = DATE.today(),
            Account_Email_Address__c = j.Account__r.Invoicing_Email_Address__c,
            Authorisation__c = j.Authorisation__c,
            Sum_of_Payments__c = 0,
            Job_Contact__c = j.Job_Raised_by__c,
            Job_Description__c = j.Combined_Scope_of_Works_for_All_WOs__c,
            RecordTypeID = Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosByName().get(record_type).getRecordTypeId(),
            GL_Code__c = ids[0],
            Exchequer_General_Ledger_Code__c = ids[1],
            DRC_Invoice__c = j.Account__r.DRC_Applies__c
        );
    }
    
    private static Customer_Invoice_Line_Item__c invoiceLine(id inv_id, id wo_id, Decimal charge_net, String vat, String category ){
        return new Customer_Invoice_Line_Item__c(
            Customer_Invoice__c = inv_id,
            Charge_Category__c = category,
            Charge_Net__c = charge_net,
            Work_Order__c = wo_id,
            VAT_Rate__c = vat
        );
    }
    
    private static void invoiceLineText(List<String> l, String description, String wo, Decimal unit_charge, Decimal quantity, Boolean drc){
        l[0] += description+' ' +wo+ '<br/>';
        l[1] += unit_charge + '<br/>';
        l[2] += quantity+'<br/>';
        l[3] += (unit_charge * quantity).setScale(2) + '<br/>';
        if(drc) {
            l[4] += '20% (DRC applies)<br/>';
            l[5] += (unit_charge).setscale(2) + '<br/>';
        }else {
            l[4] += (unit_charge * 0.2).setscale(2) +'<br/>';
            l[5] += (unit_charge * 1.2).setscale(2) +'<br/>';
        }                
    }
    
    private static void linkPayment(Job__c j, Customer_Invoice__c inv){
        try
        {
            asp04__Payment__c p = [
                SELECT id, asp04__Amount__c, Customer_Invoice__c, CreatedDate 
                FROM asp04__Payment__c 
                WHERE Customer__c = :j.Account__c AND Customer_Invoice__c = NULL 
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];
            p.Customer_Invoice__c = inv.id;
            update p;
        }
        catch (Exception e) {
            System.debug('\n\n\n-----------------------------\n\n');
            System.debug('no payment found');
            System.debug('\n\n\n-----------------------------\n\n');
        }
    }
    
    private static void updateInvoiceText( Customer_Invoice__c inv, List<List<String>> line_text ){
        
        inv.T4A__c = line_text[0][0]; 
        inv.T4B__c = line_text[0][1]; 
        inv.T4C__c = line_text[0][2];
        inv.T4D__c = line_text[0][3];
        inv.T4E__c = line_text[0][4]; 
        inv.T4F__c = line_text[0][5]; 
        
        inv.T5A__c = line_text[1][0]; 
        inv.T5B__c = line_text[1][1]; 
        inv.T5C__c = line_text[1][2];
        inv.T5D__c = line_text[1][3];
        inv.T5E__c = line_text[1][4]; 
        inv.T5F__c = line_text[1][5]; 
        
        inv.T6A__c = line_text[2][0]; 
        inv.T6B__c = line_text[2][1]; 
        inv.T6C__c = line_text[2][2];
        inv.T6D__c = line_text[2][3];
        inv.T6E__c = line_text[2][4]; 
        inv.T6F__c = line_text[2][5]; 
        
        inv.T7A__c = line_text[3][0]; 
        inv.T7B__c = line_text[3][1]; 
        inv.T7C__c = line_text[3][2];
        inv.T7D__c = line_text[3][3];
        inv.T7E__c = line_text[3][4]; 
        inv.T7F__c = line_text[3][5]; 
        
    }
    
    private static List<List<String>> init_line_container(){
        List<List<String>> line_text = new List<List<String>>();
        for(Integer i=4; i>0; i--){
            line_text.add(new List<String>{'', '', '', '', '', ''});
        }
        return line_text;
    }    
    
    /* 
Main method to generate cancelation invoice    
*/
    public static void genCancellationInvoice(Job__c job_in, id var_netID) {
        
        Job__c j = InvoiceController.getJob(job_in.Id); 
        List<Id> ids = InvoiceController.getGLC('Reactive',j.Account__r.Account_Type__c,j.Job_Type__r.Trade__c,j.Account__r.RecordType.name);    
        Customer_Invoice__c inv = InvoiceController.createInvoice(j,ids,'Cancellation Invoice');     
        List<ServiceAppointment> sas = InvoiceController.getSAs(j);
        insert inv;
        String vat = '20';
        Integer template = 3;
        List<List<String>> line_text = InvoiceController.init_line_container();
        if(j.Account__r.DRC_Applies__c) { 
            vat = '0';
            template = 8;
        }        
        
        for ( ServiceAppointment sa: sas ){                    
            insert InvoiceController.invoiceLine(inv.id, sa.ParentRecordId, 50, vat, 'Cancellation Fee' ); 
            InvoiceController.invoiceLineText(
                line_text[0],
                'Cancellation Fee(' + sa.Work_Order__r.WorkOrderNumber+')','', 50, 1, FALSE
            );
            sa.Cancellation_Invoice_Raised__c = TRUE;
        }
        
        InvoiceController.updateInvoiceText(inv,line_text);
        update sas;
        update inv;
        if(!test.isRunningTest()){
            Invoice_to_PDF.genPDF(inv.id, template, var_netID);
        }
    }
    
    /* 
Main method to generate Deposit invoice    
*/
    public static void genDepositInvoice(Job__c job_in, id var_netID ) {
        
        Job__c j = InvoiceController.getJob(job_in.Id); 
        List<Id> ids = InvoiceController.getGLC('Fixed Price',j.Account__r.Account_Type__c,j.Job_Type__r.Trade__c,j.Account__r.RecordType.name);
        Customer_Invoice__c inv = InvoiceController.createInvoice(j,ids,'Deposit');
        insert inv;
        
        // link input job job to the deposit invoice (method called from beforeupdate)
        job_in.Deposit_Invoice__c = inv.id;
        
        String vat = '20';
        Integer template = 1;
        if (j.Account__r.DRC_Applies__c){ 
            template=6; 
            vat = '0'; 
        }
        
        List<Customer_Invoice_Line_Item__c> line_items = new List<Customer_Invoice_Line_Item__c>();
        
        for ( WorkOrder wo : InvoiceController.getWOs(j) )
        {            
            if (wo.Costs_and_Charges__r.Charge_labour__c > 0) {       
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_labour__c)*.5, vat, 'Labour' ));              
            }
            
            if (wo.Costs_and_Charges__r.Charge_List_Price_Services__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_List_Price_Services__c)*.5, vat, 'List Price Service' ));
            }
            
            if ( wo.Costs_and_Charges__r.Discount_Value__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, -(wo.Costs_and_Charges__r.Discount_Value__c)*.5, vat, 'Discount' ));         
            }
            
            if (wo.Costs_and_Charges__r.Charge_Materials__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Materials__c)*.5, vat, 'Materials' ));        
            }
            
            if (wo.Costs_and_Charges__r.Charge_Other_Item__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Other_Item__c)*.5, vat, 'Other' ));              
            }
            
            if (wo.Costs_and_Charges__r.Call_out_fee__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Call_out_fee__c)*.5, vat, 'Other' ));              
            }
            
            if (wo.Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c)*.5, vat, 'Fixed Price Admin Fee' ));                
            }
            
            if (wo.Costs_and_Charges__r.Charge_ULEZ__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_ULEZ__c)*.5, vat, 'Other' ));              
            }      
            
            if (wo.Costs_and_Charges__r.Charge_Collection_Fee__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Collection_Fee__c)*.5, vat, 'Collection' ));              
            }     
        }
        if( !line_items.isEmpty() ) { insert line_items; }
        
        // if deposit invoice AND cash customer, try to find an unlinked payment of the same value
        if ( j.Account__r.Account_Type__c == 'Cash')
        {
            InvoiceController.linkPayment(j,inv);
        }
        
        //generate pdf
        if(!test.isRunningTest()){
            Invoice_to_PDF.genPDF(inv.id,template,var_netID);
        }
    }
    
    /* 
Main method to generate final fixed price invoice    
*/
    public static void genFinalInvoice(Job__c job_in, id var_netID ) {
        
        Job__c j = InvoiceController.getJob(job_in.Id); 
        List<Id> ids = InvoiceController.getGLC('Fixed Price',j.Account__r.Account_Type__c,j.Job_Type__r.Trade__c,j.Account__r.RecordType.name);    
        //Update Customer_Invoice__c RecordType form Invoice to either Final or Reactive --@Bharat
        // Customer_Invoice__c inv = InvoiceController.createInvoice(j,ids,'Invoice');     
        Customer_Invoice__c inv = InvoiceController.createInvoice(j,ids,'Final'); 
        insert inv;
        String vat = '20';
        Integer template = 2;
        if(j.Account__r.DRC_Applies__c) { 
            vat = '0'; 
            template = 7;
        }
        
        //One pence difference fix for fixed price final invoice, adding 1pence if found
        if((j.Deposit_Invoice__r.Charge_Net__c - (j.Charge_Net__c - j.Deposit_Invoice__r.Charge_Net__c) ) == 0.01){
            insert InvoiceController.invoiceLine(inv.id, NULL, (j.Charge_Net__c - j.Deposit_Invoice__r.Charge_Net__c)+0.0050, vat, 'Other' );
        }else{
            insert InvoiceController.invoiceLine(inv.id, NULL, (j.Charge_Net__c - j.Deposit_Invoice__r.Charge_Net__c), vat, 'Other' ); 
        }           
        if(!test.isRunningTest()){
            Invoice_to_PDF.genPDF(inv.id,template,var_netID);
        }
    }
    
    /* 
Main method to generate Reactive invoice    
*/
    public static void genReactiveInvoice(Job__c job_in, id var_netID ) {
        System.debug('>>genReactiveInvoice301');
        Decimal var_epr_total = 0;
        
        Job__c j = InvoiceController.getJob(job_in.Id); 
        List<Id> ids = InvoiceController.getGLC('Reactive',j.Account__r.Account_Type__c,j.Job_Type__r.Trade__c,j.Account__r.RecordType.name);    
        //Update Customer_Invoice__c RecordType form Invoice to either Final or Reactive --@Bharat
        //Customer_Invoice__c inv = InvoiceController.createInvoice(j,ids,'Invoice');
        Customer_Invoice__c inv = InvoiceController.createInvoice(j,ids,'Reactive');     
        insert inv;
        String vat = '20';
        Integer template = 0;
        if(j.Account__r.DRC_Applies__c) { 
            vat = '0';
            template = 5;
        }  
        
        List<Customer_Invoice_Line_Item__c> line_items = new List<Customer_Invoice_Line_Item__c>();
        List<Engineer_Pay_Requisition__c> eprs = new List<Engineer_Pay_Requisition__c>();
        
        List<List<String>> line_text = InvoiceController.init_line_container();
        
        for ( WorkOrder wo : InvoiceController.getWOs(j) ){        
            
            Integer buyapowaValue = 0;
            if (wo.Costs_and_Charges__r.Charge_labour__c > 0) {       
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_labour__c), vat, 'Labour' ));
                string trade_text = wo.Confirmed_Work_Type__r.Trade__c;
                if ( trade_text == NULL ) { trade_text = wo.WorkType.Trade__c; }
                if (wo.Costs_and_Charges__r.Chargeable_Duration_R1__c > 0 ) {
                    InvoiceController.invoiceLineText(
                        line_text[0], trade_text + ' (R1) ',wo.WorkOrderNumber, 
                        wo.Costs_and_Charges__r.Hourly_Charge_R1__c, wo.Costs_and_Charges__r.Chargeable_Duration_R1__c, 
                        j.Account__r.DRC_Applies__c
                    );
                }
                if (wo.Costs_and_Charges__r.Chargeable_Duration_R2__c > 0 ) {
                    InvoiceController.invoiceLineText(
                        line_text[0],
                        trade_text + ' (R2) ',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Hourly_Charge_R2__c , wo.Costs_and_Charges__r.Chargeable_Duration_R2__c, j.Account__r.DRC_Applies__c
                    );
                }
                if (wo.Costs_and_Charges__r.Chargeable_Duration_R3__c != 0 && wo.Costs_and_Charges__r.Chargeable_Duration_R3__c != NULL ) {
                    InvoiceController.invoiceLineText(
                        line_text[0],
                        trade_text + ' (R3) ',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Hourly_Charge_R3__c, wo.Costs_and_Charges__r.Chargeable_Duration_R3__c, j.Account__r.DRC_Applies__c
                    );
                }
            }
            
            if (wo.Costs_and_Charges__r.Charge_List_Price_Services__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_List_Price_Services__c), vat, 'List Price Service' ));
                InvoiceController.invoiceLineText(
                    line_text[0],
                    'List Price Service',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Charge_List_Price_Services__c,1, j.Account__r.DRC_Applies__c
                );
            }
            
            ////////********//////////@Bharat - Modified as asked by Luiza and directed by Matt for Buyapowa discount addition
            if ( wo.Costs_and_Charges__r.Discount_PL__c == 'Buyapowa referal' ) {
                buyapowaValue = 25;
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, -(buyapowaValue), vat, 'Discount' ));
                InvoiceController.invoiceLineText(
                    line_text[2],
                    'Referral Promo Code (' + wo.Costs_and_Charges__r.Discount_Code__c  + ') ',wo.WorkOrderNumber, -buyapowaValue,1, j.Account__r.DRC_Applies__c
                );
            }
            
            if ( wo.Costs_and_Charges__r.Discount_Manual_Percentage__c > 0 ) {
                
                Decimal netValue = (wo.Costs_and_Charges__r.Charge_labour__c + wo.Costs_and_Charges__r.Charge_List_Price_Services__c - buyapowaValue  ) * wo.Costs_and_Charges__r.Discount_Manual_Percentage__c/100;
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, -(netValue), vat, 'Discount' ));
                InvoiceController.invoiceLineText(
                    line_text[2],
                    'Discount Labour (' + wo.Costs_and_Charges__r.Discount_Manual_Percentage__c + '%) ',wo.WorkOrderNumber, -netValue,1, j.Account__r.DRC_Applies__c
                );
            }
            ////////*******///////////@Bharat
            
            if (wo.Costs_and_Charges__r.Charge_Materials__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Materials__c), vat, 'Materials' ));
                InvoiceController.invoiceLineText(
                    line_text[1],
                    'Parts and Materials',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Charge_Materials__c, 1,j.Account__r.DRC_Applies__c
                );
            }
            
            if (wo.Costs_and_Charges__r.Charge_Other_Item__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Other_Item__c), vat, 'Other' )); 
                InvoiceController.invoiceLineText(
                    line_text[2],
                    'Other Charge',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Charge_Other_Item__c, 1, j.Account__r.DRC_Applies__c
                );
            }
            
            if (wo.Costs_and_Charges__r.Call_out_fee__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Call_out_fee__c), vat, 'Other' )); 
                InvoiceController.invoiceLineText(
                    line_text[3],
                    'Call Out Fee',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Call_out_fee__c, 1, j.Account__r.DRC_Applies__c
                );
            }
            
            if (wo.Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c), vat, 'Fixed Price Admin Fee' ));
                InvoiceController.invoiceLineText(
                    line_text[3], 'Fixed Price Admin Fee',wo.WorkOrderNumber, 
                    wo.Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c,1, j.Account__r.DRC_Applies__c
                );               
            }
            
            if (wo.Costs_and_Charges__r.Charge_ULEZ__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_ULEZ__c), vat, 'Other' ));  
                InvoiceController.invoiceLineText(
                    line_text[3],
                    'ULEZ Fee',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Charge_ULEZ__c, 1, j.Account__r.DRC_Applies__c
                );  
            }      
            
            if (wo.Costs_and_Charges__r.Charge_Collection_Fee__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Collection_Fee__c), vat, 'Collection' ));
                InvoiceController.invoiceLineText(
                    line_text[3],
                    'Materials Collection',wo.WorkOrderNumber, wo.Costs_and_Charges__r.Charge_Collection_Fee__c, 1,  j.Account__r.DRC_Applies__c
                ); 
            }
            
            try
            {
                ServiceAppointment var_sa = [
                    SELECT id, Allocated_Engineer__c, Pay_Percentage__c, Allocated_Engineer__r.Rate_of_Pay_Tier__c,Allocated_Engineer__r.Email__c
                    FROM ServiceAppointment 
                    WHERE ParentRecordId = :wo.id 
                    LIMIT 1
                ];
                system.debug('rateOFPayPradeep -- '+var_sa.Pay_Percentage__c);
                //Check for referal job - for Reactive flow requirement - added by @Bharat
                try{
                    if(j.Raised_by_Service_Resource__c != null && j.Raised_by_Service_Resource__c != var_sa.Allocated_Engineer__c){
                        System.debug('Inside of referal job - Engineer Pay Requisition');
                        Engineer_Pay_Requisition__c engPayReq = new Engineer_Pay_Requisition__c();
                        engPayReq.Auto_Generated__c = TRUE;
                        engPayReq.Customer_Invoice__c = inv.id;
                        engPayReq.Service_Resource__c = j.Raised_by_Service_Resource__c;
                        engPayReq.Service_Resource_Email__c = j.Raised_by_Service_Resource__r.Email__c;
                        engPayReq.Job__c = j.Id;
                        engPayReq.Work_Order__c = wo.id;
                        engPayReq.Status__c = 'New';
                        engPayReq.Pay_Fixed_Price__c = 10;
                        insert engPayReq;
                    }
                }catch(Exception ex){
                    System.debug('Exception while creating referal EPR : '+ex.getMessage());
                }
                system.debug('459- test invoice controller');
                Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
                epr.Auto_Generated__c = TRUE;
                epr.Customer_Invoice__c = inv.id;
                epr.Service_Resource__c = var_sa.Allocated_Engineer__c;
                epr.Service_Resource_Email__c = var_sa.Allocated_Engineer__r.Email__c;
                epr.Job__c = j.Id;
                epr.Work_Order__c = wo.id;
                epr.Status__c = 'New';
                if(var_sa.Pay_Percentage__c != null){  //// Null check added by @bharat while Zia and Pradeep were testing 
                    epr.Rate_of_Pay__c = var_sa.Pay_Percentage__c*100;
                }
                epr.Chargeable_Units_R1__c = wo.Costs_and_Charges__r.Chargeable_Duration_R1__c;
                epr.Rate_of_Charge_R1__c = wo.Costs_and_Charges__r.Hourly_Charge_R1__c;
                epr.Chargeable_Units_R2__c = wo.Costs_and_Charges__r.Chargeable_Duration_R2__c;
                epr.Rate_of_Charge_R2__c = wo.Costs_and_Charges__r.Hourly_Charge_R2__c;
                epr.Chargeable_Units_R3__c = wo.Costs_and_Charges__r.Chargeable_Duration_R3__c;
                epr.Rate_of_Charge_R3__c = wo.Costs_and_Charges__r.Hourly_Charge_R3__c; 
                epr.Discount_Value__c = (wo.Costs_and_Charges__r.Discount_Value__c * (var_sa.Pay_Percentage__c) ).setscale(2);
                //  epr.Pay_Fixed_Price__c = (wo.Costs_and_Charges__r.Charge_Other_Item__c * 0.5 ).setscale(2)+ (wo.Costs_and_Charges__r.Call_out_fee__c * 0.5 ).setscale(2);
                //  epr.Pay_Materials__c = wo.Costs_and_Charges__r.Materials_Expense_wout_receipt_no_markup__c;
                //  
                epr.Pay_Materials__c = wo.Costs_and_Charges__r.Materials_Expense_wout_receipt_no_markup__c;
                if(wo.Costs_and_Charges__r.Charge_Other_Item__c == null){
                    wo.Costs_and_Charges__r.Charge_Other_Item__c = 0;
                }
                if(wo.Costs_and_Charges__r.Charge_List_Price_Services__c  == null){
                    wo.Costs_and_Charges__r.Charge_List_Price_Services__c  = 0;
                }
                if(wo.Costs_and_Charges__r.Call_out_fee__c == null){
                    wo.Costs_and_Charges__r.Call_out_fee__c = 0;
                }
                if(wo.Costs_and_Charges__r.Charge_Collection_Fee__c == null){
                    wo.Costs_and_Charges__r.Charge_Collection_Fee__c = 0;
                }
                epr.Pay_Fixed_Price__c =  epr.Pay_Fixed_Price__c =(wo.Costs_and_Charges__r.Charge_Other_Item__c * 0.5 ).setscale(2) +(wo.Costs_and_Charges__r.Charge_List_Price_Services__c *0.5) +(wo.Costs_and_Charges__r.Call_out_fee__c * 0.5 ).setscale(2) +(wo.Costs_and_Charges__r.Charge_Collection_Fee__c * 0.5 ).setscale(2);
                system.debug('Inserting EPR****');
                insert epr;
                var_sa.Engineer_Pay_Requisition__c = epr.id;
                update var_sa;
            } catch ( Exception e ) {
                system.debug('Exception --- ' +e.getMessage());
            }
        }
        if( !line_items.isEmpty() ) { 
            System.debug('%%% Here');
            insert line_items;
            InvoiceController.updateInvoiceText(inv,line_text); 
            update inv;
        }
        
        if(!test.isRunningTest()){
            Invoice_to_PDF.genPDF(inv.id,template,var_netID);
        }
        
        Decimal total_pay = 0;
        for (Engineer_Pay_Requisition__c epr : [
            SELECT Pay_Total__c FROM Engineer_Pay_Requisition__c WHERE Job__c = :j.Id 
        ]){ 
            total_pay+=epr.Pay_Total__c; 
        }
        j.Requisition_Total_Pay__c = total_pay;    
    }
    
    /*
@InvocableMethod(label='Generate Consolidated Invoice')
public static void genConsolidatedInvoice(List<String> jobs_list) {

List<String> ids = jobs_list[0].split('; ');
List<String> invoice_date = ids[0].split(' ');
Integer int_month = 0;
switch on invoice_date[1]
{
when 'January' { int_month = 1; }
when 'February' { int_month = 2; }
when 'March' { int_month = 3; }
when 'April' { int_month = 4; }
when 'May' { int_month = 5; }
when 'June' { int_month = 6; }
when 'July' { int_month = 7; }
when 'August' { int_month = 8; }
when 'September' { int_month = 9; }
when 'October' { int_month = 10; }
when 'November' { int_month = 11; }
when 'December' { int_month = 12; }
}


ids.remove(0);
String order_number = ids[0];
ids.remove(0);
String acc_id = [SELECT Account__c FROM Job__c WHERE id IN :ids LIMIT 1 ].Account__c;

Account var_acc = [ 
SELECT id, Invoicing_Email_Address__c, RecordTypeID 
FROM Account 
WHERE id = :acc_id
];

Customer_Invoice__c inv = new Customer_Invoice__c(
RecordTypeID = Schema.SObjectType.Customer_Invoice__c.getRecordTypeInfosByName().get('Consolidated Invoice').getRecordTypeId(),
Account__c = var_acc.id, 
Date__c = date.newInstance(Integer.valueOf(invoice_date[2]), int_month, Integer.valueOf(invoice_date[0])),
Order_Number__c = order_number,
Account_Email_Address__c = var_acc.Invoicing_Email_Address__c,
Sum_of_Payments__c = 0, 
t4a__c='', t4b__c='', t4c__c='', t4d__c='', t4e__c='', t4f__c=''
);

insert inv;


List<Job__c> jobs = [
SELECT Id, Name, Charge_Net__c, Job_Type__r.Name, Site__r.Site_PostalCode__c, Consolidated_Invoice__c 
FROM Job__c 
WHERE id IN :ids
ORDER BY Name ASC 
];

for ( Job__c j: jobs){          

j.Consolidated_Invoice__c = inv.id;

insert InvoiceController.invoiceLine(inv.id, NULL, j.Charge_Net__c, '20','Labour');


inv.t4a__c += j.Name + '<br/>' ;
inv.t4b__c += j.Site__r.Site_PostalCode__c + '<br/>';
inv.t4c__c += j.Job_Type__r.Name + '<br/>';
inv.t4d__c += j.Charge_Net__c + '<br/>';
inv.t4e__c += (j.Charge_Net__c *0.2).setscale(2) + '<br/>';
inv.t4f__c += (j.Charge_Net__c *1.2).setscale(2) + '<br/>';
}
update inv;
update jobs;

Invoice_to_PDF.genPDF(inv.id,4,Network.getNetworkId());
}

*/
    
    @AuraEnabled
    public static String genKeyAccountInvoice(id job_id) {
        
        ID networkId = Network.getNetworkId();
        Decimal var_epr_total = 0;
        
        Job__c j = InvoiceController.getJob(job_id); 
        
        if ( j.Status__c == 'Closed' )
        {
            
            return '\n\n\n Job Closed \n\n\n You cannot invoice a closed job. \n\n\n';
        }
        
        List<Id> ids = InvoiceController.getGLC('Reactive',j.Account__r.Account_Type__c,j.Job_Type__r.Trade__c,j.Account__r.RecordType.name);    
        Customer_Invoice__c inv = InvoiceController.createInvoice(j,ids,'Consolidated Invoice');     
        insert inv;
        String vat = '20';
        Integer template = 4;
        if(j.Account__r.DRC_Applies__c) { 
            vat = '0'; 
            template = 9;
        }  
        
        List<Customer_Invoice_Line_Item__c> line_items = new List<Customer_Invoice_Line_Item__c>();
        List<Engineer_Pay_Requisition__c> eprs = new List<Engineer_Pay_Requisition__c>();
        
        List<List<String>> line_text = InvoiceController.init_line_container();
        
        for ( WorkOrder wo : InvoiceController.getWOs(j) ){        
            
            if (wo.Costs_and_Charges__r.Charge_labour__c > 0) {       
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_labour__c), vat, 'Labour' ));
                string trade_text = wo.Confirmed_Work_Type__r.Trade__c;
                if ( trade_text == NULL ) { trade_text = wo.WorkType.Trade__c; }
            }
            
            if (wo.Costs_and_Charges__r.Charge_List_Price_Services__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_List_Price_Services__c), vat, 'List Price Service' ));       
            }
            
            if ( wo.Costs_and_Charges__r.Discount_Value__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, -(wo.Costs_and_Charges__r.Discount_Value__c), vat, 'Discount' ));          
            }
            
            if (wo.Costs_and_Charges__r.Charge_Materials__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Materials__c), vat, 'Materials' ));        
            }
            
            if (wo.Costs_and_Charges__r.Charge_Other_Item__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Other_Item__c), vat, 'Other' ));              
            }
            
            if (wo.Costs_and_Charges__r.Call_out_fee__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Call_out_fee__c), vat, 'Other' ));      
            }
            
            if (wo.Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c), vat, 'Fixed Price Admin Fee' ));                   
            }
            
            if (wo.Costs_and_Charges__r.Charge_ULEZ__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_ULEZ__c), vat, 'Other' ));  
                
            }      
            
            if (wo.Costs_and_Charges__r.Charge_Collection_Fee__c > 0 ) {
                line_items.add(InvoiceController.invoiceLine(inv.id, wo.id, (wo.Costs_and_Charges__r.Charge_Collection_Fee__c), vat, 'Collection' ));
                
            }
            
        }
        if( !line_items.isEmpty() ) { 
            System.debug('%%% Here');
            insert line_items;
            inv.Job_Report_for_Customer__c  = j.Attendance_Report_for_Customer__c;
            String jobTitle = j.Customer_Facing_Description__c;
            if(!String.isBlank(jobTitle)){
                if(jobTitle.contains('<p>')){
                    jobTitle = jobTitle.replace('<p>','');
                    jobTitle = jobTitle.replace('</p>','');
                }
                inv.Job_Scope_of_Works__c = jobTitle;
            }
            InvoiceController.updateInvoiceText(inv,line_text); 
            update inv;
        }
        
        j.Status__c = 'Closed';
        update j;
        
        if(!test.isRunningTest()){
            Invoice_to_PDF.genPDF(inv.id,template,networkId);
        }
        
        return inv.Id;    
    }    
}