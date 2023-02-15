public without sharing class Invoice_to_PDF {
    
    @future(callout=true)
    public static void genPDF(id inv_id, Integer t, Id var_netID){
        
        List<Customer_Invoice__c> inv = [SELECT id, Name, Ready_to_Send__c, Invoice_Generation_Complete__c 
                                         FROM Customer_Invoice__c WHERE id = :inv_id LIMIT 1];
        
        if(inv.size() > 0){
            PageReference pr;
            switch on t {
                when 0{
                    pr =  Page.Invoice_Reactive_Page; 
                }            
                when 1{
                    pr =  Page.Invoice_Deposit_Page; 
                }            
                when 2{
                    pr =  Page.Invoice_FP_Page; 
                }
                when 3{
                    pr =  Page.Invoice_Cancellation_Page; 
                }            
                when 4{
                    pr =  Page.Consolidated_Invoice_Page; 
                }
                when 5{
                    pr =  Page.Invoice_Reactive_DRC_Page; 
                }            
                when 6{
                    pr =  Page.Invoice_Deposit_DRC_Page; 
                }            
                when 7{
                    pr =  Page.Invoice_FP_DRC_Page; 
                }
                when 8{
                    pr =  Page.Invoice_Cancellation_DRC_Page; 
                }            
                when 9{
                    pr =  Page.Consolidated_Invoice_DRC_Page; 
                }
            }
            
            //Replace attachmentPDf with the page you have rendered as PDF
            pr.getParameters().put('Id',inv[0].Id);
            pr.setRedirect(true);
            Blob b;
            
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Unit.Test');
            } else {
                b = pr.getContentAsPDF();
            }
            
            ContentVersion cv = new ContentVersion(
                Title = inv[0].Name,
                PathOnClient = inv[0].Name+'.pdf',
                VersionData = b,
                networkId = var_netID
            );
            insert cv;
            
            ContentVersion cv2 = [SELECT id, ContentDocumentId FROM ContentVersion WHERE id = :cv.id ];
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = inv[0].id;
            cdl.contentdocumentid = cv2.contentdocumentid;
            if(!test.isRunningTest()){
                insert cdl;
            }
            
            inv[0].Ready_to_Send__c = true;
            inv[0].Invoice_Generation_Complete__c = TRUE;
            if(!Test.isRunningTest())
                update inv[0];
        }
    }
}