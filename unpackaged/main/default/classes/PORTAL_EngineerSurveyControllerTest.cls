@IsTest
private class PORTAL_EngineerSurveyControllerTest {

    @TestSetup
    private static void setup() {
        UserRole adminRole = [SELECT Id FROM UserRole WHERE Name = 'root'];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User adminUser = new User(
                Alias = 'admin',
                Email = 'testcommunityadmin@gmail.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'AdminLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_GB',
                ProfileId = adminProfile.Id,
                TimeZoneSidKey = 'Europe/London',
                Username = 'testcommunityadmin@gmail.com',
                UserRoleId = adminRole.Id
        );
        insert adminUser;

        System.runAs(adminUser) {
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Engineer Partner Community'];

            Account acc = new Account();
            acc.Name = 'TestAccountName';
            acc.Account_Type__c = 'Cash';
            acc.Account_Status__c = 'Open';
            insert acc;

            Contact testContact = new Contact();
            testContact.LastName = 'TestContactLastName';
            testContact.AccountId = acc.Id;
            insert testContact;

            User communityUser = new User(
                    ContactId = testContact.Id,
                    Alias = 'srUser',
                    Email = 'testSRcommunity@gmail.com',
                    EmailEncodingKey = 'UTF-8',
                    FirstName = 'UserFirstName',
                    LastName = 'UserLastName',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_GB',
                    ProfileId = communityProfile.Id,
                    TimeZoneSidKey = 'Europe/London',
                    Username = 'testcommunitysr@gmail.com',
                    IsActive = true
            );
            insert communityUser;

            ServiceResource serviceResourceForCommunityUser = new ServiceResource(
                    Name = 'SRName',
                    FirstName__c = 'SRFirstName',
                    LastName__c = 'SRLastName',
                    IsActive = true,
                    RelatedRecordId = communityUser.Id,
                    ResourceType = 'T',
                    Engineer_Role__c = 'Service_Resource');
            insert serviceResourceForCommunityUser;
        }
    }

    @IsTest
    static void getServiceResourceWithFirstNameTest() {
        User srUser = [SELECT Id, FirstName, IsActive FROM User WHERE Username = 'testcommunitysr@gmail.com'];

        System.runAs(srUser) {
            Test.startTest();
            System.assertEquals('SRFirstName', PORTAL_EngineerSurveyController.getServiceResourceFirstName());
            Test.stopTest();
        }
    }

    @IsTest
    static void getServiceResourceWithoutFirstNameTest() {
        User srUser = [SELECT Id, FirstName, IsActive FROM User WHERE Username = 'testcommunitysr@gmail.com'];
        ServiceResource sr = [SELECT Id, FirstName__c FROM ServiceResource WHERE Name = 'SRName'];
        sr.FirstName__c = null;
        update sr;

        System.runAs(srUser) {
            Test.startTest();
            System.assertEquals('SRName', PORTAL_EngineerSurveyController.getServiceResourceFirstName());
            Test.stopTest();
        }
    }

    @IsTest
    static void getServiceResourceNameWithoutSRTest() {
        User adminWithoutSR = [SELECT Id, FirstName, Name FROM User WHERE Alias = 'admin'];

        System.runAs(adminWithoutSR) {
            Test.startTest();
            System.assertEquals('Guest User', PORTAL_EngineerSurveyController.getServiceResourceFirstName());
            Test.stopTest();
        }
    }

    @IsTest
    static void isServiceResourceOlderThan30DaysTest() {
        User srUser = [SELECT Id, FirstName, IsActive FROM User WHERE Username = 'testcommunitysr@gmail.com'];

        System.runAs(srUser) {
            Test.startTest();
            System.assertEquals(false, PORTAL_EngineerSurveyController.isServiceResourceOlderThan30Days());
            Test.stopTest();
        }
    }

    @IsTest
    static void getSurveyRecordFromThisMonthTest() {
        User srUser = [SELECT Id, FirstName, IsActive FROM User WHERE Alias = 'srUser'];
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :srUser.Id];
        Survey_Form__c newSurveyForm = new Survey_Form__c(
                Service_Resource__c = sr.Id
        );
        insert newSurveyForm;

        System.runAs(srUser) {
            Test.startTest();
            PORTAL_EngineerSurveyController.getSurveyRecordFromThisMonth();
            Test.stopTest();
        }
        List<Survey_Form__c> surveyForm = [SELECT Id FROM Survey_Form__c];
        System.assertEquals(1, surveyForm.size());
    }

    @IsTest
    static void insertSurveyTest() {
        User srUser = [
                SELECT Id,FirstName, IsActive, (SELECT Id FROM ServiceResources)
                FROM User
                WHERE Alias = 'srUser'
        ];

        System.runAs(srUser) {
            Survey_Form__c newSurveyForm = new Survey_Form__c(
                    Service_Resource__c = srUser.ServiceResources[0].Id, Vehicle__c = 50, Uniform__c = 100,
                    Plant_Hire__c = 0, Shift_Patterns__c = 100, Rates_of_Pay__c = 100,
                    Ease_of_Field_Service_App__c = 50, Quality_of_Leads__c = 100, Quantity_Volume_of_Leads__c = 50,
                    Travel_Time_Distance__c = 100, Overall_Earnings__c = 100, Office_Admin_Support__c = 50,
                    Technical_Manager_Support__c = 100, Access_to_Records_Community_Portal__c = 50,
                    Crystal_Tax_Umbrella_Company__c = 50, Work_Life_Balance__c = 100, Working_for_Aspect__c = 100
            );
            Test.startTest();
            PORTAL_EngineerSurveyController.insertSurvey(newSurveyForm);
            Test.stopTest();

            Survey_Form__c updatedSurveyForm = [
                    SELECT Vehicle__c, Uniform__c, Ease_of_Field_Service_App__c,Plant_Hire__c, Shift_Patterns__c,
                            Quantity_Volume_of_Leads__c, Office_Admin_Support__c,Working_for_Aspect__c
                    FROM Survey_Form__c
            ];
            System.assertEquals(50, updatedSurveyForm.Vehicle__c);
            System.assertEquals(100, updatedSurveyForm.Uniform__c);
            System.assertEquals(50, updatedSurveyForm.Ease_of_Field_Service_App__c);
            System.assertEquals(0, updatedSurveyForm.Plant_Hire__c);
            System.assertEquals(100, updatedSurveyForm.Shift_Patterns__c);
            System.assertEquals(50, updatedSurveyForm.Quantity_Volume_of_Leads__c);
            System.assertEquals(50, updatedSurveyForm.Office_Admin_Support__c);
            System.assertEquals(100, updatedSurveyForm.Working_for_Aspect__c);
        }
    }
}