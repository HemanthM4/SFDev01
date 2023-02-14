/*
 
Modification Log:
1) 7/7/2022 - Mofified by Pradeep for Rate Cards and Rate restructure

*/

public class Aspect_JobDataController {
    @AuraEnabled 
    public static decimal hr1{
        get;set;
    }
    @AuraEnabled 
    public static decimal hr2{
        get;set;
    }
    @AuraEnabled 
    public static decimal hr3{
        get;set;
    }
    @AuraEnabled 
    public static decimal hr1amount{ 
        get;set; 
    }
    @AuraEnabled 
    public static decimal hr2amount{
        get;set;
    }
    @AuraEnabled 
    public static decimal hr3amount{
        get;set;
    }
    @AuraEnabled 
    public static Map<String, String> getTrades()
    {
        Map<String, String> options = new Map<String, String>();
        List<Trade__c> lsttrade =[Select id,Name FROM Trade__c order by Name asc  Limit 1000];
        for(Trade__c trd :lsttrade)
        {
            options.put(trd.id,trd.Name);
        }
        return options;
    }
    @AuraEnabled
    public static boolean  getUserInfo(String userId)
    {
        Boolean hidemarkup = false;
        List<User> usr=[SELECT id,ProfileId,Profile.Name from User where id=:userId];
        if(usr.size()!=0){
            if(usr[0].Profile.Name=='PHASE 2 Ops - Starter'){
                hidemarkup = true;
            }
        }
        return hidemarkup;
    }
    @AuraENabled
    public static workORderLabourWrapper getWorkOrderOnChage(String selectedTrade,workORderLabourWrapper workorderWrapperforLabour,
                                                             String recID,Boolean isFromnewWO,Boolean isTradeChange)
    {
        workORderLabourWrapper workorder = new workORderLabourWrapper();
        system.debug(workorderWrapperforLabour.rateofpay);
        if(isFromnewWO == true)
        {
            workorderWrapperforLabour = Aspect_JobDataHandler.newWorkCreation(selectedTrade,workorderWrapperforLabour,recID,isFromnewWO,isTradeChange);
            return  workorderWrapperforLabour;
        }else{
            if(workorderWrapperforLabour!=null )
                workorder =  workorderWrapperforLabour;
            workorder = Aspect_JobDataHandler.newWorkCreation(selectedTrade,workorder,recID,isFromnewWO,isTradeChange);
            
        }
        return workorder;
    }
    @AuraEnabled
    public static String getCombinedValuefromJob (Id recordId) {  
        String combinedValue ='';
        List<Job__c> jobInfo = [SELECT id,Combined_Scope_of_Works_for_All_WOs__c FROM Job__c WHERE Id=:recordId];
        if(jobInfo.size()!=0 && jobInfo[0].Combined_Scope_of_Works_for_All_WOs__c !='')
            combinedValue =  jobInfo[0].Combined_Scope_of_Works_for_All_WOs__c ;
        return combinedValue;
    }
    @AuraEnabled
    public static List<productRequiredWrapper>updatePrdowrap( List<productRequiredWrapper> ProdRelist)
    {
        List<productRequiredWrapper>prodd = new List<productRequiredWrapper>();
        for(productRequiredWrapper prds : ProdRelist){
            if(prds.overrides==true){
                if(prds.cost!=prds.costorg || prds.quantity != prds.quantityorg || prds.markup != prds.markuporg){
                    if(prds.cost==null )
                        prds.cost =0;
                    if(prds.quantity==null)
                        prds.quantity=0;
                    if(prds.markup==null)
                        prds.markup=0;
                    prds.charge = ((prds.quantity*prds.cost)*( prds.markup/100))+(prds.quantity*prds.cost);
                    if(prds.cost!=null && prds.quantity!=null)
                        prds.totalcost = (prds.cost* prds.quantity);
                    prds.costorg = prds.cost;
                    prds.quantityorg = prds.quantity;
                    prds.markuporg = prds.markup;
                }
                prodd.add(prds);
            }else {
                
                if(prds.cost!=prds.costorg || prds.quantity != prds.quantityorg || prds.markup != prds.markuporg || Test.isRunningTest() || prds.overrideorg != prds.overrides || prds.overrides==false){
                    
                    if(prds.cost==null )
                        prds.cost =0;
                    if(prds.quantity==null)
                        prds.quantity=0;
                    if(prds.markup==null)
                        prds.markup=0;
                    if((prds.cost<=100 && prds.cost!=prds.costorg) ||  (prds.overrides==false && prds.cost<=100))
                        prds.markup=60;
                    if((prds.cost>100 && prds.cost<=1000 && prds.cost!=prds.costorg) || (prds.overrides==false && prds.cost>100 && prds.cost<=1000))
                        prds.markup=40;
                    if((prds.cost>1000 && prds.cost!=prds.costorg) || (prds.overrides==false && prds.cost>1000))
                        prds.markup=35;
                    prds.charge = ((prds.quantity*prds.cost)*( prds.markup/100))+(prds.quantity*prds.cost);
                    if(prds.cost!=null && prds.quantity!=null)
                        prds.totalcost = (prds.cost* prds.quantity);
                    prds.costorg = prds.cost;
                    prds.quantityorg = prds.quantity;
                    prds.markuporg = prds.markup;
                }
                prodd.add(prds);
                
            }
            
            
        }
        return prodd;
    }
    @AuraEnabled
    public static void deleteproductrequired(String prodId)
    {
        List<ProductRequired> prods =[SELECT id from ProductRequired where id=:prodId];
        if(!prods.isEmpty())
        {
            try{
                delete prods;
            }
            catch(Exception ex)
            {
            }
        }
        
    }
    @AuraEnabled
    public static workTrageGroupWrapper tradeWOrktypeGroup(String SeelctedWorkId)
    {
        workTrageGroupWrapper  workWrap = new workTrageGroupWrapper();
        WorkOrder wo = [SELECT id,WorkType.Name,WorkType.Trade__c,WOrkType.Group__c  from WorkOrder where id=: SeelctedWorkId];
        if(wo!=null && wo.WorkType.Name!=null)
            workWrap.worktypeId = wo.WorkType.Name;
        if(wo!=null && wo.WorkTypeId!=null && wo.WorkType.Trade__c!=null){
            
            List<Trade__c> lsttrade =[Select id,Name FROM Trade__c where Name =: wo.WorkType.Trade__c LIMIT 1];
            if(!lsttrade.isEmpty())
                workWrap.tradeID =lsttrade[0].id;
        }
        if(wo!=null && wo.WOrkTypeId!=null &&  wo.WOrkType.Group__c !=null){
            List<Group__c> lstgroup =[Select id,Name FROM Group__c where Name=:wo.WOrkType.Group__c  Limit 1];
            if(!lstgroup.isEmpty())
            {   workWrap.groupId =lstgroup[0].Id ;
             workWrap.groupName =lstgroup[0].Name;
            }
        }
        return workWrap;  
    }
    public class workTrageGroupWrapper
    {
        @AuraEnabled
        public String worktypeId
        {
            get;set;
        }
        @AuraEnabled
        public String tradeID
        {
            get;set;
        }
        @AuraEnabled
        public String groupId
        {
            get;set;
        }
        @AuraEnabled
        public String groupName
        {
            get;set;
        }
        
