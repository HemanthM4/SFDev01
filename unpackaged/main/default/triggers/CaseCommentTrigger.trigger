trigger CaseCommentTrigger on CaseComment (After insert,before insert,before Update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
           CaseCommentTriggerHandler.afterInsert(Trigger.new);
        }
    }else if(Trigger.isBefore){
        if(Trigger.isInsert){
             CaseCommentTriggerHandler.beforeInsert(Trigger.new);
        }else if(Trigger.isUpdate){
             CaseCommentTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}