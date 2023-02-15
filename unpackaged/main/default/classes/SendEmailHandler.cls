public class SendEmailHandler {
    
    @AuraEnabled
    public static string processEmail(String email, String Subject, String Message,String Source,String recordIDVal){
        String sMessage='';
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email}; 
                mail.setToAddresses(toAddresses);
            if(recordIDVal!='')
                Subject +=Subject+' @-@EmailtoCase /-/'+recordIDVal;
            if(Source!='')   
                Message +=Message+ ' @-@EmailtoCase /-/'+ Source;
            //                  mail.setTargetObjectId(UserInfo.getUserId()); 
            mail.setSaveAsActivity(false);
            mail.setSubject(Subject);
            mail.setHtmlBody(Message);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            sMessage='Success';
        }
        catch(Exception ex){
            sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
        }
        return sMessage;
    }
    @AuraEnabled
    public static wrapEmail getemailidDetails(){
        wrapEmail  wrap = new wrapEmail();
        List<CommunityEmailtoCase__c> mcs = CommunityEmailtoCase__c.getall().values();
        for(CommunityEmailtoCase__c caseval: mcs){
            wrap.toemail =  caseval.Email__c;
        }
        // wrap.toemail =UserInfo.getUserEmail();
        
        return wrap;
    }
    public class wrapEmail {
        @AuraEnabled
        public String fromeamil {get; set;}
        @AuraEnabled
        public String toemail {get; set;}
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapEmail() {
            toemail =  fromeamil = '';
        }
    }
    @AuraEnabled
    public static List<String> getSucotmSetting(){
        List<String>cusValues =new List<String>();
        List<EmailtoCaseSubject__c> mcs = EmailtoCaseSubject__c.getall().values();
        for(EmailtoCaseSubject__c ems :mcs){
            cusValues.add(ems.Name);
        }
        return cusValues;
    }
    @AuraEnabled
    public static String saveFileforRecord(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        String isSuccess ='Success';
        // parentId =  serviceRes[0].id;        
        System.debug('entered APex '+base64Data);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        System.debug('entered APex new '+base64Data);
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title =fileName; 
        testContentInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        testContentInsert.PathOnClient='/' + fileName ;
        try{
            insert testContentInsert; 
        }catch(Exception ex){
            isSuccess = ex.getMessage();
            System.debug('isSuccess'+isSuccess);
        }
        
        testContentInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: testContentInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = testContentInsert.ContentDocumentId;
        cl.LinkedEntityId = parentId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        
        try{
            insert cl;
        }catch(Exception ex){
            isSuccess = ex.getMessage();
        }  
        
        
        
        return isSuccess;
    }
    @AuraEnabled
    public static String saveFile(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        String isSuccess ='Success';
        List<ServiceResource> serviceRes = [SELECT id from ServiceResource where RelatedRecordId =:Userinfo.getUserId()];
        if(serviceRes.size()!=0){
            parentId =  serviceRes[0].id;        
            System.debug('entered APex '+base64Data);
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            System.debug('entered APex  '+base64Data);
            ContentVersion testContentInsert =new ContentVersion(); 
            testContentInsert.Title =fileName; 
            testContentInsert.VersionData=EncodingUtil.base64Decode(base64Data);
            testContentInsert.PathOnClient='/' + fileName ;
            try{
                insert testContentInsert; 
            }catch(Exception ex){
                isSuccess = ex.getMessage();
                System.debug('isSuccess'+isSuccess);
            }
            
            testContentInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: testContentInsert.Id];
            ContentDocumentLink cl = new ContentDocumentLink();
            cl.ContentDocumentId = testContentInsert.ContentDocumentId;
            cl.LinkedEntityId = parentId; 
            cl.ShareType = 'V';
            cl.Visibility = 'AllUsers';
            
            try{
                insert cl;
            }catch(Exception ex){
                isSuccess = ex.getMessage();
            }  
        }else {
            isSuccess = 'No Service Resource Available';   
        }
        
        
        return isSuccess;
    }
}