        public workTrageGroupWrapper()
        {
            worktypeId = tradeID =groupId =groupName ='';
        }
    }
    @AuraEnabled 
    public static Map<String, String> getWorkType(String selectedgroup)
    {
        Map<String, String> options = new Map<String, String>();
        List<worktype> lsttrade =[Select id,Name FROM worktype  where Group_Lookup__c=:selectedgroup order by Name asc  Limit 1000];
        for(worktype trd :lsttrade)
        {
            options.put(trd.id,trd.Name);
        }
        return options;
    }
    public static Decimal getfixedPriceAdmin(String jobId)
    {
        Decimal fixedPrioce =0;
        Job__c jobs = [SELECT id,Charge_Net__c from Job__c where id=:jobId LIMIT 1];
        if(jobs.Charge_Net__c>=0 && jobs.Charge_Net__c<=249){
            fixedPrioce = jobs.Charge_Net__c*0.1;
        }else if(jobs.Charge_Net__c>=250 && jobs.Charge_Net__c<=499){
            fixedPrioce = jobs.Charge_Net__c*0.075;
        }else if(jobs.Charge_Net__c>=500 && jobs.Charge_Net__c<=999){
            fixedPrioce = jobs.Charge_Net__c*0.06;
        }else if(jobs.Charge_Net__c>=1000 && jobs.Charge_Net__c<=5999){
            fixedPrioce = jobs.Charge_Net__c*0.05;
        }else if(jobs.Charge_Net__c>=6000 && jobs.Charge_Net__c<=9999){
            fixedPrioce = jobs.Charge_Net__c*0.04;
        }else if(jobs.Charge_Net__c>=10000 && jobs.Charge_Net__c<=24999){
            fixedPrioce = jobs.Charge_Net__c*0.035;
        }else if(jobs.Charge_Net__c>=25000 && jobs.Charge_Net__c<=100000){
            fixedPrioce = jobs.Charge_Net__c*0.025;
        }
        return fixedPrioce;
    }
    @AuraEnabled 
    public static CCOtherWrapper getCCforWorkOrder(String SeelctedWorkId){ 
        
        CCOtherWrapper ccother  = new CCOtherWrapper();
        List<Costs_and_Charges__c> cc = new List<Costs_and_Charges__c>();
        List<WorkOrder> WO = [SELECT id,Costs_and_Charges__c,Job__c from WOrkOrder where Id =:SeelctedWorkId];
        if(!WO.isEMpty() && WO[0].Costs_and_Charges__c!=null){
            
            
            cc = [SELECT id,Charge_ULEZ__c,Charge_Collection_Fee__c ,Call_Out_Fee__c,Simple_Charge_Other__c,
                  Fixed_Price_Admin_Fee_2__c,Fixed_Price_Admin_Fee__c,Description__c,Cost_Other_Item__c,Charge_Other_Item__c,
                  Cost_Collection_Fee__c from Costs_and_Charges__c where Id=:WO[0].Costs_and_Charges__c];
            if(!cc.isEmpty())
            {
                if(cc[0].Charge_ULEZ__c!=null)
                {
                    ccother.chargeUlez = cc[0].Charge_ULEZ__c; 
                    ccother.costUlez = cc[0].Charge_ULEZ__c;
                }
                if(cc[0].Fixed_Price_Admin_Fee__c   !=null){
                    
                    if(cc[0].Fixed_Price_Admin_Fee_2__c!=null)
                        ccother.fixedpriceadmin =cc[0].Fixed_Price_Admin_Fee_2__c   ;
                    
                }
                
                if(cc[0].Charge_Collection_Fee__c!=null)
                    ccother.ccChargeCollecgtionFee = cc[0].Charge_Collection_Fee__c;
                if(cc[0].Charge_Collection_Fee__c!=null && cc[0].Charge_Collection_Fee__c!=0)
                    ccother.ccCostCollecgtionFee = cc[0].Charge_Collection_Fee__c/2;
                if(cc[0].Call_Out_Fee__c!=null)
                    ccother.ccChargecalloutFee = cc[0].Call_Out_Fee__c;
                
                if(cc[0].Cost_Other_Item__c !=null)
                    ccother.cccostOther =  cc[0].Cost_Other_Item__c ;
                if(cc[0].Charge_Other_Item__c!=null)
                    ccother.ccChargeother = cc[0].Charge_Other_Item__c.setScale(2);
                
                ccother.costtotal =  (ccother.chargeUlez + ccother.ccCostCollecgtionFee +ccother.cccostOther).setScale(2);
                ccother.chargetotal = (ccother.chargeUlez+ ccother.ccChargeCollecgtionFee + ccother.ccChargecalloutFee+ 
                                       ccother.fixedpriceadmin+ccother.ccChargeother).setScale(2);
                ccother.description =  cc[0].Description__c;
            }
        }
        
        return  ccother;
    }
    
