/*

Modification Log:
1) 7/7/2022 - Mofified by Pradeep for Rate Cards and Rate restructure

*/

@istest
public class Aspect_JobDataControllerTest {
    
    static testMethod void jobMethod1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='PHASE 2 Ops - Starter']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusfghgfhgfhger@testorg.com');
        insert u;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingStreet ='Test';
        acc.BillingPostalCode  ='123445';
        acc.Rate_Card__c = rca.Id;
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
        
        Rate_Card_Trade__c rct = new Rate_Card_Trade__c();
        rct.Rate_Card__c = rca.Id;
        rct.Trade__c = trade.Id;
        rct.Default_For_Estimate__c = 'Tier 8';
        rct.Charge_R1__c = 10;rct.Charge_R2__c = 20;rct.Charge_R3__c= 30;
        rct.Pay_Tier_1__c = 4;rct.Pay_Tier_2__c = 4;
        rct.Pay_Tier_3__c= 5;rct.Pay_Tier_4__c = 6;
        rct.Pay_Tier_5__c = 3;rct.Pay_Tier_6__c = 7;
        rct.Pay_Tier_7__c = 21;rct.Pay_Tier_8__c = 9;
        rct.Pay_Tier_9__c = 25;rct.Pay_Tier_10__c = 12;
        insert rct;
        
        Costs_and_Charges__c costs = new Costs_and_Charges__c();
        costs.Job__c = job.id;
        insert costs;
        
        Aspect_JobDataController.productRequiredWrapper prod = new Aspect_JobDataController.productRequiredWrapper();
        prod.type='Hire';
        prod.overrides=true;
        prod.cost =10;
        prod.costorg =11;
        prod.quantity =10;
        prod.quantityorg =11;
        prod.markup =10;
        prod.markuporg =11;
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
        WO.Trade_Rate__c = rct.Id;
        insert WO;

        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prodyuct = new Product2(
            Name = 'Hire',
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
        
        Aspect_JobDataController.CCOtherWrapper ccothers = new   Aspect_JobDataController.CCOtherWrapper();
        Test.startTest();
        Map<String,String> trades =  Aspect_JobDataController.getTrades();
        Aspect_JobDataController.workORderLabourWrapper wrap = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,true,true);
        Aspect_JobDataController.workORderLabourWrapper wrap1 = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,false,false);
        Aspect_JobDataController.workORderLabourWrapper wrap2 = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,false,true);
        Aspect_JobDataController.workORderLabourWrapper wrap3 = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,true,false);
        Aspect_JobDataController.workTrageGroupWrapper tradge =Aspect_JobDataController.tradeWOrktypeGroup(WO.id);
        Aspect_JobDataController.updateccforworkorder(WO.id);
        Aspect_JobDataController.CCOtherWrapper ccother =Aspect_JobDataController.getCCforWorkOrder(WO.id);
        List<Aspect_JobDataController.productRequiredWrapper>Prods =  Aspect_JobDataController.updatePrdowrap(prodrec);
        JOb__c jobs  =Aspect_JobDataController.getjobbrecord(Job.id);
        Aspect_JobDataController.workORderLabourWrapper wrapsLabour =   Aspect_JobDataController.getWorkorderforLabourctrl(WO.id);
        Aspect_JobDataController.workOrderWrapper  wkorder = Aspect_JobDataController.getWorkOrderDetailsCtrl(WO.id);
        List<Aspect_JobDataController.productRequiredWrapper>Prods1 =  Aspect_JobDataController.markupChangeMethod(prodrec);
        List<Aspect_JobDataController.productRequiredWrapper>Prods2 =  Aspect_JobDataController.qulaityChangeMethd(prodrec);
        List<Aspect_JobDataController.productRequiredWrapper>Prods3 =  Aspect_JobDataController.checkboxchange(prodrec,'3',true);
        List<Aspect_JobDataController.productRequiredWrapper>Prods4 =  Aspect_JobDataController.checkboxchange(prodrec,'3',false);
        Aspect_JobDataController.CCOtherWrapper ccotherss = Aspect_JobDataController.handloeotherfunction(ccothers);
        List<Aspect_JobDataController.productRequiredWrapper> prodwrapppers = Aspect_JobDataController.getProductRequiredRec(WO.id);
        Aspect_JobDataController.updateSuccess s = Aspect_JobDataController.updateJob(prodrec,wraps,'',ccothers,Job.id,false,trade.id);
        Aspect_JobDataController.updateSuccess s1 = Aspect_JobDataController.updateJob(prodrec,wraps,'',ccothers,Job.id,true,trade.id);
        Map<String,String> mpasRTrade =Aspect_JobDataController.getgroup('');
        Map<String,String> mpasRTrades =Aspect_JobDataController.getWorkType('');
        Aspect_JobDataController.workORderLabourWrapper wrap6 =    Aspect_JobDataController.getworktypechange(wt.id,wraps,WO.id,Job.id);
        String getDescription = Aspect_JobDataController.getCombinedValuefromJob(Job.id);
        Boolean wrap7 =    Aspect_JobDataController.checkOnSize(prodrec);
        Aspect_JobDataController.hr1 =10;
        Aspect_JobDataController.hr2 =10;
        Aspect_JobDataController.hr3 =10;
        Aspect_JobDataController.hr1amount =10;
        Aspect_JobDataController.hr2amount =10;
        Aspect_JobDataController.hr3amount =10;
        Boolean s5=  Aspect_JobDataController.checkUserProfile();
        List<String> s6 =Aspect_JobDataController.getProductRequiredProduct();
        //decimal s7 = Aspect_JobDataController.getfixedPriceAdmin(Job.id);
        List<Aspect_JobDataController.productRequiredWrapper> prodWraps = new  List<Aspect_JobDataController.productRequiredWrapper>();
        Aspect_JobDataController.productRequiredWrapper prodWrap = new Aspect_JobDataController.productRequiredWrapper();
        prodWrap.type='Hire';
        prodWraps.add(prodWrap);
        
        integer intValue = Aspect_JobDataController.getrandomnumber();
        //Aspect_JobDataController.deleteproductrequired(prodreq.id);
        //Boolean isCheckUser=Aspect_JobDataController.getUserInfo(u.id);
        //   String sJob1 = Aspect_JobDataController.getCombinedValuefromJob(job.id);
        Test.stopTest();
    }
    
    static testMethod void jobMethod(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='PHASE 2 Ops - Starter']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusfghgfhgfhger@testorg.com');
        insert u;
        
        Rate_Card_Account__c rca = new Rate_Card_Account__c();
        rca.Description__c = 'test';
        rca.Standard__c = TRUE;
        insert rca;
        
        ID networkId = Network.getNetworkId();
        
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
        acc.DRC_Applies__c = TRUE;
        acc.Rate_Card__c = rca.Id;
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
        
        WorkType wt=new WorkType();
        wt.trade__c='Electrical';
        wt.name ='test';
        wt.EstimatedDuration=10.00;
        insert wt;
        
        Job__c job = new Job__c();
        Job.Account__c = acc.id;
        Job.Job_Type__c = wt.Id;
        Job.Site__c =site.id;
        JOb.Combined_Scope_of_Works_for_All_WOs__c = 'Test';
        insert Job;
        
        Aspect_JobDataController.workORderLabourWrapper wraps = new Aspect_JobDataController.workORderLabourWrapper();
        Costs_and_Charges__c cost = new Costs_and_Charges__c();
        cost.JOb__c = Job.id;
        insert cost;
        
        Trade__c trade = new Trade__c();
        trade.Name = 'Electrical';
        insert trade;
        
        Rate_Card_Trade__c rct = new Rate_Card_Trade__c();
        rct.Rate_Card__c = rca.Id;
        rct.Trade__c = trade.Id;
        rct.Default_For_Estimate__c = 'Tier 8';
        rct.Charge_R1__c = 10;rct.Charge_R2__c = 20;rct.Charge_R3__c= 30;
        rct.Pay_Tier_1__c = 4;rct.Pay_Tier_2__c = 4;
        rct.Pay_Tier_3__c= 5;rct.Pay_Tier_4__c = 6;
        rct.Pay_Tier_5__c = 3;rct.Pay_Tier_6__c = 7;
        rct.Pay_Tier_7__c = 21;rct.Pay_Tier_8__c = 9;
        rct.Pay_Tier_9__c = 25;rct.Pay_Tier_10__c = 12;
        insert rct;
        
        Costs_and_Charges__c costs = new Costs_and_Charges__c();
        costs.Job__c = job.id;
        insert costs;
        
        Aspect_JobDataController.productRequiredWrapper prod = new Aspect_JobDataController.productRequiredWrapper();
        prod.type='Hire';
        prod.ProductREquiredId ='|567|';
        List<Aspect_JobDataController.productRequiredWrapper> prodrec = new List<Aspect_JobDataController.productRequiredWrapper>();
        prodrec.add(prod);
        
        WorkOrder WO  = New WOrkOrder();
        WO.JOb__c =job.id;
        WO.Costs_and_Charges__c =costs.id;
        WO.WorkTypeId =wt.id;
        WO.Trade_Rate__c = rct.Id;
        insert WO;

        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prodyuct = new Product2(
            Name = 'Hire',
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
        
        Aspect_JobDataController.CCOtherWrapper ccothers = new   Aspect_JobDataController.CCOtherWrapper();
        Test.startTest();
        Map<String,String> trades =  Aspect_JobDataController.getTrades();
        List<Id> ids = InvoiceController.getGLC('Fixed Price',Job.Account__r.Account_Type__c,Job.Job_Type__r.Trade__c,Job.Account__r.RecordType.name);
        Customer_Invoice__c inv = InvoiceController.createInvoice(Job,ids,'Deposit');
        insert inv;
        Aspect_JobDataController.workORderLabourWrapper wrap = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,true,true);
        Aspect_JobDataController.workORderLabourWrapper wrap1 = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,false,false);
        Aspect_JobDataController.workORderLabourWrapper wrap2 = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,false,true);
        Aspect_JobDataController.workORderLabourWrapper wrap3 = Aspect_JobDataController.getWorkOrderOnChage(trade.id,wraps,Job.id,true,false);
        Aspect_JobDataController.workTrageGroupWrapper tradge =Aspect_JobDataController.tradeWOrktypeGroup(WO.id);
        Aspect_JobDataController.updateccforworkorder(WO.id);
        Aspect_JobDataController.CCOtherWrapper ccother =Aspect_JobDataController.getCCforWorkOrder(WO.id);
        List<Aspect_JobDataController.productRequiredWrapper>Prods =  Aspect_JobDataController.updatePrdowrap(prodrec);
        JOb__c jobs  =Aspect_JobDataController.getjobbrecord(Job.id);
        Aspect_JobDataController.workORderLabourWrapper wrapsLabour =   Aspect_JobDataController.getWorkorderforLabourctrl(WO.id);
        Aspect_JobDataController.workOrderWrapper  wkorder = Aspect_JobDataController.getWorkOrderDetailsCtrl(WO.id);
        List<Aspect_JobDataController.productRequiredWrapper>Prods1 =  Aspect_JobDataController.markupChangeMethod(prodrec);
        List<Aspect_JobDataController.productRequiredWrapper>Prods2 =  Aspect_JobDataController.qulaityChangeMethd(prodrec);
        List<Aspect_JobDataController.productRequiredWrapper>Prods3 =  Aspect_JobDataController.checkboxchange(prodrec,'3',true);
        List<Aspect_JobDataController.productRequiredWrapper>Prods4 =  Aspect_JobDataController.checkboxchange(prodrec,'3',false);
        Aspect_JobDataController.CCOtherWrapper ccotherss = Aspect_JobDataController.handloeotherfunction(ccothers);
        List<Aspect_JobDataController.productRequiredWrapper> prodwrapppers = Aspect_JobDataController.getProductRequiredRec(WO.id);
        Aspect_JobDataController.updateSuccess s = Aspect_JobDataController.updateJob(prodrec,wraps,'',ccothers,Job.id,false,trade.id);
        Aspect_JobDataController.updateSuccess s1 = Aspect_JobDataController.updateJob(prodrec,wraps,'',ccothers,Job.id,true,trade.id);
        Map<String,String> mpasRTrade =Aspect_JobDataController.getgroup('');
        Map<String,String> mpasRTrades =Aspect_JobDataController.getWorkType('');
        Aspect_JobDataController.workORderLabourWrapper wrap6 =    Aspect_JobDataController.getworktypechange(wt.id,wraps,WO.id,Job.id);
        String getDescription = Aspect_JobDataController.getCombinedValuefromJob(Job.id);
        Boolean wrap7 =    Aspect_JobDataController.checkOnSize(prodrec);
        Aspect_JobDataController.hr1 =10;
        Aspect_JobDataController.hr2 =10;
        Aspect_JobDataController.hr3 =10;
        Aspect_JobDataController.hr1amount =10;
        Aspect_JobDataController.hr2amount =10;
        Aspect_JobDataController.hr3amount =10;
        Boolean s5=  Aspect_JobDataController.checkUserProfile();
        List<String> s6 =Aspect_JobDataController.getProductRequiredProduct();
        decimal s7 = Aspect_JobDataController.getfixedPriceAdmin(Job.id);
        List<Aspect_JobDataController.productRequiredWrapper> prodWraps = new  List<Aspect_JobDataController.productRequiredWrapper>();
        Aspect_JobDataController.productRequiredWrapper prodWrap = new Aspect_JobDataController.productRequiredWrapper();
        prodWrap.type='Hire';
        prodWraps.add(prodWrap);
        Aspect_JobDataController.workORderLabourWrapper d2= Aspect_JobDataHandler.updateWorkOrder(trade.id,wraps,Job.id,true,true);
        integer intValue = Aspect_JobDataController.getrandomnumber();
        Aspect_JobDataController.deleteproductrequired(prodreq.id);
        Boolean isCheckUser=Aspect_JobDataController.getUserInfo(u.id);
        Aspect_JobDataHandler.createupdateprod('Hire');
        //   String sJob1 = Aspect_JobDataController.getCombinedValuefromJob(job.id);
        Test.stopTest();
    }
}