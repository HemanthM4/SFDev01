public class init_skills_count {

    
    public static void reset_wts(){
        for ( WorkType wt :[SELECT id FROM WorkType WHERE Qualified_Resource_Count__c != NULL LIMIT 150]) {
            wt.Qualified_Resource_Count__c = NULL;
            wt.Qualified_Inactive_Resource_Count__c = NULL;
            update wt;
        }
    }

    public static void init_wts(Integer x){
        for ( WorkType wt :[SELECT id FROM WorkType WHERE Qualified_Resource_Count__c = NULL LIMIT :x ]) {
            wt.Qualified_Resource_Count__c = 0;
            wt.Qualified_Inactive_Resource_Count__c = 0;        
            List < List<Id> > list_of_sets = new List<List<Id>>();
            for (SkillRequirement sreq:[SELECT SkillId 
                                        FROM SkillRequirement 
                                        WHERE RelatedRecordId = :wt.id ]) 
            {
                List <Id> tmp = new List<Id>();
                for( ServiceResourceSkill srskill : [SELECT ServiceResourceId 
                                                     FROM ServiceResourceSkill 
                                                     WHERE SkillId = :sreq.SkillId])
                { tmp.add( srskill.ServiceResourceId); }
                list_of_sets.add(tmp);
            }
            if ( !list_of_sets.isEmpty() )
            {
                Set<id> sr_set = new Set<id> (list_of_sets.get(0)) ;  
                for (List<id> srs:list_of_sets) { sr_set.retainAll(srs); }
                for(ServiceResource sr:[
                    SELECT id, name, IsActive FROM ServiceResource WHERE id IN :sr_set])
                {
                    if(sr.IsActive) { wt.Qualified_Resource_Count__c++; } 
                    else { wt.Qualified_Inactive_Resource_Count__c++; }
                }
            }
            update wt;
        }
    }


    public static void reset_srs(){
        for( ServiceResource sr:[
            SELECT Id FROM ServiceResource 
            WHERE Qualifying_WTs_Count__c!=NULL AND IsActive=TRUE 
        ]){                                    
            sr.Qualifying_WTs_Count__c = NULL;
            update sr;
        } 
    }
    
    public static void init_srs(){        
        for( ServiceResource sr:[
            SELECT Id FROM ServiceResource 
            WHERE Qualifying_WTs_Count__c=NULL 
            AND IsActive=TRUE 
            LIMIT 22 
        ] ) {
            integer result = 0;
            List<id> res_ids = new List<id>();
            Map<id,integer> map_sr_wt = new Map<id,integer>(),
                map_wt_sreq = new Map<id,integer>();
            List<Skill> sr_skills = [ SELECT id FROM Skill WHERE id IN ( 
                SELECT SkillId FROM ServiceResourceSkill 
                WHERE ServiceResourceId = :sr.id )];
            for( SkillRequirement sreq:[SELECT RelatedRecordId FROM SkillRequirement 
                                        WHERE SkillId IN :sr_skills ]) 
            {
                if ( !map_sr_wt.containsKey(sreq.RelatedRecordId) )
                { map_sr_wt.put(sreq.RelatedRecordId,0); }
                map_sr_wt.put(sreq.RelatedRecordId,map_sr_wt.get(sreq.RelatedRecordId)+1);    
            }
            for( SkillRequirement sreq:[SELECT RelatedRecordId FROM SkillRequirement 
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
                                     
            sr.Qualifying_WTs_Count__c = [SELECT id, name FROM WorkType WHERE id IN :res_ids ].size();
            update sr;
        }
    }
    
}