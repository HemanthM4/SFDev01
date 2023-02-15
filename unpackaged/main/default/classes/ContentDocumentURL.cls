public class ContentDocumentURL {
    
    Public Static Map<Id,Id> condocLinkVerMap = new Map<Id,Id>();
    Public static Map<Id,Id> converDocIdMap = new Map<Id,Id>();
    Public static Map<Id,String> converDistMap = new Map<Id,String>();
    
    public static void createPublicUrlLink(List<ContentDocumentLink> conDocLinksList) {
        
        for(ContentDocumentLink cdlin : conDocLinksList){
            //find if the document is related to Purchase order

            Set<Id> LinkdEntities = new Set<Id>();
            List<ContentDocumentLink> contdoclist = new List<ContentDocumentLink>();
            switch on String.ValueOf(cdlin.linkedentityid.getsobjecttype()) 
            {
                when 'Purchase_Order__c'
                {
                    LinkdEntities.add(cdlin.linkedentityid);
                    contdoclist.add(cdlin);
                    createRecord(LinkdEntities);
                    updatePurchaseOrder(contdoclist);
                }
                when 'Customer_Invoice__c'
                {
                    LinkdEntities.add(cdlin.linkedentityid);
                    contdoclist.add(cdlin);
                    createRecord(LinkdEntities);
                    updateInvoice(contdoclist);
                }
            }

        }
    }
    
    public static list<ContentDistribution> createRecord(Set<Id> cdlinrecs){
        List<contentdocumentlink> cdls = [select contentdocument.id from contentdocumentlink where linkedentityid IN: cdlinrecs];
        Set<Id> cvIds = new Set<Id>(); 
        
        
        List<ContentDistribution> listtoCreate = new List<ContentDistribution>();
        for(contentdocumentlink cdlsrecs : cdls){
            cvIds.add(cdlsrecs.contentdocument.id);
            condocLinkVerMap.put(cdlsrecs.id,cdlsrecs.contentdocument.id);
        }
        //Get the content version ID
        for (ContentVersion cv : [select id,contentdocumentid from contentversion where contentdocumentid IN:cvIds]) {
            converDocIdMap.put(cv.contentdocumentid,cv.Id);
            //Create the ContentDistribution (Represents information about sharing a document externally)
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            listtoCreate.add(cd);
            
        }
        insert listtoCreate;
        for(ContentDistribution mapcr : [select ContentVersionId,DistributionPublicUrl from ContentDistribution where Id IN: listtoCreate]){
            converDistMap.put(mapcr.ContentVersionId,mapcr.DistributionPublicUrl);
        }
        return listtoCreate;
    }
    
    public static void updatePurchaseOrder(List<contentdocumentlink> contdoclinklist){
        Map<Id,Sobject> entityDocMap = new Map<Id,Sobject>();
        for(contentdocumentlink cdoclink : contdoclinklist){
            entityDocMap.put(cdoclink.LinkedEntityId,cdoclink);
        }
        List<Purchase_Order__c> PurOrders = [select id,Purchase_Order_Document_URL__c from Purchase_Order__c where id IN: entityDocMap.keySet()];
        for(Purchase_Order__c po : PurOrders){
            po.Purchase_Order_Document_URL__c = converDistMap.get(converDocIdMap.get(condocLinkVerMap.get(entityDocMap.get(po.Id).Id)));
        }
        update PurOrders;
    }

    public static void updateInvoice(List<contentdocumentlink> contdoclinklist){
        Map<Id,Sobject> entityDocMap = new Map<Id,Sobject>();
        for(contentdocumentlink cdoclink : contdoclinklist){
            entityDocMap.put(cdoclink.LinkedEntityId,cdoclink);
        }
        List<Customer_Invoice__c> cis = [select id,Invoice_Document_URL__c from Customer_Invoice__c where id IN: entityDocMap.keySet()];
        for(Customer_Invoice__c ci : cis){
            ci.Invoice_Document_URL__c = converDistMap.get(converDocIdMap.get(condocLinkVerMap.get(entityDocMap.get(ci.Id).Id)));
        }
        update cis;
    }
}