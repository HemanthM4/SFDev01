/*

Modification Log:
1) 13/7/2022 - Mofified by Pradeep for Rate Cards and Rate restructure

*/
public class Aspect_JobDataHandler {
    
    public static Aspect_JobDataController.workORderLabourWrapper newWorkCreation(String selectedTrade,Aspect_JobDataController.workORderLabourWrapper workorderWrapperforLabour,
                                                                                  String recID,Boolean isFromnewWO,Boolean isTradeChange)
    {
        workorderWrapperforLabour.charger1 = workorderWrapperforLabour.r1* workorderWrapperforLabour.hourrater1;
        workorderWrapperforLabour.charger2 = workorderWrapperforLabour.r2* workorderWrapperforLabour.hourrater2;
        workorderWrapperforLabour.charger3 = workorderWrapperforLabour.r3* workorderWrapperforLabour.hourrater3;
        workorderWrapperforLabour.chargelistproce = workorderWrapperforLabour.listproce;
        
        Job__c job = [SELECT id,Account__r.Rate_Card__c from Job__c where id=:recID];
        if(isTradeChange==true){
            List<Trade__c> lsttrade =[Select id,Name FROM Trade__c where id =: selectedTrade LIMIT 1];
            System.debug('entered'+lsttrade);
            if(!lsttrade.isEmpty()){
                /*
                List<Rate_Cards__c> rateCards =New List<Rate_Cards__c>();
                rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=:job.Account__c];
                if(rateCards.size()==0)
                    rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name];                                                                                              Set<id>rateIds = new Set<id>();
                for(Rate_Cards__c rate : rateCards)
                {
                    rateIds.add(rate.id);
                }
                System.debug('entered1 '+rateCards);
                if(!rateCards.isEMpty()){
                    Boolean isENtered =false;
                    for(Rate__c rate : [SELECT id ,Rate__c,Percentage__c from Rate__C where Rate_Cards__c =:rateIds and Default_for_estimate__c = true
                                        // AND Rate__c='Tier 1'
                                       ]){
                                           System.debug('entered2 '+rate);
                                           if(rate.Percentage__c<1)
                                               workorderWrapperforLabour.rateofpay =rate.Percentage__c*100;
                                           isENtered =true;
                                       }
                    if(workorderWrapperforLabour.rateofpay==null || isENtered == false)
                    {
                        workorderWrapperforLabour.rateofpay =0;
                    }
                }
                */
                Rate_Card_Trade__c tradeRateCard = new Rate_Card_Trade__c();
                String defaultForEstimate = '';
                Boolean isENtered =false;
                
                tradeRateCard = [SELECT Id,Pay_Tier_1__c,Pay_Tier_2__c,Pay_Tier_3__c,Pay_Tier_4__c,Pay_Tier_5__c,
                                 Pay_Tier_6__c,Pay_Tier_7__c,Pay_Tier_8__c,Pay_Tier_9__c,Pay_Tier_10__c, 
                                 Default_For_Estimate__c FROM Rate_Card_Trade__c
                                 WHERE Trade__c =: lsttrade[0].Id AND Rate_Card__c =: job.Account__r.Rate_Card__c
                                 AND Default_For_Estimate__c != null LIMIT 1];
                
                if(tradeRateCard == null){
                    tradeRateCard = [SELECT Id,Pay_Tier_1__c,Pay_Tier_2__c,Pay_Tier_3__c,Pay_Tier_4__c,Pay_Tier_5__c,
                                     Pay_Tier_6__c,Pay_Tier_7__c,Pay_Tier_8__c,Pay_Tier_9__c,Pay_Tier_10__c, 
                                     Default_For_Estimate__c FROM Rate_Card_Trade__c
                                     WHERE Trade__c =: lsttrade[0].Id AND Rate_Card__r.Standard__c = TRUE 
                                     AND Default_For_Estimate__c != null LIMIT 1];
                }
                defaultForEstimate = tradeRateCard.Default_For_Estimate__c;
                System.debug('defaultForEstimate '+defaultForEstimate);
                if(defaultForEstimate.contains('Tier 1') && tradeRateCard.Pay_Tier_1__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_1__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 2') && tradeRateCard.Pay_Tier_2__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_2__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 3') && tradeRateCard.Pay_Tier_3__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_3__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 4') && tradeRateCard.Pay_Tier_4__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_4__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 5') && tradeRateCard.Pay_Tier_5__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_5__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 6') && tradeRateCard.Pay_Tier_6__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_6__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 7') && tradeRateCard.Pay_Tier_7__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_7__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 8') && tradeRateCard.Pay_Tier_8__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_8__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 9') && tradeRateCard.Pay_Tier_9__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_9__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 10') && tradeRateCard.Pay_Tier_10__c < 100){
                    workorderWrapperforLabour.rateofpay = tradeRateCard.Pay_Tier_10__c;
                    isENtered = true;
                }
                if(tradeRateCard != null){
                    if(workorderWrapperforLabour.rateofpay == null || isENtered == false)
                    {
                        workorderWrapperforLabour.rateofpay = 0;
                    }
                }
                else{
                    workorderWrapperforLabour.rateofpay = 0;
                }
            }
            else{
                workorderWrapperforLabour.rateofpay =0;
            }
        }
        system.debug(workorderWrapperforLabour.rateofpay);
        workorderWrapperforLabour.costlistproce = workorderWrapperforLabour.listproce*(workorderWrapperforLabour.rateofpay/100);
        
        if(workorderWrapperforLabour.rateofpay!=null)
            workorderWrapperforLabour.costr1 = workorderWrapperforLabour.charger1*(workorderWrapperforLabour.rateofpay/100);
        if(workorderWrapperforLabour.rateofpay!=null)
            workorderWrapperforLabour.costr2 = workorderWrapperforLabour.charger2*(workorderWrapperforLabour.rateofpay/100);
        if(workorderWrapperforLabour.rateofpay!=null)
            workorderWrapperforLabour.costr3 = workorderWrapperforLabour.charger3*(workorderWrapperforLabour.rateofpay/100);
        //  if(workorderWrapperforLabour.rateofpay!=null)
        //  	workorderWrapperforLabour.costlistproce = workorderWrapperforLabour.listproce*(workorderWrapperforLabour.rateofpay/100);
        workorderWrapperforLabour.chargediscount = ( workorderWrapperforLabour.charger1 + workorderWrapperforLabour.charger2
                                                    + workorderWrapperforLabour.charger3+
                                                    workorderWrapperforLabour.chargelistproce)*( workorderWrapperforLabour.discount/100);
        workorderWrapperforLabour.costdiscount =(workorderWrapperforLabour.costr1+workorderWrapperforLabour.costr2+workorderWrapperforLabour.costr3
                                                 +workorderWrapperforLabour.costlistproce)*(workorderWrapperforLabour.discount/100);
        
        workorderWrapperforLabour.chargetotal = (workorderWrapperforLabour.charger1 +workorderWrapperforLabour.charger2
                                                 +workorderWrapperforLabour.charger3+ workorderWrapperforLabour.chargelistproce)- workorderWrapperforLabour.chargediscount ;
        if(workorderWrapperforLabour.costdiscount>=0){
            workorderWrapperforLabour.totalcost =  workorderWrapperforLabour.costr1 + workorderWrapperforLabour.costr2+ workorderWrapperforLabour.costr3+workorderWrapperforLabour.costlistproce-  workorderWrapperforLabour.costdiscount;
        }
        else{
            workorderWrapperforLabour.totalcost =  workorderWrapperforLabour.costr1 + workorderWrapperforLabour.costr2+ workorderWrapperforLabour.costr3+workorderWrapperforLabour.costlistproce+  workorderWrapperforLabour.costdiscount;
        }
        
        system.debug(workorderWrapperforLabour.rateofpay);
        List<Trade__c> lsttrade1 =[Select id,Name FROM Trade__c where id=:selectedTrade];
        if(!lsttrade1.isEmpty()){
            /*
            Job__c job1 = [SELECT id,Account__c from Job__c where id=:recID];
            List<Rate_Cards__c> rateCards =New List<Rate_Cards__c>();
            rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade1[0].Name AND Account__c=:job1.Account__c];
            if(rateCards.size()==0)
                rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade1[0].Name];
            Set<id> rateIds = new Set<id>();
            for(Rate_Cards__c rate  :rateCards)
            {
                rateIds.add(rate.id);
            }
            for(Rate__c rate : [SELECT id ,Rate__c,Amount__c from Rate__C
                                where Rate_Cards__c =:rateIds ])
            {
                 if(rate.Rate__c =='R1' &&  rate.Amount__c!=null)
					workorderWrapperforLabour.hourrater1 =  rate.Amount__c;
				else if(rate.Rate__c =='R2' &&  rate.Amount__c!=null)			 
					workorderWrapperforLabour.hourrater2 =  rate.Amount__c;
				else  if(rate.Rate__c =='R3' &&  rate.Amount__c!=null)			  
					workorderWrapperforLabour.hourrater3 = rate.Amount__c;
            }
            */
            workorderWrapperforLabour.charger1 = workorderWrapperforLabour.r1* workorderWrapperforLabour.hourrater1;
            workorderWrapperforLabour.charger2 = workorderWrapperforLabour.r2* workorderWrapperforLabour.hourrater2;
            workorderWrapperforLabour.charger3 = workorderWrapperforLabour.r3* workorderWrapperforLabour.hourrater3;
            if(workorderWrapperforLabour.rateofpay!=null)
                workorderWrapperforLabour.costr1 = workorderWrapperforLabour.charger1*(workorderWrapperforLabour.rateofpay/100);
            if(workorderWrapperforLabour.rateofpay!=null)
                workorderWrapperforLabour.costr2 = workorderWrapperforLabour.charger2*(workorderWrapperforLabour.rateofpay/100);
            if(workorderWrapperforLabour.rateofpay!=null)
                workorderWrapperforLabour.costr3 = workorderWrapperforLabour.charger3*(workorderWrapperforLabour.rateofpay/100);
            system.debug(workorderWrapperforLabour.rateofpay);
            if(workorderWrapperforLabour.rateofpay!=null)
                workorderWrapperforLabour.costlistproce = workorderWrapperforLabour.listproce*(workorderWrapperforLabour.rateofpay/100);
            workorderWrapperforLabour.chargediscount = ( workorderWrapperforLabour.charger1 + workorderWrapperforLabour.charger2
                                                        + workorderWrapperforLabour.charger3+ workorderWrapperforLabour.chargelistproce)*( workorderWrapperforLabour.discount/100);
            workorderWrapperforLabour.costdiscount =(workorderWrapperforLabour.costr1+workorderWrapperforLabour.costr3+workorderWrapperforLabour.costr2+  workorderWrapperforLabour.costlistproce)*( workorderWrapperforLabour.discount/100);
            
            // workorderWrapperforLabour.costlistproce =  workorderWrapperforLabour.listproce*(workorderWrapperforLabour.rateofpay/100);
            workorderWrapperforLabour.chargetotal = (workorderWrapperforLabour.charger1 +workorderWrapperforLabour.charger2+workorderWrapperforLabour.charger3
                                                     + workorderWrapperforLabour.chargelistproce)- workorderWrapperforLabour.chargediscount ;
            if(workorderWrapperforLabour.chargediscount>=0){
                workorderWrapperforLabour.totalcost =  workorderWrapperforLabour.costr1 + workorderWrapperforLabour.costr2+ workorderWrapperforLabour.costr3+workorderWrapperforLabour.costlistproce-  workorderWrapperforLabour.costdiscount;
            }
            else{
                workorderWrapperforLabour.totalcost =  workorderWrapperforLabour.costr1 + workorderWrapperforLabour.costr2+ workorderWrapperforLabour.costr3+workorderWrapperforLabour.costlistproce+  workorderWrapperforLabour.costdiscount;
            }
            system.debug(workorderWrapperforLabour.rateofpay);
        }
        return workorderWrapperforLabour;
    }
    
    public static Aspect_JobDataController.workORderLabourWrapper updateWorkOrder(String selectedTrade,Aspect_JobDataController.workORderLabourWrapper workorder,
                                                                                 String recID,Boolean isFromnewWO,Boolean isTradeChange)
    {
        List<Trade__c> lsttrade =[Select id,Name FROM Trade__c where id=:selectedTrade];
        
        if(isTradeChange==true){
            if(!lsttrade.isEmpty()){
                Job__c jobs = [SELECT id,Account__r.Rate_Card__c from Job__c where id=:recID];
				/*
                List<Rate_Cards__c> rateCards =New List<Rate_Cards__c>();
                rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=:jobs.Account__c];
                if(rateCards.size()==0)
                    rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name];
                Set<id>rateIds = new Set<id>();
                for(Rate_Cards__c rate : rateCards)
                {
                    rateIds.add(rate.id);
                }
                System.debug('entered1 '+rateCards);
                if(!rateCards.isEMpty()){
                    Boolean isENtered =false;
                    for(Rate__c rate : [SELECT id ,Rate__c,Percentage__c from Rate__C where Rate_Cards__c =:rateIds
                                        and Default_for_estimate__c = true
                                        // AND Rate__c='Tier 1'
                                       ]){
                                           System.debug('entered2 '+rate);
                                           if(rate.Percentage__c<1)
                                               workorder.rateofpay =rate.Percentage__c*100;
                                           isENtered = true;
                                       }
                    if(workorder.rateofpay==null || isENtered == false)
                    {
                        workorder.rateofpay =0;
                    }
                } */
                Rate_Card_Trade__c tradeRateCard = new Rate_Card_Trade__c();
                String defaultForEstimate = '';
                Boolean isENtered =false;
                
                tradeRateCard = [SELECT Id,Pay_Tier_1__c,Pay_Tier_2__c,Pay_Tier_3__c,Pay_Tier_4__c,Pay_Tier_5__c,
                                 Pay_Tier_6__c,Pay_Tier_7__c,Pay_Tier_8__c,Pay_Tier_9__c,Pay_Tier_10__c, 
                                 Default_For_Estimate__c FROM Rate_Card_Trade__c
                                 WHERE Trade__c =: lsttrade[0].Id AND Rate_Card__c =: jobs.Account__r.Rate_Card__c
                                 AND Default_For_Estimate__c != null LIMIT 1];
                if(tradeRateCard == null){
                    tradeRateCard = [SELECT Id,Pay_Tier_1__c,Pay_Tier_2__c,Pay_Tier_3__c,Pay_Tier_4__c,Pay_Tier_5__c,
                                 	 Pay_Tier_6__c,Pay_Tier_7__c,Pay_Tier_8__c,Pay_Tier_9__c,Pay_Tier_10__c, 
                                 	 Default_For_Estimate__c FROM Rate_Card_Trade__c
                                     WHERE Rate_Card__r.Standard__c = TRUE AND Default_For_Estimate__c != null LIMIT 1];
                }
                defaultForEstimate = tradeRateCard.Default_For_Estimate__c;
                System.debug('defaultForEstimate '+defaultForEstimate);
                if(defaultForEstimate.contains('Tier 1') && tradeRateCard.Pay_Tier_1__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_1__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 2') && tradeRateCard.Pay_Tier_2__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_2__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 3') && tradeRateCard.Pay_Tier_3__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_3__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 4') && tradeRateCard.Pay_Tier_4__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_4__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 5') && tradeRateCard.Pay_Tier_5__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_5__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 6') && tradeRateCard.Pay_Tier_6__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_6__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 7') && tradeRateCard.Pay_Tier_7__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_7__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 8') && tradeRateCard.Pay_Tier_8__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_8__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 9') && tradeRateCard.Pay_Tier_9__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_9__c;
                    isENtered = true;
                }
                else if(defaultForEstimate.contains('Tier 10') && tradeRateCard.Pay_Tier_10__c < 100){
                    workorder.rateofpay = tradeRateCard.Pay_Tier_10__c;
                    isENtered = true;
                }
                if(tradeRateCard != null){
                    if(workorder.rateofpay==null || isENtered == false)
                    {
                        workorder.rateofpay =0;
                    }
                }
                else
                {
                    workorder.rateofpay =0;
                }
            }
            else
            {
                workorder.rateofpay =0;
            }
        }
        if(!lsttrade.isEmpty()){
            /*
            Job__c job = [SELECT id,Account__c from Job__c where id=:recID];
            List<Rate_Cards__c> rateCards =New List<Rate_Cards__c>();
            rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name AND Account__c=:job.Account__c];
            if(rateCards.size()==0)
                rateCards = [SELECT id from Rate_Cards__c where Trade__c =:lsttrade[0].Name];                                                                                          
            
            if(!rateCards.isEmpty())
            {
                for(Rate__c rate : [SELECT id ,Rate__c,Amount__c from Rate__C where Rate_Cards__c =:rateCards[0].id ]){
                    
                       if(rate.Rate__c =='R1' &&  rate.Amount__c!=null)
						workorder.hourrater1 =  rate.Amount__c;
						else if(rate.Rate__c =='R2' &&  rate.Amount__c!=null)			 
						workorder.hourrater2 =  rate.Amount__c;
						else  if(rate.Rate__c =='R3' &&  rate.Amount__c!=null)			  
						workorder.hourrater3 = rate.Amount__c;
                }
                
            }*/
            workorder.charger1 = workorder.r1* workorder.hourrater1;
            workorder.charger2 = workorder.r2* workorder.hourrater2;
            workorder.charger3 = workorder.r3* workorder.hourrater3;
            workorder.chargelistproce = workorder.listproce;
            if(workorder.rateofpay!=null)
                workorder.costr1 = workorder.charger1*(workorder.rateofpay/100);
            if(workorder.rateofpay!=null)
                workorder.costr2 = workorder.charger2*(workorder.rateofpay/100);
            if(workorder.rateofpay!=null)
                workorder.costr3 = workorder.charger3*(workorder.rateofpay/100);
            if(workorder.rateofpay!=null)
                workorder.costlistproce =  workorder.chargelistproce*(workorder.rateofpay/100);
            workorder.chargediscount = ( workorder.charger1 + workorder.charger2
                                        + workorder.charger3+ workorder.chargelistproce)
                *( workorder.discount/100);
            workorder.costdiscount =(workorder.costr1+workorder.costr2+workorder.costr3+workorder.costlistproce) *(workorder.discount/100);
            
            workorder.chargetotal = (workorder.charger1 +workorder.charger2+workorder.charger3+ workorder.chargelistproce)- workorder.chargediscount ;
            if(workorder.costdiscount>=0)
            {
                workorder.totalcost =  (workorder.costr1 + workorder.costr2+ workorder.costr3+
                                        workorder.costlistproce)-workorder.costdiscount;
            }
            else
            {
                workorder.totalcost =  workorder.costr1 + workorder.costr2+ workorder.costr3+
                    workorder.costlistproce+workorder.costdiscount;
            }
            
            
        }
        return workorder;
        
    }
    
    public static string getAccountRate(String rctId, String tradeId){
        
        String tradeRateId = '';
        List<Rate_Card_Trade__c> rctRec = [SELECT Id FROM Rate_Card_Trade__c WHERE Trade__c =: tradeId AND Rate_Card__c =: rctId LIMIT 1];
        if(rctRec != null){
            tradeRateId = rctRec[0].Id;
        }
        return tradeRateId;
    }
    
    public static string getStandardRate(String tradeId){
        
        String tradeRateId = '';
        List<Rate_Card_Trade__c> rctRec = [SELECT Id FROM Rate_Card_Trade__c WHERE Trade__c =: tradeId AND Rate_Card__r.Standard__c = TRUE LIMIT 1];
        
        if(rctRec != null){
            tradeRateId = rctRec[0].id;
        }
        System.debug('tradeRateId'+tradeRateId);
        return tradeRateId;
    }
    
    public static Aspect_JobDataController.updateSuccess updatejob(List<Aspect_JobDataController.productRequiredWrapper>prodWrapper,
                                                                   Aspect_JobDataController.workORderLabourWrapper  workorderWrapperforLabour,
                                                                   String selectedworktype,
                                                                   Aspect_JobDataController.CCOtherWrapper CCOtherWrapperRecord ,
                                                                   String recId,Boolean IdfromWOrkLink,String selectedTrade)
    {
        Aspect_JobDataController.updateSuccess upd = new Aspect_JobDataController.updateSuccess();
        upd.isSuccess ='Yes';
        //  Id devRecordTypeId = Schema.SObjectType.Costs_and_Charges__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        String isSucess ='Success';
        List<worktype> lsttrade = new List<worktype>();
        if(selectedworktype!=null)
            lsttrade =[Select id,Name FROM worktype  where id =:selectedworktype];
        Costs_and_Charges__c cc=  new Costs_and_Charges__c();
        if(workorderWrapperforLabour.CCid!=''){ 
            cc.id = workorderWrapperforLabour.CCid;
        }else 
        {
            cc.Record_Type__c ='F';
        }
        
        /*  chargeUlez
ccChargeCollecgtionFee
ccCostCollecgtionFee
cccostOther
ccChargeother*/
        cc.Charge_List_Price_Services__c = workorderWrapperforLabour.chargelistproce;
        cc.Hourly_Charge_R3__c = workorderWrapperforLabour.hourrater3;
        cc.Hourly_Charge_R2__c = workorderWrapperforLabour.hourrater2;
        cc.Hourly_Charge_R1__c = workorderWrapperforLabour.hourrater1;
        cc.Rate_of_Pay__c = workorderWrapperforLabour.rateofpay;
        cc.Discount_Manual_Percentage__c = workorderWrapperforLabour.discount;
        cc.Charge_List_Price_Services__c = workorderWrapperforLabour.listproce;
        cc.Chargeable_Duration_R3__c = workorderWrapperforLabour.r3;
        cc.Chargeable_Duration_R2__c = workorderWrapperforLabour.r2;
        cc.description__c = workorderWrapperforLabour.description;
        if(IdfromWOrkLink == false)
            cc.Job__c =recId;
        cc.Chargeable_Duration_R1__c = workorderWrapperforLabour.r1;
        cc.Charge_ULEZ__c=CCOtherWrapperRecord.chargeUlez ;
        cc.Cost_Collection_Fee__c	 = CCOtherWrapperRecord.ccCostCollecgtionFee ;
        cc.Charge_Collection_Fee__c=CCOtherWrapperRecord.ccChargeCollecgtionFee ;
        cc.Cost_Other_Item__c	=CCOtherWrapperRecord.cccostOther ;
        cc.Fixed_Price_Admin_Fee_2__c=CCOtherWrapperRecord.fixedpriceadmin ;
        cc.Charge_Other_Item__c	= CCOtherWrapperRecord.ccChargeother;
        // cc.Description__c = CCOtherWrapperRecord.description;
        try{
            upsert cc;
        }catch(Exception ex){
            isSucess=ex.getMessage();
            upd.isSuccess =ex.getMessage();
        }
        WorkOrder Wo = new WOrkOrder();
        SYstem.debug('workorderWrapperforLabour.workorderId'+workorderWrapperforLabour.workorderId);
        if(workorderWrapperforLabour.workorderId!=''){
            Wo.id=  workorderWrapperforLabour.workorderId;		
        }else{
            Id devRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Fixed Price').getRecordTypeId();
            
            List<JOb__c> job =[SELECT id,Job_Raised_by__c,Site__c,Site__r.Site_City__c,
                               Site__r.Site_State__c,Site__r.Site_Country__c,
                               Site__r.Site_Street__c,Site__r.Site_PostalCode__c,
                               Account__c, Account__r.Rate_Card__c from JOb__c  where Id=:recId];
            if(!job.isEmpty()){
                if(job[0].Job_Raised_by__c!=null)
                    Wo.ContactId = job[0].Job_Raised_by__c;
                if(job[0].Site__c!=null)
                    Wo.Site__c = job[0].Site__c;
                if(job[0].Account__c!=null)
                    Wo.AccountId = job[0].Account__c;
                if(job[0].Site__r.Site_City__c!='')
                    Wo.City =job[0].Site__r.Site_City__c;
                if(job[0].Site__r.Site_State__c!='')
                    Wo.State =job[0].Site__r.Site_State__c;
                if(job[0].Site__r.Site_Street__c!='')
                    Wo.Street =job[0].Site__r.Site_Street__c;
                if(job[0].Site__r.Site_PostalCode__c!='')
                    Wo.PostalCode =job[0].Site__r.Site_PostalCode__c;
                if(job[0].Site__r.Site_Country__c!='')
                    Wo.Country=job[0].Site__r.Site_Country__c;
                System.debug('accountRateCard -- '+job[0].Account__r.Rate_Card__c);
                System.debug('selectedTrade -- '+selectedTrade);
               // Trade__c  trad =  [SELECT id , Name from Trade__c where id=:selectedTrade];
                String accountRate = getAccountRate(job[0].Account__r.Rate_Card__c,selectedTrade);
                String StandardRate = getStandardRate(selectedTrade);
                System.debug('accountRate --- '+accountRate);
                System.debug('StandardRate --- '+StandardRate);
                String rateCardId =accountRate!=null ?accountRate:StandardRate;
                //Wo.rate_card_id__c = rateCardId;
                wo.Trade_Rate__c = rateCardId;
            }
            Wo.Costs_and_Charges__c =  cc.id;
            Wo.Job__c =  recId;
            Wo.RecordTypeId =  devRecordTypeId;
        }
        Wo.Rate_Of_Pay_Percent__c	 = 		 workorderWrapperforLabour.rateofpay;							   
        Wo.Scope_of_Works_Amended_by_Operative__c	 =  workorderWrapperforLabour.description; 
        Wo.Other_Charges_Description__c	 = workorderWrapperforLabour.otherdescription;
        //  Wo.Description	 = CCOtherWrapperRecord.description;
        if(!lsttrade.isEmpty())
            Wo.WorkTypeId = lsttrade[0].id; 
        try{
            System.debug('Wo'+Wo);
            upsert Wo;
            upd.workorderid = Wo.id;
        }catch(Exception ex){
            isSucess= ex.getMessage();
            upd.isSuccess =ex.getMessage();
        }
        List<ProductRequired> prods =  new List<ProductRequired>();
        SET<String> setchk =NEW SET<String>();
        for(Aspect_JobDataController.productRequiredWrapper prd :prodWrapper){
            ProductRequired prod =  new ProductRequired();
            if(prd.ProductREquiredId!='' &&  !prd.ProductREquiredId.contains('|'))               
                prod.Id = 	prd.ProductREquiredId;
            if(prd.type!=null && prd.type!='')
            {   
                SET<String> Proreqname = New SET<String>();
                Map<String,ProductRequired> Prod2MAP =New Map<String,ProductRequired>();
                List<ProductRequired> prdlst =[SELECT id,Product2Id,Product_Category__c,Product2.Name,Full_Description__c,Product_Cost__c,Total_Markup_60__c,ParentRecordId,Is_override__c,QuantityRequired,Override_Mark_ups__c,Charge__c from 
                                               ProductRequired where ParentRecordId=:Wo.id];
                for(ProductRequired preq2 : prdlst)
                {
                    Prod2MAP.put(preq2.Product2.Name,preq2);
                    Proreqname.add(preq2.Product2.Name.touppercase());
                }
                system.debug('#Prod2MAP#'+Prod2MAP);
                
                prod.Product_Category__c =prd.type;
                if(Prod2MAP.containsKey(prd.pname) && prd.ProductREquiredId!='' &&  !prd.ProductREquiredId.contains('|'))
                    prod.Product2Id = Prod2MAP.get(prd.pname).Product2Id;
                else
                { 
                    SET<String> ProName = New SET<String>{'Purchase Order','Van Stock','Scaffolding','Subcontractor','Hire'};
                        system.debug('<##>'+Proreqname+'<#PNAMe#>'+prd.type.touppercase());
                    system.debug('<#PRO#>'+ProName.contains(prd.type)+'<#PRE#>'+Proreqname.contains(prd.type.touppercase()));
                    if((setchk==null || setchk<>null && !setchk.contains(prd.type)) && ProName.contains(prd.type) && !Proreqname.contains(prd.type.touppercase())){
                        System.debug('prd.type -------------------->'+prd.type);
                        List<Product2> prod2 =[Select id FROM Product2 where name=:prd.type limit 1];
                        prod.Product2Id =prod2[0].id;
                        setchk.add(prd.type);
                    }else{
                        Integer randomNumber = Integer.valueof((Math.random() * 100));
                        System.debug('randomNumber is'+randomNumber);
                        datetime dat = system.Now();
                        createupdateprod(prd.type+dat+randomNumber);
                        prod.Product_MapName__c =prd.type+dat+randomNumber;
                        system.debug('<#PRODUCT#>'+prod.Product2Id);
                    }
                }
            }if(prd.parentid=='')
                prod.ParentRecordId = Wo.id;
            prod.Product_Cost__c = 	prd.cost;
            prod.QuantityRequired = 	Decimal.valueOf(prd.quantity);
            prod.Full_Description__c = prd.description;
            prod.Override_Mark_ups__c = prd.markup;
            prod.Is_override__c =prd.overrides;
            prod.Charge__c =prd.charge;
            //prod.Total_Markup_60__c = 	prd.markup;
            if(prd.type!=null && prd.type!='')
                prods.add(prod);
        }
        if(!prods.isEmpty()){
            try{
                system.debug('<prods>'+prods);
                for(ProductRequired PR:prods)
                {
                    if(PR.Product_MapName__c!=null)
                    {
                        List<Product2> prod2 =[Select id FROM Product2 where name=:PR.Product_MapName__c limit 1];
                        if(prod2.size()>0)
                        {
                            PR.Product2Id = prod2[0].id;   
                        }
                    }
                }
                upsert prods;
            }
            catch(Exception ex){
                isSucess = ex.getMessage();
                upd.isSuccess =ex.getMessage();
            }
            
        }
        return upd;
    }
    
    @AuraEnabled    
    public static string createupdateprod(String Prd2Name) {
        string ProId='';
        Product2 prod =new Product2();
        prod.Name = Prd2Name;
        prod.CurrencyIsoCode='GBP';
        prod.isactive=true;
        insert prod;
        ProId=prod.id;
        return ProId;            
    }
}