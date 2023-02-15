@isTest
public class CaseListControllerTest {
    static testMethod void CaseListMethod() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduse21344555r@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standfefdsfdarduser@testorg.com');
        insert u;
        System.runAs(u) {
            
            Account acc = new Account();
            acc.name =' test';
            acc.BillingStreet = 'First street'; 
            insert acc;
            
            Contact con = new Contact();
            con.LastName = 'One';
            insert con;
            
            String RecordTypeIdContact = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            ServiceResource SR = new ServiceResource();
            SR.Email__c = ' Test@gmail.com';
            SR.Engineer_Role__c ='Service_Resource';
            SR.ResourceType = 'T';
            SR.Rate_of_Pay_Tier__c = 'Tier 2';
            SR.RelatedRecordId =u.id;
            SR.Name ='Test';
            insert SR;
            
            String RecordTypeIdWorkOrder = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Reactive').getRecordTypeId();
            WorkOrder WO = new WorkOrder();
            WO.Subject = 'Testing';
            WO.Status = 'Pending';
            WO.AccountId = acc.id;
            WO.Priority = 'Low';
            WO.Service_Appointment_Status__c = 'Dispatched';
            WO.ContactId = con.id;
            WO.Service_Resource__c = SR.id;
            WO.Duration = 2.00;
            WO.Description = 'Test'; 
            WO.Access_Details__c = 'code 1245';
            WO.RecordTypeId =RecordTypeIdWorkOrder;
            insert WO;
            
            ServiceAppointment SA = new ServiceAppointment();
            SA.Status	 ='Visit Complete';
            SA.ParentRecordId = WO.id;
            SA.SchedStartTime = System.today();
            SA.SchedEndTime = System.today()+1;
            SA.Allocated_Engineer__c =SR.id;
            insert SA;
            
            Case cs = new Case();
            cs.Status = 'Complaint';
            cs.Description = 'anything';
            cs.ContactId = con.Id;
            cs.Origin = 'Community';
            insert cs;
            cs.Status = 'Closed';
            update cs;
            
            Case cs1 = new case();
            cs1.Priority = 'Low';
            cs1.Status = 'Review';
            cs1.Subject = 'Anything';
            cs1.Description = 'Nothing';
            cs1.ParentId = cs.Id;
            cs1.SuppliedEmail = u.Email;
            cs1.Service_Appointment__c = SA.Id;
            cs1.Origin = 'Office';
            insert cs1;
            
            test.StartTest();
            List<CaseListController.CaseWrapper> s = CaseListController.getCaseList('All',cs.Id);
             List<CaseListController.CaseWrapper> s12 = CaseListController.getCaseList('Service Appointment',cs.Id);
             List<CaseListController.CaseWrapper> s13 = CaseListController.getCaseList('requisition',cs.Id);
             List<CaseListController.CaseWrapper> s14 = CaseListController.getCaseList('deduc',cs.Id);
            List<CaseListController.CaseWrapper> s1 = CaseListController.getCaseListbyfilter('Community');
            List<caseComment> s2 = CaseListController.getCaseCommnets(cs.Id);
            List<String> s3 = CaseListController.getCaselistvalues();
            String s4 = CaseListController.getCaseListtoClose(cs.Id);
            Boolean s5 = CaseListController.getStatusValue(cs.ID);
            CaseListController.CasecommentWrapper s6 = CaseListController.createCaseComment(cs.Id, '');
            List<CaseComment> s7 = CaseListController.getCasecommes(new List<CaseComment>{  
            });
            
            test.StopTest();
        }
    }
}