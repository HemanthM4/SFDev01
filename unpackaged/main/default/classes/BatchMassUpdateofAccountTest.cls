@isTest
public class BatchMassUpdateofAccountTest {
    static testMethod void createAccount() {
        Account acc = new Account();
        acc.Name ='Test';
        acc.Account_Type__c = 'Key Account';
        acc.Client_Alert__c ='Test';
        acc.Client_Alert_1__c ='Test';
        acc.Client_Alert_2__c ='Test';
        insert acc;
        Test.startTest();
        String accQuery = 'SELECT id,Name,Account_Type__c,CreatedDate,OwnerId,Owner.Name,Client_Alert__c,Client_Alert_1__c,Client_Alert_2__c from Account' ;
        BatchMassUpdateofAccount bdt = new BatchMassUpdateofAccount(accQuery);
        dataBase.executeBatch(bdt);
        Test.stopTest();
    }
}