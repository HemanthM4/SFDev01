public class wt_sreq_change_controller {

    public wt_sreq_change_controller() { }
    
    public void after_insert(SkillRequirement new_sreq)
    {
        //get wt
        WorkType wt = [Select id from WorkType Where id = :new_sreq.RelatedRecordId];
        // get old set of engineers
        list <ServiceResource> old_list = getSRset(new_sreq.RelatedRecordId, new_sreq);
        list <ServiceResource> new_list = getSRset(new_sreq.RelatedRecordId);
        // get new set of engineers
        //  new count - > wt.q

        wt.Qualified_Resource_Count__c = new_list.size();
        update wt;
        
        if(old_list!=NULL) {
            //   get each sr /in OLD but not in NEW
            for (ServiceResource sr:old_list) {
                if (!new_list.contains(sr) ) {                    
                    sr.Qualifying_WTs_Count__c -=1;
                    update sr; 
                }
            }
        } 
        else {
            for (ServiceResource sr:new_list) 
            {
                if(sr.Qualifying_WTs_Count__c == NULL)
                {
                    sr.Qualifying_WTs_Count__c = 0;
                }
                sr.Qualifying_WTs_Count__c += 1;
                update sr;
            }
        }
    }
    
    public void before_delete(SkillRequirement new_sreq)
    {
        WorkType wt = [Select id from WorkType Where id = :new_sreq.RelatedRecordId];
        list <ServiceResource> new_list = getSRset(new_sreq.RelatedRecordId, new_sreq);
        list <ServiceResource> old_list = getSRset(new_sreq.RelatedRecordId);
        
        if(new_list!=NULL)
        {
           //   get each sr /in OLD but not in NEW
            for (ServiceResource sr:new_list) {
                if (!old_list.contains(sr)) {
                    if(sr.Qualifying_WTs_Count__c == NULL)
                    {
                        sr.Qualifying_WTs_Count__c = 0;
                    }
                	sr.Qualifying_WTs_Count__c +=1;
                	update sr; 
                }
            }
            wt.Qualified_Resource_Count__c = new_list.size();
            update wt;
        }
        else 
        {
            for (ServiceResource sr:old_list) {
                sr.Qualifying_WTs_Count__c -=1;
                update sr;
            }
            wt.Qualified_Resource_Count__c = 0;
            update wt;
        }
		
    }
    
    public static list <ServiceResource> getSRset(id wt) {
        return helper([SELECT SkillId 
                       FROM SkillRequirement 
                       WHERE RelatedRecordId = :wt ]);
    }
    
    public static list <ServiceResource> getSRset(id wt, SkillRequirement exclude_sreq) {
        return helper([SELECT SkillId 
                       FROM SkillRequirement 
                       WHERE RelatedRecordId = :wt 
                       AND id != :exclude_sreq.id ]);
    }

    public static list <ServiceResource> helper(List <SkillRequirement> sreqs) {   
        List < List<Id> > list_of_sets = new List<List<Id>>();
        for (SkillRequirement sreq:sreqs) 
        {
            List <Id> tmp = new List<Id>();
            for( ServiceResourceSkill srskill : 
                [SELECT ServiceResourceId 
                 FROM ServiceResourceSkill 
                 WHERE SkillId = :sreq.SkillId])
            { tmp.add( srskill.ServiceResourceId); }
            list_of_sets.add(tmp);
        }
        if ( list_of_sets.isEmpty() ) { return NULL; }
        else 
        {
            Set<id> sr_set = new Set<id> (list_of_sets.get(0)) ;  
            for (List<id>  srs:list_of_sets) 
            { sr_set.retainAll(srs); }
            return [SELECT id, name, IsActive, Qualifying_WTs_Count__c 
                    FROM ServiceResource 
                    WHERE id IN :sr_set AND IsActive = TRUE];
        }
        
    }
}