public class sendCustomNotificationToUser {
    public static void sendCustomnotification(String errorMessage,String jobId,Set<String>userId){
        //  Group gr = [select id,relatedid,name from Group where Name='Community Case Status Changes']; 
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        if(!test.isRunningTest()){
            CustomNotificationType notificationType = [SELECT Id, DeveloperName  FROM CustomNotificationType WHERE DeveloperName='sendCustomnotification'];            obj.setNotificationTypeId(notificationType.id);
            
        }
        
        obj.setTargetId(jobId);
        
        obj.setTitle(errorMessage);
        
        obj.setBody(errorMessage);
        set<String> setUserIds = new Set<String>();
        // below  to be added for send user id - to be added 
        // setUserIds.add(gr.id);
        if(!test.isRunningTest())
            obj.send(userId);
        
    }
    public static void sendEMailerrorMessage(String errorString,String errorMesage,String jobId,Set<String> userEmailids,
                                             String fileName)
    {
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        String finalstr ='';
        if(jobId!=null)
            finalstr =     errorString +':'+jobId+'.'+'Error Message '+errorMesage;
        else
            finalstr =     errorString +':'+'Error Message '+errorMesage;
        
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= fileName+'.xls';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string>();
        String subject =fileName+' CSV';
        if(!Test.isRunningTest())
            toAddresses.AddAll(userEmailids);
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(subject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
    }
}