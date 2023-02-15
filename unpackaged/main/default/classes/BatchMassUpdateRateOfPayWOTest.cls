@isTest
public class BatchMassUpdateRateOfPayWOTest {
    static testmethod void testWOrkOrder(){
        Profile p = [SELECT Id FROM Profile WHERE Name='PHASE 2 Ops - Starter']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusfghgfhgfhger@testorg.com');

        insert u;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingStreet ='Test';
        acc.BillingPostalCode  ='123445';
        insert acc; 
        
        contact con  = new Contact();
        con.LastName = 'Aspect';
        insert con;
        Id RecordTypeIdContact = Schema.SObjectType.Site__c.getRecordTypeInfosByName().get('Domestic').getRecordTypeId();
        Site__c site = new Site__c();
        site.Account__c  = acc.id;
        site.RecordTypeId = RecordTypeIdContact;
        site.Name = 'test';
        site.Primary_Site_Contact__c =con.id;
        site.Site_Street__c ='Test';
        site.Site_PostalCode__c ='12345';
        Site.Site_Country__c ='Uk';
        insert site;
        Job__c job = new Job__c();
        Job.Account__c = acc.id;
        Job.Site__c =site.id;
        JOb.Combined_Scope_of_Works_for_All_WOs__c = 'Test';
        insert Job;
        Aspect_JobDataController.workORderLabourWrapper wraps = new Aspect_JobDataController.workORderLabourWrapper();
        Costs_and_Charges__c cost = new Costs_and_Charges__c();
        cost.JOb__c = Job.id;
        insert cost;
        Trade__c trade = new Trade__c();
        trade.Name = 'Roofing';
        insert trade;
        Costs_and_Charges__c costs = new Costs_and_Charges__c();
        costs.Job__c = job.id;
        insert costs;
        Aspect_JobDataController.productRequiredWrapper prod = new Aspect_JobDataController.productRequiredWrapper();
        prod.type='Hire';
        prod.ProductREquiredId ='|567|';
        List<Aspect_JobDataController.productRequiredWrapper> prodrec = new List<Aspect_JobDataController.productRequiredWrapper>();
        prodrec.add(prod);
        WorkType wt=new WorkType();
        wt.trade__c='Roofing';
        wt.name ='test';
        wt.EstimatedDuration=10.00;
        insert wt;
        WorkOrder WO  = New WOrkOrder();
        WO.JOb__c =job.id;
        WO.Costs_and_Charges__c =costs.id;
        WO.WorkTypeId =wt.id;
        WO.Rate_of_Pay__c = 45;
        insert WO;
        
         Test.startTest();
        String accQuery = 'SELECT id,Rate_of_Pay__c,Rate_Of_Pay_Percent__c from WorkOrder where  Rate_of_Pay__c !=null';
BatchMassUpdateRateOfPayWO bdt = new BatchMassUpdateRateOfPayWO(accQuery);
dataBase.executeBatch(bdt);
        Test.stopTest();
    }

}