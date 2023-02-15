public class Aspect_JobData {
  @AuraEnabled
    public static Boolean getjobType (Id recordId) {  
 Boolean ischecked = true;
        Job__c jobInfo = [SELECT id,Job_Type__c,Job_Type__r.Name FROM Job__c WHERE Id=:recordId];
 if(jobInfo.Job_Type__r.Name =='reactive')
     ischecked = false;
        return ischecked;
    }
    @AuraEnabled
    public static Boolean getActivateStatusType(String recordId){
        Boolean ischecked = true;
        Job__c jobInfo = [SELECT id,Status__c FROM Job__c WHERE Id=:recordId];
 if(jobInfo.Status__c =='New')
     ischecked = false;
        return ischecked;
    }
     @AuraEnabled
    public static String getCombinedValuefromJob (Id recordId) {  
String combinedValue ='';
        Job__c jobInfo = [SELECT id,Combined_Scope_of_Works_for_All_WOs__c FROM Job__c WHERE Id=:recordId];
 if(jobInfo.Combined_Scope_of_Works_for_All_WOs__c !='')
    combinedValue =  jobInfo.Combined_Scope_of_Works_for_All_WOs__c ;
        return combinedValue;
    }
    @AuraEnabled
    public static Job__c getJobinfo (Id recordId) {  
 
        Job__c jobInfo = [SELECT id,name,Charge_Labour__c,Cost_Labour__c,Charge_List_Price_Services__c,Charge_Materials_Total__c,Cost_Materials_Total__c,
                          Cost_Discount__c,Total_List_Price__c , Total_ulez__c, Total_Fixed_Price_Admin__c,Charge_Discount_Total__c,Charge_Call_Out__c,
						  Charge_Collection_Fee__c ,Charge_ULEZ__c,Fixed_Price_Admin_Fee__c,Cost_Other_Item__c,Cost_Collection_Fee__c,Cost_Call_Out__c,
						  Cost_ULEZ__c,Cost_Fixed_Price_Admin__c,Charge_Other_Total__c,Cost_Other_Total__c,
                          Charge_Net__c,Cost_Total__c,Charge_VAT__c,Charge_Gross__c,Charge_Deposit__c FROM Job__c WHERE Id=:recordId];
 
        return jobInfo;
    }
    
    @AuraEnabled
    public static List<WorkOrder> getWorkOrders (Id recordId) {  
 
        List<WorkOrder> workOrdersList = [SELECT id,WorkOrderNumber,WorkType.name,Costs_and_Charges__c,Costs_and_Charges__r.Charge_labour__c,
                                          Costs_and_Charges__r.Charge_Materials__c,Costs_and_Charges__r.Discount_Value__c,Costs_and_Charges__r.Charge_ULEZ__c,
                                          Costs_and_Charges__r.Charge_Collection_Fee__c, Costs_and_Charges__r.Call_Out_Fee__c,
                                           Costs_and_Charges__r.Cost_Other_Item__c, Costs_and_Charges__r.Charge_Other_Total__c,
                                          Costs_and_Charges__r.Fixed_Price_Admin_Fee_2__c,Costs_and_Charges__r.Charge_Other_Item__c,
                                          Costs_and_Charges__r.Charge_Total__c,Costs_and_Charges__r.Include_in_estimate__c,Costs_and_Charges__r.Profit_Margin__c,Costs_and_Charges__r.Charge_List_Price_Services__c 
                                          FROM WorkOrder WHERE Job__c=:recordId];
        return workOrdersList;
    }
    
    @AuraEnabled
    public static Costs_and_Charges__c includeInEstimate(Id recordId) {  
 
        Costs_and_Charges__c cc = [SELECT id,Include_in_estimate__c FROM Costs_and_Charges__c WHERE Id=:recordId];
        cc.Include_in_estimate__c = TRUE;
        update cc;
        return cc;
    }
    
    @AuraEnabled
    public static Costs_and_Charges__c excludeInEstimate(Id recordId) {  
 
        Costs_and_Charges__c cc = [SELECT id,Include_in_estimate__c FROM Costs_and_Charges__c WHERE Id=:recordId];
        cc.Include_in_estimate__c = FALSE;
        update cc;
        return cc;
    }
}