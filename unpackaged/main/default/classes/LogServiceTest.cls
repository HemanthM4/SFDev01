/**
 * @author      Andrey Gorun
 * @version     1.0
 */

@isTest
private class LogServiceTest {
    @isTest
    static void testPositive() { 
        LogService log = new LogService();
    /*    LogService.Log newLog = LogService.createLog();
        newLog.addError('Test error message');
        try {
            Integer a = 1/0;
        }
        catch (Exception e) {
            newLog.addError(e);
        }

        newLog.save();
        List<Error_Log__c> logs = [SELECT Id, Error_Message__c FROM Error_Log__c];
        Boolean isErrorDivideBy013 = logs.get(0).Error_Message__c.contains('Divide by 013');
        System.assertEquals(1, logs.size());
        System.assertEquals(true, isErrorDivideBy013);*/
    }
}