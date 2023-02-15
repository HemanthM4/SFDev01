@isTest
public class SendEmailHandlerTest {
    static testMethod void SendEmailMethod() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u) {
            
            Account acc = new Account(name='test acc');
            insert acc;
            
            String RecordTypeIdContact = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            ServiceResource SR = new ServiceResource();
            SR.Email__c = ' Test@gmail.com';
            SR.Engineer_Role__c ='Service_Resource';
            SR.ResourceType = 'T';
            SR.Rate_of_Pay_Tier__c = 'Tier 2';
            SR.RelatedRecordId =u.id;
            SR.Name ='Test';
            insert SR;    
            
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            cv.Title = 'fileName';
            cv.PathOnClient = 'filename';
            insert cv;
            
            ContentNote cn = new ContentNote();
            cn.Title = 'This is Title of the Note!';
            cn.Content = Blob.valueOf('test');
            insert cn;
            
            ContentDocumentLink cl = new ContentDocumentLink();
            cl.ContentDocumentId = cn.Id;
            cl.LinkedEntityId = acc.Id; 
       	    cl.ShareType = 'V';
       	    cl.Visibility = 'AllUsers';
            insert cl;
            
            test.StartTest();
            
            String s1 = SendEmailHandler.processEmail('','','','','');
            SendEmailHandler.wrapEmail s2 = SendEmailHandler.getemailidDetails();
            List<String> s3 = SendEmailHandler.getSucotmSetting();
          //  String s4 = SendEmailHandler.saveFileforRecord(cv.Id,'','','','');
            //String s5 = SendEmailHandler.saveFile(cv.Id,'','','','');
              String s = SendEmailHandler.saveFileforRecord(null,'Test','fsdsgfdgdfbgfngfn','','');
            String s6 = SendEmailHandler.saveFile(null,'Test','fsdsgfdgdfbgfngfn','','');
            test.StopTest();
        }
    }
}