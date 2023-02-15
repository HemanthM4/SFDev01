/*
Author: Pradeep Kumar on 05/09/2022
Purpose: This is trigger handler class created to handle all the logic related to GSRSubmissionTrigger.

Modification Log: 

*/
public class GSRSubmissionTriggerHandler {
    
    public void generatePDFForGSRSubmission(GSR_Submission__c gsrSubmissionRec, Id netWork_Id){
        if(gsrSubmissionRec != null){
            gsrSubmissionToPDFGen(gsrSubmissionRec.Id, netWork_Id, gsrSubmissionRec.Name, gsrSubmissionRec.Related_Account_Email_Formula__c);
        }
    }
    
    //Generate PDF from GSR_Certificate_V7 vf page and attach it to Notes & Attachments Object
    @Future(callout=true)
    public static void gsrSubmissionToPDFGen(Id gsrSubRecId, Id networkRecId, String gsrSubRecName, String accEmail){
        
        system.debug('gsrSubRecId -->> '+ gsrSubRecId +'   networkRecId -->> '+ networkRecId);
        PageReference pr;
        pr =  Page.GSR_Certificate;
        pr.getParameters().put('Id',gsrSubRecId);
        pr.setRedirect(true);
        Blob b;
        
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        }else{
            b = pr.getContentAsPDF();
        }
        system.debug('b value --> ' +b);
        
        ContentVersion contentVersionRec = new ContentVersion();
        contentVersionRec.Title = gsrSubRecName;
        contentVersionRec.PathOnClient = gsrSubRecName + '.pdf';
        contentVersionRec.VersionData = b;
        contentVersionRec.networkId = networkRecId;
        insert contentVersionRec;
        system.debug('contentVersionRec --> ' +contentVersionRec.Id);
        
        List<ContentVersion> contVersRec = new List<ContentVersion>();
        if(contentVersionRec != NULL){
            contVersRec = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionRec.Id LIMIT 1];
        }
        
        ContentDocumentLink conDoclink = new ContentDocumentLink();
        ContentDistribution contDocument = new ContentDistribution();
        
        If(contVersRec.size() > 0)
        {
            conDoclink.LinkedEntityId = gsrSubRecId;
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
        If(contDist != NULL){
            GSR_Submission__c gsrSubmission = new GSR_Submission__c();
            gsrSubmission.Id = gsrSubRecId;
            gsrSubmission.GSR_Certificate_URL__c = contDist[0].DistributionPublicUrl;
            gsrSubmission.Generate_GSR_Submission_Report__c = TRUE;
            gsrSubmission.Account_Email_Address__c = accEmail;
            update gsrSubmission;
        }
    }
}