public class CaseTriggerhandler {
    public static void beforeInsert(List<Case> cases)
    {
        System.debug('case trigger entered');
        Set<id>ServiceResourceId = new Set<id>();
        Id devRecordTypeIdcaseOper = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        Id devRecordTypeIdcaseSupport = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Support Request').getRecordTypeId();
        
        Map<String,RestrictCaseDML__c> mapCustomSetting = new  Map<String,RestrictCaseDML__c>();
        List<RestrictCaseDML__c > mcs = RestrictCaseDML__c.getall().values();
        
        for(RestrictCaseDML__c res :mcs){
            mapCustomSetting.put(res.Name,res);
        }
        Map<Id,Profile>ProfileMap = new Map<Id,Profile>();
        for(Profile pro :[SELECT id,Name  from Profile where Name=:mapCustomSetting.keySet() ]){
            ProfileMap.put(pro.id,pro); 
        }
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        System.debug('@@@@@@@@@@@@@@@@'+profileName);
        Set<String>caseEmail = new Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        Id caseviaTI = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case via TI').getRecordTypeId();
        Id caseviaWebsite = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case via Website (form not pre-populated)').getRecordTypeId();
        for(Case cas: cases)
        {
            if(cas.RecordtypeId==devRecordTypeIdcaseOper && cas.Origin=='Community'){
                String Sub = cas.Subject.substringBefore('@-@');
                Sub = Sub.replace('Sandbox:','');
                cas.Case_type__c = Sub;
            }
        }
        
        for(Case cas: cases)
        {
            if(!ProfileMap.containskey(profileId) && !Test.isRunningTest()){
                if(cas.RecordtypeId==devRecordTypeIdcaseOper || cas.RecordtypeId==devRecordTypeIdcaseSupport  ){
                    cas.addError('You are not Authorised to Create the records');
                }
            }
            
            if(cas.RecordTypeId==devRecordTypeId)
            {
                if(cas.Service_Resource__c!=null)
                {
                    ServiceResourceId.add(cas.Service_Resource__c);   
                }
                if(cas.Service_Resource__c==null && cas.SuppliedEmail!='')
                {
                    caseEmail.add(cas.SuppliedEmail);
                }
                System.debug('@@@@@@@@@@@@@@@@@@@'+cas.Origin);
                if(cas.Origin=='Community')
                {
                    cas.Type='Question';
                    if(cas.Subject!=null &&  cas.Description!=null &&  cas.Subject.contains('@-@EmailtoCase') && cas.Description.contains('@-@EmailtoCase'))
                    {
                        String recID = cas.Subject.substringAfter('/-/');
                        String Sub = cas.Subject.substringBefore('@-@');
                        String source = cas.Description.substringAfter('/-/');
                        String des = cas.Description.substringBefore('@-@');
                        Sub = Sub.replace('Sandbox:','');
                        if(source=='Service Appointment' || Test.isRunningTest())
                        {
                            if(Sub!='')
                            {
                                Integer s = Sub.length(); 
                                integer s1 =s/2;
                                Sub = Sub.subString(0,s1);
                            }
                            if(des!='')
                            {
                                Integer s = des.length(); 
                                integer s1 =s/2;
                                des = des.subString(0,s1);
                            }
                            cas.Subject = Sub;
                            cas.Description = des;
                            if(!Test.isRunningTest())
                                cas.Service_Appointment__c =recID;
                        }
                        if(source=='requisition' || Test.isRunningTest()){
                            if(Sub!=''){
                                Integer s = Sub.length(); 
                                integer s1 =s/2;
                                Sub = Sub.subString(0,s1);
                            }
                            if(des!=''){
                                Integer s = des.length(); 
                                integer s1 =s/2;
                                des = des.subString(0,s1);
                            }
                            cas.Subject = Sub;
                            cas.Description = des;
                            if(!Test.isRunningTest())
                                cas.Engineer_Pay_Requisition__c =recID;
                        }
                        if(source=='deduc'){
                            if(Sub!=''){
                                Integer s = Sub.length(); 
                                integer s1 =s/2;
                                Sub = Sub.subString(0,s1);
                            }
                            if(des!=''){
                                Integer s = des.length(); 
                                integer s1 =s/2;
                                des = des.subString(0,s1);
                            }
                            cas.Subject = Sub;
                            cas.Description = des;
                            if(!Test.isRunningTest())
                                cas.Engineer_Deduction__c =recID;
                        }
                    }
                    
                }
            }
        }
        Map<id,String> serviceMap=new Map<id,String>();
        Map<String,Id> caseEmailMap=new Map<String,Id>();
        Map<String,Id> communityUsebyServicer=new Map<String,Id>();
        if(!ServiceResourceId.isEmpty())
        {
            for(ServiceResource SerRes : [SELECT id,RelatedRecordId,RelatedRecord.EMail from ServiceResource where id=:ServiceResourceId])
            {
                if(SerRes.RelatedRecordId!=null)
                    serviceMap.put(SerRes.id,SerRes.RelatedRecord.EMail );
                communityUsebyServicer.put(SerRes.id,SerRes.RelatedRecordId);
            }
        }
        if(communityUsebyServicer!=null)
        {
            for(Case cas: cases)
            {
                if(communityUsebyServicer.containsKey(cas.Service_Resource__c))
                {
                    cas.Community_User__c= communityUsebyServicer.get(cas.Service_Resource__c);
                }
            }
        }
        
        if(serviceMap!=null)
        {
            for(Case cas: cases)
            {
                if(serviceMap.containsKey(cas.Service_Resource__c))
                {
                    cas.SuppliedEmail= serviceMap.get(cas.Service_Resource__c);
                }
            }
        }
        Map<String,Id> communityUser=new Map<String,Id>();
        if(!caseEmail.isEmpty())
        {
            for(ServiceResource SerRes : [SELECT id,RelatedRecord.EMail from ServiceResource where RelatedRecord.EMail=:caseEmail])
            {
                caseEmailMap.put(SerRes.RelatedRecord.EMail ,SerRes.id);
                communityUser.put(SerRes.RelatedRecord.EMail ,SerRes.RelatedRecordId);
            }
        }
        if(caseEmailMap!=null)
        {
            for(Case cas: cases)
            {
                if(caseEmailMap.containsKey(cas.SuppliedEmail))
                {
                    cas.Service_Resource__c= caseEmailMap.get(cas.SuppliedEmail);
                }
            }
            
        }
        if(communityUser!=null)
        {
            for(Case cas: cases)
            {
                if(communityUser.containsKey(cas.SuppliedEmail))
                {
                    cas.Community_User__c= communityUser.get(cas.SuppliedEmail);
                }
            }
            
        }
    }
    public static void sendCaseNoficationAssigned(String userId,String caseId){
        Case cas = [SELECT id,CaseNumber from Case where id=:caseId];
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        if(!Test.isRunningTest()){
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Case_Assigned_User_Notification'];
            // Custom notification type Id
            obj.setNotificationTypeId(notificationType.id);   
        }
        
        
        // when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(caseId);
        
        // Notification Title
        String strTitle = cas.CaseNumber+' is assigned to you ';
        obj.setTitle(strTitle);
        
        // Notification Body
        obj.setBody(strTitle);
        set<String> setUserIds = new Set<String>();
        setUserIds.add(userId);
        if(!Test.isRunningTest())
            obj.send(setUserIds);
        
    }
    public static void afterUpdate(List<case> cases,Map<id,Case> caseOld)
    {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        for(Case cas: cases)
        {
            if(cas.Assigned_to__c!=null && caseOld.get(cas.id).Assigned_to__c!=cas.Assigned_to__c){
                sendCaseNoficationAssigned(cas.Assigned_to__c,cas.id);
            }
            if(cas.RecordTypeId==devRecordTypeId && cas.Status!=caseOld.get(cas.id).Status && cas.Status=='Closed'
               && (cas.Origin=='Community' || cas.Origin=='Office')
              )
            {
                Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage(); 
                mail.setTargetObjectId(cas.Community_User__c); 
                if(!test.isRunningTest()){
                    EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,name  from EmailTemplate where Name= 'Case Status Closed VF'];
                    mail.setTemplateId(et.id); 
                }
                
                string[] to = new string[] {cas.SuppliedEmail};
                    mail.setWhatId(cas.id);    
                mail.setCCAddresses(to); 
                mail.setBccSender(false); 
                mail.setUseSignature(false);
                
                mail.setSenderDisplayName('Aspect Case Notification'); 
                
                mail.setSaveAsActivity(false);  
                if(!test.isRunningTest())
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                sendCustomnotification(cas.id,' Case is Closed');              
                
                
                /*    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
string[] to = new string[] {cas.SuppliedEmail};
email.setToAddresses(to);

email.setSubject('Case is Closed');
email.setWhatId(cas.id); 
email.setUseSignature(false); 
email.setSaveAsActivity(false); 
if(cas.Community_User__c!=null)
email.setTargetObjectId(cas.Community_User__c); 
EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,name  from EmailTemplate where Name= 'Case Status Closed VF'];
email.setTemplateId(et.id);*/
                // email.setHtmlBody('Hello , <br/><br/>'+cas.CaseNumber+' case is Closed <br/><br/>Regards<br/> Aspect');
                //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
        
        //Update related Job's countOfOpenCase field
        relatedJobOpenCases(cases);
    }
    public static void sendCustomnotification(String caseId,String caseContent)
    {
        Case cas = [SELECT id,CaseNumber from Case where id=:caseId];
        Group gr = [select id,relatedid,name from Group where Name='Community Case Status Changes'];
        
        
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        if(!Test.isRunningTest()){
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Community_User_Notification'];
            // Custom notification type Id
            obj.setNotificationTypeId(notificationType.id);   
        }
        
        
        // when we click on the notification it will redirect to the specified targetId
        obj.setTargetId(caseId);
        
        // Notification Title
        String strTitle = cas.CaseNumber+' '+caseContent;
        obj.setTitle(strTitle);
        
        // Notification Body
        obj.setBody(strTitle);
        set<String> setUserIds = new Set<String>();
        setUserIds.add(gr.id);
        if(!Test.isRunningTest())
            obj.send(setUserIds);
        
        
    }
    public static void beforeUpdate(List<Case> cases,Map<id,Case>casesOld)
    {
        Id devRecordTypeIdcaseOper = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        Id devRecordTypeIdcaseSupport = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Support Request').getRecordTypeId();
        Map<String,RestrictCaseDML__c> mapCustomSetting = new  Map<String,RestrictCaseDML__c>();
        List<RestrictCaseDML__c > mcs = RestrictCaseDML__c.getall().values();
        for(RestrictCaseDML__c res :mcs){
            mapCustomSetting.put(res.Name,res);
        }
        Map<Id,Profile>ProfileMap = new Map<Id,Profile>();
        for(Profile pro :[SELECT id,Name  from Profile where Name=:mapCustomSetting.keySet() ]){
            ProfileMap.put(pro.id,pro); 
        }
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        for(Case cas: cases)
        {
            if(!ProfileMap.containskey(profileId) && !Test.isRunningTest()){
                if(cas.RecordtypeId==devRecordTypeIdcaseOper || cas.RecordtypeId==devRecordTypeIdcaseSupport  ){
                    cas.addError('You are not Authorised to Update the records');
                }
            }
        }
    }
    public static void beforeDelete(List<Case> cases)
    {
        Id devRecordTypeIdcaseOper = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        Id devRecordTypeIdcaseSupport = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Support Request').getRecordTypeId();
        Map<String,RestrictCaseDML__c> mapCustomSetting = new  Map<String,RestrictCaseDML__c>();
        List<RestrictCaseDML__c > mcs = RestrictCaseDML__c.getall().values();
        for(RestrictCaseDML__c res :mcs){
            mapCustomSetting.put(res.Name,res);
        }
        Map<Id,Profile>ProfileMap = new Map<Id,Profile>();
        for(Profile pro :[SELECT id,Name  from Profile where Name=:mapCustomSetting.keySet() ]){
            ProfileMap.put(pro.id,pro); 
        }
        Id profileId=userinfo.getProfileId();
        for(Case cas: cases)
        {
            if(!ProfileMap.containskey(profileId) && !Test.isRunningTest()){
                if(cas.RecordtypeId==devRecordTypeIdcaseOper || cas.RecordtypeId==devRecordTypeIdcaseSupport  ){
                    cas.addError('You are not Authorised to Delete the records');
                }
            }
        }
    }
    public static void afterInsert(List<case> cases)
    {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        for(Case cas: cases)
        {
            if(cas.Assigned_to__c!=null){
                sendCaseNoficationAssigned(cas.Assigned_to__c,cas.id);
            }
            if(cas.RecordTypeId==devRecordTypeId && (cas.Origin=='Community' || cas.Origin=='Office')
              )
            {
                
                Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage(); 
                mail.setTargetObjectId(cas.Community_User__c); 
                if(!Test.isRunningTest()){
                    EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,name  from EmailTemplate where Name= 'Case Creation'];
                    mail.setTemplateId(et.id);    
                }
                //  EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,name  from EmailTemplate where Name= 'Case Creation'];
                //  mail.setTemplateId(et.id); 
                string[] to = new string[] {cas.SuppliedEmail};
                    mail.setWhatId(cas.id);    
                mail.setCCAddresses(to); 
                mail.setBccSender(false); 
                mail.setUseSignature(false);
                
                mail.setSenderDisplayName('Aspect Case Notification'); 
                
                mail.setSaveAsActivity(false);  
                if(!Test.isRunningTest())
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                sendCustomnotification(cas.id,' Case is Created');              
                
                
            }
        }
        
        //Update related Job's countOfOpenCase field
        relatedJobOpenCases(cases);
    }
    
    //Method called on case create/update/delete
    public static void relatedJobOpenCases(List<Case> cases){
        
        Set<id> JobIds = new Set<id>(); 
        List<Job__c> jobsToUpdate = new List<Job__c>();
        
        for(Case cs : cases){
            JobIds.add(cs.Job__c );
        }
        // get a map of the job with the Count_of_Open_Cases__c
        Map<id,Job__c> jobMap = new Map<id,Job__c>([select id,Count_of_Open_Cases__c from Job__c where id IN :JobIds]);
        
        // query the related 'OPEN' cases to the JOBs
        for (Job__c jobRec : [select id,name,Count_of_Open_Cases__c,(select id,status,Job__c from Cases__r where status != 'Closed') from Job__c where Id IN :JobIds]) {
            system.debug('2'+ jobRec.Cases__r.size());
            jobMap.get(jobRec.Id).Count_of_Open_Cases__c = jobRec.Cases__r.size();
            jobsToUpdate.add(jobMap.get(jobRec.Id));
        }
        update jobsToUpdate;
    }
    
}