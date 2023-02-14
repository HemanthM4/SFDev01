trigger wt_sreq_change_trigger on SkillRequirement (after insert, after update, before delete) {
                          System.debug('\n trigger start \n');

    if (Trigger.isInsert)
    {
        for ( SkillRequirement sreq:Trigger.new  ) {
            if (Trigger.NewMap.get(sreq.ID).RelatedRecordId.getSObjectType().getDescribe().getName() == 'WorkType')
            {           
                wt_sreq_change_controller tmp = new wt_sreq_change_controller();
                tmp.after_insert(sreq);
            }
        }
    }
     if (Trigger.isUpdate)
    {
                              System.debug('\n trigger update \n');
    }    
    if (Trigger.isDelete)
    {
            for ( SkillRequirement sreq:Trigger.old  ) {
            if (Trigger.OldMap.get(sreq.ID).RelatedRecordId.getSObjectType().getDescribe().getName() == 'WorkType')
            {           
            wt_sreq_change_controller tmp = new wt_sreq_change_controller();
            tmp.before_delete(sreq);
            }
        }
    }
}