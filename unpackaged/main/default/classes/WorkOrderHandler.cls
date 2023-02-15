public without sharing class WorkOrderHandler extends BaseTriggerHandler {
    override public void beforeInsert () {
        //... your code here
        setTimeFromScheduledDateTime((List<WorkOrder>)Trigger.new);
    }

    override public void beforeUpdate () {
        setTimeFromScheduledDateTime((List<WorkOrder>)Trigger.new);
    }

    //override public void beforeDelete () {
        //... your code here
    //}

    //override public void afterInsert () {
    //    //... your code here
    //}

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
     *  3. "Date' & 'Time' fields on the Work Order should be populated based on the following fields
     *  - 1.Date - Date from Scheduled/DateTime 
     *  - 2.Time - Time from Scheduled/DateTime (10.03) - should be 10 am" 
     *
     */
    @TestVisible void setTimeFromScheduledDateTime(final List<WorkOrder> newList) {
        if (hasSkipReason('setTimeFromScheduledDateTime')) {
            return;
        }

        BaseTriggerHandler.addSkipReason('setTimeFromScheduledDateTime', 'no reason to visit thos method second time');
        for(WorkOrder wo : newList) {
            if (null != wo.Scheduled_Date_Time__c) {
                wo.Date__c =  wo.Scheduled_Date_Time__c.date();
                Integer hour = wo.Scheduled_Date_Time__c.hour();
                wo.Time__c = hoursToAmPm(hour);
            }
        }
    }
    public static String hoursToAmPm(final Integer hour) {
        final String timeStr = hour < 12 ? hour + 'AM' : hour > 12 ? (hour - 12) + 'PM' : '12PM';
        return '0AM' == timeStr ? '12AM' : timeStr;
    }
}