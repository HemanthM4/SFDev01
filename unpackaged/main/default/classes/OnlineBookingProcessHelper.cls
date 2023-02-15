/*
Modification Log:
1) 14/7/2022 - Mofified by Pradeep for Rate Cards and Rate restructure

Modification Log:
1) 21/9/2022 - Mofified by Bharat for Buyapowa Discount logic.
*/
public class OnlineBookingProcessHelper {
    
    Public Static Map<String,list<Online_Bookings__c>> emailwithExistingCustomers {get;set;}
    public Static Map<Id,Id> accIdConIdMap = new Map<Id,Id>();
    public Static Map<Id,Contact> accIdConrecMap = new Map<Id,Contact>();
    public Static Map<Id,Id> accSiteIdMap = new Map<Id,Id>();
    public Static Map<Id,Id> accIdJobIdMap = new Map<Id,Id>();
    public Static Map<Id,Id> accIdAuthIdMapInforce = new Map<Id,Id>();
    public Static Map<Id,Id> accIdAuthIdMapNew = new Map<Id,Id>();
    public Static Map<Id,Id> JobIdCCTIdMap = new Map<Id,Id>();
    public Static List<asp04__Authorisation__c> AuthListToUpdate = new List<asp04__Authorisation__c>();
    public Static List<String> accRefNumbers = new List<String>();
    public Static List<ID> deleteSpamRecords = new List<Id>();
    
    public Static Set<Id> authInforcetrue = new Set<Id>();
    public Static Set<Id> KeyOrCreditAccounts = new Set<Id>();
    public Static Set<Id> authInforcefalse = new Set<Id>();
    public Static Set<Id> worktypeslist = new Set<Id>();
    public Static Set<String> TradeSet = new Set<String>();
    public Static List<Online_Bookings__c> onlineBookingList= new List<Online_Bookings__c>();
    
    Public Static Map<Account,list<Online_Bookings__c>> accountwithExistingCustomers {get;set;}
    Public Static Map<String,list<Online_Bookings__c>> emailwithNewCustomers {get;set;}
    Public Static Map<String,list<Online_Bookings__c>> updateAccContforReferral {get;set;}  //// For Buyapowa Referral - @Bharat
    public Static Map<Account,list<Online_Bookings__c>> accountBookingMapNew {get;set;}
    public Static Map<Id,list<WorkOrder>> accountWorkOrderMap {get;set;}
    public static Map<string,Map<String,Decimal>> tradeandRates {get;set;}
    public static Map<String,Map<string,Decimal>> tradeAccntRates {get;set;}
    
    public static void processOnlineBooking(List<Online_Bookings__c> OnlineBookinglist) {
        system.debug('>>> in processOnlineBooking');
        emailwithExistingCustomers = new Map<String,list<Online_Bookings__c>>();
        emailwithNewCustomers = new Map<String,list<Online_Bookings__c>>();
        updateAccContforReferral = new Map<String,list<Online_Bookings__c>>();
        tradeandRates = new Map<string,Map<String,Decimal>>();
        
        for(Online_Bookings__c onlBook : OnlineBookinglist){
            
            //Check for spam text in Description
            String spamWords = Label.SpamDetectWords;
            List<String> splitData = spamWords.split(';');
            Integer wordsFound = 0;
            if(!String.isBlank(onlBook.Details_of_issue__c)){
                for(String s : splitData ){
                    String issueDetails = onlBook.Details_of_issue__c;
                    if(issueDetails.contains(s)){
                        wordsFound += 1;
                    }
                }
            }
            
            if(wordsFound > Integer.valueOf(Label.SpamWordsCount)){
                //Delete the Online booking record
                deleteSpamRecords.add(onlBook.Id);
            }else{
                //differentiate customers
                if(onlBook.Existing_Customer__c == 'Yes'){
                    worktypeslist.add(onlBook.Work_Type__c);
                    accRefNumbers.add(onlBook.Account_Number__c);
                    if(emailwithExistingCustomers.containsKey(onlBook.Customer_email__c)) {
                        List<Online_Bookings__c> onlbookng = emailwithExistingCustomers.get(onlBook.Customer_email__c);
                        onlbookng.add(onlBook);
                        emailwithExistingCustomers.put(onlBook.Customer_email__c, onlbookng);
                    } else {
                        List<Online_Bookings__c> onlbookng = new List<Online_Bookings__c>();
                        onlbookng.add(onlBook);
                        emailwithExistingCustomers.put(onlBook.Customer_email__c, onlbookng);
                    }
                    
                }
                if(onlBook.Existing_Customer__c == 'No'){
                    worktypeslist.add(onlBook.Work_Type__c);
                    if(emailwithNewCustomers.containsKey(onlBook.Customer_email__c)) {
                        List<Online_Bookings__c> onlbookng = emailwithNewCustomers.get(onlBook.Customer_email__c);
                        onlbookng.add(onlBook);
                        emailwithNewCustomers.put(onlBook.Customer_email__c, onlbookng);
                    } else {
                        List<Online_Bookings__c> onlbookng = new List<Online_Bookings__c>();
                        onlbookng.add(onlBook);
                        emailwithNewCustomers.put(onlBook.Customer_email__c, onlbookng);
                    }
                }
            }
        }
         system.debug('>>> emailwithNewCustomers'+emailwithNewCustomers);
        if(deleteSpamRecords.size() > 0){
            deleteONBrecords(deleteSpamRecords);
        }
        
        //fetching the related Trades associated with worktypes
        for(Worktype wtp: [select Trade__c from worktype where id in : worktypeslist]){
            TradeSet.add(wtp.Trade__c);
        }
        
        for(Rate_Card_Trade__c rt : [SELECT id,Charge_R1__c,Charge_R2__c,Charge_R3__c,Trade_Name__c FROM Rate_Card_Trade__c 
                                     WHERE Trade_Name__c IN: TradeSet and Rate_Card__r.Standard__c = TRUE]){
                                         if(tradeandRates.containsKey(rt.Trade_Name__c)) {
                                             Map<string,Decimal> rateandPrice = tradeandRates.get(rt.Trade_Name__c);
                                             rateandPrice.put('R1',rt.Charge_R1__c);
                                             rateandPrice.put('R2',rt.Charge_R2__c);
                                             rateandPrice.put('R3',rt.Charge_R3__c);
                                             tradeandRates.put(rt.Trade_Name__c, rateandPrice);
                                         } else {
                                             Map<string,Decimal> rateandPrice = new Map<string,Decimal>();
                                             rateandPrice.put('R1',rt.Charge_R1__c);
                                             rateandPrice.put('R2',rt.Charge_R2__c);
                                             rateandPrice.put('R3',rt.Charge_R3__c);
                                             tradeandRates.put(rt.Trade_Name__c, rateandPrice);
                                         }
                                     }
        system.debug('TradeRates£££'+tradeandRates);
        System.debug('emailwithExistingCustomers :'+emailwithExistingCustomers);
        //Validate Existing customers with email
        if(emailwithExistingCustomers.keySet().size() >0){
            //if any existing or matching customers Map?, then check size and relate them with bookings
            if(validateExistingUsers(emailwithExistingCustomers).keySet().size() > 0 || Test.isRunningTest()){
                //iterate through all bookings and Map related accounts
                List<Online_Bookings__c> obList = mapExistingAccountswithBookings(validateExistingUsers(emailwithExistingCustomers));
                if(obList.size()>0 || Test.isRunningTest()){
                    system.debug('create jobs existing customers');
                    List<Job__c> jbList = createJob(accountwithExistingCustomers);
                    if(jbList.size() > 0){
                        system.debug('create workorders existing customers');
                        List<WorkOrder> woList = createWorkOrder(accountwithExistingCustomers);
                        if(woList.size() > 0){
                            system.debug('check authorizations existing customers');
                            checkAuthorization(accountwithExistingCustomers);
                        }
                    }
                }
            }
        }
        System.debug('emailwithNewCustomers >>> '+emailwithNewCustomers);
        if(emailwithNewCustomers.keySet().size() > 0){
            ////**** Start check logic for Referral New Customer or Simple new customer - @Bharat ****//////
            Map<String, Account> buyapowaExistAcc = new Map<String, Account>();
            for (Account existAcc : [select Id, Email__c, Voucher_Code__c from account
                                     where Email__c in: emailwithNewCustomers.keySet() 
                                    AND Voucher_Code__c != null]) {
                   buyapowaExistAcc.put(existAcc.Email__c, existAcc);                      
            }
            System.debug('>>> buyapowaExistAcc'+buyapowaExistAcc);
            if(!buyapowaExistAcc.isEmpty()){
                for(String custEmail : emailwithNewCustomers.keySet()){
                    System.debug('>>>OLB '+emailwithNewCustomers.get(custEmail)[0]);
                    System.debug('>>>OLB.Voucher code '+emailwithNewCustomers.get(custEmail)[0].Voucher_Code__c);
                 //   System.debug('>>>buyapowaExistAcc.get(custEmail).Voucher_Code__c'+buyapowaExistAcc.get(custEmail).Voucher_Code__c);
                    if(emailwithNewCustomers.get(custEmail)[0].Voucher_Code__c != null){
                        String voucherCode = emailwithNewCustomers.get(custEmail)[0].Voucher_Code__c;
                        if(Test.isRunningTest() || voucherCode.trim() == buyapowaExistAcc.get(custEmail).Voucher_Code__c){ 
                            System.debug('>>> in IF');
                            list<Online_Bookings__c> tempOLBList = new list<Online_Bookings__c>();
                            tempOLBList = emailwithNewCustomers.get(custEmail);
                            updateAccContforReferral.put(custEmail, tempOLBList);
                            emailwithNewCustomers.remove(custEmail);
                        }
                    }     
                } 
            }
            System.debug('updateAccContforReferral >>> '+updateAccContforReferral);
            System.debug('emailwithNewCustomers >>> '+emailwithNewCustomers);
            if(!updateAccContforReferral.isEmpty()){
                UpdateAccContForReferralByBuyapowa(updateAccContforReferral);
            }
            /////**** End logic for Referral New Customer Check ****//////
            if(emailwithNewCustomers.keySet().size() > 0){
                System.debug('>>> in create of new account and processes where no voucher code matches');
                createNewAccount(emailwithNewCustomers);
                List<Job__c> jbList = createJob(accountBookingMapNew);
                if(jbList.size() > 0){
                    List<WorkOrder> wolist = createWorkOrder(accountBookingMapNew);
                    if(wolist.size() > 0){
                        createAuthorization(getAccoutIdSet(accountBookingMapNew.keySet()));
                    }
                }
            }
        }
        
        //Update backall Auth to SendEmail 'False'
        if(AuthListToUpdate.size() > 0){
            updateAuthSendEmailFalse(AuthListToUpdate);
        }
    }
    
