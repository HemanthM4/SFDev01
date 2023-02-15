public class GSR_Certificate_Controller {
    
    public list <GSR_Submission__c> gsr_submission {get; set;}
    public list <GSR_Appliance_Results__c> appliance_results {get; set;}
    public list <GSR_Installation_Fault__c> installation_faults {get; set;}
    public list<gsrWrapper> gsrWrap{get;set;}
    public  Boolean hideStandardTable {get; set;}
    public  Boolean showStandardTable {get; set;}
    public Map<Integer,List<GSR_Appliance_Results__c>> approvalMap {get; set;}
    public List<GSR_Appliance_Results__c> approvalList1 {get; set;}
    public List<GSR_Appliance_Results__c> approvalList2 {get; set;}
    public List<GSR_Appliance_Results__c> approvalList3 {get; set;}
    public List<GSR_Appliance_Results__c> approvalList4 {get; set;}
    public List<GSR_Appliance_Results__c> approvalList5 {get; set;}
    public List<GSR_Appliance_Results__c> approvalList6 {get; set;}
    public List<GSR_Appliance_Results__c> approvalList7 {get; set;}
    public Boolean showFirstTable {get; set;}
    public Boolean showsecondTable {get; set;}     
    public Boolean approvalList1IsNull{get;set;}
    public Boolean approvalList2IsNull{get;set;}
    public Boolean approvalList3IsNull{get;set;}
    public Boolean approvalList4IsNull{get;set;}
    public Boolean approvalList5IsNull{get;set;}
    public Boolean approvalList6IsNull{get;set;}
    public Boolean approvalList7IsNull{get;set;}
    
    public GSR_Certificate_Controller() {
        showFirstTable =  showsecondTable = false;
        
        approvalMap = new  Map<Integer,List<GSR_Appliance_Results__c>>();
        approvalList1 = new  List<GSR_Appliance_Results__c>();approvalList4 = new  List<GSR_Appliance_Results__c>();
        approvalList2 = new  List<GSR_Appliance_Results__c>();approvalList5 = new  List<GSR_Appliance_Results__c>();
        approvalList3 = new  List<GSR_Appliance_Results__c>();approvalList6 = new  List<GSR_Appliance_Results__c>();
        approvalList7 = new  List<GSR_Appliance_Results__c>();
        
        gsrWrap = new List<gsrWrapper>();
        hideStandardTable = false;
        showStandardTable = true;
        Id gsr_id = ApexPages.currentPage().getParameters().get('id');
        
        gsr_submission = [SELECT id, Account_Name__c, Service_Resource_Lookup__r.Name, Gas_Safe_Engineer_License_Number__c, Work_Order_Lookup__r.Site__r.Site_Street__c, 
                          Work_Order_Lookup__r.Site__r.Site_City__c, Work_Order_Lookup__r.Site__r.Site_Country__c, Work_Order_Lookup__r.Site__r.Site_PostalCode__c, 
                          Work_Order_Lookup__r.Site__r.Primary_Site_Contact__r.FirstName, Work_Order_Lookup__r.Site__r.Primary_Site_Contact__r.LastName,CO_alarms_are_in_date__c,
                          Work_Order_Lookup__r.Site__r.Primary_Site_Contact_Phone__c,Work_Order_Lookup__r.Account.Phone, Completed_Date_Time__c,Report_Received_By_Type__c,
                          Work_Order_Lookup__r.Account.Name, Work_Order_Lookup__r.Account.BillingStreet, Work_Order_Lookup__r.Account.BillingCity,Number_of_Appliances_Tested__c, 
                          Work_Order_Lookup__r.Account.BillingPostalCode, Work_Order_Lookup__r.Account.BillingCountry, Satisfactory_visual_inspection__c,Name,  
                          Satisfactory_gas_tightness_test__c, Equipotential_bonding_satisfactory__c, Approved_CO_alarms_fitted__c,Emergency_control_valve_access_satisfact__c, 
                          Testing_of_CO_alarms_satisfactory__c, Smoke_alarms_fitted__c, Service_Appointment_Lookup__r.Scheduled_Date__c,Work_Order_Lookup__r.Account.RecordTypeId, 
                          Work_Order_Lookup__r.Account.First_Name__c,Work_Order_Lookup__r.Account.Last_Name__c,Number_Installation_Faults_Reported__c,Engineer_Name__c
                          FROM GSR_Submission__c WHERE Id = :gsr_id LIMIT 1];
        
        appliance_results = [SELECT Id, RCS_Label__c, Appliance_Location__c, Appliance_Manufacturer__c, Appliance_model__c, Gas_Council_Number__c, Appliance_Type__c, Flue_Type__c,
                             Appliance_Measurement__c,Appliance_measurement_type__c, Safety_devices_correct_operation__c, Spillage_test__c, Smoke_pellet_flue_flow_test__c,
                             Combustion_Initial_ratio_reading__c, Combustion_CO_reading__c,Combustion_CO2_reading__c, Combustion_Final_Reading__c, Satisfactory_termination__c,
                             Satisfactory_Flue_visual_condition__c, Adequate_ventilation__c, Landlords_Device__c, Inspected__c,Appliance_serviced__c, Appliance_safe_to_use__c
                             FROM GSR_Appliance_Results__c WHERE GSR_Submission__c = :gsr_id ORDER BY GSR_Submission__c asc];
        
        System.debug('appliance_results.size()'+appliance_results.size());
        // showFirstTable =  showsecondTable 
        Integer div  = 0;
        if(appliance_results.size() != 0 && appliance_results.size() >8 ){
            Integer mod = math.mod(appliance_results.size(),8);
            div =  appliance_results.size()/8;
            if( mod != 0){
                div = div+1;
            }
            showFirstTable = false;
            showsecondTable = true;
        }else{
            showFirstTable = true;
            showsecondTable = false;
        }
        if(showsecondTable){
            integer intValue = 1;
            for(GSR_Appliance_Results__c appliance_result:  appliance_results){
                if(approvalMap.containsKey(intValue) && approvalMap.get(intValue).size() < 8 ){
                    List<GSR_Appliance_Results__c> gsr  =  approvalMap.get(intValue);
                    gsr.add(appliance_result);
                    approvalMap.put(intValue,gsr) ;
                }else  if(!approvalMap.containsKey(intValue)){
                    List<GSR_Appliance_Results__c> gsr  = new List<GSR_Appliance_Results__c>();
                    gsr.add(appliance_result);
                    approvalMap.put(intValue,gsr) ;
                }else  if(approvalMap.containsKey(intValue) && approvalMap.get(intValue).size() == 8 ){
                    List<GSR_Appliance_Results__c> gsr  = new List<GSR_Appliance_Results__c>();
                    gsr.add(appliance_result);
                    intValue = intValue+1;
                    approvalMap.put(intValue,gsr) ;
                }
            }
            system.debug('approvalList1 - '+approvalMap.size());
            approvalList1IsNull = FALSE;approvalList4IsNull = FALSE;approvalList7IsNull = FALSE;
            approvalList2IsNull = FALSE;approvalList5IsNull = FALSE;
            approvalList3IsNull = FALSE;approvalList6IsNull = FALSE;
            for(Integer val: approvalMap.keySet()){
                system.debug('val - '+val);
                if(val==1){
                    approvalList1 = approvalMap.get(1);
                    approvalList1IsNull = TRUE;
                    system.debug('approvalList1 - '+approvalList1.size());
                }else if(val==2){                
                    approvalList2 = approvalMap.get(2);
                    approvalList2IsNull = TRUE;
                }else if(val==3){                
                    approvalList3 = approvalMap.get(3);
                    approvalList3IsNull = TRUE;
                }else if(val==4){                
                    approvalList4 = approvalMap.get(4);
                    approvalList4IsNull = TRUE;
                }else if(val==5){                
                    approvalList5 = approvalMap.get(5);
                    approvalList5IsNull = TRUE;
                }else if(val==6){                
                    approvalList6 = approvalMap.get(6);
                    approvalList6IsNull = TRUE;
                }else if(val==7){                
                    approvalList7 = approvalMap.get(7);
                    approvalList7IsNull = TRUE;
                }
            }
        }
        
        System.debug('div'+div);
        if (gsr_submission[0].Number_Installation_Faults_Reported__c == 0) { 
            hideStandardTable = true;
            showStandardTable = false;
            gsrWrapper gsr = new gsrWrapper();
            gsr.giveDetailsOfAnyFaults = 'No installation faults reported';
            gsr.recitificationWOrkCarrriedOut ='No rectification works required';
            gsr.warningNoticedIssues ='N/A' ;  
            gsr.warningTagStickFixed = 'N/A' ; 
            gsrWrap.add(gsr);
        }else { 
            installation_faults = [SELECT Id, Give_details_of_any_faults__c, GSR_Submission__r.Number_Installation_Faults_Reported__c,
                                   Rectification_work_carried_out__c, Warning_notice_issued__c, Warning_tag_or_sticker_fixed__c 
                				   FROM GSR_Installation_Fault__c WHERE GSR_Submission__c = :gsr_id ORDER BY GSR_Submission__c asc]; 
        }
    }
    
    public class gsrWrapper{
        public String recitificationWOrkCarrriedOut{get;set;}
        public String giveDetailsOfAnyFaults{get;set;}
        public String warningNoticedIssues{get;set;}
        public String warningTagStickFixed{get;set;}
        
        public gsrWrapper(){
            recitificationWOrkCarrriedOut=giveDetailsOfAnyFaults = '';
            warningNoticedIssues=warningNoticedIssues= '';
        }
    }
}