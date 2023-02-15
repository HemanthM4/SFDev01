public without Sharing class PORTAL_WorkOrderSearchController {
    @auraEnabled
    public Static List<Account> searchRecordsId(String nameSearch){

        List<Account> workOrder = [SELECT Id, Name,BillingPostalCode  FROM Account where Id =:nameSearch];
        return workOrder;
    }
    @auraEnabled
    public Static List<ServiceAppointment> searchRecords(String nameSearch){
        Id usrid = UserInfo.getUserId();
        String Searchname  = '';
        String SearchPostcode = '';
        System.debug('nameSearch'+nameSearch);
        Searchname ='\'%'+nameSearch+'%\'';
        SearchPostcode  ='\'%'+nameSearch+'%\'';
        String userid  ='\''+usrid+'\'';
        String query = '';
        query += '(Account.Name like  '+Searchname;
        query += ' OR Account.BillingPostalCode like '+SearchPostcode+')';
        query += ' AND Allocated_Engineer__r.RelatedRecordId = '+userid;
       String strQueAy = ' SELECT Id,Account.BillingPostalCode,AccountId,Account.Name  FROM ServiceAppointment where '+ query ;
        List<ServiceAppointment> workOrder = database.query(strQueAy);
        return workOrder;
    }
    
    
}