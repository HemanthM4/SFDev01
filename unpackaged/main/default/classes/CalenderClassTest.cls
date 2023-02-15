@isTest
public class CalenderClassTest {
    static testMethod void calendarMethod(){
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u){
            String RecordTypeIdContact = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            ServiceResource SR = new ServiceResource();
            SR.Email__c = ' Test@gmail.com';
            SR.Engineer_Role__c ='Service_Resource';
            SR.ResourceType = 'T';
            SR.Rate_of_Pay_Tier__c = 'Tier 2';
            SR.RelatedRecordId =u.id;
            SR.Estimate_Limit__c =100;
            SR.Name ='Test';
            insert SR;
            SR.IsActive = true;
            Update SR;
            OperatingHours oh = new OperatingHours();
            oh.Name = 'Day';
            insert oh;
            
            OperatingHours oh1 = new OperatingHours();
            oh1.Name = 'Aspect Operating Hours (24/7/365)';
            insert oh1;
            
            ResourceAbsence ra = new ResourceAbsence();
            ra.Type ='Meeting';
           
            ra.Start = SYstem.today();
            ra.End = System.today()+1;
            ra.ResourceId =SR.id;
            ra.Status__c ='Approved';
            insert ra;
            
             ResourceAbsence ra1 = new ResourceAbsence();
            ra1.Type ='Meeting';
           
            ra1.Start = SYstem.today();
            ra1.End = System.today()+1;
            ra1.ResourceId =SR.id;
            ra1.Status__c ='Not yet Approved';
            insert ra1;
            
            
             ResourceAbsence ra2 = new ResourceAbsence();
            ra2.Type ='Meeting';
           
            ra2.Start = SYstem.today();
            ra2.End = System.today()+4;
            ra2.ResourceId =SR.id;
            ra2.Status__c ='Rejected';
            insert ra2;
            
            ServiceTerritory objST = new ServiceTerritory();
            objST.Name = 'Test Territory';
            objST.OperatingHoursId = oh1.Id;
            objST.IsActive = TRUE;
            insert objST;
            
            
            ServiceTerritoryMember objSTM = new ServiceTerritoryMember();
            objSTM.TerritoryType = 'P';
            objSTM.ServiceTerritoryId = objST.Id;
            objSTM.ServiceResourceId = SR.Id;
            objSTM.EffectiveStartDate = Date.today().addDays(10);
            objSTM.EffectiveEndDate = Date.today().addDays(12);
         objSTM.OperatingHoursId = oh1.id;
            insert objSTM;
            
            Shift sh = new Shift();
            sh.Status ='Tentative';
            sh.EndTime = System.today()+7;
            sh.StartTime = System.today();
            sh.TimeSlotType ='Normal';
            sh.ServiceResourceId = SR.id;
            insert sh;
            
            test.StartTest();
            List<String> s =  CalenderClass.getPickListValuesIntoList();
            String s1 =   CalenderClass.getServiceResourceId();
            String s3 = CalenderClass.createPermissionorabsence(System.today(),System.today()+1,SR.id,RecordTypeIdContact,'','','','');
            String s4 = CalenderClass.createPermissionorabsence(System.today(),System.today()+1,SR.id,RecordTypeIdContact,'Absence','','','');
            String s5 = CalenderClass.createPermissionorabsence(System.today(),System.today()+1,SR.id,RecordTypeIdContact,'Permission','','','');
            String s6 = CalenderClass.getrecordTYpe();
            Map<Date,String> s7=  CalenderClass.getWeeksDay(System.today(),System.today()+7);
            list<CalenderClass.wrapTimeSlot> s8= CalenderClass.getAllEvents();
              List<OperatingHours> sq1 =CalenderClass.getAllOperationHour();
          Datetime dq1=  CalenderClass.getdateMinus(System.today());
            test.stopTest();
        }
    }
    
}