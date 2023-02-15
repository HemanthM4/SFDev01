@isTest
public class Aspect_JobDataTest {
    
    static testMethod void jobMethod(){
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
        site.Site_Street__c ='Test';
        site.Site_PostalCode__c ='12345';
        site.Primary_Site_Contact__c =con.id;
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
        List<Aspect_JobDataController.productRequiredWrapper> prodrec = new List<Aspect_JobDataController.productRequiredWrapper>();
        prodrec.add(prod);
        WorkOrder WO  = New WOrkOrder();
        WO.JOb__c =job.id;
        WO.Costs_and_Charges__c =costs.id;
        insert WO;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prodyuct = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prodyuct;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prodyuct.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        ProductRequired prodreq = new ProductRequired();
        prodreq.ParentRecordId =WO.id;
        prodreq.Product2Id =prodyuct.id;
        prodreq.QuantityRequired = 1;
        insert prodreq;
        Test.startTest();
        Job__c jsbd =Aspect_JobData.getJobinfo(job.id);
        Boolean boo = Aspect_JobData.getjobType(job.id);
        List<WorkOrder> WOs =Aspect_JobData.getWorkOrders(job.id);
        Costs_and_Charges__c cos = Aspect_JobData.includeInEstimate(cost.id);
        Costs_and_Charges__c cos1 = Aspect_JobData.excludeInEstimate(cost.id);
        String s1 = Aspect_JobData.getCombinedValuefromJob(job.id);
        Boolean isCheck =Aspect_JobData.getActivateStatusType(job.id);
        Test.stopTest();
    }
}