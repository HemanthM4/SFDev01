@isTest
private class ContentDocumentURL_Test {
 static testMethod void insertDoctest1() {
       
        List<Account> accountslist= TestDataFactory.createAccounts(1);
        
        /*
        Supplier_Invoice__c supInv = new Supplier_Invoice__c();
        supInv.Type__c = 'Invoice';
        supInv.Supplier_Account__c = accountslist[0].id;
        supInv.Total_Actual_Invoice_Amount_excl_VAT__c = 123.00;
        supInv.Total_Actual_Invoice_Amount_incl_VAT__c = 173.00;   
        supInv.Total_Actual_VAT_Amount__c = 50;
        insert supInv;
        */
        
         Purchase_Order__c po = new Purchase_Order__c();
         //po.Supplier_Invoice__c = supInv.Id;
         po.Delivery_Options__c = 'Deliver to Office';
         po.Supplier_Account__c = accountslist[0].id;
         insert po;
     
     
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
     
     ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = po.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        Test.startTest();
        insert contentlink; 
        Test.stopTest();
 }
}