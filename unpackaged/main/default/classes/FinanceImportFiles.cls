/*
* Class  : FinanceImportFiles
* Use    : This class is written to create and email files of some records which going to
*          to be used in finance system.
* Auther : Bharat Vyas, 17/10/2022
*/

public class FinanceImportFiles implements Queueable{
    
    public static String regExp = '(?:\\n|\\r)';
    public static List<ContentVersion> csvFileList = new List<ContentVersion>();
    public static List<ContentDocumentLink> contDocList = new List<ContentDocumentLink>();
    public CSVObjectWrapper1 csvObjectWrapper1 {get; set;}
    
    public FinanceImportFiles(List<CSVObjectWrapper1> csvObjectWrapperList1){
        CSVObjectWrapper1 = csvObjectWrapperList1[0];
        System.debug('In FinanceImportFiles Constructor >>>');
    }
    
    public void execute(QueueableContext context){
        System.debug('in execute');
        
        createCustomerAccountCSV(CSVObjectWrapper1.accList);
        CSVObjectWrapper1.accList.clear();
        createSalesRefundWithCreditNoteCSV(CSVObjectWrapper1.custCreditNoteList);
        CSVObjectWrapper1.custCreditNoteList.clear();
        createSuplierInvoiceCSV(CSVObjectWrapper1.suppInvoiceList);
        CSVObjectWrapper1.suppInvoiceList.clear();
        createSalesInvoiceAndPaymentRefundCSV(CSVObjectWrapper1.refundList);
        CSVObjectWrapper1.refundList.clear();
        createSalesInvoiceCSV(CSVObjectWrapper1.custInvoiceList);
        CSVObjectWrapper1.custInvoiceList.clear();
        createSalesInvoiceAndPaymentCSV(CSVObjectWrapper1.MatchedInvoiceList);
        CSVObjectWrapper1.MatchedInvoiceList.clear();
        System.debug('***CSVObjectWrapper1.paymentList: '+ CSVObjectWrapper1.paymentList);
        createSalesInvoiceAndPaymentPaymentCSV(CSVObjectWrapper1.paymentList);
        CSVObjectWrapper1.paymentList.clear();
        createPurchasecreditCSV(CSVObjectWrapper1.suppCreditNoteList);
        CSVObjectWrapper1.suppCreditNoteList.clear();
       
        if(!csvFileList.isEmpty()){
            insert csvFileList;
            System.debug('csvFileList >>> '+csvFileList);
            
            Set<Id> filesIdSet = new Set<Id>(new Map<Id, ContentVersion>(csvFileList).keySet());
            for (ContentVersion conVer : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: filesIdSet]){
                
                ContentDocumentLink contDocLink = New ContentDocumentLink();
                contDocLink.LinkedEntityId = CSVObjectWrapper1.excJobRecId;
                contDocLink.ContentDocumentId = conVer.ContentDocumentId;
                contDocLink.shareType = 'I';
                contDocList.add(contDocLink);
            }
            if(!contDocList.isEmpty()){
                Insert contDocList;
                System.debug('contDocList >>> '+contDocList);
                
                Exchequer_Export_Job__c excJob = new Exchequer_Export_Job__c(Id = CSVObjectWrapper1.excJobRecId);
                excJob.Status__c = 'Completed';
                excJob.Completed__c = system.now();
                update excJob;
                System.debug('Updated >>> '+excJob);
            }
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setBody('Hello User,\nPlease find the attached CSV files for Finance Import in related list of Exchequer job.');
            notification.setTitle('Files are ready!');
         // notification.setSenderId(Userinfo.getUserId());
            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Alert_User_when_Finance_Import_csvs_are_ready'];
            notification.setNotificationTypeId(type.id);
            notification.setTargetId(CSVObjectWrapper1.excJobRecId); // target object id
            notification.send(new Set<String> { Userinfo.getUserId() });
        }
		
    }
    
    public class CSVObjectWrapper1{
        
        public String excJobRecId {get; set;}
        public List<Account> accList {get; set;}
        public List<Customer_Credit_Note__c> custCreditNoteList {get; set;}
        public List<Supplier_Invoice__c> suppInvoiceList {get; set;}
        public List<asp04__Refund__c> refundList {get; set;}
        public List<Customer_Invoice__c> custInvoiceList {get; set;}
        public List<asp04__Payment__c> paymentList {get; set;}
        public List<asp04__Payment__c> MatchedInvoiceList {get; set;}
        public List<Supplier_Credit_Note__c> suppCreditNoteList {get; set;}
    }
    
     public static void createCustomerAccountCSV(List<Account> accList){
        /* Example -
		 * Record_Type,CUAccount_Code,Company_Name,Country_Code,Contact_Name,Address_Line_1,Address_Line_2,Address_Line_3,Address_Line_4,Address_Line_5,Post_Code,Email_Address,Telephone_No,Fax_No,Account_Status_0,Default_Payment_Terms_0,Currency_1,VAT_Code_2,VAT_Reg_No,Payment_Type_C,Cost_Centre,Department,Send_HTML_when_sending_XML_N,Send_Invoice,Send_Reader_with_next_e_mail_Y,Send_Statements,Statement_Account_Code,Credit_Limit_0,User_Defined_Field_10_0
         * "CU","A89684","Aadam Malik","GB","","24 Helena Road,null","Waltham Forest","","","United Kingdom","E17 7PY","onemalik@gmail.com","07947 424 620","","0","0","1","20","","B","AAA","AAA","Y","4","Y","4","","0","0014G000032iWvMQAU"
		*/
                
        String header = 'Record_Type, CUAccount_Code, Company_Name, Country_Code, Contact_Name, Address_Line_1, Address_Line_2,';
        header = header + 'Address_Line_3, Address_Line_4, Address_Line_5, Post_Code,Email_Address, Telephone_No, Fax_No,';
        header = header + 'Account_Status_0, Default_Payment_Terms_0, Currency_1,VAT_Code_2, VAT_Reg_No,Payment_Type_C,';
        header = header + 'Cost_Centre, Department, Send_HTML_when_sending_XML_N, Send_Invoice, Send_Reader_with_next_e_mail_Y,'; 
        header = header + 'Send_Statements,Statement_Account_Code,Credit_Limit_0,User_Defined_Field_10_0 \n';
        String finalstr = header ;
       
        Set<Id> resultIds = (new Map<Id,SObject>(accList)).keySet();
         for(Account acc : [SELECT Id, Name, Account_Reference__c, BillingStreet, BillingCity, BillingState, 
                            BillingCountry, BillingPostalCode, Email__c, Phone, Account_Status__c, Account_Type__c, 
                            CurrencyIsoCode, VAT_Registration_Number__c, Credit_Limit__c FROM Account WHERE Id =: resultIds]) {
                                
                                String name, street, city, state, country, postalCode, accStatus, accType, curncy, regNumber, credLimit, costCentre;
                                name = acc.Name.replaceAll(regExp, ',');
                                if(acc.BillingStreet != NULL){
                                    street = acc.BillingStreet.replaceAll(regExp, ',');
                                }
                                if(acc.BillingCity != NULL){
                                    city = acc.BillingCity.replaceAll(regExp, ',');
                                }
                                if(acc.BillingState != NULL){
                                    state = acc.BillingState.replaceAll(regExp, ',');
                                }
                                if(acc.BillingCountry != NULL){
                                    country = acc.BillingCountry.replaceAll(regExp, ',');
                                }
                                if(acc.BillingPostalCode != NULL){
                                    postalCode = acc.BillingPostalCode.replaceAll(regExp, ',');
                                }
                                accStatus = acc.Account_Status__c.equals('Open')? '0':'';
                                if(acc.Account_Type__c != NULL){    ////////
                                    accType = acc.Account_Type__c.equals('Credit')?'30':'0';
                                }
                                if(acc.CurrencyIsoCode == NULL || acc.CurrencyIsoCode.equals('GBP')){
                                    curncy = '1';
                                }
                                else{
                                    curncy = '2';
                                }
                                if(acc.VAT_Registration_Number__c != NULL){
                                    regNumber = acc.VAT_Registration_Number__c.replaceAll(regExp, ',');
                                }
                                if(acc.Account_Type__c != NULL){    ////////
                                    costCentre = acc.Account_Type__c.equals('Credit')?'AC':'AAA';
                                }
                                if(acc.Credit_Limit__c == NULL ){
                                    credLimit = '0';
                                }
                                String recordString = '"CU",'+'"'+acc.Account_Reference__c+'",'+'"'+name+'","GB","",'+'"'+street+'",';
                                recordString = recordString+'"'+city+'",'+'"'+state+'","",'+'"'+country+'",';
                                recordString = recordString+'"'+postalCode+'",'+'"'+acc.Email__c+'",'+'"'+acc.Phone+'","",';
                                recordString = recordString+'"'+accStatus+'",'+'"'+accType+'",'+'"'+curncy+'",';
                                recordString = recordString+'"20",'+'"'+regNumber+'","B",'+'"'+costCentre+'",';
                                recordString = recordString+'"AAA","Y","4","Y","4","",'+'"'+credLimit+'",'+'"'+acc.Id+'"'+ '\n';
                                finalstr = finalstr +recordString;
                            }
         
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'CustomerAccount'; 
         csvFile.PathOnClient = 'CustomerAccount.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
         // sendEmailAttCSV(finalstr, 'CustomerAccount');
         csvFile = NULL;
         finalstr = NULL;
         resultIds.clear();
         accList.clear();
    }
    
    public static void createSalesRefundWithCreditNoteCSV(List<Customer_Credit_Note__c> custCreditNoteList){
        /*Example -
         * Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,UDF1,UDF2,UDF3,Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code,Payment_Line,Pay_Ref
         *"RL","INV-113323","SCR","A81530","20-06-2022","","CCR-004312","INV-113323","","","","Penthouse building 6,15-25 und","Hackney","","United Kingdom","United Kingdom","N1 7LG","67.5","13.5","","","","","13.5","81.0","INV-113323","AAA","1","67.5","13.5","2","AAA","AAA","52080","N",""
		*/
                
        String header = 'Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,UDF1,UDF2,UDF3,';
        header = header + 'Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,';
        header = header + 'VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,';
        header = header + 'Total_Invoiced,Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,'; 
        header = header + 'Cost_Centre,GL_Code,Payment_Line,Pay_Ref \n';
        String finalstr = header ;
		
        Set<Id> resultIds = (new Map<Id,SObject>(custCreditNoteList)).keySet();
        for(Customer_Credit_Note__c crNotes : [SELECT Id, Name, Invoice_Number__c, Account_Number__c,
                                               Date__c, Billing_Address_Street__c, Billing_Address_City__c,
                                               Billing_Address_Country__c, Billing_Address_Postcode__c,
                                               Charge_Net__c, Charge_Gross__c, Customer_Record_Type__c,
                                               Gl_Code_Number__c FROM Customer_Credit_Note__c WHERE Id =: resultIds]) {
                                                   
                                                   String recordType, accountCode, dateCr, street, city, country, postalCode, lineDesc;
                                                   
                                                   Decimal chargeDiff = crNotes.Charge_Gross__c - crNotes.Charge_Net__c;
                                                   if(crNotes.Customer_Record_Type__c.equals('Commercial')) 
                                                       recordType = 'AC';
                                                   else
                                                       recordType = 'AAA';
                                                   if(crNotes.Account_Number__c != NULL) 
                                                       accountCode = crNotes.Account_Number__c.replaceAll(regExp, ',');
                                                   if(crNotes.Date__c != NULL){
                                                       date myDate = crNotes.Date__c;
                                                       dateCr = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                                   } 
                                                   if(crNotes.Billing_Address_Street__c != NULL){
                                                       street = crNotes.Billing_Address_Street__c.replaceAll(regExp, ',');
                                                       street = street.left(30);
                                                   }
                                                   if(crNotes.Billing_Address_City__c != NULL){
                                                       city = crNotes.Billing_Address_City__c.replaceAll(regExp, ',');
                                                   }
                                                   if(crNotes.Billing_Address_Country__c != NULL){
                                                       country = crNotes.Billing_Address_Country__c.replaceAll(regExp, ',');
                                                   }
                                                   if(crNotes.Billing_Address_Postcode__c != NULL){
                                                       postalCode = crNotes.Billing_Address_Postcode__c.replaceAll(regExp, ',');
                                                   }
                                                   if(crNotes.Invoice_Number__c != NULL )lineDesc = crNotes.Invoice_Number__c.left(45);
                                                   
                                                   String recordString = '"RL",'+'"'+crNotes.Invoice_Number__c+'","SCR",'+'"'+accountCode+'",';
                                                   recordString = recordString+'"'+dateCr+'","",'+'"'+crNotes.Name+'",'+'"'+crNotes.Invoice_Number__c+'",';
                                                   recordString = recordString+'"","","",'+'"'+street+'",'+'"'+city+'",'+'"",'+'"'+country+'",'+'"'+country+'",';
                                                   recordString = recordString+'"'+postalCode+'",'+'"'+crNotes.Charge_Net__c+'",'+'"'+chargeDiff.toPlainString()+'",';
                                                   recordString = recordString+'"","","","",'+'"'+chargeDiff.toPlainString()+'",'+'"'+crNotes.Charge_Gross__c+'",'+'"'+lineDesc+'",';
                                                   recordString = recordString+'"'+recordType+'","1",'+'"'+crNotes.Charge_Net__c+'",'+'"'+chargeDiff.toPlainString()+'",';
                                                   recordString = recordString+'"2","AAA",'+'"'+recordType+'",'+'"'+crNotes.Gl_Code_Number__c+'","N",""' +'\n';
                                                   finalstr = finalstr +recordString;
                                               }
        
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'SalesRefundWithCreditNote'; 
         csvFile.PathOnClient = 'SalesRefundWithCreditNote.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
        // sendEmailAttCSV(finalstr, 'SalesRefundWithCreditNote');  
        csvFile = NULL;
        finalstr = NULL;
        resultIds.clear(); 
        custCreditNoteList.clear(); 
    }
    
    public static void createSuplierInvoiceCSV(List<Supplier_Invoice__c> suppInvoiceList){
        /*Example -
		 *RL_Record_Type,Link_Ref,TH_Transaction_Type,Account_Code,Transaction_Date,Due_Date,Your_Ref,YourLongRef,User_Defined_1,User_Defined_2,User_Defined_3,Address_Line_1,Address_Line_2,Address_Line_3,Address_Line_4,Address_Line_5,Delivery_Address_Postcode,Net_Value_0,VAT_Amount_0,VAT_Analysis_Rate_S_0,VAT_Analysis_Rate_Z_0,VAT_Analysis_Rate_E_0,VAT_Analysis_Rate_1_0,VAT_Analysis_Rate_2_0,Total_Invoiced_0,Hold_Status_0,TL_Line_Description,Location_Code,Qty_1,Unit_Price_Cost_Rate_0,VAT_Amount_L0,VAT_Code,Department,Cost_Centre,GL_Code_0
		 *"RL","SI-000160","PIN","WOLSEL","19-10-2021","","SI-000160","78206994","","","","Boroughbridge Rd","Ripon","","","United Kingdom","HG4 1SL","68.66","13.73","","","","","13.73","82.39","","PO-000579","","1","68.66","13.73","2","KK","AAA","63402"
		*/
        
        String header = 'RL_Record_Type,Link_Ref,TH_Transaction_Type,Account_Code,Transaction_Date,Due_Date,Your_Ref,';
        header = header + 'YourLongRef,User_Defined_1,User_Defined_2,User_Defined_3,Address_Line_1,Address_Line_2,';
        header = header + 'Address_Line_3,Address_Line_4,Address_Line_5,Delivery_Address_Postcode,Net_Value_0,VAT_Amount_0,';
        header = header + 'VAT_Analysis_Rate_S_0,VAT_Analysis_Rate_Z_0,VAT_Analysis_Rate_E_0,VAT_Analysis_Rate_1_0,VAT_Analysis_Rate_2_0,'; 
        header = header + 'Total_Invoiced_0,Hold_Status_0,TL_Line_Description,Location_Code,Qty_1,Unit_Price_Cost_Rate_0,VAT_Amount_L0,VAT_Code,Department,Cost_Centre,GL_Code_0 \n';
        String finalstr = header ;
        
		Set<Id> resultIds = (new Map<Id,SObject>(suppInvoiceList)).keySet();
        for(Supplier_Invoice__c suppInvoice : [SELECT Id, Name, Account_Reference__c, Invoice_Date__c, Supplier_Invoice_Number__c,
                                               Supplier_Street__c, Supplier_City__c, Supplier_County__c, Supplier_Postal_Code__c,
                                               Invoice_Value_NET__c, Invoice_Value_VAT__c, Invoice_Value_Gross__c,Purchase_Order_Number__c,
                                               Exchequer_Department_Ref__c, Exchequer_General_Ledger_Code_Number__c FROM Supplier_Invoice__c WHERE Id =: resultIds]) {
                                                   
                                                   String dateTr, street, city, country, postalCode;
                                                   
                                                   if(suppInvoice.Invoice_Date__c != NULL){
                                                       date myDate = suppInvoice.Invoice_Date__c;
                                                       dateTr = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                                   } 
                                                   if(suppInvoice.Supplier_Street__c != NULL){
                                                       street = suppInvoice.Supplier_Street__c.replaceAll(regExp, ',');
                                                   }
                                                   if(suppInvoice.Supplier_City__c != NULL){
                                                       city = suppInvoice.Supplier_City__c.replaceAll(regExp, ',');
                                                   }
                                                   if(suppInvoice.Supplier_County__c != NULL){
                                                       country = suppInvoice.Supplier_County__c.replaceAll(regExp, ',');
                                                   }
                                                   if(suppInvoice.Supplier_Postal_Code__c != NULL){
                                                       postalCode = suppInvoice.Supplier_Postal_Code__c.replaceAll(regExp, ',');
                                                   }
                                                   
                                                   String recordString = '"RL",'+'"'+suppInvoice.Name+'","PIN",'+'"'+suppInvoice.Account_Reference__c+'",'+'"'+dateTr+'",';
                                                   recordString = recordString + '"",'+'"'+suppInvoice.Name+'",'+'"'+suppInvoice.Supplier_Invoice_Number__c+'","","","",';
                                                   recordString = recordString + '"'+street+'",'+'"'+city+'","",'+'"'+country+'",'+'"'+country+'",'+'"'+postalCode+'",';
                                                   recordString = recordString + '"'+suppInvoice.Invoice_Value_NET__c+'",'+'"'+suppInvoice.Invoice_Value_VAT__c+'",';
                                                   recordString = recordString + '"","","","",'+'"'+suppInvoice.Invoice_Value_VAT__c+'",'+'"'+suppInvoice.Invoice_Value_Gross__c+'",';
                                                   recordString = recordString +'"",'+'"'+suppInvoice.Purchase_Order_Number__c+'","","1",'+ '"'+suppInvoice.Invoice_Value_NET__c+'",';
                                                   recordString = recordString + '"'+suppInvoice.Invoice_Value_VAT__c+'","2",'+ '"'+suppInvoice.Exchequer_Department_Ref__c+'",';
                                                   recordString = recordString + '"AAA",'+'"'+suppInvoice.Exchequer_General_Ledger_Code_Number__c+'" \n';
                                                   finalstr = finalstr +recordString;
                                               }
        
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'SupplierInvoice'; 
         csvFile.PathOnClient = 'SupplierInvoice.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
         //sendEmailAttCSV(finalstr, 'SupplierInvoice');
        csvFile = NULL;
        finalstr = NULL;
        resultIds.clear(); 
        suppInvoiceList.clear();
    }
    
    public static void createSalesInvoiceAndPaymentRefundCSV(List<asp04__Refund__c> refundList){
        /*Example -
		 *Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code,Payment_Line,Pay_Ref,UDF1,UDF2,UDF3
		 *"RL","00002916","SRC","A78933","18-05-2022","","RF-000002916","J-056388","2 Broomhill Road","","","","United Kingdom","SW18 4HX","-480.16","","","","","","","-480.16","1e279939-ed54-4221-b8a9-6f042418de95","AAA","1","-480.16","0","","AAA","AAA","20015","Y","OWPRFND1805","","",""		
		*/
		
		String header = 'Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,';
        header = header + 'Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,';
        header = header + 'VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,';
        header = header + 'Cost_Centre,GL_Code,Payment_Line,Pay_Ref,UDF1,UDF2,UDF3 \n';
        String finalstr = header ;
		
        Set<Id> resultIds = (new Map<Id,SObject>(refundList)).keySet();
        for(asp04__Refund__c refund  : [ SELECT Id, Name, Account_Number__c,asp04__Payment_Date__c,Job_Number__c,
                                        Billing_Address_Street__c, Billing_Address_City__c, Billing_Address_Country__c,
                                        Billing_Address_Postcode__c, asp04__Amount__c, PSP_Reference__c, 
                                        Customer_Record_Type__c, Card_Type__c FROM asp04__Refund__c WHERE Id =: resultIds]){
                                                
                                                String payDate, netAmt, recordType, accCode, street, city, country, postalCode, payRef;
                                                
                                                if(refund.Account_Number__c != NULL){
                                                    accCode = refund.Account_Number__c.replaceAll(regExp, ',');
                                                }
                                                if(refund.asp04__Payment_Date__c != NULL){
                                                    date myDate = refund.asp04__Payment_Date__c;
                                                    payDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                                }
                                                if(refund.Billing_Address_Street__c != NULL){
                                                    street = refund.Billing_Address_Street__c.replaceAll(regExp, ',');
                                                }
                                                if(refund.Billing_Address_City__c != NULL){
                                                    city = refund.Billing_Address_City__c.replaceAll(regExp, ',');
                                                }
                                                if(refund.Billing_Address_Country__c != NULL){
                                                    country = refund.Billing_Address_Country__c.replaceAll(regExp, ',');
                                                }
                                                if(refund.Billing_Address_Postcode__c != NULL){
                                                    postalCode = refund.Billing_Address_Postcode__c.replaceAll(regExp, ',');
                                                }
                                                if(refund.asp04__Amount__c != NULL){
                                                    netAmt = String.valueOf(-1*refund.asp04__Amount__c);
                                                }
                                                else netAmt = '0';
                                                if(refund.Customer_Record_Type__c == NULL){
                                                    recordType = 'AAA';
                                                }
                                                else if(refund.Customer_Record_Type__c.equals('Commercial')){
                                                    recordType = 'AC';
                                                }
                                                else
                                                    recordType = 'AAA';                
                                                if(refund.Card_Type__c != NULL){
                                                    String cardType = refund.Card_Type__c;
                                                    if(cardType.equalsIgnoreCase('American Express')){
                                                        payRef = 'AMEXRFND';
                                                    }
                                                    else payRef = 'OWPRFND';
                                                    
                                                    if(payDate != NULL) payRef = payRef+payDate.split('-')[0]+payDate.split('-')[1];
                                                }
                                                
                                                String recordString = '"RL",'+'"'+refund.Name.right(8)+'","SRC",'+'"'+accCode+'",'+'"'+payDate+'","",'+'"'+refund.Name+'",';
                                                recordString = recordString +'"'+refund.Job_Number__c+'",'+'"'+street+'",'+'"'+city+'","","",'+'"'+country+'",'+'"'+postalCode+'",';
                                                recordString = recordString +'"'+netAmt+'","","","","","","",'+'"'+netAmt+'",'+'"'+refund.PSP_Reference__c+'",';
                                                recordString = recordString +'"'+recordType+'","1",'+'"'+netAmt+'","0","","AAA",'+'"'+recordType+'","20015","Y",';
                                                recordString = recordString +'"'+payRef+'","","","" \n';
                                                finalstr = finalstr +recordString;
                                            }   
                                            
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'SalesInvoiceAndPaymentRefund'; 
         csvFile.PathOnClient = 'SalesInvoiceAndPaymentRefund.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
        // sendEmailAttCSV(finalstr, 'SalesInvoiceAndPaymentRefund');
        csvFile = NULL;
        finalstr = NULL;
        resultIds.clear();
        refundList.clear();
    }
   
    public static void createSalesInvoiceCSV(List<Customer_Invoice__c> custInvoiceList){
        /*Example --
		 *Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,UDF1,UDF2,UDF3,Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code
		 *"RL","INV-091847","SIN","A70840","13-01-2022","","INV-091847","J-035404","","","","14 Percy Gardens,null","Hounslow","","","United Kingdom","TW7 6BX","301.75","60.35","","","","","60.35","362.1","INV-091847","AAA","1","301.75","60.35","2","AAA","AAA","52072"	
		*/
        
        String header = 'Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,UDF1,UDF2,UDF3,';
        header = header + 'Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,';
        header = header + 'VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,';
        header = header + 'Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code \n';
        String finalstr = header ;
		
        Set<Id> resultIds = (new Map<Id,SObject>(custInvoiceList)).keySet();
        for(Customer_Invoice__c invoice : [SELECT Id, Name, Exchequer_Account_Reference__c, Account_Number__c,
                                           Date__c, Job_Number__c, Billing_Street__c, Billing_Town__c,
                                           Billing_Country__c, Billing_Postcode__c, Charge_Net__c,
                                           Charge_Gross__c, Account_Record_Type_Name__c, Exchequer_General_Ledger_Code_Number__c
                                           FROM Customer_Invoice__c WHERE Id =: resultIds]){
                                               
                                               String invDate, vatAmt, recordType, accCode, street, town, country, postalCode, unitPrice;
                                               
                                               vatAmt = String.valueOf(invoice.Charge_Gross__c - invoice.Charge_Net__c);
                                               if(invoice.Charge_Net__c == NULL){
                                                   unitPrice = '0';
                                               }
                                               else{
                                                   unitPrice = String.valueOf(invoice.Charge_Net__c);
                                               }
                                               if(invoice.Exchequer_Account_Reference__c != NULL){
                                                   accCode = invoice.Exchequer_Account_Reference__c.replaceAll(regExp, ',');
                                               }
                                               else if(invoice.Account_Number__c != NULL){
                                                   accCode = invoice.Account_Number__c.replaceAll(regExp, ',');
                                               }
                                               if(invoice.Date__c != NULL){
                                                   date myDate = invoice.Date__c;
                                                   invDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                               }
                                               if(invoice.Billing_Street__c != NULL){
                                                   street = invoice.Billing_Street__c.replaceAll(regExp, ',');
                                               }
                                               if(invoice.Billing_Town__c != NULL){
                                                   town = invoice.Billing_Town__c.replaceAll(regExp, ',');
                                               }
                                               if(invoice.Billing_Country__c != NULL){
                                                   country = invoice.Billing_Country__c.replaceAll(regExp, ',');
                                               }
                                               if(invoice.Billing_Postcode__c != NULL){
                                                   postalCode = invoice.Billing_Postcode__c.replaceAll(regExp, ',');
                                               }
                                               if(invoice.Account_Record_Type_Name__c.equals('Commercial')){
                                                   recordType = 'AC';
                                               }
                                               else{
                                                   recordType = 'AAA'; 
                                               }    
                                               
                                               String recordString = '"RL",'+'"'+invoice.Name+'","SIN",'+'"'+accCode+'",'+'"'+invDate+'","",'+'"'+invoice.Name+'",';
                                               recordString = recordString +'"'+invoice.Job_Number__c+'","","","",'+'"'+street+'",'+'"'+town+'","","",'+'"'+country+'",';
                                               recordString = recordString +'"'+postalCode+'",'+'"'+invoice.Charge_Net__c+'",'+'"'+vatAmt+'","","","","",';
                                               recordString = recordString +'"'+vatAmt+'",'+'"'+invoice.Charge_Gross__c+'",'+'"'+invoice.Name.left(45)+'",'+'"'+recordType+'",';
                                               recordString = recordString +'"1",'+'"'+unitPrice+'",'+'"'+vatAmt+'","2","AAA",'+'"'+recordType+'",'+'"'+invoice.Exchequer_General_Ledger_Code_Number__c+'" \n';
                                               finalstr = finalstr +recordString;
                                           }
        
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'SalesInvoice'; 
         csvFile.PathOnClient = 'SalesInvoice.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
       // sendEmailAttCSV(finalstr, 'SalesInvoice');
        csvFile = NULL;
        finalstr = NULL; 
        resultIds.clear();
         custInvoiceList.clear();
    }
    
    public static void createSalesInvoiceAndPaymentCSV(List<asp04__Payment__c> paymentList){
        
        /*Example -- (2 entries at a time first for Invoice and second for Payment of that Invoice)
		*Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code,Payment_Line,Pay_Ref,UDF1,UDF2,UDF3
		*"RL","INV-128956","SRI","39502","30-09-2022","","INV-128956","J-085822","6th Floor,86 Jermyn Street","","","","","SW1Y 6JD","85.0","17.0","","","","","17.0","102.0","PAY-000077227","AAA","1","85.0","17.0","2","AAA","AAA","52037","N","","","",""
		*"RL","INV-128956","SRI","39502","01-10-2022","","INV-128956","J-085822","Flat 4 Park View","83-86 Prince Albert Road","","","United Kingdom","NW8 7RU","85.0","17.0","","","","","17.0","102.0","","AAA","","102.0","","","AAA","AAA","20015","Y","OWP0110","","",""
		*/
        
        String header = 'Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,Del_Add_1,Del_Add_2,Del_Add_3,';
        header = header + 'Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,';
        header = header + 'VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,';
        header = header + 'Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code,Payment_Line,Pay_Ref,UDF1,UDF2,UDF3 \n';
        String finalstr = header ;
		
        Set<Id> resultIds = (new Map<Id,SObject>(paymentList)).keySet();
        for(asp04__Payment__c paymtInv : [SELECT Id, Name, Customer_Invoice_Name__c, asp04__Payment_Date__c, Account_Number__c, asp04__Due_Date__c,
                                          asp04__Billing_Address_Street__c, asp04__Billing_Address_City__c, asp04__Billing_Address_Country__c,
                                          asp04__Billing_Address_PostalCode__c, asp04__Amount__c, asp04__PSP_Reference__c, Job_Number__c,
                                          Customer_Record_Type__c, asp04__Card_Type__c, Customer_Invoice__r.Name, Customer_Invoice__r.Account_Number__c, 
                                          Customer_Invoice__r.Date__c, Customer_Invoice__r.Job_Number__c, Customer_Invoice__r.Billing_Street__c, 
                                          Customer_Invoice__r.Billing_Town__c, Customer_Invoice__r.Billing_Country__c, Customer_Invoice__r.Billing_Postcode__c,
                                          Customer_Invoice__r.Charge_Gross__c, Customer_Invoice__r.Charge_Net__c, Customer_Invoice__r.Account_Record_Type_Name__c, 
                                          Customer_Invoice__r.Exchequer_General_Ledger_Code_Number__c FROM asp04__Payment__c  WHERE Id =: resultIds]){
                                              
                                              String payAccCode, payDate, payDueDate, payStreet, payCity, payCountry, payPostalCode, payVATAmt, recordType, unitPrice, payRef;
                                              String invAccCode, invDate, invDueDate, invStreet, invCity, invCountry, invPostalCode, invRecordType, invUnitPrice, invPayRef;
                                              
                                              if(paymtInv.Account_Number__c != NULL){
                                                  payAccCode = paymtInv.Account_Number__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.asp04__Payment_Date__c != NULL){
                                                  date myDate = paymtInv.asp04__Payment_Date__c;
                                                  payDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                              }
                                              if(paymtInv.asp04__Due_Date__c != NULL){
                                                  date myDate = paymtInv.asp04__Due_Date__c;
                                                  payDueDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                              }
                                              if(paymtInv.asp04__Billing_Address_Street__c != NULL){
                                                  payStreet = paymtInv.asp04__Billing_Address_Street__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.asp04__Billing_Address_City__c != NULL){
                                                  payCity = paymtInv.asp04__Billing_Address_City__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.asp04__Billing_Address_Country__c != NULL){
                                                  payCountry = paymtInv.asp04__Billing_Address_Country__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.asp04__Billing_Address_PostalCode__c != NULL){
                                                  payPostalCode = paymtInv.asp04__Billing_Address_PostalCode__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.Customer_Record_Type__c == NULL){
                                                  recordType = 'AAA';
                                              }
                                              else if(paymtInv.Customer_Record_Type__c.equals('Commercial')){
                                                  recordType = 'AC';
                                              }
                                              else
                                                  recordType = 'AAA';  
                                              if(paymtInv.asp04__Amount__c == NULL)
                                                  unitPrice = '0';
                                              else
                                                  unitPrice = String.valueOf(paymtInv.asp04__Amount__c);
                                              
                                              if(paymtInv.asp04__Card_Type__c != NULL){
                                                  String cardType = paymtInv.asp04__Card_Type__c;
                                                  if(cardType.equalsIgnoreCase('American Express')){
                                                      payRef = 'AMEX';
                                                  }
                                                  else payRef = 'OWP';
                                                  
                                                  if(payDate != NULL) 
                                                      payRef = payRef+payDate.split('-')[0]+payDate.split('-')[1];
                                                  else
                                                      payRef = payRef+payDueDate.split('-')[0]+payDueDate.split('-')[1];
                                              }
                                              
                                              payVATAmt = String.valueOf(paymtInv.Customer_Invoice__r.Charge_Gross__c - paymtInv.Customer_Invoice__r.Charge_Net__c);
                                              
                                              // Row for Payment.
                                              String recordString1 = '"RL",'+'"'+paymtInv.Customer_Invoice__r.Name+'","SRI",'+'"'+payAccCode+'",'+'"'+payDate+'","",';
                                              recordString1 = recordString1 +'"'+paymtInv.Customer_Invoice_Name__c+'",'+'"'+paymtInv.Job_Number__c+'",'+'"'+payStreet+'",';
                                              recordString1 = recordString1 +'"'+payCity+'","","",'+'"'+payCountry+'",'+'"'+payPostalCode+'",'+'"'+paymtInv.Customer_Invoice__r.Charge_Net__c+'",';
                                              recordString1 = recordString1 +'"'+payVATAmt+'","","","","",'+'"'+payVATAmt+'",'+'"'+paymtInv.asp04__Amount__c+'",';
                                              recordString1 = recordString1 +'"'+paymtInv.asp04__PSP_Reference__c+'",'+'"'+recordType+'","",'+'"'+unitPrice+'","","",';
                                              recordString1 = recordString1 +'"AAA",'+'"'+recordType+'","20015","Y",'+'"'+payRef+'",'+'"'+paymtInv.asp04__PSP_Reference__c+'",';
                                              recordString1 = recordString1 +'"","" \n';                
                                              finalstr = finalstr +recordString1;
                                              
                                              ///////////////////////////////////////////////////////////////////////////
                                              
                                              if(paymtInv.Customer_Invoice__r.Account_Number__c != NULL){
                                                  invAccCode = paymtInv.Customer_Invoice__r.Account_Number__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.Customer_Invoice__r.Date__c != NULL){
                                                  date myDate = paymtInv.Customer_Invoice__r.Date__c;
                                                  invDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                              }
                                              if(paymtInv.Customer_Invoice__r.Billing_Street__c != NULL){
                                                  invStreet = paymtInv.Customer_Invoice__r.Billing_Street__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.Customer_Invoice__r.Billing_Town__c != NULL){
                                                  invCity = paymtInv.Customer_Invoice__r.Billing_Town__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.Customer_Invoice__r.Billing_Country__c != NULL){
                                                  invCountry = paymtInv.Customer_Invoice__r.Billing_Country__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.Customer_Invoice__r.Billing_Postcode__c != NULL){
                                                  invPostalCode = paymtInv.Customer_Invoice__r.Billing_Postcode__c.replaceAll(regExp, ',');
                                              }
                                              if(paymtInv.Customer_Invoice__r.Account_Record_Type_Name__c.equals('Commercial')){
                                                  invRecordType = 'AC';
                                              }
                                              else
                                                  invRecordType = 'AAA';
                                              if(paymtInv.Customer_Invoice__r.Charge_Net__c == NULL)
                                                  invUnitPrice = '0';
                                              else
                                                  invUnitPrice = String.valueOf(paymtInv.Customer_Invoice__r.Charge_Net__c);
                                              
                                              
                                              // Row for Customer Invoice.
                                              String recordString2 = '"RL",'+'"'+paymtInv.Customer_Invoice__r.Name+'","SRI",'+'"'+invAccCode+'",'+'"'+invDate+'","",';
                                              recordString2 = recordString2 +'"'+paymtInv.Customer_Invoice__r.Name+'",'+'"'+paymtInv.Customer_Invoice__r.Job_Number__c+'",'+'"'+invStreet+'",';
                                              recordString2 = recordString2 +'"'+invCity+'","","",'+'"'+invCountry+'",'+'"'+invPostalCode+'",'+'"'+paymtInv.Customer_Invoice__r.Charge_Net__c+'",';
                                              recordString2 = recordString2 +'"'+payVATAmt+'","","","","",'+'"'+payVATAmt+'",'+'"'+paymtInv.Customer_Invoice__r.Charge_Gross__c+'",';
                                              recordString2 = recordString2 +'"'+paymtInv.Name+'",'+'"'+invRecordType+'","1",'+'"'+invUnitPrice+'",'+'"'+payVATAmt+'","2",';
                                              recordString2 = recordString2 +'"AAA",'+'"'+invRecordType+'",'+'"'+paymtInv.Customer_Invoice__r.Exchequer_General_Ledger_Code_Number__c+'","N","","",';
                                              recordString2 = recordString2 +'"","" \n';                
                                              finalstr = finalstr +recordString2;
                                              
                                          }
        
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'SalesInvoiceAndPayment'; 
         csvFile.PathOnClient = 'SalesInvoiceAndPayment.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
        // sendEmailAttCSV(finalstr, 'SalesInvoiceAndPayment');
        csvFile = NULL;
        finalstr = NULL; 
        resultIds.clear();
         paymentList.clear();
    }
    
    public static void createSalesInvoiceAndPaymentPaymentCSV(List<asp04__Payment__c> paymentList){        
        /*Example --
		 *Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,Del_Add_1,Del_Add_2,Del_Add_3,Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code,Payment_Line,Pay_Ref,UDF1,UDF2,UDF3
		 *"RL","00077108","SRC","A88960","30-09-2022","","PAY-000077108","J-085829","Wedge Hook Boltons Lane","WITNEY","","","United Kingdom","OX29 8NB","330.07","","","","","","","330.07","2a85b112-7b18-411d-851c-f1dcdf1d204b","AAA","1","330.07","0","","AAA","AAA","20015","Y","OWP3009","","",""
		*/
        
        String header = 'Record_Type,Link_Ref,Type,Account_Code,Date,Due_Date,Your_Ref,Alt_Ref,Del_Add_1,Del_Add_2,Del_Add_3,';
        header = header + 'Del_Add_4,Del_Add_5,Del_PostCode,Net_Value,VAT_Amount,VAT_Analysis_Rate_S,VAT_Analysis_Rate_Z,';
        header = header + 'VAT_Analysis_Rate_E,VAT_Analysis_Rate_1,VAT_Analysis_Rate_2,Total_Invoiced,Line_Description,Location,Qty,';
        header = header + 'Unit_Price,VAT_Amount_Line,VAT_Code,Department,Cost_Centre,GL_Code,Payment_Line,Pay_Ref,UDF1,UDF2,UDF3 \n';
        String finalstr = header ;
		        System.debug('payments list: '+paymentList);

        Set<Id> resultIds = (new Map<Id,SObject>(paymentList)).keySet();
        System.debug('result ids: '+resultIds);
        for(asp04__Payment__c paymt : [SELECT Id, Name, Customer_Invoice_Name__c, asp04__Payment_Date__c, Account_Number__c, asp04__Due_Date__c,
                                       asp04__Billing_Address_Street__c, asp04__Billing_Address_City__c, asp04__Billing_Address_Country__c,
                                       asp04__Billing_Address_PostalCode__c, asp04__Amount__c, asp04__PSP_Reference__c, Job_Number__c,
                                       Customer_Record_Type__c, asp04__Card_Type__c FROM asp04__Payment__c WHERE Id =: resultIds]){
                                           System.debug('*** payment : '+paymt.id);
                                           String payAccCode, payDate, payDueDate, payStreet, payCity, payCountry, payPostalCode, recordType, payRef;
                                           
                                           if(paymt.Account_Number__c != NULL){
                                               payAccCode = paymt.Account_Number__c.replaceAll(regExp, ',');
                                           }
                                           if(paymt.asp04__Payment_Date__c != NULL){
                                               date myDate = paymt.asp04__Payment_Date__c;
                                               payDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                           }
                                           if(paymt.asp04__Due_Date__c != NULL){
                                               date myDate = paymt.asp04__Due_Date__c;
                                               payDueDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                           }
                                           if(paymt.asp04__Billing_Address_Street__c != NULL){
                                               payStreet = paymt.asp04__Billing_Address_Street__c.replaceAll(regExp, ',');
                                           }
                                           if(paymt.asp04__Billing_Address_City__c != NULL){
                                               payCity = paymt.asp04__Billing_Address_City__c.replaceAll(regExp, ',');
                                           }
                                           if(paymt.asp04__Billing_Address_Country__c != NULL){
                                               payCountry = paymt.asp04__Billing_Address_Country__c.replaceAll(regExp, ',');
                                           }
                                           if(paymt.asp04__Billing_Address_PostalCode__c != NULL){
                                               payPostalCode = paymt.asp04__Billing_Address_PostalCode__c.replaceAll(regExp, ',');
                                           }
                                           if(paymt.Customer_Record_Type__c == NULL){
                                               recordType = 'AAA';
                                           }
                                           else if(paymt.Customer_Record_Type__c.equals('Commercial')){
                                               recordType = 'AC';
                                           }
                                           else
                                               recordType = 'AAA';  
                                           if(paymt.asp04__Card_Type__c != NULL){
                                               String cardType = paymt.asp04__Card_Type__c;
                                               if(cardType.equalsIgnoreCase('American Express')){
                                                   payRef = 'AMEX';
                                               }
                                               else payRef = 'OWP';
                                               
                                               if(payDate != NULL) 
                                                   payRef = payRef+payDate.split('-')[0]+payDate.split('-')[1];
                                               else
                                                   payRef = payRef+payDueDate.split('-')[0]+payDueDate.split('-')[1];
                                           }
                                           
                                           // Row for Payment.
                                           String recordString = '"RL",'+'"'+paymt.Name.split('-')[1]+'","SRI",'+'"'+payAccCode+'",'+'"'+payDate+'","",';
                                           recordString = recordString +'"'+paymt.Name+'",'+'"'+paymt.Job_Number__c+'",'+'"'+payStreet+'",';
                                           recordString = recordString +'"'+payCity+'","","",'+'"'+payCountry+'",'+'"'+payPostalCode+'",'+'"'+paymt.asp04__Amount__c+'",';
                                           recordString = recordString +'"","","","","","",'+'"'+paymt.asp04__Amount__c+'",';
                                           recordString = recordString +'"'+paymt.asp04__PSP_Reference__c+'",'+'"'+recordType+'","1",'+'"'+paymt.asp04__Amount__c+'","0","",';
                                           recordString = recordString +'"AAA",'+'"'+recordType+'","20015","Y",'+'"'+payRef+'",'+'"","","" \n';
                                           finalstr = finalstr +recordString;
                                       }
        
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'SalesInvoiceAndPaymentPayment'; 
         csvFile.PathOnClient = 'SalesInvoiceAndPaymentPayment.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
        // sendEmailAttCSV(finalstr, 'SalesInvoiceAndPaymentPayment');
        csvFile = NULL;
        finalstr = NULL; 
        resultIds.clear();
         paymentList.clear();
    }
    
    public static void createPurchasecreditCSV(List<Supplier_Credit_Note__c> suppCreditNoteList){        
        /*Example--
		 *RL_Record_Type,Link_Ref,TH_Transaction_Type,Account_Code,Transaction_Date,Due_Date,Your_Ref,YourLongRef,User_Defined_1,User_Defined_2,User_Defined_3,Address_Line_1,Address_Line_2,Address_Line_3,Address_Line_4,Address_Line_5,Delivery_Address_Postcode,Net_Value_0,VAT_Amount_0,VAT_Analysis_Rate_S_0,VAT_Analysis_Rate_Z_0,VAT_Analysis_Rate_E_0,VAT_Analysis_Rate_1_0,VAT_Analysis_Rate_2_0,Total_Invoiced_0,Hold_Status_0,TL_Line_Description,Location_Code,Qty_1,Unit_Price_Cost_Rate_0,VAT_Amount_L0,VAT_Code,Department,Cost_Centre,GL_Code_0
		 *RL,SCN000137,PCR,CEF,22/09/2022,,SCN000137,252315,,,,Tom Mackie House 1 Station Road,Kenilworth,,,United Kingdom,CV8 1JJ,147.44,29.49,,,,,29.49,176.93,,SI-004627,,1,147.44 ,29.49 ,2,KK,AAA,63104
		*/
        
        String header = 'RL_Record_Type,Link_Ref,TH_Transaction_Type,Account_Code,Transaction_Date,Due_Date,Your_Ref,YourLongRef,User_Defined_1,User_Defined_2,';
        header = header + 'User_Defined_3,Address_Line_1,Address_Line_2,Address_Line_3,Address_Line_4,Address_Line_5,Delivery_Address_Postcode,';
        header = header + 'Net_Value_0,VAT_Amount_0,VAT_Analysis_Rate_S_0,VAT_Analysis_Rate_Z_0,VAT_Analysis_Rate_E_0,VAT_Analysis_Rate_1_0,';
        header = header + 'VAT_Analysis_Rate_2_0,Total_Invoiced_0,Hold_Status_0,TL_Line_Description,Location_Code,Qty_1,Unit_Price_Cost_Rate_0,VAT_Amount_L0,VAT_Code,Department,Cost_Centre,GL_Code_0 \n';
        String finalstr = header ;
        
        Set<Id> resultIds = (new Map<Id,SObject>(suppCreditNoteList)).keySet();
        for(Supplier_Credit_Note__c suppCrNotes : [SELECT Id, Name, Account_Code__c, Credit_Value_Gross__c, Credit_Value_NET__c,Supplier_Credit_Note_Date__c,
                                                   Credit_Value_VAT__c, GL_Code_Number__c, Supplier_Address_City__c, Supplier_Address_Country__c,
                                                   Supplier_Address_Postcode__c, Supplier_Address_Street__c, Supplier_Credit_Note_Number__c,
                                                   Supplier_Invoice__r.Name FROM Supplier_Credit_Note__c WHERE Id =: resultIds]){
                                                       
                                                       
                                                       String suppDate, suppStreet, suppCity, suppCountry, suppPostalCode;
                                                       
                                                       if(suppCrNotes.Supplier_Credit_Note_Date__c != NULL){
                                                           date myDate = suppCrNotes.Supplier_Credit_Note_Date__c;
                                                           suppDate = DateTime.newInstance(myDate.year(),myDate.month(),myDate.day()).format('dd-MM-YYYY');
                                                       }
                                                       if(suppCrNotes.Supplier_Address_Street__c != NULL){
                                                           suppStreet = suppCrNotes.Supplier_Address_Street__c.replaceAll(regExp, ',');
                                                       }
                                                       if(suppCrNotes.Supplier_Address_City__c != NULL){
                                                           suppCity = suppCrNotes.Supplier_Address_City__c.replaceAll(regExp, ',');
                                                       }
                                                       if(suppCrNotes.Supplier_Address_Country__c != NULL){
                                                           suppCountry = suppCrNotes.Supplier_Address_Country__c.replaceAll(regExp, ',');
                                                       }
                                                       if(suppCrNotes.Supplier_Address_Postcode__c != NULL){
                                                           suppPostalCode = suppCrNotes.Supplier_Address_Postcode__c.replaceAll(regExp, ',');
                                                       }
                                                       String recordString = '"RL",'+'"'+suppCrNotes.Name+'","PCR",'+'"'+suppCrNotes.Account_Code__c+'",'+'"'+suppDate+'",';
                                                       recordString = recordString + '"",'+'"'+suppCrNotes.Name+'",'+'"'+suppCrNotes.Supplier_Credit_Note_Number__c+'",';
                                                       recordString = recordString + '"","","",'+'"'+suppStreet+'",'+'"'+suppCity+'","","",'+'"'+suppCountry+'",'+'"'+suppPostalCode+'",';
                                                       recordString = recordString + '"'+suppCrNotes.Credit_Value_NET__c+'",'+'"'+suppCrNotes.Credit_Value_VAT__c+'","","","","",';
                                                       recordString = recordString + '"'+suppCrNotes.Credit_Value_VAT__c+'",'+'"'+suppCrNotes.Credit_Value_Gross__c+'","",';
                                                       recordString = recordString + '"'+suppCrNotes.Supplier_Invoice__r.Name+'","","1",'+'"'+suppCrNotes.Credit_Value_NET__c+'",'+'"'+suppCrNotes.Credit_Value_VAT__c+'",';
                                                       recordString = recordString + '"2","KK","AAA",'+'"'+suppCrNotes.GL_Code_Number__c+'" \n';
                                                       finalstr = finalstr + recordString;
                                                   }
        
         ContentVersion csvFile = new ContentVersion();
         csvFile.ContentLocation = 'S'; 
         csvFile.Title = 'PurchaseCredit'; 
         csvFile.PathOnClient = 'PurchaseCredit.csv';
         csvFile.VersionData = Blob.valueOf(finalstr);
         csvFileList.add(csvFile);
         //sendEmailAttCSV(finalstr, 'PurchaseCredit');
        csvFile = NULL;
        finalstr = NULL; 
        resultIds.clear(); 
        suppCreditNoteList.clear();
    }
  
    /*
    public static void sendEmailAttCSV(String finalStr, String fileName){
        
        
        System.debug('>>> '+fileName+' finalstr '+finalstr);
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= fileName+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {UserInfo.getUserEmail()};
   //     String[] ccAddresses = new list<string> {'matthew.radoja@aspect.co.uk'};
        String subject =fileName+' CSV';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
   //     email.setCcAddresses(ccAddresses);
        email.setPlainTextBody('Hello User,\nPlease find the attached '+fileName+' CSV for Finance Import.\nRegards,\nChumley');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
       
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = 'AccCSV'; //title of the file
        cv.PathOnClient = csvname; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = csvBlob; //file data
      //  cv.ContentDocumentId = '0583M000000BBxzQAG';
        insert cv;
        System.debug('cv >>> '+cv);
        Id conDoc = [Select ContentDocumentId From ContentVersion Where Id =: cv.Id].ContentDocumentId;  
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = 'a223M000008GzJbQAK';
        cdl.ContentDocumentId = conDoc;
        cdl.shareType = 'I';
        Insert cdl;
        System.debug('cdl >>> '+cdl);
    }
    */
}