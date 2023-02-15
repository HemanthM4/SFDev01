@isTest
private class PurchaseOrderLineItemDeleteTest {
    
    @isTest
    private static void PurchaseOrderLineItemDeleteTest() {
        Account acc = new Account (
            Name = 'TestAccountWorkOrder '+String.valueOf(Math.round((Math.random() * (900000) + 100000))),
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial').getRecordTypeId(),
            Account_Type__c = 'Cash',
            Account_Status__c = 'Open',
            Email__c = 'testAccountEmailWork@email.test',
            BillingPostalCode = 'NW1 3HG',
            BillingStreet = '4 Triton Square',
            BillingCity = 'London',
            BillingCountry = 'United Kingdom',
            Last_Name__c = 'Last Name'
    );
    insert acc;
    Region_Area__c regionArea = new Region_Area__c (
        Region_Area_Code__c = 'aa2a'
    );
    insert regionArea;
    
    Contact primContact = new Contact(
    LastName='LastName',
        Account  = acc
        );
    insert primContact;
    /*[Select Id
                           From Contact
                           Where AccountId = :acc.Id];
    //record type should be created by builder process alread*/
    Site__c site = new Site__c (
        Site_PostalCode__c = 'aa2a 2aa',//a-zA-Z]{2}\\d[a-zA-Z]\\s\\d[a-zA-Z]{2}"),
        Region_Area__c = regionArea.Id,
        RecordTypeId = Schema.SObjectType.Site__c.getRecordTypeInfosByDeveloperName().get('Commercial').getRecordTypeId(),
        Account__c = acc.Id,
        SiteGeo_Longitude__c = 1212335,
        SiteGeo_Latitude__c = 5675346,
        Primary_Site_Contact__c = primContact.id
    );
    insert site;/*
    Site__c site = [Select Id
                    From Site__c
                    Where Account__c = :acc.Id];*/
    String wt_trade = (WorkType.Trade__c.getDescribe().getPicklistValues())[0].getLabel();

                    
    WorkType workType = new WorkType (
        Trade__c = wt_trade,
        Name = 'tmp',
        DurationType = 'Hours',
        EstimatedDuration = 2.00
    );
    insert workType;
    
    
        WorkOrder wo = new WorkOrder (
            AccountId = acc.Id,
//                Client_Status__c = 'New',
            Status = 'New',
            RecordTypeId = OnlineBookingProcessHelper.getRecordTypeIdbyName('WorkOrder','Reactive'),
            //Contact_Email__c = 'testAccountEmailWork@email.test',
            Site__c = site.Id,
            Time__c = '8AM',
            WorkTypeId = workType.Id
        );
        insert wo;
        Purchase_Order__c po = new Purchase_Order__c(
            Work_Order__c = wo.id
            //Supplier_Invoice__c = inv.id
        );
        insert po;
        Purchase_Order_Line_Item__c li = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.id
        );
        insert li;
        Test.startTest();
        delete li;
        Test.stopTest();        
    }
}