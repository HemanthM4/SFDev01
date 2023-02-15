/*
* Class  : BuyapowaGetURLsBatch
* Use    : This class is written to get two URLs(share_url & dashboard_url) from Buyapowa via Integration.
* Auther : Bharat Vyas, 21/7/2022
*/

public class BuyapowaGetURLsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{

    public void execute(SchedulableContext sc){
        database.executebatch(new BuyapowaGetURLsBatch());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        // collect the batches of records or objects to be passed to execute
        // Limit is set to 90 as we have callout limit 100 in one transaction.    
        String query = 'Select Id, Name, First_Name__c, Last_Name__c, Email__c, Buyapowa_Share_URL__c, Buyapowa_Dashboard_URL__c, Buyapowa_Signup_Status__c From Account Where Buyapowa_Share_URL__c = null AND Buyapowa_Dashboard_URL__c = null AND Pending_Referrer__c = true LIMIT 90';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> records){
        // process each batch of records
        List<Account> accList = new List<Account>();
        Buyapowa_Integration_Details__mdt  signUpAPIDetail = Buyapowa_Integration_Details__mdt.getInstance('Buyapowa_Signup_API');
        for(Account acc : records){
            
            System.debug('records >>> '+records);
            
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(signUpAPIDetail.Endpoint__c);
                request.setMethod(signUpAPIDetail.Method__c);
                request.setHeader('Content-Type', signUpAPIDetail.Content_Type__c);
                request.setHeader('auth_id',signUpAPIDetail.Auth_Id__c);
                request.setHeader('auth_token', signUpAPIDetail.Auth_Token__c);
                request.setBody('{"campaign_slug": "'+signUpAPIDetail.Campaign_Slug__c+'","send_auto_invite_email": false,"signup": {"email": "'+acc.Email__c+'","first_name": "'+acc.First_Name__c+'","last_name": "'+acc.Last_Name__c+'","custom_field_value": "'+acc.Id+'","locale": "en"}}');
                System.debug('request >>> '+request.getBody());
                HttpResponse response = http.send(request);
                System.debug('response >>> '+response.getBody());
                
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                String share_url = String.valueOf(results.get('share_url'));
                String dashboard_url = String.valueOf(results.get('dashboard_url'));
                String signup_Status = String.valueOf(results.get('status'));
                 
                System.debug('share_url >>> '+share_url);
                System.debug('dashboard_url >>> '+dashboard_url);
                System.debug('signup_Status >>> '+signup_Status);
                
                if(share_url != null){
                    
                    acc.Buyapowa_Share_URL__c = share_url;
                    acc.Buyapowa_Dashboard_URL__c = dashboard_url;
                    acc.Buyapowa_Signup_Status__c = signup_Status;
                    accList.add(acc);
                }
                
        }
        if(!accList.isEmpty()){
            update accList;
            System.debug('updated accList >>> '+accList);
        }
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}