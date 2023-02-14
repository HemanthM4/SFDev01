trigger ServiceTerrMemberTrigger on ServiceTerritoryMember (before insert,before Update) {
    if(Trigger.isBefore){
        SET<id> SRids =New SET<id>();
        set<id> setSResource =New set<id>();
        for(ServiceTerritoryMember ser : Trigger.new)
        {
            SRids.add(ser.ServiceResourceId);
        }
        if(SRids.size()>0)
        {
            List<String> resources = System.Label.Service_Resources_Name.Split(',');
            for(ServiceResource LstSR:[SELECT id,NAME FROM ServiceResource where id IN:SRids AND Name IN:resources])         
            {setSResource.add(LstSR.id);
            }
        }
        if(Trigger.isInsert){
            ServiceTerrMemTriggerHandler.beforeInsert(Trigger.new,setSResource);
        }else if(Trigger.isUpdate)
        {
            ServiceTerrMemTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap,setSResource);
        }   
    }
}