@isTest
public class LinkResponseTapToTaskRecordSched_Test {
	
    static testMethod void linkResponseToTaskMethod(){
        
        RTap__ResponseTap_Call__c responseTapRec = new RTap__ResponseTap_Call__c();
        responseTapRec.RTap__Customer_Number__c = '+1234567890';
        responseTapRec.RTap__Call_DateTime__c = system.now().addSeconds(20);
        responseTapRec.RTap__Status__c = 'Closed';
        responseTapRec.RTap__Duration__c = 100;
        insert responseTapRec;
        
        Task taskrec = new Task();
        taskrec.CLI__c = '+1234567890';
        taskrec.Subject = 'Call';
        taskrec.Interaction_Start_Time__c= '2022-10-17T10:09:58.605Z';
        taskrec.CallType = 'Inbound';
        insert taskrec;
        
        SchedulableContext sc = null;
        LinkResponseTapToTaskRecordScheduler obj = new LinkResponseTapToTaskRecordScheduler();
        obj.execute(sc);
    }
    
    static testMethod void linkResponseToTaskMethod2(){
        
        RTap__ResponseTap_Call__c responseTapRec = new RTap__ResponseTap_Call__c();
        responseTapRec.RTap__Customer_Number__c = '+1234567890';
        responseTapRec.RTap__Call_DateTime__c = system.now().addSeconds(20);
        responseTapRec.RTap__Status__c = 'Closed';
        insert responseTapRec;
        
        Task taskrec = new Task();
        taskrec.CLI__c = '+1234567811';
        taskrec.Subject = 'Call';
        taskrec.Interaction_Start_Time__c= '2022-10-17T10:09:58.605Z';
        taskrec.CallType = 'Inbound';
        insert taskrec;
        
        SchedulableContext sc = null;
        LinkResponseTapToTaskRecordScheduler obj = new LinkResponseTapToTaskRecordScheduler();
        obj.execute(sc);
    }
}