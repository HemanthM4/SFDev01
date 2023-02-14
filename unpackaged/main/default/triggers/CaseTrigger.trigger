trigger CaseTrigger on Case (before insert,after Update,before update, before delete,after insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            System.debug('entered');
            CaseTriggerhandler.beforeInsert(Trigger.new);
        }else  if(Trigger.isUpdate){
            CaseTriggerhandler.beforeUpdate(Trigger.new,Trigger.OldMap);
        }else  if(Trigger.isDelete){
            CaseTriggerhandler.beforeDelete(Trigger.old);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
             CaseTriggerhandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }else  if(Trigger.isInsert){
             CaseTriggerhandler.afterInsert(Trigger.new);
        }
    }

}