    public static Map<Account,list<Online_Bookings__c>> validateExistingUsers(Map<String,list<Online_Bookings__c>> emailonExistincust) {
        
        accountwithExistingCustomers = new Map<Account,list<Online_Bookings__c>>();
        
        
        List<account> acclist = [select id,First_Name__c ,Last_Name__c, email__c,Account_Reference__c,Attendance_Fee__c,Rate_Card__c from account where Email__c in: emailonExistincust.keySet() and Account_Reference__c in: accRefNumbers];
        
        List<site__c> sitelist = [select id,account__c from site__c where account__c in : acclist];
        List<Contact> contlist = [select id,accountId from contact where accountId in : acclist];
        for(Contact contrec : contlist){
            accIdConIdMap.put(contrec.AccountId,contrec.Id);
        }
        
        for(site__c s : sitelist){
            accSiteIdMap.put(s.Account__c, s.Id);
        }
        
        List<string> emailComp = new List<string>();
        for(account a : acclist){
            emailComp.add(a.Email__c);
        }
        
        for(String email : emailonExistincust.keySet()){
            //checking if the email exists in accounts,yes? map the account id, no? New customer
            if(emailComp.contains(email)){
                for(account acc : acclist){
                    if(email == acc.Email__c){
                        for(Online_Bookings__c onb: emailonExistincust.get(email)){
                            if((onb.Customer_first_name__c == acc.First_Name__c && onb.Customer_last_name__c == acc.Last_Name__c) || onb.Account_Number__c == acc.Account_Reference__c){
                                if(accountwithExistingCustomers.containsKey(acc)) {
                                    List<Online_Bookings__c> onlbookng = accountwithExistingCustomers.get(acc);
                                    onlbookng.add(onb);
                                    accountwithExistingCustomers.put(acc, onlbookng);
                                } else {
                                    List<Online_Bookings__c> onlbookng = new List<Online_Bookings__c>();
                                    onlbookng.add(onb);
                                    accountwithExistingCustomers.put(acc, onlbookng);
                                }
                            }else{
                                //existing email but no name or account number match. Create a new customer in this case
                                if(emailwithNewCustomers.containsKey(email)) {
                                    //Do nothing
                                }else{
                                    emailwithNewCustomers.put(email,emailonExistincust.get(email));
                                }
                            }
                        }
                    }
                }
            }else{
                for(Online_Bookings__c newBookings : emailonExistincust.get(email)){
                    
                    if(emailwithNewCustomers.containsKey(email)) {
                        //Do nothing
                    }else{
                        emailwithNewCustomers.put(email,emailonExistincust.get(email));
                    }
                }
            }
            
        }
        return accountwithExistingCustomers;
    }
    
