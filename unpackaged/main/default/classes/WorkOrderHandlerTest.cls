/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2018-11-26 13:07:52 
 *	@description:
 *	    Test methods for WorkOrderHandler
 *	
 *	Version History :   
 *		
 */
@isTest(isParallel=true)
public class WorkOrderHandlerTest  {
    final static String WorkOrder_KEY_PREFIX = Schema.SObjectType.WorkOrder.getKeyPrefix();
    final static String WorkOrder_ID_1 = WorkOrder_KEY_PREFIX + '000000000001';
    /**
     *  3. "Date' & 'Time' fields on the Work Order should be populated based on the following fields
     *  - 1.Date - Date from Scheduled/DateTime 
     *  - 2.Time - Time from Scheduled/DateTime (10.03) - should be 10 am" 
     *
     */
    @isTest
    static void testSetTimeFromScheduledDateTime () {
        final List<WorkOrder> orders = new List<WorkOrder>{
            new WorkOrder(Scheduled_Date_Time__c = null),
            new WorkOrder(Scheduled_Date_Time__c = DateTime.newInstance(2018, 11, 26, 1, 2, 3))
        };
        WorkOrderHandler handler = new WorkOrderHandler();
        handler.setTimeFromScheduledDateTime(orders);
        System.assertEquals(null, orders[0].Date__c, 'did not expect value to be set');
        System.assertEquals(null, orders[0].Time__c, 'did not expect value to be set');

        System.assertNotEquals(null, orders[1].Date__c, 'expected value to be set');
        System.assertEquals('1AM', orders[1].Time__c, 'did not expect value to be set');

        // code coverage for places without logic
        // force trigger handler to get called
        try { Database.insert(new WorkOrder(), false); } catch (Exception eIgnore){}
    }
}