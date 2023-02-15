/**
 * @author      Andrey Gorun
 * @version     1.0
 */

@isTest
public class TestDataFactory {
    public final static Map<String,Schema.RecordTypeInfo> workOrderRecordTypes = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName();

    public static List<Account> createAccounts(Integer numberAccounts) {
        Id defaultRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Payment_Provider').getRecordTypeId();
        return createAccounts(numberAccounts, defaultRecordTypeId);
    }
    public static List<Account> createAccounts(Integer numberAccounts, Id recordTypeId) {
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < numberAccounts; i++) {
            Account acc = new Account (
                Name = 'TestAccount' + i,
                RecordTypeId = recordTypeId,
                Account_Type__c = 'Cash',
                Email__c = 'testAccountEmail' + i + '@email.test',
                Account_Status__c = 'Open',
                BillingPostalCode = 'NW1 3HG',
                BillingStreet = '4 Triton Square, , LONDON,',
                BillingCity = 'London',
                BillingCountry = 'United Kingdom',
                Last_Name__c = 'Last Name'
                //Is_Provider_a_Franchisee__c = 'No'
            );
            accounts.add(acc);
        }
        return accounts;
    }

  /*  public static List<Payment_Batch__c> createPaymentBatches(Integer numberPaymentBatches) {
        List<Payment_Batch__c> paymentBatches = new List<Payment_Batch__c>();

        for (Integer i = 0; i < numberPaymentBatches; i++) {
            Payment_Batch__c paymentBatch = new Payment_Batch__c (
                Description__c = 'TestPaymentBatch' + i,
                Payment_Run_From_Date__c = System.Date.today().addMonths(-1),
                Payment_Run_To_Date__c = System.Date.today()
            );
            paymentBatches.add(paymentBatch);
        }
        return paymentBatches;
    }
 */

    public static List<ServiceResource> createServiceResources(List<User> users) {
        List<ServiceResource> serviceResources = new List<ServiceResource>();

        for (Integer i = 0; i < users.size(); i++) {
            ServiceResource serviceResource = new ServiceResource (
                Name = 'TestServiceResource' + i,
                RelatedRecordId = users.get(i).Id,
                isActive = true,
                Engineer_Role__c = 'Service_Resource',
                Visitour_Engineer_ID__c = '123',
                Email__c = 'blahblah@test.com',
                Mobile_No__c = '7876567849'
            );
            serviceResources.add(serviceResource);
        }
        return serviceResources;
    }

    public  static List<User> createUsers(String profileName, Integer numberUsers) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        List<User> users = new List<User>();

        for (Integer i = 0; i < numberUsers; i++) {
            User usr = new User (
                ProfileId = profileId,
                LastName = 'TestUser' + i,
                Email = 'TestUser' + i + '@testoism.com',
                Username = 'TestUser' + i + '@testoism.com',
                CompanyName = 'TestCompany',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            users.add(usr);
        }
        return users;
    }

    public  static User createUser(String profileName, String userName) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        User usr = new User (
                ProfileId = profileId,
                LastName = userName,
                Email = userName + '@testoism.com',
                Username = userName + '@testoism.com',
                CompanyName = 'TestCompany',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
        return usr;
    }


    public static List<Deduction__c> createEngineerDeductions(Integer numberEngineerDeductions, ServiceResource serviceResourceEngineer) {
        List<Deduction__c> engineerDeductions = new List<Deduction__c>();

        for (Integer i = 0; i < numberEngineerDeductions; i++) {
            Deduction__c engineerDeduction = new Deduction__c (Service_Resource__c= serviceResourceEngineer.Id, Amount__c=150, Deduction_Type__c='MV Repair Deduction'
            );
            engineerDeductions.add(engineerDeduction);
        }
        return engineerDeductions;
    }
    
    public static List<WorkType> createWorkTypes(Integer numberWorkTypes) {
      List<WorkType> lstworkTypes = new List<WorkType>();
        WorkType workType = new WorkType (
           // Trade__c = 'Plumbing',
            Name = 'Test Plumbing',
            RecordTypeId = Schema.SObjectType.WorkType.getRecordTypeInfosByDeveloperName().get('Reactive').getRecordTypeId(),
            DurationType = 'Hours',
            EstimatedDuration = 2.00
        );
        lstworkTypes.add(workType);
        return lstworkTypes;
    }
    
    public static Site__c createSite(Account acc){
      Region_Area__c regionArea = new Region_Area__c (
            Region_Area_Code__c = 'aa2a'
        );
        insert regionArea;
        Site__c site = new Site__c (
            Site_PostalCode__c = 'aa2a 2aa',//a-zA-Z]{2}\\d[a-zA-Z]\\s\\d[a-zA-Z]{2}"),
            Region_Area__c = regionArea.Id,
            //RecordTypeId = Schema.SObjectType.Site__c.getRecordTypeInfosByDeveloperName().get(acc.RecordType.DeveloperName).getRecordTypeId(),
            RecordTypeId = Schema.SObjectType.Site__c.getRecordTypeInfosByDeveloperName().get('Domestic').getRecordTypeId(),
            Account__c = acc.Id,
            SiteGeo_Longitude__c = 1212335,
            SiteGeo_Latitude__c = 5675346
        );
        return site;
    }
    
    public static List<WorkOrder> createWorkorders(Integer numberWorkOrders, Site__c site, WorkType wt) {
      List<WorkOrder> workOrders = new List<WorkOrder>();
      for (Integer i = 0; i < numberWorkOrders; i++) {
            WorkOrder workOrder = new WorkOrder (
         //       Client_Status__c = 'New',
                Status = 'New',
                RecordTypeId = workOrderRecordTypes.get('Reactive').getRecordTypeId(),
                //Contact_Email__c = 'testAccountEmailWork@email.test',
                Site__c = site.Id,
                Time__c = '8AM',
                WorkTypeId = wt.Id
            );
            workOrders.add(workOrder);
        }
        return workOrders;
    }

    public static List<WorkOrder> createWorkorders(Integer numberWorkOrders) {
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
        
        WorkType workType = new WorkType (
            //Trade__c = 'Air Conditioning',
           // Group__c = 'Air Conditioning Ducted Systems',
            Name = 'Air Conditioning Ducted Systems ; Installation',
            // RecordTypeId = Schema.SObjectType.WorkType.getRecordTypeInfosByDeveloperName().get('Reactive').getRecordTypeId(),
            DurationType = 'Hours',
            EstimatedDuration = 2.00
        );
        insert workType;
        List<WorkOrder> workOrders = new List<WorkOrder>();

        for (Integer i = 0; i < numberWorkOrders; i++) {
            WorkOrder workOrder = new WorkOrder (
                AccountId = acc.Id,
//                Client_Status__c = 'New',
                Status = 'New',
                RecordTypeId = workOrderRecordTypes.get('Reactive').getRecordTypeId(),
                //Contact_Email__c = 'testAccountEmailWork@email.test',
                Site__c = site.Id,
                Time__c = '8AM',
                WorkTypeId = workType.Id
                //ContactId = primContact.Id
            );
            workOrders.add(workOrder);
        }
        return workOrders;
    }
    
    public static List<WorkOrder> createWorkordersFixedPrice(Integer numberWorkOrders, Site__c site, WorkType wt) {
      List<WorkOrder> workOrders = new List<WorkOrder>();
      for (Integer i = 0; i < numberWorkOrders; i++) {
            WorkOrder workOrder = new WorkOrder (
                    AccountId = Site.Account__c,
                 //   Client_Status__c = 'New',
                    Status = 'New',
                    RecordTypeId = workOrderRecordTypes.get('Fixed_Price').getRecordTypeId(),
                    //Contact_Email__c = 'testAccountEmailWork@email.test',
                    Site__c = site.Id,
                    Time__c = '8AM',
                    StartDate = system.now().addDays(1),
                    EndDate = system.now().addDays(3),
                  WorkTypeId = wt.Id
            );
            workOrders.add(workOrder);
        }
        return workOrders;
    }

    public static List<WorkOrder> createWorkordersFixedPrice(Integer numberWorkOrders) {
        Account acc = new Account (
                Name = 'TestAccountWorkOrderFixed',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial').getRecordTypeId(),
                Account_Type__c = 'Credit',
                Account_Status__c = 'Open',
                Email__c = 'testAccountEmailWorkFixed@email.test',
                BillingPostalCode = 'NW1 3HG',
                BillingStreet = '4 Triton Square, , LONDON,',
                BillingCity = 'London',
                BillingCountry = 'United Kingdom',
                Last_Name__c = 'Last Name 123'
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



        Site__c site = new Site__c (
                Site_PostalCode__c = 'aa2a 2aa',//a-zA-Z]{2}\\d[a-zA-Z]\\s\\d[a-zA-Z]{2}"),
                Region_Area__c = regionArea.Id,
                RecordTypeId = Schema.SObjectType.Site__c.getRecordTypeInfosByDeveloperName().get('Commercial').getRecordTypeId(),
                Account__c = acc.Id,
                Primary_Site_Contact__c = primContact.id,
                SiteGeo_Longitude__c = 1212335,
                SiteGeo_Latitude__c = 5675346
        );
        insert site;
         WorkType workType = new WorkType (
           // Trade__c = 'Plumbing',
            Name = 'Test Plumbing',
            // RecordTypeId = Schema.SObjectType.WorkType.getRecordTypeInfosByDeveloperName().get('Reactive').getRecordTypeId(),
            DurationType = 'Hours',
            EstimatedDuration = 2.00
        );
        insert workType;
        List<WorkOrder> workOrders = new List<WorkOrder>();

        for (Integer i = 0; i < numberWorkOrders; i++) {
            WorkOrder workOrder = new WorkOrder (
                    AccountId = acc.Id,
                  //  Client_Status__c = 'New',
                    Status = 'New',
                    RecordTypeId = workOrderRecordTypes.get('Fixed_Price').getRecordTypeId(),
                    //Contact_Email__c = 'testAccountEmailWork@email.test',
                    Site__c = site.Id,
                    Time__c = '8AM',
                    StartDate = system.now().addDays(1),
                    EndDate = system.now().addDays(3),
                  WorkTypeId = workType.Id
            );
            workOrders.add(workOrder);
        }
        return workOrders;
    }

    public static List<ServiceAppointment> createServiceAppointments(Integer numberServiceAppointments) {
        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();
        
        //Site__c site = createSite(createAccounts(1).get(0));
//        WorkOrder wo = createWorkordersFixedPrice(1).get(0);

        for (Integer i = 0; i < numberServiceAppointments; i++) {
            ServiceAppointment serviceAppointment = new ServiceAppointment (
                    Visitour_ID__c = '10000' + i,
                    EarliestStartTime = System.now().addMonths(-1),
                    DueDate = System.now().addMonths(1),
                    Status = 'Scheduled',
                    SchedStartTime = System.now().addDays(-1),
                    SchedEndTime = System.now().addDays(1)
//                  ParentRecordId = wo.Id
            );
            serviceAppointments.add(serviceAppointment);
        }
        return serviceAppointments;
    }

    public static AssignedResource createAssignedResource(Id serviceAppointmentId, Id serviceResourceId) {
        return new AssignedResource (
            ServiceAppointmentId = serviceAppointmentId,
            ServiceResourceId = serviceResourceId
        );
    }

    public static List<ServiceTerritory> createServiceTerritories(Integer numberServiceTerritories) {
        List<ServiceTerritory> serviceTerritories = new List<ServiceTerritory>();

        for (Integer i = 0; i < numberServiceTerritories; i++) {
            ServiceTerritory serviceTerritory = new ServiceTerritory (
                Name = 'TestServiceTerritory' + i,
                IsActive = true

            );
            serviceTerritories.add(serviceTerritory);
        }
        return serviceTerritories;
    }

    public static List<OperatingHours> createOperatingHours(Integer numberOperatingHour) {
        List<OperatingHours> serviceOperatingHours = new List<OperatingHours>();

        for (Integer i = 0; i < numberOperatingHour; i++) {
            OperatingHours serviceOperatingHour = new OperatingHours (
                    Name = 'TestOperatingHours' + i
            );
            serviceOperatingHours.add(serviceOperatingHour);
        }
        return serviceOperatingHours;
    }

    public static ServiceTerritoryMember createTerritoryMember(Id serviceResourceId, Id serviceTerritoryId) {
        return new ServiceTerritoryMember (
            //TerritoryType = 'Primary',
            ServiceResourceId = serviceResourceId,
            ServiceTerritoryId = serviceTerritoryId,
            EffectiveStartDate = System.now().addMonths(-1)
        );
    }
    
    public static asp04__Authorisation__c createAuthorisation(Id AccountId, Date expiryDate, String status, string description){
      asp04__Authorisation__c auth = new asp04__Authorisation__c(
                        Customer__c = accountId, 
                        asp04__Expiry_Date__c = expiryDate, 
                        asp04__Status__c = status, 
                        asp04__Status_Description__c = description);
      insert auth;
      return auth;
    }
}