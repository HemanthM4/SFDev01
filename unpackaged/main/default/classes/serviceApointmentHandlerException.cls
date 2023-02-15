public class serviceApointmentHandlerException extends Exception{
    public void checkServiceAppointmentsOnInsert(list<ServiceAppointment> serviceAppList){
        
        List<Id> wolist = new list<Id>();
        Map<Id,Integer> woSACountMap = new Map<Id,Integer>();
        for(ServiceAppointment sa : serviceAppList){
            wolist.add(sa.ParentRecordId);
        }
        
        for(ServiceAppointment sarec : [select id,ParentRecordId,ParentRecord.RecordType.name from ServiceAppointment where ParentRecordId in: wolist]){
        if(sarec.ParentRecord.RecordType.name == 'Reactive'){
                if(woSACountMap.containsKey(sarec.ParentRecordId)){
                Integer count = woSACountMap.get(sarec.ParentRecordId);
                    woSACountMap.put(sarec.ParentRecordId,count+1);
                }else{
                    woSACountMap.put(sarec.ParentRecordId,1);
                }
            }
        }
        
        for(ServiceAppointment sa : serviceAppList){
            
            if(woSACountMap.containsKey(sa.ParentRecordId)){
                sa.addError( new serviceApointmentHandlerException('Only one ServiceAppointment can be created for a reactive job'));
            }
        }
        
        
    }
    
}