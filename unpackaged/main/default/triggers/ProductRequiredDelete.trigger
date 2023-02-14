trigger ProductRequiredDelete on ProductRequired (before delete, after insert, after update) {
    
    if( Trigger.isDelete)
    {
        //for (ProductRequired preq : Trigger.old)
        //{
            Phase2_ProductRequiredController controller = new Phase2_ProductRequiredController();
            controller.PREQ_deleted(Trigger.old);
        //}
    } 
    if (Trigger.isInsert || Trigger.isUpdate)
    {
        //for (ProductRequired preq : Trigger.new)
        //{
            Phase2_ProductRequiredController controller = new Phase2_ProductRequiredController();
            controller.PREQ_created_edited(Trigger.new);
        //}
    }
}