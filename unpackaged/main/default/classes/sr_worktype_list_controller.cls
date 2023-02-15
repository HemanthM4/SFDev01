public class sr_worktype_list_controller 
{
    public list <WorkType> results_nosreq {get; set;}
    public list <WorkType> wt_results {get; set;}
    public list <WorkType> results_not_qual {get; set;}

    public sr_worktype_list_controller( ) 
    {
        List<id> res_ids = new List<id>();
        Map<id,integer> map_sr_wt = new Map<id,integer>(),
            map_wt_sreq = new Map<id,integer>();
        List<Skill> sr_skills = [ SELECT id FROM Skill WHERE id IN ( 
            SELECT SkillId FROM ServiceResourceSkill 
            WHERE ServiceResourceId = :ApexPages.currentPage().getParameters().get('id') )];
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
        wt_results = [
            SELECT id, name, Trade__c, (SELECT skill.description, skill.masterlabel FROM SkillRequirements) 
            FROM WorkType WHERE id IN :res_ids 
            ORDER BY Trade__c ASC
        ];
        results_nosreq = [
            SELECT Id, Name FROM WorkType 
            WHERE Id NOT IN (SELECT RelatedRecordId FROM SkillRequirement)
            ORDER BY Trade__c ASC  
        ];
        results_not_qual = [
            SELECT id, name, Trade__c, (SELECT skill.description, skill.masterlabel FROM SkillRequirements WHERE skill.id NOT IN :sr_skills ) 
            FROM WorkType WHERE (id NOT IN :res_ids) AND (id NOT IN :results_nosreq)
            ORDER BY Trade__c ASC
        ];
    }   
  /*     
    public void tmp_method2() {
        
        for( ServiceResource sr:[SELECT Id FROM ServiceResource 
                                 WHERE Qualifying_WTs_Count__c!=NULL 
                                 AND IsActive=TRUE 
                                  ] ) {
            
                                     
            sr.Qualifying_WTs_Count__c = NULL;
            update sr;
        } 
    }
  
    public void tmp_method() {
        
        for( ServiceResource sr:[SELECT Id FROM ServiceResource 
                                 WHERE Qualifying_WTs_Count__c=NULL 
                                 AND IsActive=TRUE 
                                 LIMIT 20 ] ) {
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
    } */
}