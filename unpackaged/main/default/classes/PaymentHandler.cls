public without sharing class PaymentHandler  extends BaseTriggerHandler {
    // override public void beforeInsert () {
        //... your code here
        // setTimeFromScheduledDateTime((List<WorkOrder>)Trigger.new);
    //}

    // override public void beforeUpdate () {
        //... your code here
    // }

    //override public void beforeDelete () {
        //... your code here
    //}

    override public void afterInsert () {
        callBatchSendPayments();
    }

    //override public void afterUpdate () {
        //... your code here
    //}

    //override public void afterDelete () {
        //... your code here
    //}

    //override public void afterUnDelete () {
        //... your code here
    //}
    
    /**
     *  For payment record which have been created, we need to submit the payment
     *  
     *  
     *
     */
    // @future
    @TestVisible static void callBatchSendPayments() {
        asp04.BatchSendPayments bsp = new asp04.BatchSendPayments(); 
		bsp.execute(null);
    }
}