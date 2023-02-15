@isTest
public class RT_Interaction_Log_Controller_Test {
    
    static testmethod void interaction_log_test()
    {
        RTap__ResponseTap_Call__c rtc = new RTap__ResponseTap_Call__c(
            RTap__Customer_Number__c = '+123456789',
            RTap__Call_DateTime__c = Datetime.now(),
            RTap__Duration__c = 10
        );
        insert rtc;
        
        Task t = new Task(
            OwnerId = [SELECT id FROM User LIMIT 1].id,
            CLI__c = rtc.RTap__Customer_Number__c
        );
        insert t;
        
        rtc.RTap__Status__c = 'Closed';
        update rtc;

        RTap__ResponseTap_Call__c rtc2 = new RTap__ResponseTap_Call__c();
        insert rtc2;
        rtc2.RTap__Status__c = 'Closed';
        update rtc2;
                
        Account a = new Account(
            Name = 'Test',
            Account_Type__c = 'Cash',
            Account_Status__c = 'Open'
        );
        insert a;        
        t.WhatId = a.id;
        update t;
        
        Contact c = new Contact(
            AccountId = a.Id,
            LastName = 'LastName'
        ); 
        insert c;
        
        Site__c s = new Site__c(
            Name = 'Test Site',
            Site_Street__c = '123 Test Street',
            Site_PostalCode__c = 'AB1 2CD',
            Account__c = a.Id,
            Primary_Site_Contact__c = c.id
        );
        insert s;
        t.WhatId = s.id;
        update t;
 
        Job__c j = new Job__c(
            Account__c = a.id,
            Site__c = s.id
        );
        insert j;
        t.WhatId = j.id;
        update t;
        
        WorkOrder wo = new WorkOrder(
            Job__c = j.Id
        );
        insert wo;         
        t.WhatId = wo.id;
        update t;
       
    }
}