trigger AuthorisationTrigger on asp04__Authorisation__c (before insert) {
if(Trigger.isInsert && Trigger.isBefore)  
    {
        for(asp04__Authorisation__c p : Trigger.new ) 
        {
            p.asp04__Merchant_Group__c = 'cybersource_test';
        }
    }
    
}