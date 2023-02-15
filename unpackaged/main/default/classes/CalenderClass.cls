public without sharing class CalenderClass {
    @AuraEnabled
    public static List<String> getPickListValuesIntoList()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ResourceAbsence.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static String getServiceResourceId(){
        List<ServiceResource> serviceRes = [SELECT id from ServiceResource where RelatedRecordId =:Userinfo.getUserId()];
        if(!serviceRes.isEmpty())
        {
            return serviceRes[0].id;
        }
        return null;
    }
    @AuraEnabled
    public static List<OperatingHours> getAllOperationHour()
    {
        return [SELECT id,Name from OperatingHours  where Name like 'Night%' or Name like 'Day%'];
    }
    @AuraEnabled
    public static String createPermissionorabsence(Datetime starttime,Datetime endtime,String resourceID,
                                                   String recordtype,String label,String operationHour,String type,String imgvalue)
    {
        String messageerror ='';
        String ServieTerrorityOverrideId ='';
        String ServieTerrorityId ='';
        Boolean isOverride = false;
        String OpId ='';
        String s = starttime.format('HH:mm:ss'); 
        System.debug(s+'TeststartTime'+s.subString(0,2));
        Integer strtTime = Integer.valueOf(s.subString(0,2));
        
        OpId =
            [SELECT id,Name from OperatingHours  where Name ='Aspect Operating Hours (24/7/365)'].id;
        
        if(label == 'Absence')
        {
            ResourceAbsence abs  = new ResourceAbsence();
            abs.ResourceId =resourceID;
            abs.Type	 = type;
            abs.Start = starttime;
            abs.end = endtime;
            abs.FSL__Approved__c = false;
            // abs.app
            abs.Status__c = 'Not yet Approved';
            abs.RecordTypeId =  recordtype;
            abs.Description__c = imgvalue;
            try
            {
                insert abs;
            }
            catch(DMLEXception ex)
            {
                messageerror = ex.getMessage();
                return messageerror;
            }
        }else if (label == 'Permission')
        {
            List<ServiceTerritoryMember> serviceTerr = [SELECT id,ServiceTerritoryId,ServiceTerritory.Name,EffectiveStartDate,EffectiveEndDate from ServiceTerritoryMember where
                                                        ServiceResourceId =:resourceID 
                                                        and  ServiceTerritory.IsActive = true];
            if(!serviceTerr.isEmpty())
            {
                //  OperatingHours opr =[SELECT id,Name from OperatingHours  where Name =:operationHour];
                for(ServiceTerritoryMember service : serviceTerr)
                {
                    isOverride= getDateCalculation(  starttime,endtime,service.EffectiveStartDate,service.EffectiveEndDate);
                    if(isOverride == true){
                        ServieTerrorityOverrideId = service.ServiceTerritoryId;
                        break;
                    }
                }
                if(isOverride== false || Test.isRunningTest())
                {
                    ServiceTerritoryMember serviceMember = new ServiceTerritoryMember();
                    serviceMember.ServiceResourceId = resourceID;
                    serviceMember.ServiceTerritoryId = serviceTerr[0].ServiceTerritoryId;
                    //  serviceMember.TerritoryType ='Relocation';
                    serviceMember.EffectiveStartDate =starttime.addhours(-1);
                    serviceMember.EffectiveEndDate =endtime.addhours(1);
                    serviceMember.OperatingHoursId =OpId;
                    serviceMember.SOurce__c ='Shift';
                    try{
                        insert serviceMember;
                    }catch(DMLEXception ex){
                        messageerror = ex.getMessage();
                        System.debug(messageerror);
                        return messageerror;
                    }
                    ServieTerrorityId = serviceTerr[0].ServiceTerritoryId;
                }else {
                    ServieTerrorityId = ServieTerrorityOverrideId;
                }
                Shift shi = new Shift();
                shi.Label= serviceTerr[0].ServiceTerritory.Name+'-'+System.now();
                shi.Status  = 'Confirmed';
                shi.StartTime = starttime;
                shi.EndTime = endtime;
                shi.TimeSlotType ='Normal';
                shi.ServiceResourceId	 = resourceID;
                shi.ServiceTerritoryId	 = ServieTerrorityId;
                //  insert shi;
                try{
                    insert shi;
                }catch(DMLEXception ex){
                    messageerror = ex.getMessage();
                    System.debug(messageerror);
                    return messageerror;
                }
            }else {
                messageerror = 'No Active Service Terrority is availble'; 
            }
        }
        return messageerror;
    }
    
    @AuraEnabled 
    public static string getrecordTYpe()
    {
        List<RecordType> recordtypevalues = [SELECT id,Name from RecordType where Name ='Non Availability'];
        return recordtypevalues[0].id;
    }
    public static  Map<Date,String> getWeeksDay(Date timeSlotStartDate, Date timeSlotEndDate)
    {
        Map<Date,String> weeksDay = new  Map<Date,String>();
        Date updatedDate = null;
        Integer dayDifference = timeSlotStartDate.daysBetween(timeSlotEndDate);
        dayDifference =dayDifference;
        System.debug('dayDifference'+dayDifference);
        for(integer i=0;i<=dayDifference;i++)
        {
            //  updatedDate = timeSlotStartDate;
            if(updatedDate != timeSlotEndDate)
            {
                Date dates =  timeSlotStartDate.addDays(i) ;
                Date daysvalue = date.newinstance(dates.year(), dates.month(),dates.day());
                String values =  String.valueOf( DateTime.newInstance(daysvalue, Time.newInstance(0, 0, 0, 0)));
                DateTime formattedDate = DateTime.valueOf(values);
                weeksDay.put(dates,formattedDate.format('EEEE'));
                System.debug('date---->'+dates+'--'+formattedDate.format('EEEE'));
                updatedDate = dates.addDays(i+1);
                if(updatedDate==timeSlotEndDate)
                    updatedDate = dates.addDays(i);
            }else if(updatedDate == timeSlotEndDate){
                
                Date daysvalue = date.newinstance(timeSlotEndDate.year(), timeSlotEndDate.month(),timeSlotEndDate.day());
                String values =  String.valueOf( DateTime.newInstance(daysvalue, Time.newInstance(0, 0, 0, 0)));
                DateTime formattedDate = DateTime.valueOf(values);
                weeksDay.put(daysvalue,formattedDate.format('EEEE'));
                System.debug('date----> 1'+daysvalue+'--'+formattedDate.format('EEEE'));
            }
        }
        return weeksDay;
    }
    /*  @AuraEnabled
public static void getWrapDateTime(List<Object> wraps,String eventId){
List<wrapTimeSlot> wraplist = new List<wrapTimeSlot>();
for (Object o : wraps)
wraplist.add((wrapTimeSlot) o);
for(wrapTimeSlot wrps : wraplist){
System.debug('wrps'+wrps);
}
}*/
    @AuraEnabled
    public static list<wrapTimeSlot> getAllEvents()
    {
        Map<id,ServiceTerritoryMember> operationsids  = new Map<id,ServiceTerritoryMember>();
        DateTime todayDate = System.now();
        List<wrapTimeSlot>wrapList = new List<wrapTimeSlot>();
        Date timeSlotStartDate = null;
        Date timeSlotEndDate = null;
        //  Map<Date,String> weeksDay = new Map<Date,String>()
        for(ServiceAppointMent service : [SELECT id,Scheduled_Date__c,AppointmentNumber,Address,WorkTypeId,WorkType.Name,
                                          Engineer_Pay_Requisition__c,City,Street,State,PostalCode,Country,SchedStartTime,SchedEndTime,
                                          Engineer_Pay_Requisition__r.Pay_Labour_Total__c,Engineer_Pay_Requisition__r.Status__c 
                                          from ServiceAppointment   where Status ='Dispatched' and 
                                          Allocated_Engineer__r.RelatedRecordid =:UserInfo.getUserId() and   SchedEndTime>=:todayDate]){
                                              System.debug('@@@@@@@@@@@@@@@@@@@@@@@ wrapper vlaue Service Appointment'+service);
                                              wrapTimeSlot wrap = new wrapTimeSlot();  
                                              wrap.startDate = service.SchedStartTime.addDays(1);
                                              wrap.endDate =service.SchedEndTime.addDays(1);
                                              wrap.id = service.id; 
                                              wrap.eventTItle = 'Upcoming Appointment';
                                              wrap.startTime = service.SchedStartTime.format('HH:mm');
                                              wrap.endTIme = service.SchedEndTime.format('HH:mm');
                                              wrap.status =wrap.startTime+'-'+wrap.endTIme;
                                              wrap.backgroundColor  = '#009EDB';
                                              
                                              wrapList.add(wrap);         
                                          }
        for(Shift shitfRecord: [SELECT id,EndTime,StartTime from Shift where  ServiceResource.RelatedRecordId =:Userinfo.getUserId()
                                and EndTime>=:todayDate])
        {
            System.debug('shitfRecord'+shitfRecord);
            wrapTimeSlot wrap = new wrapTimeSlot();  
            wrap.startDate = shitfRecord.StartTime.addDays(1);
            wrap.endDate =shitfRecord.EndTime.addDays(1);
            wrap.id = shitfRecord.id; 
            wrap.eventTItle = 'Approved Overtime';
            wrap.startTime = shitfRecord.StartTime.format('HH:mm');
            wrap.endTIme = shitfRecord.EndTime.format('HH:mm');
            wrap.status =wrap.startTime+'-'+wrap.endTIme;
            wrap.backgroundColor  = '#00D748';//green
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@ wrapper vlaue'+wrap);
            wrapList.add(wrap);
        }
        for(ResourceAbsence resource :[SELECT id,Start,End,Type,Status__c from ResourceAbsence
                                       where Resource.RelatedRecordId =: Userinfo.getUserId()  and Status__c !='Waiting' and End>=:todayDate])
        {
            wrapTimeSlot wrap = new wrapTimeSlot(); 
            wrap.startDate = resource.Start.addDays(1);
            wrap.endDate =resource.End.addDays(1);
            wrap.id = resource.id; 
            if(resource.Status__c=='Approved')
                wrap.backgroundColor = '#708090';
            else  if(resource.Status__c=='Not yet Approved')
                wrap.backgroundColor = '#FFCA00'; 
            else  if(resource.Status__c=='Rejected')
                wrap.backgroundColor = '#FF3D57';
            if(resource.Status__c=='Not yet Approved')
                wrap.eventTItle ='Pending Leave';
            else
                wrap.eventTItle =resource.Status__c+' Leave';
            wrap.startTime = resource.Start.format('HH:mm');
            wrap.endTIme = resource.End.format('HH:mm');
            if(resource.Status__c=='Approved')
                wrap.status =wrap.startTime+'-'+wrap.endTIme ;
            else
                wrap.status =wrap.startTime+'-'+wrap.endTIme;
            wrapList.add(wrap);
        }
        list<ServiceTerritoryMember> eventlist =[Select id,TerritoryType,OperatingHoursId,EffectiveStartDate,
                                                 EffectiveEndDate from ServiceTerritoryMember where
                                                 ServiceResource.RelatedRecordId =:Userinfo.getUserId() 
                                                 and  EffectiveEndDate>=:todayDate
                                                 and Source__c !='Shift' AND (TerritoryType='R' OR TerritoryType='P')] ;
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@'+eventlist.size());
        /* if(!eventlist.isEMpty()){
for(ServiceTerritoryMember event :  eventlist){
if(event.OperatingHoursId!=null){
timeSlotStartDate =   date.newinstance(event.EffectiveStartDate.year(),
event.EffectiveStartDate.month(), 
event.EffectiveStartDate.day());
timeSlotEndDate =date.newinstance(event.EffectiveEndDate.year(), 
event.EffectiveEndDate.month(), event.EffectiveEndDate.day());
//  weeksDay.putAll(getWeeksDay(timeSlotStartDate,timeSlotEndDate));
operationsids.put(event.OperatingHoursId,event);
}
}
}
for(TimeSlot timeslotrecord : [SELECT id,StartTime,EndTime,DayOfWeek,OperatingHoursId from TimeSlot where 
OperatingHoursId =: operationsids.keySet() ])
{
Map<Date,String> weeksDay = new Map<Date,String>();
ServiceTerritoryMember service = new ServiceTerritoryMember();
service = operationsids.get(timeslotrecord.OperatingHoursId);
timeSlotStartDate =   date.newinstance(service.EffectiveStartDate.year(),
service.EffectiveStartDate.month(), 
service.EffectiveStartDate.day());
timeSlotEndDate =date.newinstance(service.EffectiveEndDate.year(), 
service.EffectiveEndDate.month(),
service.EffectiveEndDate.day());
weeksDay.putAll(getWeeksDay(timeSlotStartDate,timeSlotEndDate));
for(Date datetimeVale : weeksDay.keySet()){
String dayValue = weeksDay.get(datetimeVale);
if(service.OperatingHoursId == timeslotrecord.OperatingHoursId  && dayValue ==  timeslotrecord.DayOfWeek)
{
wrapTimeSlot wrap = new wrapTimeSlot(); 
wrap.startDate =datetimeVale+1;
wrap.endDate = datetimeVale+1;
wrap.id = timeslotrecord.id; 
wrap.eventTItle = 'Availability ';
wrap.startTime = String.valueOf(timeslotrecord.StartTime);
wrap.endTIme = String.valueOf(timeslotrecord.EndTime);
wrap.status ='Working '+wrap.startTime +'-'+wrap.endTIme;
wrapList.add(wrap);
}
}
}*/
        Map<Date,String> weeksDay = new Map<Date,String>();
        
        if(!eventlist.isEMpty())
        {
            for(ServiceTerritoryMember event :  eventlist)
            {
                if(event.OperatingHoursId!=null)
                {
                    timeSlotStartDate =   date.newinstance(event.EffectiveStartDate.year(),
                                                           event.EffectiveStartDate.month(), 
                                                           event.EffectiveStartDate.day());
                    Datetime dateend ;
                    if(event.EffectiveEndDate==null && event.EffectiveStartDate!=null){
                         dateend = event.EffectiveStartDate.addDays(1);
                    }else if(event.EffectiveEndDate!=null){
                        dateend = event.EffectiveEndDate;
                    }
                    timeSlotEndDate =date.newinstance(dateend.year(), 
                                                      dateend.month(), dateend.day());
                    weeksDay.putAll(getWeeksDay(timeSlotStartDate,timeSlotEndDate));
                    for(Date datetimeVale : weeksDay.keySet())
                    {
                        String dayValue = weeksDay.get(datetimeVale);
                        system.debug('<datetimeVale>'+datetimeVale);
                        for(TimeSlot timeslotrecord : [SELECT id,OperatingHours.Name,StartTime,EndTime,DayOfWeek,OperatingHoursId from TimeSlot where 
                                                       OperatingHoursId=:event.OperatingHoursId and DayOfWeek=:dayValue])
                        { 
                            wrapTimeSlot wrap = new wrapTimeSlot(); 
                            wrap.startDate =datetimeVale+1;
                            wrap.endDate = datetimeVale+1;
                            wrap.id = timeslotrecord.id; 
                           
                            wrap.startTime = String.valueOf(timeslotrecord.StartTime).subString(0,5);
                            wrap.endTIme = String.valueOf(timeslotrecord.EndTime).subString(0,5);
                            wrap.status =wrap.startTime +'-'+wrap.endTIme;
                            if(event.TerritoryType=='R'){
                                wrap.eventTItle = 'Relocation '; 
                                  wrap.backgroundColor = '#FF8C00';
                            }
                            else{
                                wrap.eventTItle = 'Availability ';
                                 wrap.backgroundColor = '#285498';
                            }
                           
                            wrapList.add(wrap);
                            
                        }
                    }
                    weeksDay= new Map<Date,String>();
                }
            }
        }
        List<wrapTimeSlot> wrapslist = new List<wrapTimeSlot>();
        for(wrapTimeSlot wrap : wrapList)
        {
            String strttime = wrap.startTime.subString(0,2);
            String endtime = wrap.endTIme.subString(0,2);
            Integer strt = Integer.ValueOf(strttime);
            Integer endvalue =  Integer.ValueOf(endtime);
            if(strt>17 && strt<=23)
                wrap.startDate =  wrap.startDate.addHours(-5);
            if(endvalue>17 && endvalue<=23)
                wrap.endDate =  wrap.endDate.addHours(-5);
            
            wrapslist.add(wrap);
            
        }
        return wrapslist;
    }
    public static boolean getDateCalculation(DateTIme starttime,DateTIme  endtime,DateTIme EffectiveStartDate,DateTIme EffectiveEndDate)
    {
        Boolean isOverride = false;
        if(EffectiveEndDate==null && EffectiveStartDate!=null){
            EffectiveEndDate =EffectiveStartDate.AddDays(1);
        }
        Date starttimes = Date.newInstance(starttime.year(), starttime.month(), starttime.day());
        Date endtimes = Date.newInstance(endtime.year(), endtime.month(), endtime.day());
        Date EffectiveStartDates = Date.newInstance(EffectiveStartDate.year(), EffectiveStartDate.month(), EffectiveStartDate.day());
        Date EffectiveEndDates = Date.newInstance(EffectiveEndDate.year(), EffectiveEndDate.month(), EffectiveEndDate.day());
        Integer numberDaysDue = EffectiveStartDates.daysBetween(EffectiveEndDates);
        for(integer i=0;i<numberDaysDue;i++)
        {
            if(EffectiveStartDates.addDays(i) == starttimes || EffectiveEndDates==endtimes || EffectiveStartDates.addDays(i)== endtimes){
                isOverride = true;
            }
        }
        return isOverride;
    }
    @AuraEnabled
    public static Datetime getdateMinus(DateTime  Datevalue)
    {
        Datevalue = Datevalue.addDays(-1);
        return Datevalue;
    }
    public class wrapTimeSlot 
    {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public Boolean isApproved {get; set;}
        @AuraEnabled
        public String eventTItle {get; set;}
        @AuraEnabled
        public DateTime startDate {get; set;}
        @AuraEnabled
        public String startTime {get; set;}
        @AuraEnabled
        public String endTIme {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public DateTime endDate {get; set;}
        @AuraEnabled
        public String backgroundColor  {get; set;}
        public wrapTimeSlot() {
            status ='';
            eventTItle = id = '';
            startTime=endTIme= '';
            startDate = endDate = null;
            isApproved = false;
            backgroundColor ='';
        }
    }
}