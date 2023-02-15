public with sharing class FinanceAppController implements Metadata.DeployCallback {
    @AuraEnabled
    public static List<Exchequer_Export_Job__c> getJobs() {
		return [
            SELECT Id, Name, Job_Category__c, Status__c, User__r.Name, Completed__c, Submitted__c, Start_Date__c, End_Date__c
            FROM Exchequer_Export_Job__c
            WHERE Start_Date__c >: Date.today() - 62 OR End_Date__c >: Date.today() - 62 OR (Start_Date__c <: Date.today() + 3 AND End_Date__c >: Date.today() - 62)
        ];
    }
    
    @AuraEnabled
    public static Map<String, List<sObject>> getInfoFromDateRange(String type, Date startDate, Date endDate) {
        Map<String, List<sObject>> resultMap = new Map<String, List<sObject>>();
        
        
/*        
        if (type != null && type.split(' ').size() != 1) {
            resultMap.put('Invoices' , [SELECT Id FROM Customer_Invoice__c WHERE Date__c >=: startDate AND Date__c <=: endDate
                               						  AND Account__r.Account_Type__c =: type.split(' ').get(1)]);
            resultMap.put('Refunds' , [SELECT Id FROM asp04__Refund__c WHERE
                                  				asp04__Payment_Date__c >=: startDate AND asp04__Payment_Date__c <=: endDate
                          AND Account__r.Account_Type__c =: type.split(' ').get(1)]);
            resultMap.put('Accounts' , [SELECT Id FROM Account WHERE
                        CreatedDate >=: startDate AND CreatedDate <=: endDate AND Account_Type__c =: type.split(' ').get(1)]);
        } else {
            resultMap.put('Invoices' , [SELECT Id FROM Customer_Invoice__c WHERE Date__c >=: startDate AND Date__c <=: endDate]);
            resultMap.put('Refunds' , [SELECT Id  FROM asp04__Refund__c WHERE
                                  				asp04__Payment_Date__c >=: startDate AND asp04__Payment_Date__c <=: endDate]);
            resultMap.put('Accounts' , [SELECT Id FROM Account WHERE
                        CreatedDate >=: startDate AND CreatedDate <=: endDate AND Account_Type__c =: type]);
        }*/
        
		resultMap.put('Invoices' , [
            SELECT Id FROM Customer_Invoice__c 
            WHERE Date__c >=: startDate 
            AND Date__c <=: endDate 
            AND id NOT IN (SELECT Customer_Invoice__c FROM asp04__Payment__c  
            WHERE asp04__Payment_Date__c >=: startDate 
            AND asp04__Payment_Date__c <=: endDate
            AND asp04__Payment_Stage__c = 'Collected from customer'
            AND asp04__Payment_Route_Selected__c = 'Card'
            AND Is_SRI_Candidate__c = TRUE)
        ]);
         
        resultMap.put('MatchedInvoices' , [
            SELECT Id FROM asp04__Payment__c  
            WHERE asp04__Payment_Date__c >=: startDate 
            AND asp04__Payment_Date__c <=: endDate
            AND asp04__Payment_Stage__c = 'Collected from customer'
            AND asp04__Payment_Route_Selected__c = 'Card'
            AND Is_SRI_Candidate__c = TRUE
        ]);
        
        resultMap.put('Payments' , [
            SELECT Id FROM asp04__Payment__c  
            WHERE asp04__Payment_Date__c >=: startDate 
            AND asp04__Payment_Date__c <=: endDate 
            AND Is_SRI_Candidate__c = FALSE
            AND asp04__Payment_Stage__c = 'Collected from customer'
            AND asp04__Payment_Route_Selected__c = 'Card'
        ]);
        
        resultMap.put('Accounts' , [
            SELECT Id FROM Account 
            WHERE CreatedDate >=: startDate 
            AND CreatedDate <=: endDate 
        ]);
         resultMap.put('Refunds' , [
             SELECT Id FROM asp04__Refund__c 
             WHERE asp04__Payment_Date__c >=: startDate 
             AND asp04__Payment_Date__c <=: endDate
             AND asp04__Payment_Route__c = 'Card'
             AND asp04__Refund_Stage__c = 'Refunded to customer'
         ]);
        resultMap.put('CreditNotes' , [
            SELECT Id FROM Customer_Credit_Note__c 
            WHERE Date__c >=: startDate AND Date__c <=: endDate
        ]);
        resultMap.put('SupplierInvoices' , [
            SELECT Id FROM Supplier_Invoice__c 
            WHERE Invoice_Date__c >=: startDate 
            AND Invoice_Date__c <=: endDate]);
        
        resultMap.put('SupplierCreditNotes' , [
            SELECT Id FROM Supplier_Credit_Note__c 
            WHERE Supplier_Credit_Note_Date__c >=: startDate AND Supplier_Credit_Note_Date__c <=: endDate
        ]);
        return resultMap;
    }

    @AuraEnabled
    public static Map<String, Integer> getDataFromDateRange(String type, Date startDate, Date endDate) {
        Map<String, List<sObject>> newMap = FinanceAppController.getInfoFromDateRange(type, startDate, endDate);
        Map<String, Integer> resultMap = new Map<String, Integer>();
        resultMap.put('Invoices' , newMap.get('Invoices').size());
        resultMap.put('MatchedInvoices' , newMap.get('MatchedInvoices').size());
        resultMap.put('Payments' , newMap.get('Payments').size());
        resultMap.put('Refunds' , newMap.get('Refunds').size());
        resultMap.put('CreditNotes' , newMap.get('CreditNotes').size());
        resultMap.put('Accounts' , newMap.get('Accounts').size());
        return resultMap;
    }

    @AuraEnabled
    public static Date getStartDateFromMetadata(String type) {
        Date result;
        List<Finance_App_Date_Ranges__mdt> mcs = Finance_App_Date_Ranges__mdt.getAll().values();
        for (Finance_App_Date_Ranges__mdt range : mcs) {
            if (range.Job_Category__c == type) {
                result = range.Start_Date__c;
            }
        }
        return result;
    }

    @AuraEnabled
    public static void createExportJob(String type, Date startDate, Date endDate) {
        List<Exchequer_Export_Job__c> pJob = [
            SELECT Id, Name, Job_Category__c
            FROM Exchequer_Export_Job__c
            WHERE Job_Category__c =: 'Purchases'
            OR Job_Category__c =: 'Engineer Costs'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        List<Exchequer_Export_Job__c> sJob = [
            SELECT Id, Name, Job_Category__c
            FROM Exchequer_Export_Job__c
            WHERE Job_Category__c =: 'Sales Cash'
            OR Job_Category__c =: 'Sales Credit'
            OR Job_Category__c =: 'Sales Key'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Exchequer_Export_Job__c job = new Exchequer_Export_Job__c();
        if (pJob.size() == 0 && (type == 'Purchases' || type == 'Engineer Costs')) {
            job.Name = 'P1';
        } else if (sJob.size() == 0 && (type != 'Purchases' && type != 'Engineer Costs')) {
            job.Name = 'S1';
        } else if (sJob.size() != 0 && pJob.size() != 0) {
            Integer pNumber = Integer.valueOf(pJob[0].Name.split('P')[1]);
            Integer sNumber = Integer.valueOf(sJob[0].Name.split('S')[1]);
            job.Name = type == 'Purchases' || type == 'Engineer Costs' ? 'P' + ++pNumber : 'S' + ++sNumber;
        }
        job.Job_Category__c = type;
        job.Status__c = 'Queued';
        job.User__c = UserInfo.getUserId();
        job.Submitted__c = System.now();
        job.Start_Date__c = startDate;
        job.End_Date__c = endDate;
        insert job;
		
        Map<String, List<SObject>> newMap = FinanceAppController.getInfoFromDateRange(type, startDate, endDate);
        List <FinanceImportFiles.CSVObjectWrapper1> csvObjectWrapperList1 = new List<FinanceImportFiles.CSVObjectWrapper1>();
        FinanceImportFiles.CSVObjectWrapper1 wrap = new FinanceImportFiles.CSVObjectWrapper1();
        
        System.debug('in FinanceAppController1 limits.getLimitHeapSize() >>> '+limits.getLimitHeapSize());
        System.debug('in FinanceAppController1 limits.getHeapSize() >>> '+limits.getHeapSize());
        
        
        wrap.excJobRecId = job.Id;
        wrap.accList = newMap.get('Accounts');
        newMap.remove('Accounts');
        wrap.custCreditNoteList = newMap.get('CreditNotes');
        newMap.remove('CreditNotes');
        //[SELECT Id FROM Customer_Credit_Note__c WHERE Date__c >: startDate AND Date__c <: endDate];
        wrap.suppInvoiceList = newMap.get('SupplierInvoices');
        newMap.remove('SupplierInvoices');
        //[SELECT Id FROM Supplier_Invoice__c WHERE Invoice_Date__c >: startDate AND Invoice_Date__c <: endDate];
        wrap.refundList = newMap.get('Refunds');
         newMap.remove('Refunds');
        //[SELECT Id FROM asp04__Refund__c WHERE asp04__Payment_Date__c >: startDate AND asp04__Payment_Date__c <: endDate];
        wrap.custInvoiceList = newMap.get('Invoices');
         newMap.remove('Invoices');
        //[ SELECT Id FROM Customer_Invoice__c WHERE Date__c >: startDate AND Date__c <: endDate];
        wrap.paymentList = newMap.get('Payments');
        System.debug('*** newMap get Payments: '+newMap.get('Payments'));
         newMap.remove('Payments');
        System.debug('*** wrap: '+wrap.paymentList);
        
         wrap.MatchedInvoiceList = newMap.get('MatchedInvoices');
         newMap.remove('MatchedInvoices');
        //[SELECT Id FROM asp04__Payment__c WHERE asp04__Payment_Date__c >: startDate AND asp04__Payment_Date__c <: endDate AND Is_SRI_Candidate__c = FALSE];
        wrap.suppCreditNoteList = newMap.get('SupplierCreditNotes');
         newMap.remove('SupplierCreditNotes');
        //[SELECT Id FROM Supplier_Credit_Note__c WHERE Supplier_Credit_Note_Date__c >: startDate AND Supplier_Credit_Note_Date__c <: endDate];
        csvObjectWrapperList1.add(wrap);
     
        System.debug('in FinanceAppController2 limits.getLimitHeapSize() >>> '+limits.getLimitHeapSize());
        System.debug('in FinanceAppController2 limits.getHeapSize() >>> '+limits.getHeapSize());
        
        System.enqueueJob(new FinanceImportFiles(csvObjectWrapperList1));
        FinanceAppController.updateMetadataDate(endDate, type);
    }

    @future
    public static void updateMetadataDate(Date endDate, String type) {
        List<Finance_App_Date_Ranges__mdt> mcs = Finance_App_Date_Ranges__mdt.getAll().values();
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for (Finance_App_Date_Ranges__mdt range : mcs) {
            if (range.Job_Category__c == type) {
                Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
                customMetadata.fullName = 'Finance_App_Date_Ranges.' + range.QualifiedApiName;
                customMetadata.label = range.label;

                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = 'Start_Date__c';
                customField.value = endDate + 1;
                customMetadata.values.add(customField);

                mdContainer.addMetadata(customMetadata);
            }
        }
        FinanceAppController callback = new FinanceAppController();
        if (!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('Success: ' + result);
        } else {
            System.debug('Fail: ' + result);
        }
    }
       
}