public class Phase_2_SR_activation_change_controller {


   public static void beforeUpdate(List<ServiceResource> sr, Map<id,ServiceResource> srmap){
        for(ServiceResource srrecord : sr){
            if(srrecord.IsActive != srmap.get(srrecord.id).IsActive){
                if(srrecord.IsActive){
                    srrecord.Qualifying_WTs_Count__c = before_activation(srrecord);
                }else{
                    before_deactivation(srrecord);
                }
            }
        }
    }
    public static integer before_activation(ServiceResource sr) {
        
        list <WorkType> wts = getWTset(sr);
        List<WorkType> wtUpdate = new List<WorkType>();
        if(wts.size() != 0){
            for (WorkType wt:wts)
            {
                wt.Qualified_Resource_Count__c =  wt.Qualified_Resource_Count__c + 1;
                wt.Qualified_Inactive_Resource_Count__c  =  wt.Qualified_Inactive_Resource_Count__c - 1;
                wtUpdate.add(wt);
            }  
        }
        
        if(wtUpdate.size() !=0){
            update wtUpdate;
        }
        return wtUpdate.size();
    }
    public static void before_deactivation(ServiceResource sr)
    {
        sr.Qualifying_WTs_Count__c = 0;
        list <WorkType> wts = getWTset(sr);
        List<WorkType> wtUpdate = new List<WorkType>();
        if(wts.size() !=0){
            for (WorkType wt:wts)
            {
                wt.Qualified_Resource_Count__c  =  wt.Qualified_Resource_Count__c -1;
                wt.Qualified_Inactive_Resource_Count__c  =  wt.Qualified_Inactive_Resource_Count__c +1;
                wtUpdate.add(wt);
            }
        }
        
        if(wtUpdate.size() !=0){
            update wtUpdate;
        }
    }
    public static list <WorkType> getWTset(ServiceResource sr) 
    {
        List<Skill> sr_skills = [ 
            SELECT id FROM Skill WHERE id IN ( 
                SELECT SkillId 
                FROM ServiceResourceSkill 
                WHERE ServiceResourceId = :sr.id 
            )
        ];
        List<id> res_ids = new List<id>();
        Map<id,integer> map_sr_wt = new Map<id,integer>(),
            map_wt_sreq = new Map<id,integer>();
        if(sr_skills.size() !=0){
            for( SkillRequirement sreq:[SELECT RelatedRecordId 
                                        FROM SkillRequirement 
                                        WHERE SkillId IN :sr_skills ]) 
            {
                if ( !map_sr_wt.containsKey(sreq.RelatedRecordId) )
                {
                    map_sr_wt.put(sreq.RelatedRecordId,0);
                }
                map_sr_wt.put(sreq.RelatedRecordId,map_sr_wt.get(sreq.RelatedRecordId)+1);    
            } 
        }
        if(map_sr_wt.size() !=0){
            for( SkillRequirement sreq:[SELECT RelatedRecordId 
                                        FROM SkillRequirement 
                                        WHERE RelatedRecordId IN :map_sr_wt.keyset()] ) 
            {
                if ( !map_wt_sreq.containsKey(sreq.RelatedRecordId) )
                { 
                    map_wt_sreq.put(sreq.RelatedRecordId,0);
                }
                map_wt_sreq.put(sreq.RelatedRecordId,map_wt_sreq.get(sreq.RelatedRecordId)+1);   
            } 
        }
        if(map_wt_sreq.size() !=0 ){
            for ( id key : map_wt_sreq.keyset() ) {
                if (map_wt_sreq.get(key) ==  map_sr_wt.get(key) )
                { 
                    res_ids.add(key); 
                }
            } 
        }
        if(res_ids.size() !=0){
            return [SELECT id, name, Qualified_Resource_Count__c, Qualified_Inactive_Resource_Count__c
                    FROM WorkType 
                    WHERE id IN :res_ids ]; 
        }
        return null;
        
    }

}