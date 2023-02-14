public class EprDataController {
   
    @AuraEnabled
    public static  Epr_History_log__c prepopulateValues(String selectedRec){
        Epr_History_log__c epr = [SELECT id,Comment__c,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,Start_Date__c,Status__c,isExecuted__c from
                                  Epr_History_log__c where id=:selectedRec];
        return epr;
    }
    
    //    Scheduled_Date__c >=:'+ epr.Start_Date__c  +' 
    //              AND Scheduled_Date__c <=:'+ epr.End_Date__c +' AND 
    @AuraEnabled
    public static  Boolean runBatchMethod(String selectedRec,Date scheduledDate){
        Epr_History_log__c epr = [SELECT id,Comment__c,isExecuted__c,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,Start_Date__c,Status__c from
                                  Epr_History_log__c where id=:selectedRec];
        List<Epr_History_log__c> eprsHistory = new List<Epr_History_log__c>();
        if(epr.isExecuted__c == false){
            epr.isExecuted__c = true;
            eprsHistory.add(epr);
        }
        if(eprsHistory.size() !=0){
            update eprsHistory;
        }
        //String dateStr = Date.today().format();
        Datetime startDate =epr.Start_Date__c;
        Datetime endDate = epr.End_Date__c;
        Boolean hasNull = false;
        Set<String> accountype = new Set<String>();
        Set<String>jobtype = new Set<String>();
        List<String> acctypes =  new  List<String> ();
        List<String> jobtypes =  new  List<String> ();
        if(epr.Job_TypeMP__c.contains(';')){
            jobtypes = epr.Job_TypeMP__c.split(';');
        }else{
            jobtypes.add(epr.Job_TypeMP__c);
        }
        
        if(epr.Account_TypeMP__c.contains(';')){
            acctypes = epr.Account_TypeMP__c.split(';');
        }else{
            acctypes.add(epr.Account_TypeMP__c);
        }
        String accountypevalue = '(\'' + String.join(acctypes, '\',\'') + '\')';
        String jobtypevalue = '(\'' + String.join(jobtypes, '\',\'') + '\')';
        String accQuery = 'SELECT CreatedDate,Id,Name,Payroll_month__c,Scheduled_Date__c, Status__c  FROM Engineer_Pay_Requisition__c WHERE  Service_Resource__r.IsActive = TRUE    AND Status__c = \''+epr.Status__c+'\'' +' AND Service_Resource__r.Exclude_EPR_Automatic__c = false  '  +' AND Job_Type__c in  '+ jobtypevalue +  '  and Account_Type__c  IN '+accountypevalue ;
        if(startDate  != null && endDate == null){        
            accQuery = accQuery +' AND Scheduled_Date__c >='+ startDate.format('yyyy-MM-dd') +'   AND Scheduled_Date__c <='+ startDate.format('yyyy-MM-dd');
        }else if(startDate == null && endDate  != null){
            accQuery = accQuery +' AND Scheduled_Date__c >='+ endDate.format('yyyy-MM-dd')+'   AND Scheduled_Date__c <='+endDate.format('yyyy-MM-dd') ;
        }else if(startDate  != null && endDate  != null){
            accQuery = accQuery +' AND Scheduled_Date__c >='+ startDate.format('yyyy-MM-dd')+'   AND Scheduled_Date__c <='+endDate.format('yyyy-MM-dd');
        }else if(startDate  == null && endDate  == null){
            accQuery = accQuery +' AND Scheduled_Date__c = null ';
        }
        // accQuery = accQuery +' Service_Resource__r.Exclude_EPR_Automatic__c = false ';
        //accQuery =  accQuery + ' Limit 1';
        
        System.debug('accQuery'+accQuery);
          BatchMssUpdateEpr bdt = new BatchMssUpdateEpr(accQuery,scheduledDate);
       // BatchMssUpdateEpr bdt = new BatchMssUpdateEpr(accQuery,scheduledDate,'','');
     dataBase.executeBatch(bdt);
        return true;
    }
    @AuraEnabled
    public static List<wrapAccount> updateEPRList(list<wrapAccount> caseWrapList){
        List<Epr_History_log__c> eprHiss = new List<Epr_History_log__c>();
        Set<id> epsHisId = new Set<id>();
        for(wrapAccount wrapAcc:caseWrapList ){
            Epr_History_log__c eprHis = new Epr_History_log__c();
            eprHis.id = wrapAcc.recid;
            epsHisId.add(wrapAcc.recid);
            eprHis.Comment__c = wrapAcc.comment;// wrap.comment = epr.Comment__c;
            eprHiss.add(eprHis);
        }
        if(eprHiss.size() !=0){
            update eprHiss;
        }
        List<wrapAccount> wraps = new List<wrapAccount>();
        for(Epr_History_log__c epr: [SELECT id,Comment__c,Account_TypeMP__c,End_Date__c,isExecuted__c,Job_TypeMP__c,Start_Date__c,Status__c,CreatedDate,
                                     Createdby.name from
                                     Epr_History_log__c   order by createdDate DESC Limit 5]){
                                         System.debug('entered 1');
                                         wrapAccount wrap = new wrapAccount();
                                         wrap.acctype = epr.Account_TypeMP__c;
                                         TimeZone tz = UserInfo.getTimeZone();
                                         DateTime dt = epr.CreatedDate;
                                         DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                         wrap.isExecuted =epr.isExecuted__c;
                                         wrap.createdDate = dateTimeCreatedDate;
                                         wrap.createdUser = epr.Createdby.Name;
                                         wrap.endDate =  epr.End_Date__c;
                                         wrap.jobtype = epr.Job_TypeMP__c;
                                         wrap.recid = epr.id;
                                         wrap.hasChecked = false;
                                         wrap.status = epr.Status__c;
                                         wrap.comment = epr.Comment__c;
                                         wrap.startDate = epr.Start_Date__c;
                                         wraps.add(wrap);
                                         System.debug('wraps'+wraps);
                                     }
        return wraps;
    }
    @AUraEnabled
    public static List<wrapAccount> downloadcsv(Date startdateValue, Date enddateValue, 
                                                List<String> accoutntypevalue, String statusValue, List<String>  jobtypeValue)
    {
        List<wrapAccount> wraps = new List<wrapAccount>();
        List<Engineer_Pay_Requisition__c> eprs = new List<Engineer_Pay_Requisition__c>();
        List<String> acctypes =  new  List<String> ();
        List<String> jobtypes =  new  List<String> ();
        acctypes.addAll(accoutntypevalue);
        jobtypes.addAll(jobtypeValue);
        System.debug('jobtypeValue'+jobtypeValue);
        System.debug('accoutntypevalues'+accoutntypevalue);
        String accountypevalue = '(\'' + String.join(acctypes, '\',\'') + '\')';
        String jobtypevalueforQuery = '(\'' + String.join(jobtypes, '\',\'') + '\')';
        String accQuery = 'SELECT CreatedDate,Id,Name,Engineer_Pay_Requisition__c.Account_Type__c,Engineer_Pay_Requisition__c.Job_Type__c,Payroll_month__c,Scheduled_Date__c,Pay_Total__c, Status__c  FROM Engineer_Pay_Requisition__c WHERE  Service_Resource__r.IsActive = TRUE   AND Service_Resource__r.Exclude_EPR_Automatic__c = false   AND Status__c = \''+statusValue+'\''   +' AND Job_Type__c in  '+ jobtypevalueforQuery +  '  and Account_Type__c  IN '+accountypevalue ;
        Datetime startDate =startdateValue;
        Datetime endDate = enddateValue;
        System.debug('accountypevalue'+accountypevalue);
        System.debug('jobtypevalueforQuery'+jobtypevalueforQuery);
        if(startDate  != null && endDate == null){        
            accQuery = accQuery +' AND Scheduled_Date__c >='+ startDate.format('yyyy-MM-dd') +'   AND Scheduled_Date__c <='+ startDate.format('yyyy-MM-dd');
        }else if(startDate == null && endDate  != null){
            accQuery = accQuery +' AND Scheduled_Date__c >='+ endDate.format('yyyy-MM-dd')+'   AND Scheduled_Date__c <='+endDate.format('yyyy-MM-dd') ;
        }else if(startDate  != null && endDate  != null){
            accQuery = accQuery +' AND Scheduled_Date__c >='+ startDate.format('yyyy-MM-dd')+'   AND Scheduled_Date__c <='+endDate.format('yyyy-MM-dd');
        }else if(startDate  == null && endDate  == null){
            accQuery = accQuery +' AND Scheduled_Date__c = null ';
        }
        System.debug('accQuery'+accQuery);
        eprs = Database.query(accQuery);
        
        
        for(Engineer_Pay_Requisition__c epr: eprs){
            
            wrapAccount wrap = new wrapAccount();
            wrap.acctype = epr.Account_Type__c;
            wrap.scheduledDate =  epr.Scheduled_Date__c;
            wrap.jobtype = epr.Job_Type__c;
            wrap.recid = epr.id;
            // wrap.isExecuted =epr.isExecuted__c;
            wrap.status = epr.Status__c;
            wrap.paytotal = epr.Pay_Total__c;
            wrap.Name = epr.Name;
            wraps.add(wrap);
            
        }
        return wraps;
        
    }
    @AUraEnabled
    public static eprWrap checkEprRecords(Date startdateValue, Date enddateValue, 
                                          List<String> accoutntypevalues, String statusValue,List<String> jobtypeValues)
    {
        List<String> acctypes =  new  List<String> ();
        List<String> jobtypes =  new  List<String> ();
        acctypes.addAll(accoutntypevalues);
        jobtypes.addAll(jobtypeValues);
        System.debug('jobtypeValues'+jobtypeValues);
        System.debug('accoutntypevalues'+accoutntypevalues);
        String accountypevalue = '(\'' + String.join(acctypes, '\',\'') + '\')';
        String jobtypevalue = '(\'' + String.join(jobtypes, '\',\'') + '\')';
        String accQuery = 'SELECT CreatedDate,Id,Name,Payroll_month__c,Scheduled_Date__c,Pay_Total__c, Status__c  FROM Engineer_Pay_Requisition__c WHERE  Service_Resource__r.IsActive = TRUE AND Service_Resource__r.Exclude_EPR_Automatic__c = false    AND Status__c = \''+statusValue+'\''   +' AND Job_Type__c in  '+ jobtypevalue +  '  and Account_Type__c  IN '+accountypevalue ;
        Datetime startDate =startdateValue;
        Datetime endDate = enddateValue;
        System.debug('accountypevalue'+accountypevalue);
        System.debug('jobtypevalue'+jobtypevalue);
        if(startDate  != null && endDate == null){        
            accQuery = accQuery +' AND Scheduled_Date__c >='+ startDate.format('yyyy-MM-dd') +'   AND Scheduled_Date__c <='+ startDate.format('yyyy-MM-dd');
        }else if(startDate == null && endDate  != null){
            accQuery = accQuery +' AND Scheduled_Date__c >='+ endDate.format('yyyy-MM-dd')+'   AND Scheduled_Date__c <='+endDate.format('yyyy-MM-dd') ;
        }else if(startDate  != null && endDate  != null){
            accQuery = accQuery +' AND Scheduled_Date__c >='+ startDate.format('yyyy-MM-dd')+'   AND Scheduled_Date__c <='+endDate.format('yyyy-MM-dd');
        }else if(startDate  == null && endDate  == null){
            accQuery = accQuery +' AND Scheduled_Date__c = null ';
        }
        System.debug('accQuery 1 '+accQuery);
        List<Engineer_Pay_Requisition__c> eprs = Database.query(accQuery);
        eprWrap eprWp = new eprWrap();
        eprWp.recordCount = eprs.size();
        for(Engineer_Pay_Requisition__c epr: eprs){
            eprWp.payTotal =epr.Pay_Total__c + eprWp.payTotal;
        }
        return eprWp;
    }
    
    @AuraEnabled
    public static List <String> getAccountPickLIst() {
        List<String> plValues = new List<String>();
        
        //Get the object type from object name. Here I've used custom object Book.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Epr_History_log__c');
        
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        //Get the specific field information from field name. Here I've used custom field Genre__c of Book object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Account_TypeMP__c').getDescribe();
        
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        plValues.sort();
        return plValues;
    }
    
    @AuraEnabled
    public static List <String> getjobPiklistValues() {
        List<String> plValues = new List<String>();
        
        //Get the object type from object name. Here I've used custom object Book.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Epr_History_log__c');
        
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        //Get the specific field information from field name. Here I've used custom field Genre__c of Book object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Job_TypeMP__c').getDescribe();
        
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        plValues.sort();
        return plValues;
    }
    @auraEnabled
    public static list<wrapAccount>retrieveRecordsofEPRonSearchApex(String search1){
        System.debug('entered');
        List<wrapAccount> wraps = new List<wrapAccount>();
        for(Epr_History_log__c epr: [SELECT id,Comment__c,Account_TypeMP__c,isExecuted__c,End_Date__c,Job_TypeMP__c,Start_Date__c,Status__c,CreatedDate,
                                     Createdby.Name from
                                     Epr_History_log__c order by createdDate DESC LIMIT 5]){
                                         System.debug('entered 1');
                                         if(epr.Comment__c !=null && epr.Comment__c!='' && epr.Comment__c.contains(search1)){
                                             wrapAccount wrap = new wrapAccount();
                                             wrap.acctype = epr.Account_TypeMP__c;
                                             wrap.endDate =  epr.End_Date__c;
                                             wrap.jobtype = epr.Job_TypeMP__c;
                                             wrap.recid = epr.id;
                                             wrap.isExecuted =epr.isExecuted__c;
                                             TimeZone tz = UserInfo.getTimeZone();
                                             DateTime dt = epr.CreatedDate;
                                             DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                             wrap.createdDate =dateTimeCreatedDate;
                                             wrap.createdUser = epr.Createdby.Name;
                                             wrap.startDate = epr.Start_Date__c;
                                             wrap.hasChecked = false;
                                             wrap.status = epr.Status__c;
                                             wrap.comment = epr.Comment__c;
                                             wraps.add(wrap);
                                             System.debug('wraps'+wraps);
                                         }
                                     }
        return wraps;
    }
    
    @auraEnabled
    public static  List<wrapAccount> getallEprforShow1(List<wrapAccount>wrapList){
        System.debug('1');
        set<id>erpIds = new set<id>();
        for(wrapAccount wrap : wrapList){
            erpIds.add(wrap.recid);
        }
        List<wrapAccount> wraps = new List<wrapAccount>();
        for(Epr_History_log__c epr: [SELECT id,Comment__c,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,CreatedDate,Createdby.Name,
                                     Start_Date__c,Status__c,isExecuted__c from Epr_History_log__c  where id !=:erpIds
                                     Order By CreatedDate DESC ]){
                                         wrapAccount wrap = new wrapAccount();
                                         wrap.acctype = epr.Account_TypeMP__c;
                                         wrap.endDate =  epr.End_Date__c;
                                         wrap.jobtype = epr.Job_TypeMP__c;
                                         wrap.recid = epr.id;
                                         wrap.isExecuted =epr.isExecuted__c;
                                         wrap.startDate = epr.Start_Date__c;
                                         TimeZone tz = UserInfo.getTimeZone();
                                         DateTime dt = epr.CreatedDate;
                                         DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                         wrap.createdDate = dateTimeCreatedDate;
                                         wrap.createdUser = epr.Createdby.Name;
                                         wrap.hasChecked = false;
                                         wrap.status = epr.Status__c;
                                         wrap.comment = epr.Comment__c;
                                         wraps.add(wrap);
                                     }
        System.debug('wraps'+wraps.size());
        return wraps;
    }
    @auraEnabled
    public static  List<wrapAccount> getallEprforShow2(List<wrapAccount>wrapList){
        set<id>erpIds = new set<id>();
        for(wrapAccount wrap : wrapList){
            erpIds.add(wrap.recid);
        }
        List<wrapAccount> wraps = new List<wrapAccount>();
        for(Epr_History_log__c epr: [SELECT id,Comment__c,isExecuted__c,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,CreatedDate,Createdby.Name,
                                     Start_Date__c,Status__c from Epr_History_log__c  where id !=:erpIds
                                     Order By CreatedDate DESC ]){
                                         wrapAccount wrap = new wrapAccount();
                                         wrap.acctype = epr.Account_TypeMP__c;
                                         wrap.endDate =  epr.End_Date__c;
                                         wrap.jobtype = epr.Job_TypeMP__c;
                                         wrap.recid = epr.id;
                                         wrap.startDate = epr.Start_Date__c;
                                         TimeZone tz = UserInfo.getTimeZone();
                                         DateTime dt = epr.CreatedDate;
                                         DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                         wrap.createdDate = dateTimeCreatedDate;
                                         wrap.createdUser = epr.Createdby.Name;
                                         wrap.hasChecked = false;
                                         wrap.status = epr.Status__c;
                                         wrap.comment = epr.Comment__c;
                                         wrap.isExecuted =epr.isExecuted__c;
                                         wraps.add(wrap);
                                     }
        
        return wraps;
    }
    
    @auraEnabled
    public static wrapAccountNew getallEpr(){
        List<wrapAccount> wraps = new List<wrapAccount>();
        integer i=0;
        list<Epr_History_log__c> eprscount =[SELECT id,Comment__c,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,CreatedDate,Createdby.Name,
                                             Start_Date__c,Status__c from Epr_History_log__c ];
        for(Epr_History_log__c epr: [SELECT id,Comment__c,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,CreatedDate,Createdby.Name,
                                     Start_Date__c,Status__c,isExecuted__c from Epr_History_log__c 
                                     Order By CreatedDate DESC LIMIT 5]){
                                         i++;
                                         wrapAccount wrap = new wrapAccount();
                                         wrap.acctype = epr.Account_TypeMP__c;
                                         wrap.endDate =  epr.End_Date__c;
                                         wrap.jobtype = epr.Job_TypeMP__c;
                                         wrap.recid = epr.id;
                                         wrap.startDate = epr.Start_Date__c;
                                         TimeZone tz = UserInfo.getTimeZone();
                                         wrap.isExecuted =epr.isExecuted__c;
                                         DateTime dt = epr.CreatedDate;
                                         DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                         wrap.createdDate = dateTimeCreatedDate;
                                         wrap.createdUser = epr.Createdby.Name;
                                         wrap.hasChecked = false;
                                         wrap.status = epr.Status__c;
                                         wrap.comment = epr.Comment__c;
                                         wraps.add(wrap);
                                     }
        wrapAccountNew wrapsnew  = new wrapAccountNew();
        if(eprscount.size() != i){
            wrapsnew.wraps = wraps;
            wrapsnew.hasRecordtoShow = true;
            
        }else{
            wrapsnew.wraps = wraps; 
        }
        return wrapsnew;
    }
     @AuraEnabled
    public static integer getDeductionCount(){
        List<Deduction__c> deds = [SELECT id, Status__c, Payroll_Month__c, Service_Resource__r.IsActive FROM Deduction__c  WHERE Status__c  ='Processed'  AND  Service_Resource__r.IsActive = TRUE ];
        return deds.size();
    }
    @AuraEnabled
    public static void processDedcutionMethod(Date payrollDate){ 
        String status = 'Processed';
        String payrollQuery = '';
        if(!Test.isRunningTest())
            payrollQuery =  'SELECT id, Status__c, Payroll_Month__c, Service_Resource__r.IsActive FROM Deduction__c  WHERE Status__c  = \''+status+'\'' +'  AND  Service_Resource__r.IsActive = TRUE ' ;
        else
            payrollQuery =  'SELECT id, Status__c, Payroll_Month__c, Service_Resource__r.IsActive FROM Deduction__c ';    
        BatchProcessDeduction bdt = new BatchProcessDeduction(payrollQuery,payrollDate);
        dataBase.executeBatch(bdt);
        
    }
    @AuraEnabled
    public static List<WrapAccount> checkExistingRecord(Date startdateValue, Date enddateValue, 
                                                        List<String> accoutntypevalue, String statusValue,List<String> jobtypeValue)
    {
        
        String jobList = '';
        String jobListNew = '';
        String AccListnew = '';
        String AccList = '';
        for(String s1 : accoutntypevalue){
            if(AccList==''){
                AccListnew=  AccList = s1;
            }else{
                AccList =AccList+','+ s1;
                AccListnew =  AccListnew+';'+s1;
            }
        }
        for(String s1 : jobtypeValue){
            if(jobList==''){
                jobList = s1;
                jobListNew = s1;
            }else{
                jobList =jobList+','+ s1;
                jobListNew =jobListNew+';'+ s1;
            }
        }
        System.debug('accoutntypevalue'+AccList);
        System.debug('jobtypeValue'+jobList);
        List<Epr_History_log__c> eprs= new List<Epr_History_log__c>();
        eprs =  [SELECT id,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,Start_Date__c,Status__c,isExecuted__c from Epr_History_log__c
                 where Start_Date__c=: startdateValue and End_Date__c=:enddateValue and  
                 Job_TypeMP__c includes (:jobList) and Status__c=:statusValue 
                 and Account_TypeMP__c includes (:AccList)];
        System.debug('eprs'+eprs);
        if(eprs.size() == 0){
            System.debug('1');
            Epr_History_log__c epr  = new Epr_History_log__c();
            epr.Start_Date__c= startdateValue;
            epr.End_Date__c= enddateValue;
            epr.Job_TypeMP__c=jobListNew ;
            epr.Status__c=statusValue ;
            epr.Account_TypeMP__c=AccListnew ;
            try{
                System.debug('2'+epr);
                insert epr;  
                System.debug('3'+epr);
            }catch(Exception ex){
                System.debug('error' +ex.getMessage());
            }
            
        }  
        List<wrapAccount> wraps = new List<wrapAccount>();
        for(Epr_History_log__c epr: [SELECT id,Comment__c,CreatedDate,isExecuted__c,Createdby.Name,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,Start_Date__c,Status__c from Epr_History_log__c
                                     Order by createdDate DESC  LIMIT 5]){
                                         wrapAccount wrap = new wrapAccount();
                                         wrap.acctype = epr.Account_TypeMP__c;
                                         wrap.startDate = epr.Start_Date__c;
                                         wrap.endDate =  epr.End_Date__c;
                                         wrap.jobtype = epr.Job_TypeMP__c;
                                         TimeZone tz = UserInfo.getTimeZone();
                                         DateTime dt = epr.CreatedDate;
                                         DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                         wrap.createdDate = dateTimeCreatedDate;
                                         wrap.createdUser = epr.Createdby.Name;
                                         wrap.recid = epr.id;
                                         wrap.isExecuted =epr.isExecuted__c;
                                         wrap.hasChecked = false;
                                         wrap.status = epr.Status__c;
                                         wrap.comment = epr.Comment__c;
                                         wraps.add(wrap);
                                     }
        return wraps;
    }
    @AuraEnabled
    public static getAllEPrsforCmp getALEPS(){
        getAllEPrsforCmp  getall = new getAllEPrsforCmp();
        List<wrapAccount> wraps = new List<wrapAccount>();
        for(Epr_History_log__c epr: [SELECT id,Comment__c,Account_TypeMP__c,isExecuted__c,End_Date__c,Job_TypeMP__c,Start_Date__c,Status__c,CreatedDate,
                                     Createdby.Name from
                                     Epr_History_log__c order by createdDate DESC LIMIT 5]){
                                         System.debug('entered 1');
                                         wrapAccount wrap = new wrapAccount();
                                         wrap.acctype = epr.Account_TypeMP__c;
                                         wrap.endDate =  epr.End_Date__c;
                                         wrap.startDate = epr.Start_Date__c;
                                         wrap.jobtype = epr.Job_TypeMP__c;
                                         wrap.recid = epr.id;
                                         wrap.isExecuted =epr.isExecuted__c;
                                         TimeZone tz = UserInfo.getTimeZone();
                                         DateTime dt = epr.CreatedDate;
                                         DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                         wrap.createdDate =dateTimeCreatedDate;
                                         wrap.createdUser = epr.Createdby.Name;
                                         wrap.hasChecked = false;
                                         wrap.status = epr.Status__c;
                                         wrap.comment = epr.Comment__c;
                                         wraps.add(wrap);
                                         System.debug('wraps'+wraps);
                                         
                                     }
        
        
        
        set<id>erpIds = new set<id>();
        for(wrapAccount wrap : wraps){
            erpIds.add(wrap.recid);
        }
        
        List<wrapAccount> wraps1 = new List<wrapAccount>();
        for(Epr_History_log__c epr: [SELECT id,Comment__c,isExecuted__c,Account_TypeMP__c,End_Date__c,Job_TypeMP__c,CreatedDate,Createdby.Name,
                                     Start_Date__c,Status__c from Epr_History_log__c  where id !=:erpIds
                                     Order By CreatedDate DESC ]){
                                         wrapAccount wrap = new wrapAccount();
                                         wrap.acctype = epr.Account_TypeMP__c;
                                         wrap.endDate =  epr.End_Date__c;
                                         wrap.jobtype = epr.Job_TypeMP__c;
                                         wrap.recid = epr.id;
                                         wrap.startDate = epr.Start_Date__c;
                                         TimeZone tz = UserInfo.getTimeZone();
                                         DateTime dt = epr.CreatedDate;
                                         DateTime dateTimeCreatedDate = dt.addSeconds((tz.getOffset(dt)/1000));
                                         wrap.createdDate = dateTimeCreatedDate;
                                         wrap.createdUser = epr.Createdby.Name;
                                         wrap.hasChecked = false;
                                         wrap.status = epr.Status__c;
                                         wrap.comment = epr.Comment__c;
                                         wrap.isExecuted =epr.isExecuted__c;
                                         wraps1.add(wrap);
                                     }
        getall.wrap1 = wraps;
        getall.wrap2 = wraps1;
        return getall;
    }
    public class getAllEPrsforCmp {
        @AuraEnabled
        public List<wrapAccount> wrap1 {get; set;}
        @AuraEnabled
        public  List<wrapAccount> wrap2 {get; set;}
        public getAllEPrsforCmp() {
            wrap1 = new list<wrapAccount>();
            wrap2 = new list<wrapAccount>();
        }
    }
    public class wrapAccount {
        @AuraEnabled
        public String acctype {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public Date startDate {get; set;}
        @AuraEnabled
        public Date endDate {get; set;}
        @AuraEnabled
        public DateTime createdDate {get; set;}
        @AuraEnabled
        public String createduser {get; set;}
        @AuraEnabled
        public String jobtype {get; set;}
        @AuraEnabled
        public String recid {get; set;}
        @AuraEnabled
        public String comment {get; set;}
        @AuraEnabled
        public Boolean hasChecked {get; set;}
        @AuraEnabled
        public Date scheduledDate {get; set;}
        @AuraEnabled
        public Decimal paytotal {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @auraEnabled
        public Boolean editDisbale{get;set;}
        @auraEnabled
        public Boolean isExecuted{get;set;}
        
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapAccount() {
            createdDate = null;
            createdUser = '';
            Name =comment  =acctype = status =jobtype =recid ='';
            scheduledDate = startDate =endDate= null;
            isExecuted = hasChecked = false; paytotal =0;editDisbale= true;
        }
    }
    public class wrapAccountNew {
        @auraEnabled
        public List<wrapAccount> wraps {get; set;}
        @auraEnabled
        public Boolean hasRecordtoShow {get; set;}
        
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapAccountNew() {
            wraps = new List<wrapAccount> ();
            hasRecordtoShow = false;
        }
    }
    public class eprWrap {
        @AuraEnabled
        public Decimal recordCount {get; set;}
        @AuraEnabled
        public dECIMAL payTotal {get; set;}
        PUBLIC eprWrap(){
            payTotal = recordCount =0;
        }
    } 
}

//testHM