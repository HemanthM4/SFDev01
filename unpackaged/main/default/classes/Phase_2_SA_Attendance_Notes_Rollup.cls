public class Phase_2_SA_Attendance_Notes_Rollup
{

    public Phase_2_SA_Attendance_Notes_Rollup(id wo_id, id job_id){
        wo_rollup(wo_id);
        job_rollup(job_id);
    }

    public void wo_rollup(id wo_id) {
        List<ServiceAppointment> sas = [
            SELECT AppointmentNumber, ActualEndTime, ActualStartTime, Allocated_Engineer_First_Name__c, 
            Allocated_Engineer_Last_Name__c, Attendance_Notes_for_Office__c, Attendance_Report_for_Customer__c
            FROM ServiceAppointment
            WHERE Work_Order__c = :wo_id  
        ];

        WorkOrder wo = [
            SELECT id, Work_Type_Name__c, WorkOrderNumber, Attendance_Notes_for_Office__c, Attendance_Report_for_Customer__c
            FROM WorkOrder
            WHERE id = :wo_id 
        ];

        String wo_office_note = '', wo_customer_note='';
        for (ServiceAppointment sa:sas) {
            try{
                String sa_header = 
                    '\r\n' + sa.ActualStartTime.format('dd/MM/yyyy HH:mm') + ' - '+ sa.ActualEndTime.format('dd/MM/yyyy HH:mm') +
                    '\r\n'+ sa.Allocated_Engineer_First_Name__c+' '+sa.Allocated_Engineer_Last_Name__c+'\r\n';
                wo_office_note += sa_header+sa.Attendance_Notes_for_Office__c+'\r\n' ;
                wo_customer_note += sa_header+ sa.Attendance_Report_for_Customer__c + '\r\n';
            } catch (Exception e) {}
        }
        wo.Attendance_Report_for_Customer__c = wo_customer_note;
        wo.Attendance_Notes_for_Office__c = wo_office_note;
        update wo;
    }

    public void job_rollup(id job_id) {

        List<WorkOrder> wos = [
            SELECT id, Attendance_Notes_for_Office__c, Attendance_Report_for_Customer__c
            FROM WorkOrder
            WHERE Job__c = :job_id
        ];

        String job_office_note = '', job_customer_note='';

        for (WorkOrder wo:wos)
        {
            if(!String.isBlank(wo.Attendance_Notes_for_Office__c)){
	            job_office_note += wo.Attendance_Notes_for_Office__c + '\r\n\r\n';
            }
            if(!String.isBlank(wo.Attendance_Report_for_Customer__c)){
                job_customer_note += wo.Attendance_Report_for_Customer__c + '\r\n\r\n';
            }
        }
        Job__c job = [
            SELECT id, Attendance_Notes_for_Office__c, Attendance_Report_for_Customer__c 
            FROM Job__c 
            WHERE id = :job_id
        ];

        job.Attendance_Notes_for_Office__c = job_office_note;
        job.Attendance_Report_for_Customer__c = job_customer_note;
        update job;
    }


}