public class CaseCommentTriggerHandler {
    public static void afterInsert(List<CaseComment> caseComm){
        Set<id> caseId = new Set<Id>();
        for(CaseComment  caseCommenrect : caseComm){
            if(caseCommenrect.parentId!=null){
                caseId.add(caseCommenrect.parentId);
            }
        }
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        if(!caseId.isEmpty()){
            for(Case cas :[SELECT id,SuppliedEmail,Service_Resource__c,Service_Resource__r.RelatedRecordId,RecordTypeId,Origin,Community_User__c ,
                           Service_Resource__r.RelatedRecord.Name,CaseNumber from Case where id=:caseId]){
                               if((cas.Origin=='Community' || cas.Origin=='Office') && cas.RecordTypeId==devRecordTypeId &&
                                  cas.SuppliedEmail!=''  && cas.SuppliedEmail!=null){
                                      
                                      Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage(); 
                                      mail.setTargetObjectId(cas.Community_User__c); 
                                      if(!Test.isRunningtest()){
                                         EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,name  from EmailTemplate where Name= 'Case Comment VF'];
                                      mail.setTemplateId(et.id);    
                                      }
                                      string[] to = new string[] {cas.SuppliedEmail};
                                          mail.setWhatId(cas.id);    
                                      mail.setCCAddresses(to); 
                                      mail.setBccSender(false); 
                                      mail.setUseSignature(false);
                                      
                                      mail.setSenderDisplayName('Aspect Case Notification'); 
                                      
                                      mail.setSaveAsActivity(false);  
                                      if(!Test.isRunningtest())
                                          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                      
                                      sendCustomnotification(cas.id);                                  
                                      
                                      /*  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
string[] to = new string[] {cas.SuppliedEmail};
sendCustomnotification(cas.id);
email.setToAddresses(to);
EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,name  from EmailTemplate
where Name= 'Case Comment Html'];
email.setWhatId(cas.id);
email.setSubject('new Case Comment Created');
email.setTemplateID('00X7E000003fVPW');
email.setSaveAsActivity(false);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });*/
                                      //   email.setHtmlBody(emailTemplate.Body);
                                      
                                  }
                           }
        }
    }
    public static void sendCustomnotification(String caseId){
        Case cas = [SELECT id,CaseNumber from Case where id=:caseId];
        Group gr = [select id,relatedid,name from Group where Name='Community Case Status Changes'];
           Messaging.CustomNotification obj = new Messaging.CustomNotification();
        if(!test.isRunningTest()){
              CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Community_User_Notification'];
          obj.setNotificationTypeId(notificationType.id);
     
        }
      
        
        // Custom notification type Id
      
        
        // when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(caseId);
        
        // Notification Title
        String strTitle = 'New Case Comment is Created for the Case'+cas.CaseNumber;
        obj.setTitle(strTitle);
        
        // Notification Body
        obj.setBody(strTitle);
        set<String> setUserIds = new Set<String>();
        setUserIds.add(gr.id);
        // send used to send the notification, pass the set of user ids , Group or Queue member
        if(!test.isRunningTest())
        obj.send(setUserIds);
        
        
    }
    public static void beforeInsert(List<CaseComment>caseCommres){
        for(CaseComment casecom :caseCommres){
            if(casecom.IsPublished!=true){
                casecom.IsPublished = true;
            }
        }
    }
    public static void beforeUpdate(List<CaseComment>caseCommres,Map<Id,CaseComment> caseCommesOld){
        for(CaseComment casecom :caseCommres){
            if(caseCommesOld.containsKey(casecom.id)){
                if(caseCommesOld.get(casecom.id).IsPublished!=casecom.IsPublished && casecom.IsPublished!=true){
                    casecom.IsPublished = true;
                } 
            }
            
        }
    }
    
}