    @AuraEnabled 
    public static Map<String, String> getgroup(String selectedTrade)
    {
        Map<String, String> options = new Map<String, String>();
        List<Group__c> lstgroup =[Select id,Name FROM Group__c where Trade__c=:selectedtrade order by Name asc  Limit 1000];
        for(Group__c grp :lstgroup)
        {
            options.put(grp.id,grp.Name);
        }
        return options;
    }
    @AuraEnabled
    public static Job__c getjobbrecord (Id recordId) {  
        
        Job__c jobInfo = [SELECT id,name,Charge_Labour__c,Cost_Labour__c,Charge_List_Price_Services__c,Charge_Materials_Total__c,Cost_Materials_Total__c,
                          Cost_Discount__c,Total_List_Price__c , Total_ulez__c, Total_Fixed_Price_Admin__c,Charge_Discount_Total__c,Charge_Call_Out__c,
                          Charge_Collection_Fee__c,Charge_ULEZ__c,Fixed_Price_Admin_Fee__c,Cost_Other_Item__c,Cost_Collection_Fee__c,Cost_Call_Out__c,
                          Cost_ULEZ__c,Cost_Fixed_Price_Admin__c,Charge_Other_Total__c,Cost_Other_Total__c,
                          Charge_Net__c,Cost_Total__c,Charge_VAT__c,Charge_Gross__c,Charge_Deposit__c FROM Job__c WHERE Id=:recordId];
        
        return jobInfo;
    }
    @AuraEnabled
    public static workORderLabourWrapper getworktypechange(String selectedworktype,workORderLabourWrapper workorderWrapperforLabour,String WOrkORderId,
                                                           String jobId){
                                                               workORderLabourWrapper  workWrapper = new workORderLabourWrapper();
                                                               workWrapper = workorderWrapperforLabour;
                                                               Job__c job =New Job__c();
                                                               System.debug('selectedworktype'+selectedworktype);
                                                               List<Trade__c> lsttrade =New  List<Trade__c> ();
                                                               List<WOrkORder> WO =[SELECT id,Costs_and_Charges__c,Rate_Of_Pay_Percent__c,WorkType.Trade__c,Job__c,Description,WorkTypeId,WorkType.Name,Scope_of_Works_Amended_by_Operative__c,
                                                                                    Other_Charges_Description__c       from WorkOrder where id=:WOrkORderId ];
                                                               if(WO.size()!=0)
                                                                   job = [SELECT id,Account__c,Account__r.Rate_Card__c from Job__c where id=:WO[0].Job__c];
                                                               else
                                                                   job = [SELECT id,Account__c,Account__r.Rate_Card__c from Job__c where id=:jobId];   
                                                               List<worktype> worktpyerecord =[Select id,Name,Scope_of_Works__c,Trade__c     FROM worktype  where id=:selectedworktype order by Name asc  Limit 1];
                                                               lsttrade =[Select id,Name FROM Trade__c where Name =: worktpyerecord[0].Trade__c LIMIT 1];
                                                               if(!worktpyerecord.isEMpty()){
                                                                   workWrapper.description = worktpyerecord[0].Scope_of_Works__c;
                                                               }
                                                               if(!WO.isEmpty()  && WO[0].Costs_and_Charges__c!=null)
                                                               {
                                                                   /* 
List<Rate_Cards__c> rateCards =New List<Rate_Cards__c>();
rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=:job.Account__c];
if(rateCards.size()==0)
rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=''];
Set<id> rateIds = new Set<id>();
for(Rate_Cards__c rate  :rateCards)
{
rateIds.add(rate.id);
}
system.debug('<rateIds>'+rateIds);
for(Rate__c rate : [SELECT id ,Rate__c,Amount__c from Rate__C
where Rate_Cards__c =:rateIds ])
{

if(rate.Rate__c =='R1' &&  rate.Amount__c!=null)
workWrapper.hourrater1 = rate.Amount__c;
else if(rate.Rate__c =='R2' &&  rate.Amount__c!=null)            
workWrapper.hourrater2 = rate.Amount__c;
else  if(rate.Rate__c =='R3' &&  rate.Amount__c!=null)            
workWrapper.hourrater3 = rate.Amount__c;
}
*/
                                                                   Rate_Card_Trade__c tradeRateCard = new Rate_Card_Trade__c();
                                                                   tradeRateCard = [Select Id, Charge_R1__c, Charge_R2__c, Charge_R3__c FROM Rate_Card_Trade__c
                                                                                    WHERE Trade__c =: lsttrade[0].Id AND Rate_Card__c =: job.Account__r.Rate_Card__c LIMIT 1];
                                                                   if(tradeRateCard == null){
                                                                       tradeRateCard = [Select Id, Charge_R1__c, Charge_R2__c, Charge_R3__c FROM Rate_Card_Trade__c
                                                                                        WHERE Rate_Card__r.Standard__c = TRUE LIMIT 1];
                                                                   }
                                                                   
                                                                   if(tradeRateCard != null){
                                                                       workWrapper.hourrater1 = tradeRateCard.Charge_R1__c;           
                                                                       workWrapper.hourrater2 = tradeRateCard.Charge_R2__c;            
                                                                       workWrapper.hourrater3 = tradeRateCard.Charge_R3__c;
                                                                   }
                                                                   
                                                                   Costs_and_Charges__c CC =[SELECT id,Chargeable_Duration_R1__c,Chargeable_Duration_R2__c,Chargeable_Duration_R3__c,Charge_List_Price_Services__c ,
                                                                                             Discount_Manual_Percentage__c,Rate_of_Pay__c,Hourly_Charge_R1__c,Hourly_Charge_R2__c,Hourly_Charge_R3__c,
                                                                                             Charge_ULEZ__c,Charge_Collection_Fee__c,Simple_Charge_Other__c
                                                                                             from Costs_and_Charges__c where id=:WO[0].Costs_and_Charges__c];
                                                                   
                                                                   if(CC.Chargeable_Duration_R1__c!=null){
                                                                       workWrapper.r1=CC.Chargeable_Duration_R1__c;
                                                                       hr1 = CC.Chargeable_Duration_R1__c;
                                                                   }
                                                                   if(CC.Chargeable_Duration_R2__c!=null)
                                                                   {
                                                                       workWrapper.r2=CC.Chargeable_Duration_R2__c;
                                                                       hr2 = CC.Chargeable_Duration_R2__c;
                                                                   }
                                                                   if(CC.Chargeable_Duration_R3__c!=null)
                                                                   {
                                                                       workWrapper.r3=CC.Chargeable_Duration_R3__c;
                                                                       hr3 = CC.Chargeable_Duration_R3__c;
                                                                   }
                                                                   if(CC.Charge_List_Price_Services__c!=null)
                                                                       workWrapper.listproce =CC.Charge_List_Price_Services__c ;
                                                                   if(CC.Discount_Manual_Percentage__c!=null)
                                                                       workWrapper.discount = CC.Discount_Manual_Percentage__c;
                                                                   
                                                                   if(CC.Hourly_Charge_R1__c!=null){
                                                                       //workWrapper.hourrater1 = CC.Hourly_Charge_R1__c;
                                                                       hr1amount = CC.Hourly_Charge_R1__c;
                                                                   }
                                                                   if(CC.Hourly_Charge_R2__c!=null)
                                                                   {
                                                                       //workWrapper.hourrater2 = CC.Hourly_Charge_R2__c;
                                                                       hr2amount = CC.Hourly_Charge_R2__c;
                                                                   }
                                                                   if(CC.Hourly_Charge_R3__c!=null)
                                                                   {
                                                                       //workWrapper.hourrater3 = CC.Hourly_Charge_R3__c;
                                                                       hr3amount = CC.Hourly_Charge_R3__c;
                                                                   }
                                                                   workWrapper.charger1 = (workWrapper.r1* workWrapper.hourrater1).setScale(2);
                                                                   workWrapper.charger2 =(workWrapper.r2* workWrapper.hourrater2).setScale(2);
                                                                   workWrapper.charger3 = (workWrapper.r3* workWrapper.hourrater3).setScale(2);
                                                                   
                                                                   if(CC.Charge_List_Price_Services__c!=null)
                                                                       workWrapper.chargelistproce = CC.Charge_List_Price_Services__c;
                                                                   
                                                                   
                                                                   if(workWrapper.rateofpay!=0)
                                                                       workWrapper.costr1 =  (workWrapper.charger1*( workWrapper.rateofpay /100)).setScale(2);
                                                                   if(workWrapper.rateofpay!=0)
                                                                       workWrapper.costr2 = (workWrapper.charger2*( workWrapper.rateofpay /100)).setScale(2);
                                                                   if(workWrapper.rateofpay!=0)
                                                                       workWrapper.costr3 = (workWrapper.charger3*( workWrapper.rateofpay /100)).setScale(2);
                                                                   if(workWrapper.rateofpay!=0)
                                                                       workWrapper.costlistproce = (workWrapper.listproce*( workWrapper.rateofpay /100)).setScale(2);
                                                                   workWrapper.chargediscount = (( workWrapper.charger1 + workWrapper.charger2
                                                                                                  + workWrapper.charger3+ workWrapper.chargelistproce)*( workWrapper.discount/100)).setScale(2);
                                                                   workWrapper.costdiscount =((workWrapper.costr1+workWrapper.costr2+workWrapper.costr3+workWrapper.costlistproce)*( workWrapper.discount/100)).setScale(2);
                                                                   
                                                                   
                                                                   workWrapper.diablehourrater1 = true;
                                                                   workWrapper.diablehourrater2 = true;
                                                                   workWrapper.diablehourrater3 = true;
                                                                   workWrapper.workorderId = WO[0].Id;
                                                                   workWrapper.CCid=CC.id;
                                                                   if( workWrapper.costdiscount>=0){
                                                                       workWrapper.totalcost =  (workWrapper.costr1 + workWrapper.costr2+ workWrapper.costr3+workWrapper.costlistproce
                                                                                                 - workWrapper.costdiscount).setScale(2);
                                                                   }else{
                                                                       workWrapper.totalcost =  (workWrapper.costr1 + workWrapper.costr2+ workWrapper.costr3+workWrapper.costlistproce
                                                                                                 + workWrapper.costdiscount).setScale(2);
                                                                   }
                                                                   workWrapper.chargetotal = ((workWrapper.charger1 +workWrapper.charger2+workWrapper.charger3+ workWrapper.chargelistproce)- workWrapper.chargediscount).setScale(2) ;
                                                                   
                                                               }else{
                                                                   /*
                                                                   List<Rate_Cards__c> rateCards =New List<Rate_Cards__c>();
                                                                   rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=:job.Account__c];
                                                                   if(rateCards.size()==0)
                                                                       rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=''];
                                                                   Set<id> rateIds = new Set<id>();
                                                                   for(Rate_Cards__c rate  :rateCards)
                                                                   {
                                                                       rateIds.add(rate.id);
                                                                   }
                                                                   system.debug('<rateIds>'+rateIds);
                                                                   for(Rate__c rate : [SELECT id ,Rate__c,Amount__c from Rate__C
                                                                                       where Rate_Cards__c =:rateIds ])
                                                                   {
                                                                       
                                                                       if(rate.Rate__c =='R1' &&  rate.Amount__c!=null)
                                                                           workWrapper.hourrater1 = rate.Amount__c;
                                                                       else if(rate.Rate__c =='R2' &&  rate.Amount__c!=null)            
                                                                           workWrapper.hourrater2 = rate.Amount__c;
                                                                       else  if(rate.Rate__c =='R3' &&  rate.Amount__c!=null)            
                                                                           workWrapper.hourrater3 = rate.Amount__c;
                                                                   }
                                                                   */
                                                                   Rate_Card_Trade__c tradeRateCard = new Rate_Card_Trade__c();
                                                                   tradeRateCard = [Select Id, Charge_R1__c, Charge_R2__c, Charge_R3__c FROM Rate_Card_Trade__c
                                                                                    WHERE Trade__c =: lsttrade[0].Id AND Rate_Card__c =: job.Account__r.Rate_Card__c LIMIT 1];
                                                                   if(tradeRateCard == null){
                                                                       tradeRateCard = [Select Id, Charge_R1__c, Charge_R2__c, Charge_R3__c FROM Rate_Card_Trade__c
                                                                                        WHERE Rate_Card__r.Standard__c = TRUE LIMIT 1];
                                                                   }
                                                                   
                                                                   if(tradeRateCard != null){
                                                                       workWrapper.hourrater1 = tradeRateCard.Charge_R1__c;           
                                                                       workWrapper.hourrater2 = tradeRateCard.Charge_R2__c;            
                                                                       workWrapper.hourrater3 = tradeRateCard.Charge_R3__c;
                                                                   }
                                                               }
                                                               return workWrapper;
                                                           }
    @AuraEnabled
    public static workORderLabourWrapper getWorkorderforLabourctrl(String WOrkORderId){
        workORderLabourWrapper workWrapper  = new workORderLabourWrapper();
        Job__c job =New Job__c();
        List<Trade__c> lsttrade =New  List<Trade__c> ();
        List<WOrkORder> WO =[SELECT id,Costs_and_Charges__c,Rate_Of_Pay_Percent__c,WorkType.Trade__c,Job__c,Description,WorkTypeId,WorkType.Name,Scope_of_Works_Amended_by_Operative__c,
                             Other_Charges_Description__c       from WorkOrder where id=:WOrkORderId ];
        if((!WO.isEmpty() && WO[0]!=null && WO[0].WorkTypeId!=null && WO[0].WorkType.Trade__c!=null) || Test.isRunningTest()){
            workWrapper.description = WO[0].Scope_of_Works_Amended_by_Operative__c;
            workWrapper.otherdescription = Wo[0].Other_Charges_Description__c;
            if(Wo[0].Rate_Of_Pay_Percent__c!=null)
                workWrapper.rateofpay=  Wo[0].Rate_Of_Pay_Percent__c;                              
            else        
                workWrapper.rateofpay=  0;              
            job = [SELECT id,Account__c,Account__r.Rate_Card__c from Job__c where id=:WO[0].Job__c];
            List<worktype> worktpyerecord =[Select id,Name,Scope_of_Works__c     FROM worktype  where Name=:WO[0].WorkType.Name order by Name asc  Limit 1];
            lsttrade =[Select id,Name FROM Trade__c where Name =: WO[0].WorkType.Trade__c LIMIT 1];
            
        }
        if(!WO.isEmpty()  && WO[0].Costs_and_Charges__c!=null)
        {
            /*
            List<Rate_Cards__c> rateCards =New List<Rate_Cards__c>();
            rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=:job.Account__c];
            if(rateCards.size()==0)
                rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=''];
            Set<id> rateIds = new Set<id>();
            for(Rate_Cards__c rate  :rateCards)
            {
                rateIds.add(rate.id);
            }
            system.debug('<rateIds>'+rateIds);
            for(Rate__c rate : [SELECT id ,Rate__c,Amount__c from Rate__C
                                where Rate_Cards__c =:rateIds ])
            {
                
                if(rate.Rate__c =='R1' &&  rate.Amount__c!=null)
                    workWrapper.hourrater1 = rate.Amount__c;
                else if(rate.Rate__c =='R2' &&  rate.Amount__c!=null)            
                    workWrapper.hourrater2 = rate.Amount__c;
                else  if(rate.Rate__c =='R3' &&  rate.Amount__c!=null)            
                    workWrapper.hourrater3 = rate.Amount__c;
            }
            */
            Rate_Card_Trade__c tradeRateCard = new Rate_Card_Trade__c();
            tradeRateCard = [Select Id, Charge_R1__c, Charge_R2__c, Charge_R3__c FROM Rate_Card_Trade__c
                             WHERE Trade__c =: lsttrade[0].Id AND Rate_Card__c =: job.Account__r.Rate_Card__c LIMIT 1];
            if(tradeRateCard == null){
                tradeRateCard = [Select Id, Charge_R1__c, Charge_R2__c, Charge_R3__c FROM Rate_Card_Trade__c
                                 WHERE Rate_Card__r.Standard__c = TRUE LIMIT 1];
            }
            
            if(tradeRateCard != null){
                workWrapper.hourrater1 = tradeRateCard.Charge_R1__c;           
                workWrapper.hourrater2 = tradeRateCard.Charge_R2__c;            
                workWrapper.hourrater3 = tradeRateCard.Charge_R3__c;
            }
            
            Costs_and_Charges__c CC =[SELECT id,Chargeable_Duration_R1__c,Chargeable_Duration_R2__c,Chargeable_Duration_R3__c,Charge_List_Price_Services__c ,
                                      Discount_Manual_Percentage__c,Rate_of_Pay__c,Hourly_Charge_R1__c,Hourly_Charge_R2__c,Hourly_Charge_R3__c,
                                      Charge_ULEZ__c,Charge_Collection_Fee__c,Simple_Charge_Other__c
                                      from Costs_and_Charges__c where id=:WO[0].Costs_and_Charges__c];
            
            if(CC.Chargeable_Duration_R1__c!=null){
                workWrapper.r1=CC.Chargeable_Duration_R1__c;
                hr1 = CC.Chargeable_Duration_R1__c;
            }
            if(CC.Chargeable_Duration_R2__c!=null)
            {
                workWrapper.r2=CC.Chargeable_Duration_R2__c;
                hr2 = CC.Chargeable_Duration_R2__c;
            }
            if(CC.Chargeable_Duration_R3__c!=null)
            {
                workWrapper.r3=CC.Chargeable_Duration_R3__c;
                hr3 = CC.Chargeable_Duration_R3__c;
            }
            if(CC.Charge_List_Price_Services__c!=null)
                workWrapper.listproce =CC.Charge_List_Price_Services__c ;
            if(CC.Discount_Manual_Percentage__c!=null)
                workWrapper.discount = CC.Discount_Manual_Percentage__c;
            
            if(CC.Hourly_Charge_R1__c!=null){
                //workWrapper.hourrater1 = CC.Hourly_Charge_R1__c;
                hr1amount = CC.Hourly_Charge_R1__c;
            }
            if(CC.Hourly_Charge_R2__c!=null)
            {
                //workWrapper.hourrater2 = CC.Hourly_Charge_R2__c;
                hr2amount = CC.Hourly_Charge_R2__c;
            }
            if(CC.Hourly_Charge_R3__c!=null)
            {
                //workWrapper.hourrater3 = CC.Hourly_Charge_R3__c;
                hr3amount = CC.Hourly_Charge_R3__c;
            }
            workWrapper.charger1 = (workWrapper.r1* workWrapper.hourrater1).setScale(2);
            workWrapper.charger2 =(workWrapper.r2* workWrapper.hourrater2).setScale(2);
            workWrapper.charger3 = (workWrapper.r3* workWrapper.hourrater3).setScale(2);
            
            if(CC.Charge_List_Price_Services__c!=null)
                workWrapper.chargelistproce = CC.Charge_List_Price_Services__c;
            
            
            if(workWrapper.rateofpay!=0)
                workWrapper.costr1 =  (workWrapper.charger1*( workWrapper.rateofpay /100)).setScale(2);
            if(workWrapper.rateofpay!=0)
                workWrapper.costr2 = (workWrapper.charger2*( workWrapper.rateofpay /100)).setScale(2);
            if(workWrapper.rateofpay!=0)
                workWrapper.costr3 = (workWrapper.charger3*( workWrapper.rateofpay /100)).setScale(2);
            if(workWrapper.rateofpay!=0)
                workWrapper.costlistproce = (workWrapper.listproce*( workWrapper.rateofpay /100)).setScale(2);
            workWrapper.chargediscount = (( workWrapper.charger1 + workWrapper.charger2
                                           + workWrapper.charger3+ workWrapper.chargelistproce)*( workWrapper.discount/100)).setScale(2);
            workWrapper.costdiscount =((workWrapper.costr1+workWrapper.costr2+workWrapper.costr3+workWrapper.costlistproce)*( workWrapper.discount/100)).setScale(2);
            
            
            workWrapper.diablehourrater1 = true;
            workWrapper.diablehourrater2 = true;
            workWrapper.diablehourrater3 = true;
            workWrapper.workorderId = WO[0].Id;
            workWrapper.CCid=CC.id;
            if( workWrapper.costdiscount>=0){
                workWrapper.totalcost =  (workWrapper.costr1 + workWrapper.costr2+ workWrapper.costr3+workWrapper.costlistproce
                                          - workWrapper.costdiscount).setScale(2);
            }else{
                workWrapper.totalcost =  (workWrapper.costr1 + workWrapper.costr2+ workWrapper.costr3+workWrapper.costlistproce
                                          + workWrapper.costdiscount).setScale(2);
            }
            workWrapper.chargetotal = ((workWrapper.charger1 +workWrapper.charger2+workWrapper.charger3+ workWrapper.chargelistproce)- workWrapper.chargediscount).setScale(2) ;
            
        }
        
        
        return workWrapper;
        
    }
    @AuraEnabled 
    public static void updateccforworkorder(String SeelctedWorkId){
        List<Costs_and_Charges__c> ccs = new  List<Costs_and_Charges__c>();
         System.debug('entered 0 '+SeelctedWorkId);
        List<WorkOrder> wo = [SELECT id,Costs_and_Charges__c from WOrkOrder where id =:SeelctedWorkId];
        System.debug('entered'+wo);
        if(wo.size()!=0 && wo[0].Costs_and_Charges__c != null){
            System.debug('entered 1 '+wo[0].Costs_and_Charges__c );
            for( Costs_and_Charges__c cc:[SELECT id   from Costs_and_Charges__c where Id=: wo[0].Costs_and_Charges__c LIMIT 1]) {
                cc.Discount_Manual_Override__c = true;
                 System.debug('entered 2 '+cc);
                ccs.add(cc);
            } 
        }
        if(ccs.size()!=0){
            update ccs;
             System.debug('entered 3 '+ccs);
        }
    }
    @AuraEnabled
    public static workOrderWrapper getWorkOrderDetailsCtrl(String WOrkORderId)
    {     
        workOrderWrapper WOWrapper = new workOrderWrapper();
        List<Costs_and_Charges__c> cc = new  List<Costs_and_Charges__c>();
        List<WorkOrder> WO = [SELECT id,Costs_and_Charges__c,WorkOrderNumber from WOrkOrder where Id    =:WOrkORderId];
        WOWrapper.workorderId =WO[0].WorkOrderNumber;
        if(!WO.isEMpty() && WO[0].Costs_and_Charges__c!=null){
            cc = [SELECT id,Charge_labour__c ,Charge_List_Price_Services__c,Budget_Materials_Charge__c,Charge_ULEZ__c,Rate_of_Pay__c,Charge_Other_Item__c,
                  Charge_Collection_Fee__c,Call_Out_Fee__c,Discount_Value__c,Job__c,Cost_Materials_Total__c,Simple_Charge_Other__c,Cost_Labour__c,Charge_Total__c,
                  Fixed_Price_Admin_Fee_2__c,Cost_Total__c,Charge_Other_Total__c    ,Cost_Other_Total__c          
                  from Costs_and_Charges__c where Id=:WO[0].Costs_and_Charges__c LIMIT 1];
            if(!cc.isEmpty()){
                Decimal chargeulez1 =0;
                Decimal chargecollection1 =0;
                Decimal simplecharge =0;
                if(cc[0].Cost_Total__c!=null)
                    WOWrapper.costNet =cc[0].Cost_Total__c.setScale(2);
                if(cc[0].Charge_ULEZ__c!=null)
                    chargeulez1=cc[0].Charge_ULEZ__c;
                if(cc[0].Charge_Collection_Fee__c!=null)
                    chargecollection1=cc[0].Charge_Collection_Fee__c*0.5;
                if(cc[0].Simple_Charge_Other__c!=null)
                    simplecharge=cc[0].Simple_Charge_Other__c;
                if(cc[0].Cost_Other_Total__c!=null)                  
                    WOWrapper.costMaterila=cc[0].Cost_Other_Total__c.setScale(2);
                if(cc[0].Charge_labour__c!=null && cc[0].Charge_List_Price_Services__c!=null)
                    WOWrapper.ChargeLabour=cc[0].Charge_labour__c+ cc[0].Charge_List_Price_Services__c.setScale(2);
                else if(cc[0].Charge_labour__c!=null )
                    WOWrapper.ChargeLabour=cc[0].Charge_labour__c.setScale(2);
                else if(cc[0].Charge_List_Price_Services__c!=null )
                    WOWrapper.ChargeLabour= cc[0].Charge_List_Price_Services__c.setScale(2);
                
                if(cc[0].Budget_Materials_Charge__c!=null)
                    WOWrapper.BudgetMaterials= cc[0].Budget_Materials_Charge__c.setScale(2);
                if(cc[0].Cost_Materials_Total__c!=null)
                    WOWrapper.CostMaterilaTOtal=(cc[0].Cost_Materials_Total__c).setScale(2);
                Decimal chargeulez = 0;
                Decimal chargecollection = 0;
                Decimal calloutfees = 0;
                
                if(cc[0].Charge_Total__c!=null){ 
                    WOWrapper.ChargetNet=cc[0].Charge_Total__c.setScale(2);
                    WOWrapper.vat=(cc[0].Charge_Total__c*0.2).setScale(2);
                    WOWrapper.ChargeGross=(cc[0].Charge_Total__c*1.2).setScale(2);
                    WOWrapper.CHargeDeposit=(cc[0].Charge_Total__c*0.6).setScale(2);
                }
                if(cc[0].Charge_ULEZ__c!=null)
                    chargeulez = cc[0].Charge_ULEZ__c;
                if(cc[0].Charge_Collection_Fee__c!=null)
                    chargecollection = cc[0].Charge_Collection_Fee__c; 
                if(cc[0].Call_Out_Fee__c!=null)
                    calloutfees = cc[0].Call_Out_Fee__c;
                if(cc[0].Charge_Other_Total__c!=null)
                    WOWrapper.other= cc[0].Charge_Other_Total__c.setScale(2);
                
                //  if(cc[0].Fixed_Price_Admin_Fee_2__c!=null)
                //    WOWrapper.other +=cc[0].Fixed_Price_Admin_Fee_2__c;
                if(cc[0].Discount_Value__c!=null)
                    WOWrapper.discountvakue=cc[0].Discount_Value__c.setScale(2);
                if(cc[0].Rate_of_Pay__c!=null)
                    WOWrapper.rateofPay= cc[0].Rate_of_Pay__c; 
                if(cc[0].Cost_Labour__c!=null)
                    WOWrapper.costLaboyur=(cc[0].Cost_Labour__c).setScale(2)    ;
                if(WOWrapper.rateofPay!=0 && cc[0].Charge_List_Price_Services__c!=null)
                    WOWrapper.costLaboyur =  (WOWrapper.costLaboyur+
                                              (cc[0].Charge_List_Price_Services__c*(WOWrapper.rateofPay/100))).setScale(2);
                if(WOWrapper.rateofPay!=0)
                    WOWrapper.disountvalue= (WOWrapper.discountvakue *(WOWrapper.rateofPay/100)).setScale(2);
                else
                    WOWrapper.disountvalue=0; 
                WOWrapper.CCid = cc[0].id;
                
                WOWrapper.nettotal = (WOWrapper.ChargetNet- WOWrapper.costNet).setScale(2);
                if( WOWrapper.nettotal!=0)
                    WOWrapper.netprofit =((WOWrapper.nettotal/ WOWrapper.ChargetNet)*100).setScale(2);
            }
        }
        if(!cc.isEmpty() && cc[0].Job__c !=null)
        {
            List<Job__c>jobs = [SELECT id,Charge_Net__c,Charge_VAT__c,Charge_Gross__c,Charge_Deposit__c,Cost_Labour__c,Cost_Materials_Total__c
                                from Job__c where id =: cc[0].Job__c LIMIT 1];
            if(!jobs.isEmpty())
            {
                WOWrapper.jobId = jobs[0].id;
            }  
        }
        WOWrapper.labourtotal =  (WOWrapper.ChargeLabour - WOWrapper.costLaboyur).setScale(2) ;
        if(WOWrapper.ChargeLabour !=null && WOWrapper.ChargeLabour !=0)
            WOWrapper.labourpercent = ((WOWrapper.labourtotal / WOWrapper.ChargeLabour)*100).setScale(2) ;
        WOWrapper.materialtotal =  (WOWrapper.BudgetMaterials - WOWrapper.CostMaterilaTOtal).setScale(2) ;
        if(WOWrapper.BudgetMaterials!=null && WOWrapper.BudgetMaterials!=0)
            WOWrapper.materialprofit = ((WOWrapper.materialtotal /WOWrapper.BudgetMaterials)*100).setScale(2) ;
        WOWrapper.othertotal =(WOWrapper.other - WOWrapper.costMaterila).setScale(2) ;
        if(WOWrapper.othertotal!=null && WOWrapper.othertotal!=0 &&  WOWrapper.other!=null &&  WOWrapper.other!=0)
            WOWrapper.otherprofit = ((WOWrapper.othertotal / WOWrapper.other)*100).setScale(2);
        WOWrapper.discounttotal = (WOWrapper.discountvakue- WOWrapper.disountvalue).setScale(2);
        if(WOWrapper.discountvakue!=null && WOWrapper.discountvakue!=0)
            WOWrapper.discountprofit = ((WOWrapper.discounttotal/WOWrapper.discountvakue)*100).setScale(2);
        
        return WOWrapper;
    }
    
