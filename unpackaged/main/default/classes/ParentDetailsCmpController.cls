public without sharing  class ParentDetailsCmpController {
    @AuraEnabled
    public static wrapAccount getAccount(){
        wrapAccount wrap = new wrapAccount();
        wrap.hasRecord = false;
        Id usrid = UserInfo.getUserId();
        System.debug('@@@@@@@@ acc usrid'+usrid);
        List<ServiceResource> acc =[SELECT id,Name,Company_Name__c,Company_Registered_Number__c,Date_of_Birth__c,Bank_Account_Number__c,
                                    Date_of_VAT_Registration__c,Email__c,Employee_No__c,Engineer_Role__c,
                                    Mobile_No__c,Payment_Provider__c,Phone__c,Residential_Street__c,
                                    Residential_City__c,Residential_State__c,Residential_Country__c,Residential_PostalCode__c,
                                    Service_Resource_User_Id__c
                                                from ServiceResource 
                            where RelatedRecordId	=: usrid];
        System.debug('@@@@@@@@ acc'+acc);
        if(!acc.isEmpty()){
            wrap.acc = acc[0];
            wrap.hasRecord = true;
        }
        return wrap;
    }
    public class wrapAccount {
        @AuraEnabled
        public ServiceResource acc {get; set;}
        @AuraEnabled
        public Boolean hasRecord {get; set;}
        
        public wrapAccount( ) {
            acc = null;
            hasRecord = false;
        }
    }
}