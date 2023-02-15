public class ResourceAbsenceTriggerHandler {
    public static void beforeInsert(List<ResourceAbsence > resc){
        for(ResourceAbsence res :resc){
            if( res.FSL__Approved__c ==true ){
                res.Status__c= 'Approved';
            }
        }
    }
    public static void beforeupdate(List<ResourceAbsence > resc,Map<id,ResourceAbsence>mapold){
        for(ResourceAbsence res :resc){
            if(res.FSL__Approved__c != mapold.get(res.id).FSL__Approved__c && res.FSL__Approved__c==true  )
            {
                res.Status__c= 'Approved';
            }else  if(res.FSL__Approved__c != mapold.get(res.id).FSL__Approved__c && res.FSL__Approved__c==false  )
            {
                res.Status__c= 'Not yet Approved';
            }
        }
        
    }
    
}