    @AuraEnabled 
    public static List<String> getProductRequiredProduct()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ProductRequired.Product_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            if (pickListVal.isActive()) 
                pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    public class workOrderWrapper
    {
        @AuraEnabled
        public decimal   ChargeLabour{
            get;set;
        }
        @AuraEnabled
        public decimal ChargeListProce{
            get;set;
        }
        @AuraEnabled
        public decimal costNet
        {
            get;set;
        }
        @AuraEnabled
        public decimal BudgetMaterials
        {
            get;set;
        }
        @AuraEnabled
        public decimal other
        {
            get;set;
        }
        @AuraEnabled
        public decimal ChargeUlez
        {
            get;set;
        }
        @AuraEnabled
        public decimal ChargeCOllectionFees
        {
            get;set;
        }
        @AuraEnabled
        public decimal Calloutfees
        {
            get;set;
        }
        @AuraEnabled
        public decimal discountvakue
        {
            get;set;
        }
        @AuraEnabled
        public decimal ChargetNet
        {
            get;set;
        }
        @AuraEnabled
        public decimal vat
        { 
            get;set;
        }
        @AuraEnabled
        public decimal ChargeGross
        {
            get;set;
        }
        @AuraEnabled
        public decimal CHargeDeposit
        {
            get;set;
        }
        @AuraEnabled
        public decimal costLaboyur
        {
            get;set;
        }
        @AuraEnabled
        public decimal CostMaterilaTOtal
        {
            get;set;
        }
        @AuraEnabled
        public decimal disountvalue
        {
            get;set;
        }
        @AuraEnabled
        public decimal rateofPay
        {
            get;set;
            
        }
        @AuraEnabled
        public decimal labourtotal
        {
            get;set;
        }
        @AuraEnabled
        public decimal labourpercent
        {
            get;set;
        }
        @AuraEnabled
        public decimal materialtotal
        {
            get;set;
        }
        @AuraEnabled
        public decimal materialprofit
        {
            get;set;
        }
        @AuraEnabled
        public decimal othertotal
        {
            get;set;
        }
        @AuraEnabled
        public decimal otherprofit
        {
            get;set;
        }
        @AuraEnabled
        public decimal discounttotal
        {
            get;set;
        }
        @AuraEnabled
        public decimal discountprofit
        {
            get;set;
        }
        @AuraEnabled
        public decimal nettotal
        {
            get;set;
        }
        @AuraEnabled
        public decimal netprofit
        {
            get;set;
        }
        @AuraEnabled
        public decimal costMaterila
        {
            get;set;
        }
        
        @AuraEnabled
        public String CCid
        {
            get;set;
        }
        @AuraEnabled
        public String jobId
        {
            get;set;
        }
        @AuraEnabled
        public String workorderId
        {
            get;set;
        }
        
        public workOrderWrapper(){
            workorderId ='';
            costMaterila =0;
            CCid = jobId ='';
            costNet =0;
            other = ChargeLabour=ChargeListProce=BudgetMaterials=ChargeUlez=ChargeCOllectionFees=Calloutfees=discountvakue=ChargetNet=vat=ChargeGross=CHargeDeposit=costLaboyur=CostMaterilaTOtal=disountvalue=rateofPay=0;
            labourtotal=labourpercent=materialtotal=materialprofit=othertotal=otherprofit=discounttotal=discountprofit=nettotal=netprofit=0;
        }
    }
    @AuraEnabled
    public static List<productRequiredWrapper>markupChangeMethod( List<productRequiredWrapper> ProdRelist)
    {
        List<productRequiredWrapper> prodswraper = new  List<productRequiredWrapper>();
        for(productRequiredWrapper prods :ProdRelist)
        {
            prods.charge =(prods.productrequiredActulacost*prods.quantity) +prods.markup;
            prodswraper.add(prods);
        }
        return prodswraper;
        
    }
    @AuraEnabled
    public static List<productRequiredWrapper> qulaityChangeMethd( List<productRequiredWrapper> prodWrapper)
    {
        List<productRequiredWrapper> prodswraper = new  List<productRequiredWrapper>();
        for(productRequiredWrapper prods :prodWrapper)
        {
            prods.charge = (prods.quantity*prods.cost)+prods.markup;
            prodswraper.add(prods);
        }
        return prodswraper;
    }
    @AuraEnabled
    public static List<productRequiredWrapper>checkboxchange( List<productRequiredWrapper> prodWrapper,String checkline,Boolean chkval)
    {
        List<productRequiredWrapper> prodswraper = new  List<productRequiredWrapper>();
        for(productRequiredWrapper prods :prodWrapper)
        {
            if(prods.ProductREquiredId == checkline){  
                
                if(chkval==true){
                    prods.enableMarkupField = false;
                    prods.overrides=true;}
                else if(chkval ==false)
                {
                    prods.overrides=false;
                    prods.enableMarkupField = true;
                }
            }          
            prodswraper.add(prods);
        }
        return prodswraper;
        
    }
    @AuraEnabled
    public static CCOtherWrapper handloeotherfunction(CCOtherWrapper CCOtherWrapperRecord)
    {
        if(CCOtherWrapperRecord.ccChargeCollecgtionFee!=0 && CCOtherWrapperRecord.ccChargeCollecgtionFee!=null)
            CCOtherWrapperRecord.ccCostCollecgtionFee =(CCOtherWrapperRecord.ccChargeCollecgtionFee)/2;
        else
            CCOtherWrapperRecord.ccCostCollecgtionFee = 0;
        CCOtherWrapperRecord.costUlez=CCOtherWrapperRecord.chargeUlez; 
        if(CCOtherWrapperRecord.cccostOther<=100)
            CCOtherWrapperRecord.ccChargeother =(CCOtherWrapperRecord.cccostOther*0.6)+CCOtherWrapperRecord.cccostOther;
        else  if(CCOtherWrapperRecord.cccostOther>100 && CCOtherWrapperRecord.cccostOther<=1000)
            CCOtherWrapperRecord.ccChargeother =(CCOtherWrapperRecord.cccostOther*0.4)+CCOtherWrapperRecord.cccostOther;
        else  if( CCOtherWrapperRecord.cccostOther>1000)
            CCOtherWrapperRecord.ccChargeother =(CCOtherWrapperRecord.cccostOther*0.35)+CCOtherWrapperRecord.cccostOther;
        CCOtherWrapperRecord.costtotal=CCOtherWrapperRecord.cccostOther +CCOtherWrapperRecord.ccCostCollecgtionFee+CCOtherWrapperRecord.chargeUlez;
        CCOtherWrapperRecord.chargetotal=CCOtherWrapperRecord.fixedpriceadmin+CCOtherWrapperRecord.ccChargeother
            +CCOtherWrapperRecord.ccChargecalloutFee+CCOtherWrapperRecord.ccChargeCollecgtionFee+CCOtherWrapperRecord.chargeUlez;
        return CCOtherWrapperRecord;
    }
    // prod.Is_override__c =prd.overrides;
    @AuraEnabled
    public static List<productRequiredWrapper> getProductRequiredRec(String workorderid){
        List<productRequiredWrapper> prods = new List<productRequiredWrapper>();
        List<ProductRequired> prod =[SELECT id,createdDate,Product2Id,Product_Category__c,Product2.Name,Description__c,Product_Cost__c,Total_Markup_60__c,ParentRecordId,Is_override__c,QuantityRequired,Override_Mark_ups__c,Charge__c from 
                                     ProductRequired where ParentRecordId=:workorderid order by ProductRequiredNumber asc];
        
        if(!prod.isEmpty()){
            for(ProductRequired prd :prod){
                productRequiredWrapper prodWrap = new productRequiredWrapper();
                prodWrap.ProductREquiredId = prd.Id;
                prodWrap.type = prd.Product_Category__c;
                prodWrap.pname = prd.Product2.Name;
                prodWrap.parentid = prd.ParentRecordId ;
                prodWrap.description =prd.Description__c;
                prodWrap.charge = prd.Charge__c;
                prodwrap.overrides =prd.Is_override__c;
                if(prd.Product_Cost__c!=null){
                    prodWrap.cost = prd.Product_Cost__c;
                    prodWrap.costorg = prd.Product_Cost__c;
                    prodWrap.productrequiredActulacost = prd.Product_Cost__c;
                }
                if(prd.Is_override__c == false){
                    if( prodWrap.cost!=null &&  prodWrap.cost<=100 ){
                        prodWrap.markup = 60;
                        prodWrap.markuporg = 60;
                    } else if( prodWrap.cost!=null &&   prodWrap.cost<1000 &&    prodWrap.cost>100){
                        prodWrap.markup = 40;
                        prodWrap.markuporg = 40;
                    } else if( prodWrap.cost!=null &&  prodWrap.cost>=1000 ){
                        prodWrap.markup = 35;
                        prodWrap.markuporg = 35;
                    }
                }else{
                    prodWrap.markup = prd.Override_Mark_ups__c;
                    prodWrap.overrideorg = true;
                }
                // prodWrap.charge = prodWrap.cost + (prodWrap.markup/100);
                prodWrap.quantity = Integer.valueOf(prd.QuantityRequired);
                prodWrap.quantityorg = Integer.valueOf(prd.QuantityRequired);
                if(prodWrap.quantity!=null && prodWrap.cost!=null)
                    prodWrap.totalcost = prodWrap.quantity * prodWrap.cost;
                prods.add(prodWrap);
                /*
if(prodWrap.cost<=100 )
prodWrap.cost = prodWrap.cost*0.6;
else if(prodWrap.cost<1000 && prodWrap.cost>100 )
prodWrap.cost = prodWrap.cost*0.4;
else if(prodWrap.cost>1000 )
prodWrap.cost = prodWrap.cost*0.35;*/
            }
        }
        return prods;
    }
    
