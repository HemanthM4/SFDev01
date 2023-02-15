@isTest
public class Phase_2_Estimate_Clone_Test {

    static testmethod void clonetest(){

        Account acc = new Account();
        acc.Name = 'Invoice Test';
        acc.First_Name__c = 'Invoice';
        acc.Last_Name__c = 'Test';
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

        Site__c site = new Site__c();
        site.Name = acc.Name +'-'+ acc.BillingStreet+'-'+ acc.BillingPostalCode;
        site.Site_Street__c = acc.BillingStreet;
        site.Access_Details__c = acc.Access_Details__c;
        site.Site_PostalCode__c = acc.BillingPostalCode;
        site.Site_City__c = acc.BillingCity;
        site.Account__c = acc.Id;
        site.Primary_Site_Contact__c = con.id;
        insert site;

        WorkType wt = new WorkType();
        wt.DurationType = 'Hours';
        wt.EstimatedDuration = 2;
        wt.Name = 'tmp';
        insert wt;

        Job__c job = new Job__c();
        job.Account__c = acc.id;
        job.Job_Type__c = wt.id;
        Job.Site__c = site.id;
        insert job;

        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = job.id;

        insert cct;


        WorkOrder wo = new WorkOrder();
        wo.Job__c = job.Id;
        wo.WorkTypeId = wt.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Duration = wt.EstimatedDuration;
        wo.country = 'United Kingdom';
        wo.Costs_and_Charges__c = cct.id;
        wo.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('WorkOrder','Reactive');
        insert wo;

        Product2 prod = new Product2(name='tmp');
        insert prod;

        ProductRequired preq = new ProductRequired();
        preq.ParentRecordId = wo.id;
        preq.Product2Id = prod.id ; //[SELECT id FROM Product2 LIMIT 1].id;
        preq.Product_Category__c = 'Van Stock';
        insert preq;

        Test.startTest();
        List<Id> job_ids = new List<Id>();
        job_ids.add(job.id);

        id new_job_id = Phase_2_Estimate_Clone.clone_job(job.id);

        preq.Product_Category__c = 'Purchase Order';
        update preq;
        Test.stopTest();
    }

    static testmethod void cloneEstimateTest(){

        Account acc = new Account();
        acc.Name = 'Invoice Test';
        acc.First_Name__c = 'Invoice';
        acc.Last_Name__c = 'Test';
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

        Site__c site = new Site__c();
        site.Name = acc.Name +'-'+ acc.BillingStreet+'-'+ acc.BillingPostalCode;
        site.Site_Street__c = acc.BillingStreet;
        site.Access_Details__c = acc.Access_Details__c;
        site.Site_PostalCode__c = acc.BillingPostalCode;
        site.Site_City__c = acc.BillingCity;
        site.Account__c = acc.Id;
        site.Primary_Site_Contact__c = con.id;
        insert site;

        WorkType wt = new WorkType();
        wt.DurationType = 'Hours';
        wt.EstimatedDuration = 2;
        wt.Name = 'tmp';
        insert wt;

        Job__c job = new Job__c();
        job.Account__c = acc.id;
        job.Job_Type__c = wt.id;
        Job.Site__c = site.id;
        insert job;

        Job__c job1 = new Job__c();
        job1.Account__c = acc.id;
        job1.Job_Type__c = wt.id;
        Job1.Site__c = site.id;
        insert job1;

        Costs_and_Charges__c cct = new Costs_and_Charges__c();
        cct.Job__c = job.id;
        insert cct;

        Costs_and_Charges__c cct1 = new Costs_and_Charges__c();
        cct1.Job__c = job1.id;
        insert cct1;


        WorkOrder wo = new WorkOrder();
        wo.Job__c = job.Id;
        wo.WorkTypeId = wt.Id;//Id input from the form submitted online
        wo.Description = 'Blah blah';
        wo.ContactId = con.Id;
        wo.AccountId = acc.Id;
        wo.Site__c = site.Id;
        wo.Duration = wt.EstimatedDuration;
        wo.country = 'United Kingdom';
        wo.Costs_and_Charges__c = cct.id;
        wo.RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('WorkOrder','Reactive');
        insert wo;

        Product2 prod = new Product2(name='tmp');
        insert prod;

        Product2 prod1 = new Product2(name='tmp1');
        insert prod1;

        ProductRequired preq1 = new ProductRequired();
        preq1.ParentRecordId = wo.id;
        preq1.Product2Id = prod1.id ; //[SELECT id FROM Product2 LIMIT 1].id;
        preq1.Product_Category__c = 'Van Stock';
        insert preq1;

        ProductRequired preq = new ProductRequired();
        preq.ParentRecordId = wo.id;
        preq.Product2Id = prod.id ; //[SELECT id FROM Product2 LIMIT 1].id;
        preq.Product_Category__c = 'Van Stock';
        insert preq;

        Test.startTest();
        List<Id> job_ids = new List<Id>();
        job_ids.add(job.id);
        job_ids.add(job1.id);

        Phase_2_Estimate_Clone.clone_job_with_10_percent_discount(job_ids);

        preq.Product_Category__c = 'Purchase Order';
        update preq;
        Test.stopTest();
    }
}