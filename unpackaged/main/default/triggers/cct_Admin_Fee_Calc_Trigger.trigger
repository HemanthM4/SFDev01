trigger cct_Admin_Fee_Calc_Trigger on Costs_and_Charges__c (after insert, after update) {

    if (Trigger.isInsert) {
        for (Costs_and_Charges__c cct : Trigger.new) {
            
            if( Trigger.newMap.get(cct.ID).Record_Type__c == 'F') 
            cct_Admin_Fee_Calc admin_fee = new cct_Admin_Fee_Calc(Trigger.newMap.get(cct.ID).Id);
        }
    }
    if (Trigger.isUpdate) {
        for (Costs_and_Charges__c cct : Trigger.old) {
            
            if(
                (Trigger.oldMap.get(cct.ID).Charge_Total_Pre_Admin_Fee__c != Trigger.newMap.get(cct.ID).Charge_Total_Pre_Admin_Fee__c) 
                &&
                Trigger.oldMap.get(cct.ID).Record_Type__c == 'F'
            ) 
            cct_Admin_Fee_Calc admin_fee = new cct_Admin_Fee_Calc(Trigger.oldMap.get(cct.ID).Id);
        }   
    }
    
}