    @AuraEnabled
    public static updateSuccess updateJob(List<productRequiredWrapper>prodWrapper,workORderLabourWrapper  workorderWrapperforLabour,
                                          String selectedworktype,CCOtherWrapper CCOtherWrapperRecord ,String recId,
                                          Boolean IdfromWOrkLink, String selectedTrade)
    {
        updateSuccess upd =  Aspect_JobDataHandler.updatejob(prodWrapper,workorderWrapperforLabour,selectedworktype,CCOtherWrapperRecord,
                                                             recId,IdfromWOrkLink,selectedTrade);
        return upd; 
    }
    @AuraEnabled
    public static Boolean checkUserProfile(){
        Boolean isUserProfile = false;
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName=='PHASE 2 Operations Director' || profileName=='PHASE 2 Manager - Ops' || profileName=='PHASE 2 Ops - Sales & Schedule'
           || profileName=='PHASE 2 Manager - Process' || profileName=='Phase 2 Ops - Processing' || profileName=='System Administrator'){
               isUserProfile = true;
           }
        return isUserProfile;
    }
    public class updateSuccess{
        @AuraEnabled
        public String isSuccess{get;set;}
        @AuraEnabled
        public String workorderid{get;set;}
        public updateSuccess(){
            isSuccess=workorderid='';
        }}
    public class productRequiredWrapper{
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String pname{get;set;}
        @AuraEnabled
        public Decimal productrequiredActulacost{get;set;}
        @AuraEnabled
        public String ProductREquiredId{get;set;}
        @AuraEnabled
        public Integer quantity{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public Decimal cost{get;set;}
        @AuraEnabled
        public Decimal totalcost{get;set;}
        @AuraEnabled
        public Decimal markup{get;set;}
        @AuraEnabled
        public Boolean overrides{get;set;}
        @AuraEnabled
        public String parentid{get;set;}
        @AuraEnabled
        public Boolean  enableMarkupField{get;set;}
        @AuraEnabled
        public Boolean  overrideorg{get;set;}
        @AuraEnabled
        public Boolean  overridenew{get;set;}
        @AuraEnabled
        public Decimal charge{get;set;}
        @AuraEnabled
        public Integer quantityorg{get;set;}
        @AuraEnabled
        public Decimal costorg{get;set;}
        @AuraEnabled
        public Decimal markuporg{get;set;}
        public productRequiredWrapper(){
            costorg = markuporg =0;
            quantityorg = 0;
            quantity = 0;totalcost=0;
            parentid ='';
            ProductREquiredId =  description =  type = pname ='';
            cost =  markup = markup  = charge =0;
            overrides = false;
            enableMarkupField = true;
            productrequiredActulacost = 0;
            overrideorg =overridenew=false;
            
        }
        
        
    }
    
    public class CCOtherWrapper{
        @AuraEnabled
        public Decimal chargeUlez{get;set;}
        @AuraEnabled
        public Decimal ccCostCollecgtionFee{get;set;}
        @AuraEnabled
        public Decimal ccChargeCollecgtionFee{get;set;}
        @AuraEnabled
        public Decimal ccChargecalloutFee{get;set;}
        @AuraEnabled
        public Decimal cccostOther{get;set;}
        @AuraEnabled
        public Decimal ccChargeother{get;set;}
        @AuraEnabled
        public Decimal fixedpriceadmin{get;set;}
        @AuraEnabled
        public Decimal costtotal{get;set;}
        @AuraEnabled
        public Decimal costUlez{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public Decimal chargetotal{get;set;}
        public CCOtherWrapper(){
            description = '';
            costUlez = chargeUlez=  ccCostCollecgtionFee=ccChargeCollecgtionFee=ccChargecalloutFee=cccostOther
                =ccChargeother=fixedpriceadmin=costtotal=chargetotal=0;
        }
    }
    public class workORderLabourWrapper{
        @AuraEnabled
        public Decimal r1{get;set;}
        @AuraEnabled
        public String workorderId{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public String otherdescription{get;set;}
        @AuraEnabled
        public Decimal r2{get;set;}
        @AuraEnabled
        public Decimal r3{get;set;}
        @AuraEnabled
        public Decimal listproce{get;set;}
        @AuraEnabled
        public Decimal discount{get;set;}
        @AuraEnabled
        public Decimal  rateofpay{get;set;}
        @AuraEnabled
        public Decimal costr1{get;set;}
        @AuraEnabled
        public Decimal costr2{get;set;}
        @AuraEnabled
        public Decimal costr3{get;set;}
        @AuraEnabled
        public Decimal costlistproce{get;set;}
        @AuraEnabled
        public Decimal costdiscount{get;set;}
        @AuraEnabled
        public Decimal totalcost{get;set;}
        @AuraEnabled
        public Decimal hourrater1{get;set;}
        @AuraEnabled
        public Decimal hourrater2{get;set;}
        @AuraEnabled
        public Decimal hourrater3{get;set;}
        @AuraEnabled
        public Decimal charger1{get;set;}
        @AuraEnabled
        public Decimal charger2{get;set;}
        @AuraEnabled
        public Decimal charger3{get;set;}
        @AuraEnabled
        public Decimal chargelistproce{get;set;}
        @AuraEnabled
        public Decimal chargediscount{get;set;}
        @AuraEnabled
        public Decimal chargetotal{get;set;}
        @AuraEnabled
        public Decimal costMaterila{get;set;}
        
        @AuraEnabled
        public Boolean diablehourrater1{get;set;}
        @AuraEnabled
        public Boolean diablehourrater2{get;set;}
        @AuraEnabled
        public Boolean diablehourrater3{get;set;}
        @AuraEnabled
        public String CCId{get;set;}
        
        public workORderLabourWrapper(){
            costMaterila =0;
            otherdescription =  CCId = description=  workorderId = '';
            diablehourrater3 =  diablehourrater2 = diablehourrater1 = false;
            r1 = r2=r3 =listproce=discount=rateofpay=rateofpay=costr1=costr2=costr3=costlistproce=costdiscount=totalcost=hourrater1=hourrater2=hourrater3=charger1=charger2=charger3=chargelistproce=chargediscount=chargetotal=0;
            
        }
        
        
        
    }
    @AuraEnabled
    public static boolean checkOnSize(List<productRequiredWrapper>ProductRequireds){
        Boolean ischeck = false;
        integer i=0;
        for(productRequiredWrapper prod :ProductRequireds){
            if(prod.ProductREquiredId.length() <=8) {
                i++;
            }  
        }
        if(i!=0 && ProductRequireds.size()==8)
            ischeck=true; 
        return ischeck;
    }
    @AuraEnabled    
    public static integer getrandomnumber(){
        integer randomNumber;
        randomNumber = Integer.valueof((Math.random() * 100));
        Integer start = Datetime.now().millisecond();
        return randomNumber+start;
    }
    
}