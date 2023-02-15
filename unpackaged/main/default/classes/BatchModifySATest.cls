@isTest
public class BatchModifySATest {
 static testMethod void createEPR() {
        Account acc = new Account();
        acc.Name = 'Flying' + 'Jack 02';
        acc.First_Name__c = 'Flying';
        acc.Last_Name__c = 'Jack 02';
        acc.Email__c = 'dasfrog.web@gmail.com';
        acc.Invoicing_Email_Address__c = 'dasfrog.web@gmail.com';
        acc.Account_Type__c = 'Cash';
        acc.Account_Status__c = 'Open';
        acc.BillingStreet = '8 Allington way';
        acc.BillingCity = 'Swanley';
        acc.BillingCountry = 'United Kingdom';
        acc.BillingPostalCode = 'BR8 8FG';
        acc.Access_Details__c = '2333';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = acc.First_Name__c;
        con.LastName = acc.Last_Name__c;
        con.Email = acc.Email__c;
        insert con;
        Profile p = [Select Name from Profile where Name = 'Engineer Partner Community'];
        
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p.id, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='testerfefefre@noemail.com');
        
        insert user;
        
        Profile p1 = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'Samuel',
                          lastname='XfdsfdsXXX',
                          Alias='Samuel',
                          email = 'samuelXXXXX@gmail.com',
                          username= 'samuelXXXXdsfsfdsX@gmail.com', 
                          profileId= p1.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;
        ServiceResource SR = new ServiceResource();
        System.runAs(u){
            
            SR.RelatedRecordId = u.id;
            SR.Email__c = 'Test@gmail.com';
            SR.Rate_of_Pay_Tier__c = 'Tier 2';
            SR.Engineer_Role__c = 'Service_Resource';
            SR.ResourceType ='T';
            SR.Name = 'Test';
            insert SR;
           
        }
        Test.startTest();
        BatchModifySA bdt = new BatchModifySA(SR.id, null);
        dataBase.executeBatch(bdt);
        
        Test.stopTest();
        
        
    }
}