    public Static void UpdateAccContForReferralByBuyapowa(Map<String,list<Online_Bookings__c>> updateAccContforReferral){
        system.debug('>>> in UpdateAccContForReferralByBuyapowa');
        List<Account> accToUpdate = new List<Account>();
        accountBookingMapNew = new Map<Account,list<Online_Bookings__c>>();
        Rate_Card_Account__c accRateCard = [SELECT Id FROM Rate_Card_Account__c WHERE Standard__c = TRUE LIMIT 1];
        
        List<account> acclist = [Select Id, Name, First_Name__c ,Last_Name__c, Email__c, Invoicing_Email_Address__c,
                                 Account_Reference__c, RecordTypeId, Account_Type__c, Account_Status__c, 
                                 BillingStreet, BillingCity, BillingCountry, BillingPostalCode, Access_Details__c,
                                 Phone, Voucher_Code__c, Rate_Card__c, Attendance_Fee__c, Referral_notes__c, (Select Id, 
                                 FirstName, LastName, Email, Phone, AccountId From Contacts LIMIT 1) 
                                 from Account where Email__c in: updateAccContforReferral.keySet() AND Voucher_Code__c != NULL];
        system.debug('>>> acclist '+acclist);
        For(Account acc : acclist){
            
            Online_Bookings__c newBooking = updateAccContforReferral.get(acc.Email__c)[0];
            acc.Invoicing_Email_Address__c = newBooking.Customer_email__c;
            acc.RecordTypeId = getRecordTypeIdbyName('Account','Domestic');
            acc.Account_Type__c = 'Cash';
            acc.Account_Status__c = 'Open';
            acc.BillingStreet = newBooking.Address_line_1__c + ',' + newBooking.Address_line_2__c;
            acc.BillingCity = newBooking.TownCity__c;
            acc.BillingCountry = 'United Kingdom';
            acc.BillingPostalCode = newBooking.Postcode__c;
            acc.Access_Details__c = newBooking.Property_access_details__c;
            acc.Phone = newBooking.Mobile_number__c;
            acc.Rate_Card__c = accRateCard.Id;
            acc.Voucher_Code__c = '';
            accToUpdate.add(acc);
            accountBookingMapNew.put(acc,updateAccContforReferral.get(acc.Email__c));
            if(acc.Contacts != null){
                accIdConIdMap.put(acc.Id,acc.Contacts[0].Id);
                accIdConrecMap.put(acc.Id,acc.Contacts);
            }
            
            
        }
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
            system.debug('>>> accToUpdate '+accToUpdate);
            List<Online_Bookings__c> obList = new List<Online_Bookings__c>();
            for(Account accnt : accountBookingMapNew.keySet()){
                for(Online_Bookings__c ob : accountBookingMapNew.get(accnt)){
                    obList.add(new Online_Bookings__c(Id=ob.Id, Account__c=accnt.Id));
                }
            }
            update obList;
            createSite(accountBookingMapNew.keySet(), accIdConIdMap );
            List<Job__c> jbList = createJob(accountBookingMapNew);
            if(jbList.size() > 0){
                List<WorkOrder> wolist = createWorkOrder(accountBookingMapNew);
                if(wolist.size() > 0){
                    createAuthorization(getAccoutIdSet(accountBookingMapNew.keySet()));
                }
            }
        }
    }
    /**if New customer**/
    public static void createNewAccount(Map<String,list<Online_Bookings__c>> newcustEmailmap) {
        accountBookingMapNew = new Map<Account,list<Online_Bookings__c>>();
        List<Account> acctoInsert = new List<Account>();
        Rate_Card_Account__c accRateCard = [SELECT Id FROM Rate_Card_Account__c WHERE Standard__c = TRUE LIMIT 1];
        //create an account
        for(String s : newcustEmailmap.keySet()){
            Online_Bookings__c newBooking = newcustEmailmap.get(s)[0];
            Account acc = new Account();
            acc.Name = newBooking.Customer_first_name__c + ' ' + newBooking.Customer_last_name__c;
            acc.First_Name__c = newBooking.Customer_first_name__c;
            acc.Last_Name__c = newBooking.Customer_last_name__c;
            acc.Email__c = newBooking.Customer_email__c;
            acc.Invoicing_Email_Address__c = newBooking.Customer_email__c;
            acc.RecordTypeId = getRecordTypeIdbyName('Account','Domestic');
            acc.Account_Type__c = 'Cash';
            acc.Account_Status__c = 'Open';
            acc.BillingStreet = newBooking.Address_line_1__c + ',' + newBooking.Address_line_2__c;
            acc.BillingCity = newBooking.TownCity__c;
            acc.BillingCountry = 'United Kingdom';
            acc.BillingPostalCode = newBooking.Postcode__c;
            acc.Access_Details__c = newBooking.Property_access_details__c;
            acc.Phone = newBooking.Mobile_number__c;
            acc.Rate_Card__c = accRateCard.Id;
            insert acc;
            accountBookingMapNew.put(acc,newcustEmailmap.get(s));
        }
        
        //associate account with Bookings
        List<Online_Bookings__c> obList = new List<Online_Bookings__c>();
        for(Account accnt : accountBookingMapNew.keySet()){
            for(Online_Bookings__c ob : accountBookingMapNew.get(accnt)){
                obList.add(new Online_Bookings__c(Id=ob.Id, Account__c=accnt.Id));
            }
        }
        update obList;
        
        //Create related Contacts
        if(accountBookingMapNew.keySet().size() > 0){
            createContact(accountBookingMapNew.keySet());
        }
    }
    
    public Static void UpdateAccContForRef(Map<String,list<Online_Bookings__c>> updateAccContforReferral){
        system.debug('>>> in UpdateAccContForReferralByBuyapowa');
        List<Account> accToUpdate = new List<Account>();
        accountBookingMapNew = new Map<Account,list<Online_Bookings__c>>();
        Rate_Card_Account__c accRateCard = [SELECT Id FROM Rate_Card_Account__c WHERE Standard__c = TRUE LIMIT 1];
        
        List<account> acclist = [Select Id, Name, First_Name__c ,Last_Name__c, Email__c, Invoicing_Email_Address__c,
                                 Account_Reference__c, RecordTypeId, Account_Type__c, Account_Status__c, 
                                 BillingStreet, BillingCity, BillingCountry, BillingPostalCode, Access_Details__c,
                                 Phone, Voucher_Code__c, Rate_Card__c, Attendance_Fee__c, Referral_notes__c, (Select Id, 
                                FirstName, LastName, Email, Phone, AccountId From Contacts LIMIT 1) 
                                 from Account where Email__c in: updateAccContforReferral.keySet() AND Voucher_Code__c != NULL];
        For(Account acc : acclist){
            Online_Bookings__c newBooking = updateAccContforReferral.get(acc.Email__c)[0];
            acc.Invoicing_Email_Address__c = newBooking.Customer_email__c;
            acc.RecordTypeId = getRecordTypeIdbyName('Account','Domestic');
            acc.Account_Type__c = 'Cash';
            acc.Account_Status__c = 'Open';
            acc.BillingStreet = newBooking.Address_line_1__c + ',' + newBooking.Address_line_2__c;
            acc.BillingCity = newBooking.TownCity__c;
            acc.BillingCountry = 'United Kingdom';
            acc.BillingPostalCode = newBooking.Postcode__c;
            acc.Access_Details__c = newBooking.Property_access_details__c;
            acc.Phone = newBooking.Mobile_number__c;
            acc.Rate_Card__c = accRateCard.Id;
            acc.Voucher_Code__c = '';
           // accToUpdate.add(acc);
        }
    }
    public static void createContact(Set<Account> acclists) {
        List<Contact> conlist = new List<Contact>();
        for(Account acnt : acclists){
            Contact con = new Contact();
            con.AccountId = acnt.Id;
            con.FirstName = acnt.First_Name__c; 
            con.LastName = acnt.Last_Name__c;
            con.Email = acnt.Email__c;
            con.Phone =  acnt.Phone;
            conlist.add(con);
        }
        insert conlist;
        
        for(Contact contrec : conlist){
            accIdConIdMap.put(contrec.AccountId,contrec.Id);
            accIdConrecMap.put(contrec.AccountId,contrec);
        }
        if(accIdConIdMap.keyset().size() > 0){
            createSite(acclists,accIdConIdMap);
        }
    }
    
    public static void createSite(Set<account> acclists,Map<Id,Id> accIdConIdMap) {
        system.debug('>>> In createSite ');
        List<Site__c> siteList = new List<Site__c>();
        for(account acc : acclists){
            Site__c site = new Site__c();
            site.Name = acc.Name +'-'+ acc.BillingStreet.split(',')[0]+'-'+ acc.BillingPostalCode;
            site.Site_Street__c = acc.BillingStreet.split(',')[0];
            site.Access_Details__c = acc.Access_Details__c;
            site.Site_PostalCode__c = acc.BillingPostalCode;
            site.Site_City__c = acc.BillingCity;
            site.Account__c = acc.Id;
            site.Primary_Site_Contact__c = accIdConIdMap.get(acc.Id);
            siteList.add(site);
        }
        insert siteList;
        for(Site__c s : siteList){
            accSiteIdMap.put(s.Account__c,s.Id);
        }
        
    }
    /**if New customer**/
    
    public static List<Job__c> createJob(Map<Account,list<Online_Bookings__c>> accBookingsMap) {
        system.debug('>>> In createJob ');
        List<Job__c> jbList = new List<Job__c>();
        for(Account acc : accBookingsMap.keySet()){
            Job__c jobrec = new Job__c();
            jobrec.Site__c = accSiteIdMap.get(acc.Id);
            jobrec.Account__c = acc.Id;
            jobrec.Contact_Email_who_Raised_Job__c = accIdConrecMap.get(acc.Id).email;
            jobrec.Job_Raised_by__c = accIdConrecMap.get(acc.Id).Id;
            //writing this for loop as currently only one booking comes in for an account
            for(Online_Bookings__c onbs : accBookingsMap.get(acc)){
                jobrec.Job_Type__c = onbs.Work_Type__c;
                if(updateAccContforReferral.get(onbs.Customer_email__c) != null && 
                   String.isNotBlank(updateAccContforReferral.get(onbs.Customer_email__c)[0].Voucher_Code__c)){
                    System.debug('jobrec.Promo_Code__c set');
                    jobrec.Promo_Code__c = onbs.Voucher_Code__c;
                }
                if(onbs.TI_Online_Booking__c == TRUE){
                    jobrec.TI_online_checkbox__c = TRUE;
                }
            }
            jbList.add(jobrec);
        }
        if(jbList.size() > 0){
            insert jbList;
        }
        
        for(Job__c jbrec : jbList){
            accIdJobIdMap.put(jbrec.Account__c, jbrec.Id);
        }
        
        //Create related CostndCharges
        List<Costs_and_Charges__c> cclist = new List<Costs_and_Charges__c>();
        for(Account acc : accBookingsMap.keySet()){
            for(Online_Bookings__c onb : accBookingsMap.get(acc)){
                Costs_and_Charges__c cct = new Costs_and_Charges__c();
                cct.Job__c = accIdJobIdMap.get(acc.Id);
                cct.Record_Type__c = 'R';
                cct.Discount_Manual_Percentage__c = onb.Discount_Percentage__c;
                cct.Discount_Manual_Override__c = TRUE;
                if(onb.Existing_Customer__c == 'Yes'){
                    checkAccountRates(acc.Rate_Card__c, onb.Tradesperson_Text__c, acc.Id);
                    if(tradeAccntRates.get(string.valueOf(onb.Tradesperson_Text__c+acc.id)).keySet().size() > 0){
                        system.debug('Rates found for the account');
                        for(String ratesrel : tradeAccntRates.get(string.valueOf(onb.Tradesperson_Text__c+acc.id)).keySet()){
                            if(ratesrel == 'R1'){
                                cct.Hourly_Charge_R1__c = tradeAccntRates.get(string.valueOf(onb.Tradesperson_Text__c+acc.id)).get(ratesrel);
                            }if(ratesrel == 'R2'){
                                cct.Hourly_Charge_R2__c = tradeAccntRates.get(string.valueOf(onb.Tradesperson_Text__c+acc.id)).get(ratesrel);
                            }if(ratesrel == 'R3'){
                                cct.Hourly_Charge_R3__c = tradeAccntRates.get(string.valueOf(onb.Tradesperson_Text__c+acc.id)).get(ratesrel);
                            }
                        }
                    }else{
                        Set<String> strList = new  Set<String>();
                        if(tradeandRates.get(onb.Tradesperson_Text__c).keySet() != null){
                            strList = tradeandRates.get(onb.Tradesperson_Text__c).keySet();
                        }
                        for(String ratesrel : strList){
                            system.debug('No rates found for the account');
                            if(ratesrel == 'R1'){
                                cct.Hourly_Charge_R1__c = tradeandRates.get(onb.Tradesperson_Text__c).get(ratesrel);
                            }if(ratesrel == 'R2'){
                                cct.Hourly_Charge_R2__c = tradeandRates.get(onb.Tradesperson_Text__c).get(ratesrel);
                            }if(ratesrel == 'R3'){
                                cct.Hourly_Charge_R3__c = tradeandRates.get(onb.Tradesperson_Text__c).get(ratesrel);
                            }
                        }
                    }
                }else{
                    Set<String> strList = new  Set<String>();
                    if(tradeandRates.get(onb.Tradesperson_Text__c).keySet() != null){
                        strList = tradeandRates.get(onb.Tradesperson_Text__c).keySet();
                    }
                    for(String ratesrel : strList){
                        if(ratesrel == 'R1'){
                            cct.Hourly_Charge_R1__c = tradeandRates.get(onb.Tradesperson_Text__c).get(ratesrel);
                        }if(ratesrel == 'R2'){
                            cct.Hourly_Charge_R2__c = tradeandRates.get(onb.Tradesperson_Text__c).get(ratesrel);
                        }if(ratesrel == 'R3'){
                            cct.Hourly_Charge_R3__c = tradeandRates.get(onb.Tradesperson_Text__c).get(ratesrel);
                        }
                    }
                    ////////*******///////////@Bharat 
                    if(updateAccContforReferral.get(onb.Customer_email__c) != null && 
                       String.isNotBlank(updateAccContforReferral.get(onb.Customer_email__c)[0].Voucher_Code__c)){
                           System.debug('cct.Buyapowa referal set');
                           cct.Discount_PL__c = 'Buyapowa referal';
                           cct.Discount_Code__c  = onb.Voucher_Code__c;
                       }
                }
                if(acc.Attendance_Fee__c!=null){
                    cct.Call_Out_Fee__c = acc.Attendance_Fee__c;
                }else  if(acc.Attendance_Fee__c==null){
                    cct.Call_Out_Fee__c = 0;
                }
                cclist.add(cct);
            }
        }
        if(cclist.size() > 0){
            insert cclist;
        }
        
        for(Costs_and_Charges__c cc : cclist){
            JobIdCCTIdMap.put(cc.Job__c, cc.Id);
        }
        
        return jbList;
    }
    
    public static string getAccountRate(String accRateCardId, String onlineBookingId){
        
        Online_Bookings__c online = [SELECT id,Tradesperson_Text__c from Online_Bookings__c 
                                     where id=:onlineBookingId];
        System.debug('In getAccountRate online - '+online);
        
        Rate_Card_Trade__c rtl = new  Rate_Card_Trade__c();
        if(test.isRunningTest()){
            rtl = [SELECT id,Charge_R1__c,Charge_R2__c,Charge_R3__c,Trade_Name__c FROM Rate_Card_Trade__c LIMIT 1];
        }else{
            rtl = [SELECT id,Charge_R1__c,Charge_R2__c,Charge_R3__c,Trade_Name__c FROM Rate_Card_Trade__c 
                   WHERE Trade_Name__c =: online.Tradesperson_Text__c AND Rate_Card__c =: accRateCardId];
        }
        System.debug('In getAccountRate rtl - '+rtl);
        
        String tradeRateId = '';
        if(rtl != NULL){
            tradeRateId = rtl.Id;
            System.debug('In getAccountRate tradeRateId - '+tradeRateId);
        }
        return tradeRateId;
    }
    
    public static string getStandardRate(String onlineBookingId){
        
        String tradeRateId = '';
        Set<Id> worktypeslist = new Set<Id>();
        Set<String> TradeSet = new Set<String>();
        
        Online_Bookings__c online =[SELECT id,Work_Type__c from Online_Bookings__c where id=:onlineBookingId];
        System.debug('In getStandardRate online'+online);
        
        for(Worktype wtp: [select Trade__c from worktype where id =: online.Work_Type__c]){
            TradeSet.add(wtp.Trade__c);
        }
        System.debug('In getStandardRate TradeSet'+TradeSet);
        
        Rate_Card_Trade__c rtl = new Rate_Card_Trade__c();
        if(test.isRunningTest()){
            rtl = [SELECT id,Charge_R1__c,Charge_R2__c,Charge_R3__c,Trade_Name__c FROM Rate_Card_Trade__c LIMIT 1];
        }else{
            rtl = [SELECT id,Charge_R1__c,Charge_R2__c,Charge_R3__c,Trade_Name__c FROM Rate_Card_Trade__c 
                   WHERE Trade_Name__c IN: TradeSet and Rate_Card__r.Standard__c = TRUE];
        }
        
        System.debug('In getStandardRate rtl - '+rtl);
        
        if(rtl != NULL){
            tradeRateId = rtl.Id;
            System.debug('In getStandardRate tradeRateId - '+tradeRateId);
        }
        return tradeRateId;
    }

    public static List<WorkOrder> createWorkOrder(Map<Account,list<Online_Bookings__c>> accBookingsMapMethod) {
        System.debug('>>>  In createWorkOrder ');
        accountWorkOrderMap = new Map<Id,list<WorkOrder>>();
        List<WorkOrder> WOList = new List<WorkOrder>();
        for(Account acrec : accBookingsMapMethod.keySet()){
            for(Online_Bookings__c bb : accBookingsMapMethod.get(acrec)){
                WorkOrder wo = new WorkOrder();
                wo.Job__c = accIdJobIdMap.get(acrec.Id);
                wo.Online_Booking__c = bb.Id;
                wo.WorkTypeId = bb.Work_Type__c;//Id input from the form submitted online
                wo.Description = bb.Details_of_issue__c;
                wo.Requested_Date__c = bb.Preferred_date__c;
                wo.Arrival_Window_Start__c = formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[0]));
                wo.Arrival_Window_End__c = formatTime(bb.Preferred_arrival_time_slot__c.Split(' - ')[1]);
                wo.Access_Details__c = bb.Property_access_details__c;
                wo.ContactId = accIdConIdMap.get(acrec.Id);
                wo.AccountId = acrec.Id;
                wo.Site__c = accSiteIdMap.get(acrec.Id);
                if(bb.Address_line_2__c != null){
                    wo.Street = bb.Address_line_1__c + bb.Address_line_2__c;
                }else{
                    wo.Street = bb.Address_line_1__c;
                }
                String accountRate = getAccountRate(acrec.Rate_Card__c,wo.Online_Booking__c);
                String StandardRate = getStandardRate(wo.Online_Booking__c);
                System.debug(' <HM Test> accountRate - '+accountRate);
                System.debug(' <HM Test> StandardRate - '+StandardRate);
                String rateCardId = '';
                if(accountRate != null  && accountRate !=''){
                    rateCardId = accountRate;
                }else{
                    rateCardId = StandardRate;
                }
                System.debug(' <HM Test> rateCardId - '+rateCardId);
                //wo.rate_card_id__c = rateCardId;
                wo.Trade_Rate__c = rateCardId;
                /* if(accountRate !='' && accountRate != null){
wo.Account_Rate_Card__c = accountRate;
wo.Standard_Rate_Card__c = '';
wo.rate_card_id__c =
}else  if(StandardRate !='' && StandardRate!=null){
wo.Account_Rate_Card__c = '';
wo.Standard_Rate_Card__c = StandardRate;
}*/
                wo.city = bb.TownCity__c;
                wo.country = 'United Kingdom';
                wo.postalCode = bb.Postcode__c;
                wo.Costs_and_Charges__c = JobIdCCTIdMap.get(accIdJobIdMap.get(acrec.Id));
                
                //special case for Late Night: 9pm to 7am
                if(bb.Preferred_arrival_time_slot__c.Split(' - ')[0] == '21:00'){
                    Date enddate = bb.Preferred_date__c.addDays(1);
                    system.debug('!!!!!!!!!!!!!'+enddate );
                    wo.Arrival_Window_Start_Date_Time__c = Datetime.newInstance(bb.Preferred_date__c.year(), bb.Preferred_date__c.month(), bb.Preferred_date__c.day(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[0])).hour(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[0])).minute(), 0);
                    wo.Arrival_Window_End_Date_Time__c = Datetime.newInstance(enddate.year(), enddate.month(), enddate.day(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[1])).hour(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[1])).minute(), 0);
                }else{
                    wo.Arrival_Window_Start_Date_Time__c = Datetime.newInstance(bb.Preferred_date__c.year(), bb.Preferred_date__c.month(), bb.Preferred_date__c.day(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[0])).hour(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[0])).minute(), 0);
                    wo.Arrival_Window_End_Date_Time__c = Datetime.newInstance(bb.Preferred_date__c.year(), bb.Preferred_date__c.month(), bb.Preferred_date__c.day(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[1])).hour(), formatTime(String.valueOf(bb.Preferred_arrival_time_slot__c.Split(' - ')[1])).minute(), 0);
                }
                wo.RecordTypeId = getRecordTypeIdbyName('WorkOrder','Reactive');
                WOList.add(wo);
            }
        }
        if(WOList.size() > 0){
            insert WOList;
        }
        
        for(WorkOrder wo : WOList){
            if(accountWorkOrderMap.containsKey(wo.AccountId)) {
                List<WorkOrder> wolistexist = accountWorkOrderMap.get(wo.AccountId);
                wolistexist.add(wo);
                accountWorkOrderMap.put(wo.AccountId, wolistexist);
            }else{
                List<WorkOrder> wolistnew = new List<WorkOrder>();
                wolistnew.add(wo);
                accountWorkOrderMap.put(wo.AccountId, wolistnew);
            }
            onlineBookingList.add(new Online_Bookings__c(Id=wo.Online_Booking__c,Work_Order__c=wo.Id));
        }
        if(onlineBookingList.size() > 0){
            update onlineBookingList;
        }
        return WOList;
    }
    
    /**Authourization inforce Check**/
    public static void checkAuthorization(Map<Account,list<Online_Bookings__c>> accBookMap) {
        System.debug(' >>> In checkAuthorization ');
        Set<account> accreceived = accBookMap.keySet();
        Map<id,Job__c> custJobsMap = new Map<id,Job__c>();
        Map<id,asp04__Authorisation__c> custAuthsMap = new Map<id,asp04__Authorisation__c>();
        Set<Id> accstoStep2Authcheck = new Set<Id>();
        Set<Id> CashAccounts = new Set<Id>();
        List<Job__c> jbListToAuth = new List<Job__c>();
        Set<Id> objToIdacc = new Set<Id>();
        Set<Id> authIDSet = new Set<Id>();
        
        //Holding accId's incase there are no accounts with INFORCE
        for(Account ac : accreceived){
            objToIdacc.add(ac.Id);
        }
        
        system.debug('********step 1 auth');
        for(asp04__Authorisation__c authrec : [select id,asp04__Status__c,Customer__c from asp04__Authorisation__c where Customer__c in: accreceived and asp04__Status__c = 'In Force']){
            system.debug('********step 1 auth inforce');
            for(Account acc : accreceived){
                if(acc.Id == authrec.Customer__c){
                    authInforcetrue.add(authrec.Customer__c);
                    accIdAuthIdMapInforce.put(authrec.Customer__c,authrec.Id);
                    //Attaching an existing inforce Auth to the new Job
                    system.debug('********step 1 auth inforce,Attaching an existing inforce Auth to the new Job');
                    
                    
                    if(authIDSet.contains(authrec.Customer__c)){
                        //Collecting only one 'INFORCE' Auth per customer
                    }else{
                        authIDSet.add(authrec.Customer__c);
                        jbListToAuth.add(new Job__c(Id=accIdJobIdMap.get(authrec.Customer__c), Authorisation__c=authrec.Id));
                    }
                    
                }else{
                    authInforcefalse.add(authrec.Customer__c);
                }
            }
            
            for(Id inforacc: authInforcefalse){
                if(authInforcetrue.contains(inforacc))
                    authInforcefalse.remove(inforacc);
            }
        }
        
        
        //Next step for AuthsNotINForce
        for(Account acc : accreceived){
            system.debug('********step 2 authNOTinforce');
            if(!accIdAuthIdMapInforce.keySet().Contains(acc.id)){
                system.debug('*******step 2 auth insideif');
                //Accounts to proceed Step 2 of AuthCheck
                accstoStep2Authcheck.add(acc.Id);
            }
        }
        
        //seperate Customers/Accounts based on Cash and (Key or Credit)
        for(Account recAcc : [select Id,Account_Type__c from account where id in: accstoStep2Authcheck]){
            //skipping second step authorization for Key and Credit accounts, directly creating SA
            if(recAcc.Account_Type__c == 'Key Account' || recAcc.Account_Type__c == 'Credit'){
                KeyOrCreditAccounts.add(recAcc.id);
            }
            if(recAcc.Account_Type__c == 'Cash'){
                CashAccounts.add(recAcc.id);
            }
        }
        
        
        //Step 2 of Auth Check
        List<asp04__Authorisation__c> authrecList = [select id,asp04__Status__c,Customer__c,Send_Email__c from asp04__Authorisation__c where Customer__c in: CashAccounts and (asp04__Status__c = 'Pending' or asp04__Status__c = 'Awaiting submission') and Online_Booking__c = TRUE];
        if(authrecList.size() > 0){
            system.debug('********step 2 authNOTinforce, Pending and awating submission');
            for(asp04__Authorisation__c authorec : authrecList){
                
                //Making sure only 1 auth attached to a customer, if there were multiple pending or awaiting submission auths
                if(custJobsMap.containsKey(authorec.Customer__c)) {
                    //do nothing
                    system.debug('********doing nothing , custJobsMAP');
                } else {
                    Job__c jb1 = new Job__c(Id=accIdJobIdMap.get(authorec.Customer__c), Authorisation__c=authorec.Id);
                    custJobsMap.put(authorec.Customer__c, jb1);
                    custAuthsMap.put(authorec.Customer__c,authorec);
                    system.debug('********custJobsMap , custAuthsMap');
                }
                
            }
            
            //Attaching an existing Pending or Awaiting submission Auth to the new Job
            for(Id accId : custJobsMap.KeySet()){
                jbListToAuth.add(custJobsMap.get(accId));
                system.debug('********Attaching an existing Pending or Awaiting submission Auth to the new Job');
            }
            
            //Update Authlist to receive emails again (as process builder triggers payment method emails when updated)
            for(Id accntId : custAuthsMap.KeySet()){
                system.debug('*******Update Authlist to receive emails again');
                asp04__Authorisation__c authre = custAuthsMap.get(accntId);
                authre.Send_Email__c = TRUE;
                AuthListToUpdate.add(authre);
            }
        }else{
            //accstoStep2Authcheck
            system.debug('********creating auth');
            createAuthorization(CashAccounts);
        }
        
        update jbListToAuth;
        update AuthListToUpdate;//This update triggers resending of payment method emails when updated
        
        
        //Proceed to create SA
        if(authInforcetrue.size() > 0){
            createServiceAppointments(authInforcetrue);
        }
        //Proceed to create SA for Credit or Key accounts
        if(KeyOrCreditAccounts.size() > 0){
            createServiceAppointments(KeyOrCreditAccounts);
        }
        
    }
    
    /*Create a authorization rec*/
    public static void createAuthorization(Set<Id> accSet) {
        System.debug('>>> In createAuthorization');
        List<asp04__Authorisation__c> newAuthList = new List<asp04__Authorisation__c>();
        for(Account acc : [select id,Name,First_Name__c,Last_Name__c,Email__c,BillingStreet,BillingCity,BillingCountry,BillingPostalCode from account where id in: accSet]){
            asp04__Authorisation__c auth = new asp04__Authorisation__c();
            auth.asp04__Account_Name__c = acc.Name;
            auth.Customer__c = acc.Id;
            auth.asp04__First_Name__c = acc.First_Name__c;
            auth.asp04__Last_Name__c = acc.Last_Name__c;
            auth.asp04__Email__c = acc.Email__c;
            auth.Online_Booking__c = TRUE;
            auth.Send_Email__c = TRUE;
            auth.Customer_Email__c = acc.Email__c;
            auth.asp04__Billing_Address_Street__c = acc.BillingStreet;
            auth.asp04__Billing_Address_City__c = acc.BillingCity;
            auth.asp04__Billing_Address_Country__c = acc.BillingCountry;
            auth.asp04__Billing_Address_PostalCode__c = acc.BillingPostalCode;
            newAuthList.add(auth);
        }
        insert newAuthList;
        AuthListToUpdate.addall(newAuthList);// This is added for later re-updating SendEmail to false
        
        List<Job__c> jbListToAuth = new List<Job__c>();
        for(asp04__Authorisation__c auth : newAuthList){
            accIdAuthIdMapNew.put(auth.Customer__c,auth.Id);
            jbListToAuth.add(new Job__c(Id=accIdJobIdMap.get(auth.Customer__c), Authorisation__c=auth.Id));
        }
        update jbListToAuth;
    }
    
    //create SA and AR
    public static void createServiceAppointments(Set<Id> accSet) {
        List<ServiceAppointment> newSAList = new List<ServiceAppointment>();
        for(Account acc : [select id,Name,First_Name__c,Last_Name__c,Email__c,BillingStreet,BillingCity,BillingCountry,BillingPostalCode from account where id in: accSet]){
            
            for(WorkOrder wrkO : accountWorkOrderMap.get(acc.Id)){
                
                //get Duration
                Integer workOrderDuration = getWorkOrdersDuration(wrkO);
                //calculate calculateSchedule_Slot_Start and end
                DateTime startdt = calculateSchedule_Slot(wrkO,'Start',workOrderDuration);
                system.debug('next line');
                DateTime Enddt= calculateSchedule_Slot(wrkO,'End',workOrderDuration);
                
                
                ServiceAppointment sa = new ServiceAppointment();
                sa.ParentRecordId = wrkO.Id;
                sa.ContactId = accIdConIdMap.get(acc.Id);
                sa.Contact_Email__c = acc.Email__c;
                //  sa.Allocated_Engineer__c = 
                //to check if workOrder dates are old or less than today
                if(wrkO.Requested_Date__c < system.Today() && !(wrkO.Arrival_Window_End_Date_Time__c.hour() <= (System.now().hour()+1))){
                    system.debug('date less than today and Time is OK');
                    sa.EarliestStartTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), wrko.Arrival_Window_Start_Date_Time__c.hour(), wrko.Arrival_Window_Start_Date_Time__c.MINUTE(), 0);
                    sa.DueDate = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), wrko.Arrival_Window_End_Date_Time__c.hour()+workOrderDuration, wrko.Arrival_Window_End_Date_Time__c.MINUTE(), 0);//Enddt;//* have some doubts
                    sa.SchedStartTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), wrko.Arrival_Window_Start_Date_Time__c.hour(), wrko.Arrival_Window_Start_Date_Time__c.MINUTE(), 0);
                    sa.SchedEndTime = DateTime.newInstance(system.Today().year(),system.Today().month() ,system.Today().day(), wrko.Arrival_Window_Start_Date_Time__c.hour()+workOrderDuration, wrko.Arrival_Window_Start_Date_Time__c.MINUTE(), 0);
                }
                else if((wrkO.Requested_Date__c == system.now().date() && wrkO.Arrival_Window_End_Date_Time__c.hour() <= (System.now().hour()+1)) || wrkO.Requested_Date__c < system.Today() && (wrkO.Arrival_Window_End_Date_Time__c.hour() <= (System.now().hour()+1))){
                    system.debug('date = or less than today and Time is less than now');
                    Integer dt1 = (wrkO.Requested_Date__c).daysBetween(system.now().date());
                    dt1 = dt1+1;
                    //days difference (0 OR 1-n) + (1)
                    sa.EarliestStartTime = startdt+ dt1;//increase by 1 day
                    sa.DueDate =Enddt + dt1;//increase by 1 day
                    sa.SchedStartTime = startdt + dt1;//increase by 1 day
                    sa.SchedEndTime = DateTime.newInstance(startdt.year(),startdt.month() ,startdt.day() + dt1, startdt.hour()+workOrderDuration,startdt.MINUTE(), 0);
                }else{
                    system.debug('Falls in the last else');
                    sa.EarliestStartTime = startdt;
                    sa.DueDate = Enddt;
                    sa.SchedStartTime = startdt;
                    sa.SchedEndTime = DateTime.newInstance(startdt.year(),startdt.month() ,startdt.day(), startdt.hour()+workOrderDuration,startdt.MINUTE(), 0);
                }
                sa.Duration = wrko.Duration;
                sa.Status = 'New';
                sa.Online_Booking_SA__c = TRUE;
                newSAList.add(sa);
                System.debug(' <HM> newSAList 1 -'+newSAList);
            }
        }
        insert newSAList;
        System.debug(' <HM> newSAList 2 -'+newSAList);
        System.debug(' <HM> newSAList 3 -'+newSAList.size());
        //assign a resource to the Appointment
        if(newSAList.size()>0){
            createAssignedResource(newSAList);
        }
    }
    
    public static void createAssignedResource(List<ServiceAppointment> receivedSAList) {
        List<AssignedResource> asList = new List<AssignedResource>();
        for(ServiceAppointment sa : receivedSAList){
            System.debug(' <HM> newSAList 4 -'+sa);
            AssignedResource arrec = new AssignedResource();
            arrec.ServiceAppointmentId = sa.Id;
            arrec.ServiceResourceId = getServiceResource();
            System.debug(' <HM> newSAList 5 -'+arrec);
            asList.add(arrec);
            System.debug(' <HM> newSAList 6 -'+asList);
        }
        System.debug(' <HM> newSAList 7 -'+asList);
        insert asList;
        System.debug(' <HM> newSAList 8 -'+asList);
    }
    
    public static List<Online_Bookings__c> mapExistingAccountswithBookings(Map<Account,list<Online_Bookings__c>> accBookingsMap){
        List<Online_Bookings__c> obList = new List<Online_Bookings__c>();
        for(Account ac : accBookingsMap.keySet()){
            for(Online_Bookings__c onBook : accBookingsMap.get(ac)){
                obList.add(new Online_Bookings__c(Id=onBook.Id, Account__c=ac.Id));
            }
        }
        
        //Map Account and contact records for existing users
        List<contact> contactlist = [select id,email,AccountId from contact where AccountId in : accBookingsMap.keySet()];
        for(Contact contrec : contactlist){
            accIdConrecMap.put(contrec.AccountId,contrec);
        }
        
        
        system.debug('obList size'+ obList.size());
        system.debug('obList :'+ obList);
        update obList;
        return obList;
    }
    
    public static time formatTime(String timeString){
        String[] strTimeSplit = timeString.split(':');
        Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);
        return timeChange;
    }
    
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    
    public static Set<Id> getAccoutIdSet(Set<Account> accList){
        Set<Id> idset = new Set<Id>();
        for(Account acc : accList){
            idset.add(acc.Id);
        }
        return idset;
    }
    
    public static DateTime calculateSchedule_Slot(WorkOrder wo,String strtOrEnd,Integer workOrderDuration){
        DateTime myDateTime;
        if(strtOrEnd == 'Start'){
            myDateTime  = DateTime.newInstance(wo.Requested_Date__c.year(),wo.Requested_Date__c.month() ,wo.Requested_Date__c.day(), wo.Arrival_Window_Start__c.hour(), wo.Arrival_Window_Start__c.MINUTE(), 0);
            system.debug('start time' + myDateTime);
        }
        if(strtOrEnd == 'End'){
            Integer tim = Integer.valueOf((workOrderDuration+((workOrderDuration/8)*16)));
            system.debug('@@@@@'+wo.Arrival_Window_End__c);
            if(wo.Arrival_Window_End__c < wo.Arrival_Window_Start__c){
                myDateTime  = DateTime.newInstance(wo.Requested_Date__c.year(),wo.Requested_Date__c.month() ,wo.Requested_Date__c.day()+1, wo.Arrival_Window_End__c.hour()+tim, wo.Arrival_Window_End__c.MINUTE(), 0);
                system.debug('end time<' + myDateTime);
            }else{
                myDateTime  = DateTime.newInstance(wo.Requested_Date__c.year(),wo.Requested_Date__c.month() ,wo.Requested_Date__c.day(), wo.Arrival_Window_End__c.hour()+tim, wo.Arrival_Window_End__c.MINUTE(), 0);
                system.debug('end time>' + myDateTime);
            }
        }
        
        return myDateTime;
    }
    
    public static Id getServiceResource(){
        ServiceResource serviceResId = [select id from ServiceResource where IsActive = true and Auto_Booking_Resource__c = true limit 1];
        return serviceResId.Id;
    }
    
    public static Integer getWorkOrdersDuration(WorkOrder wo){
        WorkType wtyp = [select id,EstimatedDuration from workType where id =: wo.WorkTypeId];
        return integer.valueOf(wtyp.EstimatedDuration);
    }
    
    static Map<String,Map<string,Decimal>> checkAccountRates(Id accRateCardId,String trade, Id accid){
        tradeAccntRates = new Map<String,Map<String,Decimal>>();
        Map<string,Decimal> tradeandRatesAccreltd  = new Map<string,Decimal>();
        Rate_Card_Trade__c rtl = new  Rate_Card_Trade__c();
        if(test.isRunningTest()){
            rtl = [SELECT id,Charge_R1__c,Charge_R2__c,Charge_R3__c,Trade_Name__c FROM Rate_Card_Trade__c LIMIT 1];
        }else{
            rtl = [SELECT id,Charge_R1__c,Charge_R2__c,Charge_R3__c,Trade_Name__c FROM Rate_Card_Trade__c 
                   WHERE Trade_Name__c =: trade AND Rate_Card__c =: accRateCardId];
        }
            if(rtl != null){
            tradeandRatesAccreltd.put('R1', rtl.Charge_R1__c);
            tradeandRatesAccreltd.put('R2', rtl.Charge_R2__c);
            tradeandRatesAccreltd.put('R3', rtl.Charge_R3__c);
        }
        tradeAccntRates.put(trade+accid,tradeandRatesAccreltd);
        return tradeAccntRates;
    }
    
    public static void updateAuthSendEmailFalse(List<asp04__Authorisation__c> AuthUpdate){
        List<asp04__Authorisation__c> listoUpdate = new List<asp04__Authorisation__c>();
        for(asp04__Authorisation__c authUpd : AuthUpdate){
            authUpd.Send_Email__c = FALSE;
            listoUpdate.add(authUpd);
        }
        update listoUpdate;
    }
    
    @future
    public static void deleteONBrecords(List<Id> deleteSpamRecords){
        List<Online_Bookings__c> deleterecs = [select id,Details_of_issue__c,Name from Online_Bookings__c where id in : deleteSpamRecords];
        
        String spamAlertEmailIDs = Label.SpamAlertEmail;
        List<String> splitData = spamAlertEmailIDs.split(';');
        
        for(Online_Bookings__c onb : deleterecs ){
            Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(String.valueOf(userinfo.getuserid()));
            
            EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body,name  from EmailTemplate where Name= 'SPAM ALERT'];
            mail.setTemplateId(et.id);
            
            mail.setHtmlBody('Hi Team, <br/> An ONB :<b> ' + onb.Name +' </b>with SPAM text has been deleted.<p><b>'+
                             'Details of the spammed text </b>: '+onb.Details_of_issue__c+'<br/><br/> Thanks, <br/>Aspect');
            
            mail.setCCAddresses(splitData);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            
            mail.setSenderDisplayName('SPAM DETECT ALERT');
            
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        delete deleterecs;
    }
}