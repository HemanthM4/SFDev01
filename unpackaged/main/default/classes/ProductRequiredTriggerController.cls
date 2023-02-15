public class ProductRequiredTriggerController {
    public static void beforeInsert(list<ProductRequired> prodsNew){
        Set<id> WOid = new Set<id>();
        Map<String,ProductRequired>prdsMap = new  Map<String,ProductRequired>();
        for(ProductRequired prd :prodsNew){
            if(prd.ParentRecordId!=null && String.valueOf(prd.ParentRecordId).subString(0,3) =='0WO'){
                WOid.add(prd.ParentRecordId);
            }
        }
        if(!WOid.isEMpty()){
            for(ProductRequired prd :[SELECT id,Product2Id,Product2.Name from ProductRequired where ParentRecordId=:WOid]){
                prdsMap.put(prd.Product2.Name,prd);
            }
        }
       
        for(ProductRequired prd :prodsNew){
             System.debug(' prd.Product2Id beforwe'+ prd.Product2Id);
            if(prdsMap==null && prdsMap.containsKey(prd.Product_Category__c)){ 
                prd.Product2Id =  Aspect_JobDataHandler.createupdateprod(prd.Product_Category__c);
            }
             System.debug(' prd.Product2Id after'+ prd.Product2Id);
        }
        
    }
    public static void beforeupdate(list<ProductRequired> prodsNew,Map<id,ProductRequired> prodsOld){
        Set<id> WOid = new Set<id>();
        Map<String,ProductRequired>prdsMap = new  Map<String,ProductRequired>();
        for(ProductRequired prd :prodsNew){
            if(prd.ParentRecordId!=null && prodsOld.containsKey(prd.id) && prodsOld.get(prd.id).ParentRecordId!=prd.ParentRecordId &&
               String.valueOf(prd.ParentRecordId).subString(0,3) =='0WO'){
                   WOid.add(prd.ParentRecordId);
               }
        }
        if(!WOid.isEMpty()){
            for(ProductRequired prd :[SELECT id,Product2Id,Product2.Name from ProductRequired where ParentRecordId=:WOid]){
                prdsMap.put(prd.Product2.Name,prd);
            }
        }
        for(ProductRequired prd :prodsNew){
            if(prdsMap.containsKey(prd.Product_Category__c)){
                prd.Product2Id =  Aspect_JobDataHandler.createupdateprod(prd.Product_Category__c);
            }
        }
    }
}