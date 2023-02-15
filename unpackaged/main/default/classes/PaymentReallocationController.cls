public class PaymentReallocationController {

    public static void recalcInvoice(id inv_id){
        
        if( inv_id != NULL )
        {
            Decimal pay = 0;
            Customer_Invoice__c ci = [SELECT id, Sum_of_Payments__c FROM Customer_Invoice__c WHERE id = :inv_id ];
            List<asp04__Payment__c> ps = [SELECT id, asp04__Amount__c, asp04__Total_Refunded__c FROM asp04__Payment__c WHERE Customer_Invoice__c = :inv_id AND asp04__Payment_Stage__c = 'Collected from customer' ];
            for (asp04__Payment__c p:ps)
            {
                pay += (p.asp04__Amount__c - p.asp04__Total_Refunded__c);
            }
            ci.Sum_of_Payments__c = pay;
            update ci;
        }
    }
    
    public static void updateSRICandidateValue(List<asp04__Payment__c> paymentRecList){
        
        set<Id> idSet = new Set<Id>();
        List<asp04__Payment__c> allPaymentList = new  List<asp04__Payment__c>();
        List<asp04__Payment__c> paymentToUpdate = new  List<asp04__Payment__c>();
        Map<Id, List<asp04__Payment__c>> invoicePaymentMap = new Map<Id, List<asp04__Payment__c>>();
            
        for(asp04__Payment__c pRec : paymentRecList){
            idSet.add(pRec.Customer_Invoice__c);
        }
        
        allPaymentList = [SELECT Id, Customer_Invoice__c, Is_SRI_Candidate__c FROM asp04__Payment__c 
                          WHERE Customer_Invoice__c IN: idSet AND asp04__Payment_Stage__c = 'Collected from customer' 
                          AND asp04__Payment_Route_Selected__c = 'Card'
                          ORDER BY CreatedDate ASC LIMIT 9000];

        for(asp04__Payment__c rec : allPaymentList)
        {
            if(invoicePaymentMap.containsKey(rec.Customer_Invoice__c)){
                List<asp04__Payment__c> payRecList = new  List<asp04__Payment__c>();
                payRecList = invoicePaymentMap.get(rec.Customer_Invoice__c);
                payRecList.add(rec);
                invoicePaymentMap.put(rec.Customer_Invoice__c, payRecList);
            }else{
                invoicePaymentMap.put(rec.Customer_Invoice__c, new  List<asp04__Payment__c>{rec});
            }
        }
        system.debug('allPaymentList --> ' + allPaymentList.size()+'     invoicePaymentMap -- '+invoicePaymentMap.Size());
        if(invoicePaymentMap != NULL){
            for(id recId : invoicePaymentMap.keyset()){
                for(asp04__Payment__c payRec : invoicePaymentMap.get(recId)){
                    if(recId == payRec.Customer_Invoice__c){
                        if(payRec.Is_SRI_Candidate__c == TRUE){
                            System.debug('Inside true value If--- ');
                            break;
                        }else{
                            System.debug('Inside False value else--- '+payRec.Id);
                           	payRec.Is_SRI_Candidate__c = TRUE;
                            paymentToUpdate.add(payRec);
                            break;
                        }
                    }
                }
            }
        }
        if(paymentToUpdate.size() > 0){
            system.debug('paymentToUpdate --> ' +paymentToUpdate.size());
            update paymentToUpdate;
        }
    }
}