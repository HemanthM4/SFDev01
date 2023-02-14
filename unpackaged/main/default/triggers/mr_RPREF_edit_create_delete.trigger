trigger mr_RPREF_edit_create_delete on ResourcePreference (after insert, after update, after delete ) {
    if (Trigger.isDelete) {
        for (ResourcePreference rpref : Trigger.old ) {
            if (Trigger.OldMap.get(rpref.ID).RelatedRecordId.getSObjectType().getDescribe().getName() == 'WorkOrder') {
                sa_mark_with_ResourcePreference.updateWOSAsLabel( Trigger.OldMap.get(rpref.ID).RelatedRecordId );
            }
        }
    } else {
        for (ResourcePreference rpref : Trigger.new ) {
            if (rpref.RelatedRecordId.getSObjectType().getDescribe().getName() == 'WorkOrder'){
                sa_mark_with_ResourcePreference.updateWOSAsLabel(rpref.RelatedRecordId);
            }
        }
    }
}