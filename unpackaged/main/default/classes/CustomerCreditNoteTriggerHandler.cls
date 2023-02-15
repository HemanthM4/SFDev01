/*
Author: Pradeep Kumar on 22/07/2022
Purpose: This is trigger handler class created to handle all the logic related to Customer Credit Note Object.

Modification Log: 

*/
public class CustomerCreditNoteTriggerHandler {
    
    public void attachPDFToNoteAndAttachment(List<Customer_Credit_Note__c> custCredNoteList, Id netWork_Id){
        
        if(custCredNoteList.size() > 0){
            for(Customer_Credit_Note__c ccn : custCredNoteList){
                creditNoteToPDFGen(ccn.Id, netWork_Id, ccn.Name);
            }
        }
    }
    //Generate PDF from Credit_Note vf page and attach it to Notes & Attachments Object
    @Future(callout=true)
    public static void creditNoteToPDFGen(Id ccnRecId, Id networkRecId, String ccnRecName){
        system.debug('ccnRecId --> '+ccnRecId +'   networkRecId --> '+networkRecId);
        PageReference pr;
        pr =  Page.Credit_Note; 
        //Replace attachmentPDf with the page you have rendered as PDF
        pr.getParameters().put('Id',ccnRecId);
        pr.setRedirect(true);
        Blob b;
        
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        }else{
            b = pr.getContentAsPDF();
        }
        system.debug('b value --> ' +b);
        
        ContentVersion contentVersionRec = new ContentVersion();
        contentVersionRec.Title = ccnRecName;
        contentVersionRec.PathOnClient = ccnRecName + '.pdf';
        contentVersionRec.VersionData = b;
        contentVersionRec.networkId = networkRecId;
        insert contentVersionRec;
        system.debug('contentVersionRec --> ' +contentVersionRec.Id);
        
        List<ContentVersion> contVersRec = new List<ContentVersion>();
        if(contentVersionRec != NULL){
            contVersRec = [SELECT Id, ContentDocumentId FROM ContentVersion 
                           WHERE Id =: contentVersionRec.Id LIMIT 1];
        }
        
        ContentDocumentLink conDoclink = new ContentDocumentLink();
        ContentDistribution contDocument = new ContentDistribution();
        
        If(contVersRec.size() > 0)
        {
            conDoclink.LinkedEntityId = ccnRecId;
            conDoclink.contentdocumentId = contVersRec[0].contentdocumentId;
            insert conDoclink;
            system.debug('conDoclink --> ' +conDoclink.Id);
            
            contDocument.Name = 'Test';
            contDocument.ContentVersionId = contVersRec[0].Id;
            contDocument.PreferencesAllowViewInBrowser= true;
            contDocument.PreferencesLinkLatestVersion=true;
            contDocument.PreferencesNotifyOnVisit=false;
            contDocument.PreferencesPasswordRequired=false;
            contDocument.PreferencesAllowOriginalDownload= true;
            insert contDocument;
            system.debug('contDocument --> ' +contDocument.Id);
        }
        
        List<ContentDistribution> contDist = new List<ContentDistribution>();
        if(contDocument != NULL){
            contDist = [SELECT ContentVersionId, DistributionPublicUrl FROM ContentDistribution 
                        WHERE Id =: contDocument.Id LIMIT 1];
        }
        
        Customer_Credit_Note__c ccnRec = new Customer_Credit_Note__c();
        ccnRec.Id = ccnRecId;
        ccnRec.Credit_Note_Document_URL__c = contDist[0].DistributionPublicUrl;
        update ccnRec;
    }
}