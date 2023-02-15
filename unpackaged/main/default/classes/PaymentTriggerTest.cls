/**
 *	@author: Navin Muneesamy (Westbrook)
 *	@date: 2019-03-04 18:05:00 
 *	@description:
 *	    Test methods for PaymentHandler
 *	
 *	Version History :   
 *		V1.0: Initial Version
 */
@isTest(isParallel=true)
public class PaymentTriggerTest {
    @isTest
    static void testSetTimeFromScheduledDateTime () {
        insert new asp04__AsperatoOneSettings__c(asp04__Customer_ID__c = '1');
        final List<asp04__Payment__c> paymentList = new List<asp04__Payment__c>{
            new asp04__Payment__c(asp04__Last_Name__c='Doe', asp04__Amount__c = 300, asp04__Payment_Route_Selected__c = 'Cash'),
            new asp04__Payment__c(asp04__Last_Name__c='Smith', asp04__Amount__c = 100, asp04__Payment_Route_Selected__c = 'Cash')
        }; 
        System.Test.startTest();
        insert paymentList;
        System.Test.stopTest();
        List<asp04__Payment__c> paymentResultList = [Select asp04__Payment_Stage_Description__c from asp04__Payment__c];
        System.assertEquals(null, paymentResultList[0].asp04__Payment_Stage_Description__c);
        


        // disabled as intrerfering with new payment menthod and the assertions above are not ones we cannot already confirm.
        // N.B. Need to either remove this entirely or add suitable test method.

    }

}