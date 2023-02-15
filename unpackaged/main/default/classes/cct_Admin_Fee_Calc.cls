public class cct_Admin_Fee_Calc {

    public cct_Admin_Fee_Calc(id cct_id) {
        List<Service_Fee_Banding__mdt> bands = [ 
            SELECT End_of_Band__c, Service_Fee_Percentage__c 
            FROM Service_Fee_Banding__mdt 
        	ORDER BY End_of_Band__c ASC 
        ];
        Costs_and_Charges__c cct = [
            SELECT id, Charge_Total_Pre_Admin_Fee__c, Fixed_Price_Admin_Fee_2__c, Admin_Fee_Percentage__c, Job__r.Account_Type__c
            FROM Costs_and_Charges__c 
            WHERE id = :cct_id
            LIMIT 1
        ];
        Decimal percentage = 0;
        Decimal start_of_band = 0;
        Boolean use_next = FALSE;
        for ( Service_Fee_Banding__mdt band:bands ) 
        {
            if ( cct.Charge_Total_Pre_Admin_Fee__c < band.End_of_Band__c && cct.Charge_Total_Pre_Admin_Fee__c > start_of_band ) 
            {
                percentage = band.Service_Fee_Percentage__c;
            }
            start_of_band = band.End_of_Band__c;
        }
        cct.Fixed_Price_Admin_Fee_2__c = 0;
        cct.Admin_Fee_Percentage__c = percentage;
        if (cct.Job__r.Account_Type__c <> 'Key Account')
        {
        	cct.Fixed_Price_Admin_Fee_2__c = (cct.Charge_Total_Pre_Admin_Fee__c * percentage/100).setscale(2);
        }
        update cct;
    } 
    
}