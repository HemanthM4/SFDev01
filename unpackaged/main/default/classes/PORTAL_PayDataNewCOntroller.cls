Global without sharing class PORTAL_PayDataNewCOntroller {
    
    
    @AuraEnabled
    public static List<Wrapper> fetchEnginnerPaytest(String stat,String filterDate)
    {
        Integer numberOfDays = 0;
        Date lastDayOfMonth = System.Today();
        Date startDayOfMonth = System.Today();
        String filterQuery = '';
        String filterQueryReq = '';
        String filterQueryDed = '';
        String filterStatus = '';
        Id userId = UserInfo.getUserId();
        
        if(stat == 'None'){
            filterStatus = '';
        }else{
            filterStatus = 'and Status__c = :stat ';
        }
        
        if(filterDate == 'This Month'){
             numberOfDays = Date.daysInMonth(System.Today().year(), System.Today().month());
             startDayOfMonth = Date.newInstance(System.Today().year(), System.Today().month(), 1);
             lastDayOfMonth = Date.newInstance(System.Today().year(), System.Today().month(), numberOfDays+1);
             filterQuery = ' and (CreatedDate >= :startDayOfMonth and CreatedDate <= :lastDayOfMonth)';
             filterQueryReq = 'select id, Name,Pay_Lead_Fee__c,Rate_of_Pay__c,Payroll_month__c,Job__r.Site__r.Site_PostalCode__c,Status__c,Invoice_Balance__c,Site_Address__c,Client_Full_Name__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Pay_Labour_Total__c,Pay_Materials__c,Pay_Fixed_Price__c,Pay_Total__c,createddate from    Engineer_Pay_Requisition__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+ filterQuery+' Order By createdDate DESC';
             filterQueryDed = 'select id, Name,Engineer_Pay_Requisition__r.Pay_Lead_Fee__c,Engineer_Pay_Requisition__r.Job__r.Site__r.Site_PostalCode__c,Engineer_Pay_Requisition__r.Rate_of_Pay__c,Payroll_month__c,Amount__c,Deduction_Requested_By__c,Deduction_Requested_By__r.name,Deduction_WO_Number__c,Description__c,Engineer_Pay_Requisition__r.Name,Work_Order__r.WorkOrderNumber,Status__c,Work_Order__c,createddate from Deduction__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+ filterQuery+' Order By createdDate DESC';  
            system.debug('generated query###'+filterQueryReq);
        }else if(filterDate == 'Last Month'){           
            numberOfDays = Date.daysInMonth(System.Today().year(), System.Today().month()-1);
            startDayOfMonth = Date.newInstance(System.Today().year(), System.Today().month()-1, 1);
            lastDayOfMonth = Date.newInstance(System.Today().year(), System.Today().month()-1, numberOfDays+1);
            filterQuery = ' and (CreatedDate >= :startDayOfMonth and CreatedDate <= :lastDayOfMonth)';
            filterQueryReq = 'select id, Name,Pay_Lead_Fee__c,Rate_of_Pay__c,Payroll_month__c,Job__r.Site__r.Site_PostalCode__c,Status__c,Invoice_Balance__c,Site_Address__c,Client_Full_Name__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Pay_Labour_Total__c,Pay_Materials__c,Pay_Fixed_Price__c,Pay_Total__c,createddate from Engineer_Pay_Requisition__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+ filterQuery+' Order By createdDate DESC';
            filterQueryDed = 'select id, Name,Engineer_Pay_Requisition__r.Pay_Lead_Fee__c,Engineer_Pay_Requisition__r.Job__r.Site__r.Site_PostalCode__c,Engineer_Pay_Requisition__r.Rate_of_Pay__c,Payroll_month__c,Amount__c,Deduction_Requested_By__c,Deduction_Requested_By__r.name,Deduction_WO_Number__c,Description__c,Engineer_Pay_Requisition__r.Name,Status__c,Work_Order__c,Work_Order__r.WorkOrderNumber,createddate from Deduction__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+ filterQuery+' Order By createdDate DESC';
            system.debug('generated query###'+filterQueryReq);
        }else if(filterDate == 'All Time'){
            filterQuery = '';
            filterQueryReq = 'select id, Name,Pay_Lead_Fee__c,Rate_of_Pay__c,Payroll_month__c,Job__r.Site__r.Site_PostalCode__c,Status__c,Invoice_Balance__c,Site_Address__c,Client_Full_Name__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Pay_Labour_Total__c,Pay_Materials__c,Pay_Fixed_Price__c,Pay_Total__c,createddate from Engineer_Pay_Requisition__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+'Order By createdDate DESC';
            filterQueryDed = 'select id, Name,Engineer_Pay_Requisition__r.Pay_Lead_Fee__c,Engineer_Pay_Requisition__r.Job__r.Site__r.Site_PostalCode__c,Engineer_Pay_Requisition__r.Rate_of_Pay__c,Payroll_month__c,Amount__c,Deduction_Requested_By__c,Deduction_Requested_By__r.name,Deduction_WO_Number__c,Description__c,Engineer_Pay_Requisition__r.Name,Status__c,Work_Order__c,Work_Order__r.WorkOrderNumber,createddate from Deduction__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+'Order By createdDate DESC';
            system.debug('generated query###'+filterQueryReq);
        }else if(filterDate.contains('-')){
            String monthtext = filterDate.SubStringBefore('-');
            String year = filterDate.SubStringAfter('-');
            numberOfDays = Date.daysInMonth(Integer.valueOf(year), fetchMonthInteger(monthtext));    
            startDayOfMonth = Date.newInstance(Integer.valueOf(year), fetchMonthInteger(monthtext), 1);
            lastDayOfMonth = Date.newInstance(Integer.valueOf(year), fetchMonthInteger(monthtext), numberOfDays+1);
            filterQuery = ' and (Payroll_month__c >= :startDayOfMonth and Payroll_month__c <= :lastDayOfMonth)';
            filterQueryReq = 'select id, Name,Pay_Lead_Fee__c,Rate_of_Pay__c,Payroll_month__c,Job__r.Site__r.Site_PostalCode__c,Status__c,Invoice_Balance__c,Site_Address__c,Client_Full_Name__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Pay_Labour_Total__c,Pay_Materials__c,Pay_Fixed_Price__c,Pay_Total__c,createddate from Engineer_Pay_Requisition__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+ filterQuery+' Order By createdDate DESC';
            filterQueryDed = 'select id, Name,Engineer_Pay_Requisition__r.Pay_Lead_Fee__c,Engineer_Pay_Requisition__r.Job__r.Site__r.Site_PostalCode__c,Engineer_Pay_Requisition__r.Rate_of_Pay__c,Payroll_month__c,Amount__c,Deduction_Requested_By__c,Deduction_Requested_By__r.name,Deduction_WO_Number__c,Description__c,Engineer_Pay_Requisition__r.Name,Status__c,Work_Order__c,Work_Order__r.WorkOrderNumber,createddate from Deduction__c where Service_Resource__r.RelatedRecordId =:userId '+filterStatus+ filterQuery+' Order By createdDate DESC';   
            system.debug('generated query###'+filterQueryReq);
        }else if(filterDate == 'PayrollMonth'){
            filterQuery = '';
            filterQueryReq = 'select id, Name,Pay_Lead_Fee__c,Rate_of_Pay__c,Payroll_month__c,Job__r.Site__r.Site_PostalCode__c,Status__c,Invoice_Balance__c,Site_Address__c,Client_Full_Name__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Pay_Labour_Total__c,Pay_Materials__c,Pay_Fixed_Price__c,Pay_Total__c,createddate from Engineer_Pay_Requisition__c where Payroll_month__c != null and Service_Resource__r.RelatedRecordId =:userId '+filterStatus+'Order By createdDate DESC';
            filterQueryDed = 'select id,Engineer_Pay_Requisition__r.Job__r.Site__r.Site_PostalCode__c,Engineer_Pay_Requisition__r.Pay_Lead_Fee__c,Engineer_Pay_Requisition__r.Rate_of_Pay__c, Name,Payroll_month__c,Amount__c,Deduction_Requested_By__c,Deduction_Requested_By__r.name,Deduction_WO_Number__c,Description__c,Engineer_Pay_Requisition__r.Name,Status__c,Work_Order__c,Work_Order__r.WorkOrderNumber,createddate from Deduction__c where Payroll_month__c != null and Service_Resource__r.RelatedRecordId =:userId '+filterStatus+'Order By createdDate DESC';
            system.debug('generated query###'+filterQueryReq);
        }   
        
        
        List<Wrapper> engWrapperList = new List<Wrapper>();
        List<Engineer_Pay_Requisition__c> EnginnerPay =  new List<Engineer_Pay_Requisition__c>();
        for(Engineer_Pay_Requisition__c req : Database.query(filterQueryReq)){
                                                   EnginnerPay.add(req)  ;         
                                               }
        if(!EnginnerPay.isEmpty()){
            for(Engineer_Pay_Requisition__c requisition :EnginnerPay){
                Wrapper engPaywrap = new  Wrapper(requisition);
                engWrapperList.add(engPaywrap);
            }
        }
        
        List<Deduction__c> deductionList =  new List<Deduction__c>();
        for(Deduction__c ded : Database.query(filterQueryDed)){
                                                   deductionList.add(ded)  ;         
                                               }
        
        if(!deductionList.isEmpty()){
            for(Deduction__c deduction :deductionList){
                Wrapper engPaywrap = new  Wrapper(deduction);
                engWrapperList.add(engPaywrap);
            }
        }
        
        List<Wrapper> sortedWrapperASC= new List<Wrapper>();
        //Sorting data based on createddate or Payroll month(to display right info where users are coming from)
        if(filterDate.contains('-') || filterDate == 'PayrollMonth'){
            system.debug('@@@@@@payroll@@@@@@@@');
            sortedWrapperASC=sortWrapperList(engWrapperList,'DESC','createddate');
        }else{
            system.debug('@@@@@@@createddate@@@@@@@');
            sortedWrapperASC=sortWrapperList(engWrapperList,'DESC','createddate');
        }
        
        return sortedWrapperASC;  
    }
        
    Global class Wrapper{
        
        @AuraEnabled
        public Deduction__c deduc { get; set; }
          @AuraEnabled
        public String recId { get; set; }
        @AuraEnabled
        public Engineer_Pay_Requisition__c requisition { get;  set; }
        @AuraEnabled
        public String dataType { get;  set; }
        @AuraEnabled
        public Date createddate {get; set;}
        @AuraEnabled
        public decimal calculatedAmount {get; set;}
        @AuraEnabled
        public String status { get;  set; }
        @AuraEnabled
        public String name { get;  set; }
        @AuraEnabled
        public String description { get;  set; }
        @AuraEnabled
        public String deductionRequestedBy { get;  set; }
        @AuraEnabled
        public Decimal deductionAmt {get;  set;}
        @AuraEnabled
        public String workOrder { get;  set; }
        @AuraEnabled
        public Date workOrderCreatedDate { get;  set; }
        @AuraEnabled
        public String sitePostCode { get;  set; }
        @AuraEnabled
        public String engPayRequisNumber { get;  set; }
        @AuraEnabled
        public Decimal invoiceBalance { get;  set; }
        @AuraEnabled
        public Decimal payLabourTotal { get;  set; }
        @AuraEnabled
        public Decimal payMaterials { get;  set; }
        @AuraEnabled
        public Decimal payOther { get;  set; }
        @AuraEnabled
        public Decimal payTotal { get;  set; }
        @AuraEnabled
        public Date payrollMonth { get;  set; }
         @AuraEnabled
        public Decimal percentagevalue { get;  set; }
        @AuraEnabled
        public Decimal leadFees { get;  set; }
        
        
        public Wrapper(Deduction__c n) {
            deduc = n;
            dataType = 'deduc';
            recId =deduc.id;
            name = deduc.name;
            status = deduc.Status__c;
            engPayRequisNumber = deduc.Engineer_Pay_Requisition__r.Name;
            workOrder = deduc.Work_Order__r.WorkOrderNumber;
            sitePostCode = deduc.Engineer_Pay_Requisition__r.Job__r.Site__r.Site_PostalCode__c;
            description = deduc.Description__c;
            deductionRequestedBy = deduc.Deduction_Requested_By__r.Name;
            deductionAmt = deduc.Amount__c;    
            createddate = date.valueOf(deduc.CreatedDate);
            payrollMonth = deduc.Payroll_month__c;
            percentagevalue= deduc.Engineer_Pay_Requisition__r.Rate_of_Pay__c;
            leadFees =deduc.Engineer_Pay_Requisition__r.Pay_Lead_Fee__c;
        }

        public Wrapper(Engineer_Pay_Requisition__c r) {
            requisition = r;
            dataType = 'requisition';
             recId =requisition.id;
            status = requisition.Status__c;
            engPayRequisNumber = requisition.name;
            workOrder = requisition.Work_Order__r.WorkOrderNumber;
            sitePostCode = requisition.Job__r.Site__r.Site_PostalCode__c;
            invoiceBalance = requisition.Invoice_Balance__c;
            payLabourTotal = requisition.Pay_Labour_Total__c;
            payMaterials = requisition.Pay_Materials__c;
            payOther = requisition.Pay_Fixed_Price__c;
            payTotal = requisition.Pay_Total__c;
            name = requisition.name;
            createddate = date.valueOf(requisition.CreatedDate);
            payrollMonth = requisition.Payroll_month__c;
             percentagevalue= requisition.Rate_of_Pay__c;
                leadFees =requisition.Pay_Lead_Fee__c;
            
        }

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
    public static List<Wrapper> sortWrapperList(List<Wrapper> recList,string sortType,string decider){
        List<Wrapper> sortedList = new List<Wrapper>();
        system.debug('******sortedList before sorting in '+sortType+':'+recList);
        if(recList.size()>0){
            sortedList = recList;
             if(sortType.equalsIgnoreCase('ASC')){
                for(integer i = 0; i < sortedList.size()-1; i++){
                    for(integer j = 1; j < sortedList.size(); j++){
                        //sorting based on decider wrapper field (createddate or Payroll Month)
                        if(decider == 'createddate'){
                            Datetime firstValue = sortedList[j-1].createddate;
                            Datetime nextValue = sortedList[j].createddate;
                            //if firstValue > nextValue, swap the elements
                            if(firstValue > nextValue){
                                Wrapper tmpValue = sortedList[j-1];
                                sortedList[j-1]=sortedList[j];
                                sortedList[j]=tmpValue;
                            }
                        }if(decider == 'payrollMonth'){
                            system.debug('sorting by payroll month@@@');
                            Date firstValue = sortedList[j-1].payrollMonth;
                            Date nextValue = sortedList[j].payrollMonth;
                            //if firstValue > nextValue, swap the elements
                            if(firstValue > nextValue){
                                Wrapper tmpValue = sortedList[j-1];
                                sortedList[j-1]=sortedList[j];
                                sortedList[j]=tmpValue;
                            }
                        }
                                                
                    }
                }
            }    
        }
        system.debug('******sortedList after sorting in '+sortType+':'+sortedList);
        return sortedList;
    }
    
    public static Map<Integer, Map<String,Decimal>> paySummaryTotal(List<Wrapper> records)
    {
        Map<Integer,String> numStringMonthMap = new  Map<Integer,String>();
        Map<Integer, Map<String,Decimal>> yearMonthMap = new Map<Integer, Map<String,Decimal>>();
        
        
        
        numStringMonthMap.put(1,'January');
        numStringMonthMap.put(2,'February');
        numStringMonthMap.put(3,'March');
        numStringMonthMap.put(4,'April');
        numStringMonthMap.put(5,'May');
        numStringMonthMap.put(6,'June');
        numStringMonthMap.put(7,'July');
        numStringMonthMap.put(8,'August');
        numStringMonthMap.put(9,'September');
        numStringMonthMap.put(10,'October');
        numStringMonthMap.put(11,'November');
        numStringMonthMap.put(12,'December');
        
        
        for (Wrapper record : records)
        {
            Decimal amountTotal = 0;
            Decimal amountTotalNew = 0;
            
            if (yearMonthMap.containsKey(record.payrollMonth.year())){
                 Map<String,Decimal> iteratMap = yearMonthMap.get(record.payrollMonth.year());
                    if(iteratMap.containsKey(numStringMonthMap.get(record.payrollMonth.month()))){
                        amountTotal = iteratMap.get(numStringMonthMap.get(record.payrollMonth.month()));
                        if(record.dataType == 'deduc'){
                            amountTotal -= record.deduc.Amount__c;
                        }if(record.dataType == 'requisition'){
                            amountTotal += record.requisition.Pay_Total__c;
                        }
                        iteratMap.put(numStringMonthMap.get(record.payrollMonth.month()),amountTotal);
                        yearMonthMap.put(record.payrollMonth.year(),iteratMap);
                    }else{
                        if(record.dataType == 'deduc'){
                            amountTotalNew -= record.deduc.Amount__c;
                            iteratMap.put(numStringMonthMap.get(record.payrollMonth.month()),amountTotalNew);
                            yearMonthMap.put(record.payrollMonth.year(),iteratMap);
                        }if(record.dataType == 'requisition'){
                            amountTotalNew = record.requisition.Pay_Total__c;
                            iteratMap.put(numStringMonthMap.get(record.payrollMonth.month()),record.requisition.Pay_Total__c);
                            yearMonthMap.put(record.payrollMonth.year(),iteratMap);
                        }
                    }
            }else{
                Map<String, Decimal> monthAmountMap = new Map<String, Decimal>();
               if(record.dataType == 'deduc'){
                   amountTotal -= record.deduc.Amount__c;
                    monthAmountMap.put(numStringMonthMap.get(record.payrollMonth.month()),amountTotal);
                    yearMonthMap.put(record.payrollMonth.year(),monthAmountMap);
                }if(record.dataType == 'requisition'){
                    amountTotal = record.requisition.Pay_Total__c;
                    monthAmountMap.put(numStringMonthMap.get(record.payrollMonth.month()),amountTotal);
                    yearMonthMap.put(record.payrollMonth.year(),monthAmountMap);
                }
            }
        }
        return yearMonthMap;
    }
    
    @AuraEnabled
    public static Map<Integer, Map<String,Decimal>> paySummaryTotal()
    {
       return paySummaryTotal(fetchEnginnerPaytest('Paid','PayrollMonth')); 
    }
    
    public static Integer fetchMonthInteger(string monText){
        Map<String,Integer> stringNumMonthMap = new  Map<String,Integer>();
        stringNumMonthMap.put('January',1);
        stringNumMonthMap.put('February',2);
        stringNumMonthMap.put('March',3);
        stringNumMonthMap.put('April',4);
        stringNumMonthMap.put('May',5);
        stringNumMonthMap.put('June',6);
        stringNumMonthMap.put('July',7);
        stringNumMonthMap.put('August',8);
        stringNumMonthMap.put('September',9);
        stringNumMonthMap.put('October',10);
        stringNumMonthMap.put('November',11);
        stringNumMonthMap.put('December',12);   
        
        return stringNumMonthMap.get(monText);
    }
}