public class sa_mark_with_ResourcePreference {

    /*
    @InvocableMethod
    public static void updateWOSAsLabel2( List <ID> var_wo) {
        if ( ![SELECT id FROM ResourcePreference WHERE RelatedRecordId = :var_wo AND PreferenceType = 'Required'].isEmpty() ) 
             {
                for ( ServiceAppointment sa:[SELECT id FROM ServiceAppointment WHERE ParentRecordId = :var_wo ]) 
                {
                    sa.FSL__GanttIcon__c = 'https://www.aspect.co.uk/email-templates/sf/assets/letter_e.png';
                    update sa;
                }
             } else {
                 for ( ServiceAppointment sa:[SELECT id FROM ServiceAppointment WHERE ParentRecordId = :var_wo ]) 
                {
                    sa.FSL__GanttIcon__c = '';
                    update sa;
                }
             }
        }
    */
    
    public static void updateWOSAsLabel(ID var_wo) {
        if ( ![SELECT id FROM ResourcePreference WHERE RelatedRecordId = :var_wo AND PreferenceType = 'Required'].isEmpty() ) 
             {
                for ( ServiceAppointment sa:[SELECT id FROM ServiceAppointment WHERE ParentRecordId = :var_wo ]) 
                {
                    sa.FSL__GanttIcon__c = 'https://www.aspect.co.uk/email-templates/sf/assets/letter_e.png';
                    update sa;
                }
             } else {
                 for ( ServiceAppointment sa:[SELECT id FROM ServiceAppointment WHERE ParentRecordId = :var_wo ]) 
                {
                    sa.FSL__GanttIcon__c = '';
                    update sa;
                }
             }
        }
    
}