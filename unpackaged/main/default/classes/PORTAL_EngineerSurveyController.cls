public with sharing class PORTAL_EngineerSurveyController {

    public static final Integer MONTH_IN_DAYS = 30;

    public static ServiceResource srForCurrentUser {
        get {
            List<ServiceResource> activeServiceResources = new List<ServiceResource>();
            if (srForCurrentUser == null) {
                activeServiceResources = [
                        SELECT Id, FirstName__c, Name, CreatedDate, IsActive
                        FROM ServiceResource
                        WHERE RelatedRecord.Id = :UserInfo.getUserId()
                        AND IsActive = TRUE
                        AND (RelatedRecord.Profile.Name = 'Engineer Partner Community'
                        OR RelatedRecord.Profile.Name = 'System Administrator')
                        LIMIT 1
                ];
            }
            if (!activeServiceResources.isEmpty()) {
                return activeServiceResources[0];
            } else {
                return null;
            }
        }
        set;
    }

    @AuraEnabled
    public static String getServiceResourceFirstName() {
        if (srForCurrentUser != null) {
            if (srForCurrentUser.FirstName__c != null) {
                return srForCurrentUser.FirstName__c;
            } if (srForCurrentUser.Name != null) {
                return srForCurrentUser.Name;
            }
        }
        return 'Guest User';
    }

    @AuraEnabled
    public static Boolean isServiceResourceOlderThan30Days() {
        if (srForCurrentUser != null) {
            Integer daysDif = (Date.valueOf(srForCurrentUser.CreatedDate)).daysBetween(System.today());
            return daysDif > MONTH_IN_DAYS;
        } else {
            return true;
        }
    }

    @AuraEnabled
    public static List<Survey_Form__c> getSurveyRecordFromThisMonth() {
        if (srForCurrentUser != null) {
            return [
                    SELECT Service_Resource__r.Id,
                            Vehicle__c, Uniform__c, Plant_Hire__c, Shift_Patterns__c, Rates_of_Pay__c,
                            Ease_of_Field_Service_App__c, Quality_of_Leads__c, Quantity_Volume_of_Leads__c,
                            Travel_Time_Distance__c, Overall_Earnings__c, Office_Admin_Support__c,
                            Technical_Manager_Support__c, Access_to_Records_Community_Portal__c,
                            Crystal_Tax_Umbrella_Company__c, Work_Life_Balance__c, Working_for_Aspect__c
                    FROM Survey_Form__c
                    WHERE Service_Resource__c = :srForCurrentUser.Id
                    AND CreatedDate = THIS_MONTH
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void insertSurvey(Survey_Form__c surveyRecord) {
        if (srForCurrentUser == null) {
            return;
        }
        if (surveyRecord.Service_Resource__c == null) {
            surveyRecord.Service_Resource__c = srForCurrentUser.Id;
        }
        SurveyWoSharingHelper surveyHelper = new SurveyWoSharingHelper();
        surveyHelper.insertNewSurvey(surveyRecord);
    }

    public without sharing class SurveyWoSharingHelper {
        public void insertNewSurvey(Survey_Form__c surveyRecord) {
            insert surveyRecord;
        }
    }
}