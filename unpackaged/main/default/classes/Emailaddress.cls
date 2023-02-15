public class Emailaddress{

    @InvocableMethod
    public static void EmailAddresses(list<String> jobslist){
        
        //Data crunch to seperate emailId from the rest of JOBIDs
        string data = jobslist[0];
        String emailString = '';
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> authIdSet = new Set<Id>();
        Set<Id> siteIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        
        List<String> splitData = data.split(';');
        
        
        List<Id> trimmedJobIdList = new List<Id>(); 
         //Identify the email in the list
         for(String recvdListrec : splitData){
            if(recvdListrec.contains('@')){
                emailString = recvdListrec;
            }else{
                trimmedJobIdList.add(id.valueOf(recvdListrec.trim()));
            } 
         }
         
         ////Update Jobs
            list<Job__c> joblist = [select id,Site__c,Site__r.Primary_Site_Contact__c,Contact_Email_who_Raised_Job__c,Account__c,Authorisation__c from Job__c where Id in :  trimmedJobIdList];

            system.debug('Job list ' + joblist.size());

            for(Job__c jj : joblist){
                jj.Contact_Email_who_Raised_Job__c = emailString;
                accIdSet.add(jj.Account__c);
                authIdSet.add(jj.Authorisation__c); 
                siteIdSet.add(jj.Site__c);
                if(jj.Site__r.Primary_Site_Contact__c != NULL){
                    contactIdSet.add(jj.Site__r.Primary_Site_Contact__c);
                }
                
            }
            update joblist; 
          
         //Account 
         List<Account> accList = [select id,email__c,Invoicing_Email_Address__c  from account where id in: accIdSet];
         for(Account acc : accList){
                acc.Invoicing_Email_Address__c = emailString;
                acc.Email__c = emailString;
          }
            update accList;
         
         //Contact
         if(contactIdSet.size() > 0){
             List<Contact> contList = [select id,Email from Contact where Id  in: contactIdSet];
             for(Contact Con: contList ){
                    con.Email = emailString;
              }
              update contList ;
         }
         
          
         //Site 
         List<Site__c> siteList = [select id,Email__c from Site__c where id in: siteIdSet];
         for(Site__c siterec: siteList ){
                siterec.Email__c = emailString;
          }
          update siteList;
         
         //WO , Pending,
         list<WorkOrder> wolist = [select id,Contact_Email_who_Raised_Work_Order__c from WorkOrder where Job__c in :  trimmedJobIdList and Status = 'Pending'];
         for(WorkOrder ww : wolist){
            ww.Contact_Email_who_Raised_Work_Order__c = emailString;
         }
         update wolist;
        
         //Authorization ,Awaiting submission, Pending or INforce
         list<asp04__Authorisation__c> authlist = [select id,Customer_Email__c from asp04__Authorisation__c where id in :  authIdSet and 
         (asp04__Status__c = 'Awaiting submission' OR asp04__Status__c = 'Pending' OR asp04__Status__c = 'In Force')];
         for(asp04__Authorisation__c auth : authlist){
               auth.Customer_Email__c = emailString;
               auth.asp04__Email__c = emailString;
         }
         update authlist;
            
         //SA ,!= Visit complete
         List<ServiceAppointment> SAList = [select id,Contact_Email__c from ServiceAppointment where Work_Order__c in :  wolist and Status != 'Visit Complete'];
         for(ServiceAppointment sa : SAList){
             sa.Contact_Email__c = emailString;
         }
         update SAList;
        
          //CI , Outstanding, Account__c
          list<Customer_Invoice__c> CIlist = [select id,Account_Email_Address__c from Customer_Invoice__c where Job__c in :  trimmedJobIdList and Status__c != 'Paid'];
          for(Customer_Invoice__c ci : CIlist){
               ci.Account_Email_Address__c = emailString;
          }
          update CIlist;
            
         //Not including payments for email updates   
         /*Payment , != Collected from customer
         list<asp04__Payment__c> paymentlist = [select id,Account_Email__c from asp04__Payment__c where Customer__c in :  accIdSet];
         for(asp04__Payment__c pay : paymentlist){
              pay.Account_Email__c = 'upparapalli3.saikrishna@gmail.com';
         }
         update paymentlist;*/
                        
    }
}