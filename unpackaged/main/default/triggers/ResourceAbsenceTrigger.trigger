trigger ResourceAbsenceTrigger on ResourceAbsence (before insert,before update) {
    if(Trigger.isBefore){
        if(trigger.isInsert){
            ResourceAbsenceTriggerHandler.beforeInsert(Trigger.new);
        }else if(Trigger.isUpdate){
            ResourceAbsenceTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }  
    }
}