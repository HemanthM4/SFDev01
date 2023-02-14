trigger PC_Interaction_Log on RTap__ResponseTap_Call__c (before update) 
{  
    /*
    for( RTap__ResponseTap_Call__c rtc: Trigger.new )
    {
        if( Trigger.oldMap.get(rtc.ID).RTap__Status__c != Trigger.newMap.get(rtc.ID).RTap__Status__c &&
            Trigger.newMap.get(rtc.ID).RTap__Status__c == 'Closed'){
            RT_Interaction_Log_Controller.link_rt_to_pc(rtc);
        }
    }
    */
}