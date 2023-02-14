trigger ServiceAppointmentTrigger on ServiceAppointment (before insert,after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            serviceApointmentHandlerException exClass = new serviceApointmentHandlerException();
            exClass.checkServiceAppointmentsOnInsert(Trigger.new);
        }
    }
    
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {

            for(ServiceAppointment sa:Trigger.new) {
                if (
                    Trigger.NewMap.get(sa.ID).Attendance_Notes_for_Office__c
                    !=
                    Trigger.OldMap.get(sa.ID).Attendance_Notes_for_Office__c
                    ||
                    Trigger.NewMap.get(sa.ID).Attendance_Report_for_Customer__c
                    !=
                    Trigger.OldMap.get(sa.ID).Attendance_Report_for_Customer__c
                )
                {
                  //check if WO and Job Are Null
                  if(sa.Work_Order__c!=null && sa.Job_record_ID__c!=null){
                    Phase_2_SA_Attendance_Notes_Rollup tmp = new Phase_2_SA_Attendance_Notes_Rollup(sa.Work_Order__c, sa.Job_record_ID__c);
                }

            }

        }

    }
}
}