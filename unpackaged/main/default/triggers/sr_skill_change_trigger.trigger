trigger sr_skill_change_trigger on ServiceResourceSkill (after insert, before delete) {

    if (Trigger.isInsert)
    {
        for ( ServiceResourceSkill srskill:Trigger.new  ) {          
            sr_skill_change_controller tmp = new sr_skill_change_controller();
            tmp.after_insert(srskill);
        }
    }
    if (Trigger.isUpdate) {}     
    if (Trigger.isDelete) 
    {
        for ( ServiceResourceSkill srskill:Trigger.old  ) {          
            sr_skill_change_controller tmp = new sr_skill_change_controller();
            tmp.before_delete(srskill);
        }
    }
}