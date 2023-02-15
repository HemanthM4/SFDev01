/*

Modification Log:
1) 11/7/2022 - Mofified by Pradeep for Rate Cards and Rate restructure

*/

public class job_LabourRequisitionsController {
    
    public string recordid {get;set;}
    public Map <Costs_and_Charges__c,List<ServiceAppointment>> sas {get;set;}
    public list<Costs_and_Charges__c> ccts {get;set;}
    
    public job_LabourRequisitionsController(){ 
        ccts = [SELECT id FROM Costs_and_Charges__c WHERE Job__c = :recordid];
        IF(ccts != null){
            for (Costs_and_Charges__c cct:ccts) {
                system.debug('cost and charges value-- '+cct);
                sas.put(cct, [SELECT id, AppointmentNumber, Allocated_Engineer__r.Name FROM ServiceAppointment 
                              WHERE  Work_Order__r.Costs_and_Charges__c=:cct.id  ]);
            }
        }
    }
    
    public static void genReqs(Job__c job) {
        
        List<Costs_and_Charges__c> listOfCostsAndCharges = new List<Costs_and_Charges__c>();
        Decimal var_epr_total = 0; Decimal engRateOfPayPercent = 0; Decimal engRateOfPay = 0;
        Set<Id> ccIdSet = new Set<Id>();
        Set<Id> woIdSet = new Set<Id>();
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        List<ServiceAppointment> listOfSA = new List<ServiceAppointment>();
        Map<Id, ServiceAppointment> serviceAppMap = new Map<Id, ServiceAppointment>();
        List<Rate_Card_Trade__c> listOfTradeRateCard = new List<Rate_Card_Trade__c>();
        Set<String> tradeSet = new Set<String>();
        Map<String, Rate_Card_Trade__c> tradeRateCardMap = new Map<String, Rate_Card_Trade__c>();
        List<Engineer_Pay_Requisition__c> eprRecordToInsert = new List<Engineer_Pay_Requisition__c>();
        List<ServiceAppointment> saRecToUpdate = new List<ServiceAppointment>();
        
        if(job != null){
        listOfCostsAndCharges = [SELECT id,Charge_labour__c, Chrage_Labour_Discounted__c,Charge_List_Price_Services__c,Charge_Materials__c,
                                 Charge_Collection_Fee__c,Materials_Expense_wout_receipt_no_markup__c,Charge_Other_Item__c,Call_out_fee__c,
                                 Charge_ULEZ__c,Fixed_Price_Admin_Fee_2__c,Hourly_Charge_R1__c, Hourly_Charge_R2__c, Hourly_Charge_R3__c,
                                 Chargeable_Duration_R1__c, Chargeable_Duration_R2__c, Chargeable_Duration_R3__c,Discount_Manual_Override__c, 
                                 Discount_Manual_Percentage__c, Discount_Value__c,Discount_Office__c, Discount_Engineer__c 
                                 FROM Costs_and_Charges__c WHERE Job__c =: job.Id AND Include_in_estimate__c = TRUE];
        }
        for(Costs_and_Charges__c recCC: listOfCostsAndCharges){
            ccIdSet.add(recCC.Id);
        }
        
        if(ccIdSet.size() > 0){
           workOrderList = [SELECT id, WorkOrderNumber, Confirmed_Work_Type__r.Trade__c, WorkType.Trade__c, Record_Type_Name__c, 
                            Costs_and_Charges__c, Trade__c FROM WorkOrder WHERE Costs_and_Charges__c IN: ccIdSet]; 
        }
        if(workOrderList.size() > 0){
            for(WorkOrder recWO: workOrderList){
                workOrderMap.put(recWO.Costs_and_Charges__c, recWO);
                woIdSet.add(recWO.Id);
                tradeSet.add(recWO.Trade__c);
            }
        }
        
        if(woIdSet.size() > 0){
            listOfSA = [SELECT id, Allocated_Engineer__c, Allocated_Engineer__r.Rate_of_Pay_Tier__c,status,Allocated_Engineer__r.Email__c,
                        ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN: woIdSet AND Status != 'Cancelled'];
        }
        for(ServiceAppointment recSA: listOfSA){
            serviceAppMap.put(recSA.ParentRecordId, recSA);
        }
        
        if(tradeSet.size() > 0){
            listOfTradeRateCard = [SELECT Id,Pay_Tier_1__c,Pay_Tier_2__c,Pay_Tier_3__c,Pay_Tier_4__c,Pay_Tier_5__c,Pay_Tier_6__c,
                                   Pay_Tier_7__c,Pay_Tier_8__c,Pay_Tier_9__c,Pay_Tier_10__c,Trade_Name__c FROM Rate_Card_Trade__c
                                   WHERE Trade_Name__c IN: tradeSet AND Rate_Card__c =: job.Account__r.Rate_Card__c];
            if(listOfTradeRateCard.size() == 0 || listOfTradeRateCard == null){
                listOfTradeRateCard = [SELECT Id, Pay_Tier_1__c,Pay_Tier_2__c,Pay_Tier_3__c,Pay_Tier_4__c,Pay_Tier_5__c,Pay_Tier_6__c,
                                       Pay_Tier_7__c,Pay_Tier_8__c,Pay_Tier_9__c,Pay_Tier_10__c,Trade_Name__c FROM Rate_Card_Trade__c
                                       WHERE Trade_Name__c IN: tradeSet AND Rate_Card__r.Standard__c = TRUE];
            }
        }
        for(Rate_Card_Trade__c recTRC: listOfTradeRateCard){
            tradeRateCardMap.put(recTRC.Trade_Name__c, recTRC);
        }
        
        if(listOfCostsAndCharges.size() > 0 && workOrderMap != null){
            for (Costs_and_Charges__c cct: listOfCostsAndCharges){
                
                WorkOrder var_wo = workOrderMap.get(cct.Id);
                
                ServiceAppointment var_sa;
                Engineer_Pay_Requisition__c epr = new Engineer_Pay_Requisition__c();
                epr.Auto_Generated__c = TRUE;
                epr.Pay_Fixed_Price__c = 0;
                try {
                    if(serviceAppMap.containskey(var_wo.Id)){
                        var_sa = serviceAppMap.get(var_wo.Id);
                    }
                } catch (QueryException e) {
                    System.debug('No service appointment found:\n ' + e.getMessage());   
                }
                
                Rate_Card_Trade__c var_tradeRateCard = new Rate_Card_Trade__c();
                String rateOfPayTier = var_sa.Allocated_Engineer__r.Rate_of_Pay_Tier__c;
                if ( var_sa != NULL && rateOfPayTier != NULL)
                {
                    try {
                        /*
var_rc = [SELECT id FROM Rate_Cards__c WHERE Account__c = :job.Account__c 
AND Trade__c = :var_wo.WorkType.Trade__c LIMIT 1];
} catch (QueryException e) {
System.debug('No acount specific rate card found:\n ' + e.getMessage());   
}
if ( var_rc == NULL )
{
try {
var_rc = [SELECT id FROM Rate_Cards__c WHERE Account__c = NULL AND Trade__c = :var_wo.WorkType.Trade__c LIMIT 1];
} catch (QueryException e) {
System.debug('No general rate card found:\n ' + e.getMessage());   
}
}

String type= 'Rate_Card_Trade__c';
Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
Schema.SObjectType TradeRateCardSchema = schemaMap.get(type);
Map<String, Schema.SObjectField> fieldMap = TradeRateCardSchema.getDescribe().fields.getMap();
for (String fieldName: fieldMap.keySet()) {
String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
if(fieldLabel.contains(rateOfPayTier)){ 
}
}*/
                        if(tradeRateCardMap.containskey(var_wo.WorkType.Trade__c)){
                            var_tradeRateCard = tradeRateCardMap.get(var_wo.WorkType.Trade__c);
                        }
                        if(rateOfPayTier.contains('Tier 1')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_1__c;
                        }
                        else if(rateOfPayTier.contains('Tier 2')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_2__c;
                        }
                        else if(rateOfPayTier.contains('Tier 3')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_3__c;
                        }
                        else if(rateOfPayTier.contains('Tier 4')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_4__c;
                        }
                        else if(rateOfPayTier.contains('Tier 5')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_5__c;
                        }
                        else if(rateOfPayTier.contains('Tier 6')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_6__c;
                        }
                        else if(rateOfPayTier.contains('Tier 7')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_7__c;
                        }
                        else if(rateOfPayTier.contains('Tier 9')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_9__c;
                        }
                        else if(rateOfPayTier.contains('Tier 10')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_10__c;
                        }
                        else if(rateOfPayTier.contains('Tier 8')){
                            engRateOfPayPercent = var_tradeRateCard.Pay_Tier_8__c;
                        }
                        engRateOfPay = engRateOfPayPercent/100;
                    } catch (QueryException e) {
                        System.debug('No general rate card found:\n ' + e.getMessage());   
                    }
                    
                    //epr.Customer_Invoice__c = inv.id;
                    epr.Job__c = job.Id;
                    epr.Work_Order__c = var_wo.id;
                    epr.Status__c = 'New';
                    if ( var_sa != NULL ) {
                        epr.Service_Resource__c = var_sa.Allocated_Engineer__c;
                        epr.Service_Resource_Email__c = var_sa.Allocated_Engineer__r.Email__c;    
                    }
                    if( var_tradeRateCard != NULL ){
                        epr.Rate_of_Pay__c = engRateOfPay * 100;
                    }
                }
                
                if (cct.Charge_labour__c != 0 && cct.Charge_labour__c != NULL) {
                    
                    epr.Chargeable_Units_R1__c = cct.Chargeable_Duration_R1__c;
                    epr.Rate_of_Charge_R1__c = cct.Hourly_Charge_R1__c;        
                    
                    epr.Chargeable_Units_R2__c = cct.Chargeable_Duration_R2__c;
                    epr.Rate_of_Charge_R2__c = cct.Hourly_Charge_R2__c;
                    
                    epr.Chargeable_Units_R3__c = cct.Chargeable_Duration_R3__c;
                    epr.Rate_of_Charge_R3__c = cct.Hourly_Charge_R3__c;
                }
                
                if (cct.Charge_List_Price_Services__c != 0 && cct.Charge_List_Price_Services__c != NULL ){
                    epr.Pay_Fixed_Price__c += (cct.Charge_List_Price_Services__c *0.5); 
                }
                
                if (cct.Discount_Manual_Override__c == TRUE && cct.Discount_Value__c != 0 && cct.Discount_Value__c != NULL ){
                    if (var_tradeRateCard != NULL ) {   
                        // set discount value on EPR
                        if (cct.Discount_Manual_Percentage__c <= 10 || cct.Discount_Engineer__c > cct.Discount_Office__c ) {
                            epr.Discount_Value__c = (cct.Discount_Value__c * engRateOfPay ).setscale(2);    
                        } else {
                            epr.Discount_Value__c = ( (cct.Charge_labour__c + cct.Call_out_fee__c ) * 0.1 * engRateOfPay ).setscale(2);
                        }
                    }                    
                }
                
                if (cct.Charge_Materials__c != 0 && cct.Charge_Materials__c != NULL) {
                    epr.Pay_Materials__c = cct.Materials_Expense_wout_receipt_no_markup__c;
                }
                
                if (cct.Charge_Other_Item__c != 0 && cct.Charge_Other_Item__c != NULL) { 
                    epr.Pay_Fixed_Price__c += (cct.Charge_Other_Item__c * 0.5 ).setscale(2);
                }
                
                if (cct.Call_out_fee__c != 0 && cct.Call_out_fee__c != NULL) {
                    epr.Pay_Fixed_Price__c += (cct.Call_out_fee__c * 0.5 ).setscale(2);
                }
                
                if (cct.Charge_Collection_Fee__c != 0 && cct.Charge_Collection_Fee__c != NULL) {
                    epr.Pay_Fixed_Price__c += (cct.Charge_Collection_Fee__c * 0.5 ).setscale(2);
                }
                system.debug('var_sa -- '+var_sa);
                if ( var_sa != NULL ) {
                     epr.Has_Batch_Created_EPR__c =  true;
                    eprRecordToInsert.add(epr);
                    var_sa.Engineer_Pay_Requisition__c = epr.id;
                    saRecToUpdate.add(var_sa);
                }
                system.debug('saRecToUpdate -- '+saRecToUpdate.Size());
            }
        }
        if(eprRecordToInsert.size() > 0){
            insert eprRecordToInsert;
        }
        if(saRecToUpdate.size() > 0){
            update saRecToUpdate;
        }
        Decimal total_pay = 0;
        for (Engineer_Pay_Requisition__c epr2 : [SELECT Pay_Total__c FROM Engineer_Pay_Requisition__c WHERE Job__c = :job.Id]){ 
            total_pay += epr2.Pay_Total__c; 
        }
        job.Requisition_Total_Pay__c = total_pay;
    }
}