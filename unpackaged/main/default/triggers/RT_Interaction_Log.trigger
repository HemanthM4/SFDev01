trigger RT_Interaction_Log on Task (before update) 
{
    for( Task t: Trigger.new )
    {
        if( Trigger.oldMap.get(t.ID).whatID != Trigger.newMap.get(t.ID).whatID )
        {
            RT_Interaction_Log_Controller.stamp_related_info(t);
        }
    }
}