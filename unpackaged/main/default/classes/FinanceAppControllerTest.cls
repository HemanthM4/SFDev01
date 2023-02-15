@IsTest
public with sharing class FinanceAppControllerTest {
    @IsTest
    public static void getJobsTest() {
        FinanceAppController.createExportJob('Purchases', Date.today(), Date.today() + 2);
        Test.startTest();
        List<Exchequer_Export_Job__c> jobs = FinanceAppController.getJobs();
        System.assertEquals(1, jobs.size());
        System.assertEquals('Purchases', jobs.get(0).Job_Category__c);
        System.assertEquals(Date.today(), jobs.get(0).Start_Date__c);
        System.assertEquals(Date.today() + 2, jobs.get(0).End_Date__c);
        Test.stopTest();
    }

    @IsTest
    public static void getDataFromDateRangeTest() {
        Test.startTest();
        Map<String, Integer> data = FinanceAppController.getDataFromDateRange('Sales Key',Date.today(), Date.today() + 2);
        System.assertEquals(6, data.size());
        Test.stopTest();
    }

    @IsTest
    public static void getStartDateFromMetadataTest() {
        Test.startTest();
        Date resultDate = FinanceAppController.getStartDateFromMetadata('Purchases');
        Test.stopTest();
    }

    @IsTest
    public static void createExportJobTest() {
        Test.startTest();
        FinanceAppController.createExportJob('Purchases', Date.today(), Date.today() + 2);
        List<Exchequer_Export_Job__c> jobs = [SELECT Id, Name, Job_Category__c, Status__c, User__r.Name, Completed__c, Submitted__c, Start_Date__c, End_Date__c FROM Exchequer_Export_Job__c];
        System.assertEquals(1, jobs.size());
        System.assertEquals('Purchases', jobs.get(0).Job_Category__c);
        System.assertEquals(Date.today(), jobs.get(0).Start_Date__c);
        System.assertEquals(Date.today() + 2, jobs.get(0).End_Date__c);
        Test.stopTest();
    }

    @IsTest
    public static void updateMetadataDateTest() {
        Test.startTest();
        FinanceAppController.updateMetadataDate(Date.today(), 'Purchases');
        Test.stopTest();
    }

    @IsTest
    public static void handleResultTest() {
        FinanceAppController metadata = new FinanceAppController();
        Test.startTest();
        metadata.handleResult(new Metadata.DeployResult(), new Metadata.DeployCallbackContext());
        Test.stopTest();
    }
}