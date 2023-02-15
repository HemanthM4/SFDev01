public class ServiceTerrMemTriggerHandler {    
    public static void beforeInsert(List<ServiceTerritoryMember>servs,set<id> setSResource){
        for(ServiceTerritoryMember ser : servs)
        {
            System.debug(ser.ServiceResource.name);
            if(ser.EffectiveStartDate!=null && ser.EffectiveEndDate!=null && !setSResource.Contains(ser.ServiceResourceId) && ser.Exclude_from_Community_vadlidation__c	 == false){
                Date strt = date.newinstance(ser.EffectiveStartDate.year(), ser.EffectiveStartDate.month(), ser.EffectiveStartDate.day());
                Date EndDat = date.newinstance(ser.EffectiveEndDate.year(), ser.EffectiveEndDate.month(), ser.EffectiveEndDate.day());
                Integer numberDaysDue = strt.daysBetween(EndDat); 
                if(numberDaysDue>90){
                    ser.addError('Start Date and End Date Should not exceed 90 days.'); 
                }
            }
        }
    }
    public static void beforeUpdate(List<ServiceTerritoryMember>servs,Map<Id,ServiceTerritoryMember>servOld,set<id> setSResource){
        for(ServiceTerritoryMember ser : servs)
        {
            System.debug(ser.ServiceResourceId);
            if(!setSResource.Contains(ser.ServiceResourceId) && ser.EffectiveStartDate!=null && ser.EffectiveEndDate!=null
               && 
               (ser.EffectiveStartDate !=servOld.get(ser.id).EffectiveStartDate ||
                ser.EffectiveEndDate != servOld.get(ser.id).EffectiveEndDate )  && ser.Exclude_from_Community_vadlidation__c == false){
                    System.debug('ser'+ser);
                    Date strt = date.newinstance(ser.EffectiveStartDate.year(), ser.EffectiveStartDate.month(), ser.EffectiveStartDate.day());
                    Date EndDat = date.newinstance(ser.EffectiveEndDate.year(), ser.EffectiveEndDate.month(), ser.EffectiveEndDate.day());
                    Integer numberDaysDue = strt.daysBetween(EndDat);
                      System.debug('numberDaysDue'+numberDaysDue);
                    if(numberDaysDue>90){
                         System.debug('numberDaysDue'+numberDaysDue);
                        ser.addError('Start Date and End Date Should not excced 90 days'); 
                    }
                }
        }
    }
    
}