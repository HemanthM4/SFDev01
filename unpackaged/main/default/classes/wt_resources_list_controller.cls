public class wt_resources_list_controller 
{
    public list <ServiceResource> sr_active_results {get; set;}
    public list <ServiceResource> sr_inactive_results {get; set;}
    public wt_resources_list_controller( ) { 
        List < List<Id> > list_of_sets = new List<List<Id>>();
        for (SkillRequirement sreq:[SELECT SkillId 
                                    FROM SkillRequirement 
                                    WHERE RelatedRecordId = :ApexPages.currentPage().getParameters().get('id') ]) 
        {
            List <Id> tmp = new List<Id>();
            for( ServiceResourceSkill srskill : [SELECT ServiceResourceId 
                                                 FROM ServiceResourceSkill 
                                                 WHERE SkillId = :sreq.SkillId])
            { tmp.add( srskill.ServiceResourceId); }
            list_of_sets.add(tmp);
        }
        if ( list_of_sets.isEmpty() )
        {
            sr_active_results = [ SELECT id, name, IsActive 
            FROM ServiceResource 
            WHERE IsActive = TRUE];
            sr_inactive_results = [SELECT id, name, IsActive 
            FROM ServiceResource 
            WHERE IsActive = FALSE];

        } else {
            Set<id> sr_set = new Set<id> (list_of_sets.get(0)) ;  
            for (List<id>  srs:list_of_sets) 
            { sr_set.retainAll(srs); }
            sr_active_results = [SELECT id, name, IsActive 
                          FROM ServiceResource 
                          WHERE id IN :sr_set
                          AND IsActive = TRUE ];
            sr_inactive_results = [SELECT id, name, IsActive
                          FROM ServiceResource 
                          WHERE id IN :sr_set
                          AND IsActive = FALSE ];
        }
    }
/*
    public integer search(id input_id)
    { 
        List < List<Id> > list_of_sets = new List<List<Id>>();
        for (SkillRequirement sreq:[SELECT SkillId 
                                    FROM SkillRequirement 
                                    WHERE RelatedRecordId = :input_id ]) 
        {
            List <Id> tmp = new List<Id>();
            for( ServiceResourceSkill srskill : [SELECT ServiceResourceId 
                                                 FROM ServiceResourceSkill 
                                                 WHERE SkillId = :sreq.SkillId])
            { tmp.add( srskill.ServiceResourceId); }
            list_of_sets.add(tmp);
        }
        if ( list_of_sets.isEmpty() )
        {
            return 0;
        } else {
            Set<id> sr_set = new Set<id> (list_of_sets.get(0)) ;  
            for (List<id>  srs:list_of_sets) 
            { sr_set.retainAll(srs); }
            return sr_set.size();
        }
    }
    public void updatewt() {
        /*for ( WorkType wt :[SELECT id FROM WorkType ]) {
            wt.Qualified_Resource_Count__c = search(wt.id);
            update wt;
        }

        WorkType wt = [SELECT id 
                       FROM WorkType 
                       WHERE id=:ApexPages.currentPage().getParameters().get('id')];
        wt.Qualified_Resource_Count__c = sr_active_results.size();
        update wt;
    }*/
}