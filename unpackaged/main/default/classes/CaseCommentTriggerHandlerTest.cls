@isTest
public class CaseCommentTriggerHandlerTest 
{
    static testMethod void CaseCommentTriggerTest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='PHASE 2 Ops - Processing']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operative Contact').getRecordTypeId();
        
            
          //  EmailTemplate e = new EmailTemplate (developerName = 'CaseCreation',  FolderId = u.Id,   TemplateType= 'Text', Name = 'Case Creation'); // plus any other fields that you want to set

//insert e;
            
        Account acc = new Account();
        acc.name =' test';
        acc.BillingStreet = 'First street'; 
        insert acc;
            
        Contact con = new Contact();
        con.LastName = 'One';
        insert con;
        
        Case cs = new Case();
        cs.Status = 'Complaint';
        cs.Description = 'anything';
        cs.ContactId = con.Id;
        cs.Origin = 'Community';
        cs.Type = 'Question';
        cs.SuppliedEmail = u.Email;
        cs.RecordTypeId =devRecordTypeId;
        cs.AccountId = acc.Id;
        insert cs;
            
        CaseComment cm = new CaseComment();
        cm.ParentId = cs.id;
        insert cm;
        cm.IsPublished = true;
        update cm;
          
         Messaging.CustomNotification obj = new Messaging.CustomNotification();
            
            
        }
    }
}