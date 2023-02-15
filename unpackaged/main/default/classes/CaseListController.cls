public without sharing class CaseListController {
    @AuraEnabled
    public static String getCaseListtoClose(String idx){
        String isSucess ='Success';
        Case cas= new Case(Id=idx,Status='Closed');
        try{
            update cas;
        }
        catch(DMLException ex){
            isSucess =ex.getMessage();
        }
        return isSucess;
    }
    @AuraEnabled
    public static List<CaseWrapper> getCaseListbyfilter(String filtervalue){
        List<Case> cases = new List<Case>();
        User usr = [SELECT id,EMail from User where id=:UserInfo.getUserId()];
        List<CaseWrapper> serWrap = new List<CaseWrapper>();
        cases = [SELECT id,CaseNumber,Priority,Status,Subject,Description from Case where SuppliedEmail=:usr.Email 
                 and (Origin='Community' OR Origin='Office')  and Status=:filtervalue Order by CreatedDate Desc] ;
        if(!cases.isEmpty()){
            for(Case cas : cases){
                CaseWrapper serWr=  new CaseWrapper();
                serWr.caseNumber = cas.CaseNumber;
                serWr.caseId =cas.Id;
                serWr.caseProiority =cas.Priority;
                serWr.caseStatus =cas.Status;
                serWr.caseSubject=cas.Subject;
                serWr.caseDexcription =cas.Description;
                serWrap.add(serWr);
            }
            
        }
        return serWrap;
        
    }
    @AuraEnabled
    public static List<CaseWrapper> getCaseList(String showCase,String parentid){
        List<Case> cases = new List<Case>();
        List<CaseWrapper> serWrap = new List<CaseWrapper>();
        User usr = [SELECT id,EMail from User where id=:UserInfo.getUserId()];
        if(showCase=='All'){
            cases = [SELECT id,CaseNumber,Priority,Status,Subject,Description from Case where SuppliedEmail=:usr.Email
                     and (Origin='Community' OR Origin='Office') Order by CreatedDate Desc] ;
        }else  if(showCase=='Service Appointment'){
            cases = [SELECT id,CaseNumber,Priority,Status,Subject,Description from Case where SuppliedEmail=:usr.Email 
                     and (Origin='Community' OR Origin='Office')  and Service_Appointment__c=:parentid Order by CreatedDate Desc] ; 
        }else  if(showCase=='requisition'){
            cases = [SELECT id,CaseNumber,Priority,Status,Subject,Description from Case where SuppliedEmail=:usr.Email
                     and (Origin='Community' OR Origin='Office')  and Engineer_Pay_Requisition__c=:parentid Order by CreatedDate Desc] ;
        }else  if(showCase=='deduc'){
            cases = [SELECT id,CaseNumber,Priority,Status,Subject,Description from Case where SuppliedEmail=:usr.Email 
                     and (Origin='Community' OR Origin='Office')  and Engineer_Deduction__c=:parentid Order by CreatedDate Desc] ;
        }
        if(!cases.isEmpty()){
            for(Case cas : cases){
                CaseWrapper serWr=  new CaseWrapper();
                serWr.caseNumber = cas.CaseNumber;
                serWr.caseId =cas.Id;
                serWr.caseProiority =cas.Priority;
                serWr.caseStatus =cas.Status;
                serWr.caseSubject=cas.Subject;
                serWr.caseDexcription =cas.Description;
                serWrap.add(serWr);
            }
            
        }
        return serWrap;
    }
    public class CaseWrapper{
        @AuraEnabled
        public string caseNumber{get;set;}
        @AuraEnabled
        public string caseId{get;set;}
        @AuraEnabled
        public string caseProiority{get;set;}
        @AuraEnabled
        public string caseStatus{get;set;}
        @AuraEnabled
        public string caseSubject{get;set;}
        @AuraEnabled
        public string caseDexcription{get;set;}
        public CaseWrapper(){
            caseNumber =  caseId = caseProiority =caseStatus = caseSubject=caseDexcription ='';
        }
    }
    @AuraEnabled
    Public static Boolean getStatusValue(String recordid){
        Boolean isTrue = false;
        Case cas=[SELECT id,Status from Case Where id=:recordid];
        if(cas.Status=='Closed')
            isTrue =true;
        return isTrue;
    }
    @AuraEnabled
    Public static List<caseComment> getCaseCommnets(String recordid){
        List<caseComment> caseComm =[SELECT id,CommentBody,CreatedDate,CreatedById,CreatedBy.Name,ParentId  from CaseComment where ParentId=:recordid 
                                     Order by CreatedDate ASC] ;
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@'+caseComm);
        return caseComm;
    }
    @AuraEnabled
    public static List<String> getCaselistvalues()
    {
        List<String> options = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getValue()=='Open' ||  f.getValue()=='Closed')
                options.add(f.getValue());
        }       
        return options;
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
    
    
    
}