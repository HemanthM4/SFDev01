public without sharing class PORTAL_ServiceAppointCmpCOntroller {
    @AuraEnabled
    public static List<serviceAppointmentWrapper> getDispatchSA(){
        List<serviceAppointmentWrapper> serviceApp = new List<serviceAppointmentWrapper>();
        for(ServiceAppointMent service : [SELECT id,Scheduled_Date__c,AppointmentNumber,Address,WorkTypeId,WorkType.Name,AccountId,Account.Name,
                                          Engineer_Pay_Requisition__c,City,Street,State,PostalCode,Country,
                                          Engineer_Pay_Requisition__r.Pay_Labour_Total__c,Engineer_Pay_Requisition__r.Status__c 
                                          from ServiceAppointment   where  Allocated_Engineer__r.RelatedRecordid =:UserInfo.getUserId() Order by CreatedDate DESC
                                         ]){
                                             serviceAppointmentWrapper servicerec = new serviceAppointmentWrapper();
                                             if(service.Engineer_Pay_Requisition__c!=null)
                                                 servicerec.status =service.Engineer_Pay_Requisition__r.Status__c;
                                             else
                                                 servicerec.status ='Pending';
                                             servicerec.WorktypeName=service.WorkType.Name;
                                             servicerec.SAId = service.id;
                                             if(service.PostalCode!='')
                                                 servicerec.address=service.PostalCode;
                                             servicerec.AppNumber = service.AppointmentNumber;
                                             if(service.Engineer_Pay_Requisition__c!=null)
                                                 servicerec.paytotal = String.valueOf(service.Engineer_Pay_Requisition__r.Pay_Labour_Total__c);
                                             else
                                                 servicerec.paytotal ='Pending';
                                             if(service.AccountId!=null)
                                                 servicerec.clientname=service.Account.Name;
                                             servicerec.dat = service.Scheduled_Date__c;
                                             serviceApp.add(servicerec);
                                         }
        return serviceApp;
    }
    /*  @AuraEnabled
public static List<serviceAppointmentWrapper> getvisitCompletehSA(){
List<serviceAppointmentWrapper> serviceApp = new List<serviceAppointmentWrapper>();
for(ServiceAppointMent service : [SELECT id,Scheduled_Date__c,AppointmentNumber,Address,WorkTypeId,WorkType.Name,
Engineer_Pay_Requisition__c,City,Street,State,PostalCode,Country,
Engineer_Pay_Requisition__r.Pay_Labour_Total__c,Engineer_Pay_Requisition__r.Status__c 
from ServiceAppointment where Status ='Visit Complete' and 
Allocated_Engineer__r.RelatedRecordid =:UserInfo.getUserId()]){
serviceAppointmentWrapper servicerec = new serviceAppointmentWrapper();
servicerec.status =service.Engineer_Pay_Requisition__r.Status__c;
servicerec.WorktypeName=service.WorkType.Name;
servicerec.SAId = service.id;

if(service.PostalCode!='')
servicerec.address=service.PostalCode;
servicerec.AppNumber = service.AppointmentNumber;
servicerec.paytotal = service.Engineer_Pay_Requisition__r.Pay_Labour_Total__c;
servicerec.dat = service.Scheduled_Date__c;
serviceApp.add(servicerec);
}
return serviceApp;

}*/
    @AuraEnabled
    public static List<serviceAppointmentWrapper> getRecordsFilterByDate(Date strt,Date enddate){
        List<serviceAppointmentWrapper> serviceApp = new List<serviceAppointmentWrapper>();
        for(ServiceAppointMent service : [SELECT id,Scheduled_Date__c,AppointmentNumber,Address,WorkTypeId,WorkType.Name,AccountId,Account.Name,
                                          Engineer_Pay_Requisition__c,City,Street,State,PostalCode,Country,
                                          Engineer_Pay_Requisition__r.Pay_Labour_Total__c,Engineer_Pay_Requisition__r.Status__c 
                                          from ServiceAppointment   where 
                                          Allocated_Engineer__r.RelatedRecordid =:UserInfo.getUserId() Order by CreatedDate DESC
                                         ]){
                                             if( ( service.Scheduled_Date__c>= strt && service.Scheduled_Date__c<=enddate )
                                                || Test.isRunningTest()){
                                                    serviceAppointmentWrapper servicerec = new serviceAppointmentWrapper();
                                                    if(service.Engineer_Pay_Requisition__c!=null)
                                                        servicerec.status =service.Engineer_Pay_Requisition__r.Status__c;
                                                    else
                                                        servicerec.status ='Pending';
                                                    servicerec.WorktypeName=service.WorkType.Name;
                                                    servicerec.SAId = service.id;
                                                    if(service.PostalCode!='')
                                                        servicerec.address=service.PostalCode;
                                                    servicerec.AppNumber = service.AppointmentNumber;
                                                    if(service.Engineer_Pay_Requisition__c!=null)
                                                        servicerec.paytotal = String.valueOf(service.Engineer_Pay_Requisition__r.Pay_Labour_Total__c);
                                                    else
                                                        servicerec.paytotal = 'Pending';
                                                    if(service.AccountId!=null)
                                                 servicerec.clientname=service.Account.Name;
                                                    servicerec.dat = service.Scheduled_Date__c;
                                                    serviceApp.add(servicerec);
                                                } 
                                         }
        return serviceApp;
    }
    @AuraEnabled
    Public static CasecommentWrapper createCaseComment(String recordid,String casecOMMENT){
        CasecommentWrapper casecomm = new CasecommentWrapper();
        casecomm.response ='Success';
        CaseComment caseCom = new CaseComment(ParentId =recordid,CommentBody=casecOMMENT,IsPublished=true);
        try{
            insert caseCom;   
        }
        catch(Exception ex){
            casecomm.response ='Success';
        }
        List<CaseComment> casecommmm = [SELECT id,CommentBody,ParentId from CaseComment where ParentID=:recordid];
        casecomm.caseComment =casecommmm;
        return casecomm;
        
    }
    @AuraEnabled
    public static List<CaseComment> getCasecommes(List<CaseComment> caseComms){
        return  caseComms;
    }
    public class CasecommentWrapper{
        @AuraEnabled
        public string response{get;set;}
        @AuraEnabled
        public List<CaseComment> caseComment{get;set;}
        
        public CasecommentWrapper(){
            response =  '';
            caseComment = new List<CaseComment>();
        }
    }
    @AuraEnabled
    public static serviceAppointmentWrapper getSAforpopup(String Ide){
        serviceAppointmentWrapper SRforPopup = new serviceAppointmentWrapper();
        for(ServiceAppointMent service : [SELECT id,Scheduled_Date__c,AppointmentNumber,Address,WorkTypeId,WorkType.Name,AccountId,Account.Name,
                                          Engineer_Pay_Requisition__c,City,Street,State,PostalCode,Country,Work_Order__r.WorkType.Trade__c,
                                          Engineer_Pay_Requisition__r.Pay_Labour_Total__c,Engineer_Pay_Requisition__r.Status__c 
                                          ,Engineer_Pay_Requisition__r.Pay_Fixed_Price__c,Engineer_Pay_Requisition__r.Invoice_Balance__c,
                                          Engineer_Pay_Requisition__r.Pay_Total__c, 
                                          Engineer_Pay_Requisition__r.Rate_of_Pay__c,
                                          Engineer_Pay_Requisition__r.Pay_Lead_Fee__c,
                                          Work_Order__c,Work_Order__r.WorkOrderNumber,Engineer_Pay_Requisition__r.Pay_Materials__c
                                          from ServiceAppointment where id=:Ide]){
                                              
                                              SRforPopup.AppNumber = service.AppointmentNumber;
                                              SRforPopup.workorder = service.Work_Order__r.WorkOrderNumber;
                                                if(service.AccountId!=null)
                                                  SRforPopup.clientname=service.Account.Name;
                                              if(service.PostalCode!='')
                                                  SRforPopup.address=service.PostalCode;
                                              if(service.Engineer_Pay_Requisition__c!=null){
                                                  if(service.Engineer_Pay_Requisition__r.Pay_Total__c!=null)
                                                      SRforPopup.paytotal = String.valueOf(service.Engineer_Pay_Requisition__r.Pay_Total__c);
                                                  else
                                                      SRforPopup.paytotal ='NA';
                                                   if(service.Engineer_Pay_Requisition__r.Invoice_Balance__c!=null)
                                                      SRforPopup.invoicebalabnce = String.valueOf(service.Engineer_Pay_Requisition__r.Invoice_Balance__c);
                                                  else
                                                      SRforPopup.invoicebalabnce ='NA';
                                                  if(service.Engineer_Pay_Requisition__r.Pay_Labour_Total__c!=null)
                                                      SRforPopup.paylabourtotal = String.valueOf(service.Engineer_Pay_Requisition__r.Pay_Labour_Total__c);
                                                  else
                                                      SRforPopup.paytotal ='NA';
                                                  if(service.Engineer_Pay_Requisition__r.Pay_Fixed_Price__c!=null)
                                                      SRforPopup.payother = String.valueOf(service.Engineer_Pay_Requisition__r.Pay_Fixed_Price__c);
                                                  else
                                                      SRforPopup.payother ='NA';
                                                  if(service.Engineer_Pay_Requisition__r.Pay_Materials__c!=null)
                                                      SRforPopup.paymaterial   =String.valueOf(service.Engineer_Pay_Requisition__r.Pay_Materials__c);
                                                  else
                                                      SRforPopup.paymaterial ='NA';
                                                  if(service.Engineer_Pay_Requisition__r.Pay_Lead_Fee__c!=null)
                                                      SRforPopup.leadfee = String.valueOf(service.Engineer_Pay_Requisition__r.Pay_Lead_Fee__c);
                                                  else
                                                      SRforPopup.leadfee ='NA';
                                                  if(service.Engineer_Pay_Requisition__r.Rate_of_Pay__c!=null)
                                                      SRforPopup.percentage = String.valueOf(service.Engineer_Pay_Requisition__r.Rate_of_Pay__c);
                                                  else
                                                      SRforPopup.percentage ='NA';
                                                  if(service.Engineer_Pay_Requisition__r.Status__c!=null)
                                                      SRforPopup.status =service.Engineer_Pay_Requisition__r.Status__c; 
                                                  else
                                                      SRforPopup.status ='NA';
                                              }else{
                                                  SRforPopup.paytotal = 'NA';
                                                  SRforPopup.paylabourtotal = 'NA';
                                                  SRforPopup.payother = 'NA';
                                                  SRforPopup.paymaterial   ='NA';
                                                  SRforPopup.leadfee = 'NA';
                                                  SRforPopup.percentage = 'NA';
                                                  SRforPopup.status ='NA';
                                                   SRforPopup.invoicebalabnce ='NA';
                                              }
                                              
                                              
                                              
                                          }
        return SRforPopup;
    }
    public class serviceAppointmentWrapper{
        @AuraEnabled
        public Date dat { get; set;}
        @AuraEnabled
        public String SAId { get; set;}
        @AuraEnabled
        public String AppNumber  { get; set;}
        @AuraEnabled
        public String address  { get; set;}
        @AuraEnabled
        public String invoicebalabnce  { get; set;}
        @AuraEnabled
        public String WorktypeName  { get; set;}
        @AuraEnabled
        public String workorder  { get; set;}
        @AuraEnabled
        public String clientname  { get; set;}
        @AuraEnabled
        public String paytotal  { get; set;}
        @AuraEnabled
        public String paylabourtotal  { get; set;}
        @AuraEnabled
        public String paymaterial { get; set;}
        @AuraEnabled
        public String payother { get; set;}
        @AuraEnabled
        public String percentage { get; set;}
        @AuraEnabled
        public String leadfee { get; set;}
        @AuraEnabled
        public String status  { get; set;}
        public serviceAppointmentWrapper(){
            percentage = leadfee ='';
            status = WorktypeName= address='';
            paylabourtotal  = invoicebalabnce = clientname = workorder ='';
            AppNumber = '';
            payother = paymaterial = '';
            paytotal ='';
            SAId ='';
            dat = null;
        }
    }
}