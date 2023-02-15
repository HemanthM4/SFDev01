public class sr_skill_change_controller {

    public sr_skill_change_controller() {}
    
    public void after_insert(ServiceResourceSkill new_srs){
        ServiceResource sr = [SELECT id 
                              FROM ServiceResource 
                              WHERE id = :new_srs.ServiceResourceId];
        // get old set of engineers
        list <WorkType> old_list = getWTset(sr, new_srs);
        list <WorkType> new_list = getWTset(sr);
        if ( new_list!=NULL ) {
            for (WorkType wt:new_list){
                if (!old_list.contains(wt)){
                    if(wt.Qualified_Resource_Count__c == NULL)
                    {
                        wt.Qualified_Resource_Count__c = 0;
                    }
                    wt.Qualified_Resource_Count__c ++ ;
                    update wt;
                }
            }
            sr.Qualifying_WTs_Count__c = new_list.size();
            update sr;
        }
    }
    
    public void before_delete(ServiceResourceSkill new_srs){
        ServiceResource sr = [SELECT id 
                              FROM ServiceResource 
                              WHERE id = :new_srs.ServiceResourceId];
        // get old set of engineers
        list <WorkType> new_list = getWTset(sr, new_srs);
        list <WorkType> old_list = getWTset(sr);
        if ( old_list!=NULL ) {
            for (WorkType wt:old_list) {
                if (!new_list.contains(wt)) {
                    wt.Qualified_Resource_Count__c -- ;
                    update wt;
                }
            }
            sr.Qualifying_WTs_Count__c = new_list.size();
            update sr;
        }
    }
    public list <WorkType> getWTset(ServiceResource sr) 
    {
         return helper([ 
             SELECT id FROM Skill WHERE id IN ( 
                 SELECT SkillId 
                 FROM ServiceResourceSkill 
                 WHERE ServiceResourceId = :sr.id 
             )
         ]);      
    }
    public list <WorkType> getWTset(ServiceResource sr, ServiceResourceSkill new_srs) 
    {
        
        return helper([ 
            SELECT id FROM Skill WHERE id IN ( 
                SELECT SkillId 
                FROM ServiceResourceSkill 
                WHERE ServiceResourceId = :sr.id
                //// exclude 
                AND id != :new_srs.id
            )
        ]);
    }
    public list <WorkType> helper(List<Skill> sr_skills) 
    {
        List<id> res_ids = new List<id>();
        Map<id,integer> map_sr_wt = new Map<id,integer>(),
            map_wt_sreq = new Map<id,integer>();
        for( SkillRequirement sreq:[SELECT RelatedRecordId 
                                    FROM SkillRequirement 
                                    WHERE SkillId IN :sr_skills ]) 
        {
            if ( !map_sr_wt.containsKey(sreq.RelatedRecordId) )
            { map_sr_wt.put(sreq.RelatedRecordId,0); }
            map_sr_wt.put(sreq.RelatedRecordId,map_sr_wt.get(sreq.RelatedRecordId)+1);    
        }
        for( SkillRequirement sreq:[SELECT RelatedRecordId 
                                    FROM SkillRequirement 
                                    WHERE RelatedRecordId IN :map_sr_wt.keyset()] ) 
        {
            if ( !map_wt_sreq.containsKey(sreq.RelatedRecordId) )
            { map_wt_sreq.put(sreq.RelatedRecordId,0); }
            map_wt_sreq.put(sreq.RelatedRecordId,map_wt_sreq.get(sreq.RelatedRecordId)+1);   
        }
        for ( id key : map_wt_sreq.keyset() ) {
            if (map_wt_sreq.get(key) ==  map_sr_wt.get(key) )
            { res_ids.add(key); }
        }
        return [SELECT id, name, Qualified_Resource_Count__c 
                FROM WorkType 
                WHERE id IN :res_ids ];
    }
        
}