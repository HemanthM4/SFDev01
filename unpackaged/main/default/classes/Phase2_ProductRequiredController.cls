public class Phase2_ProductRequiredController {
    
    Set<String> exclude_IdSet = new Set<String>();
    
    public void Phase2_ProductRequiredController(){}
    
    public void PREQ_created_edited(List<ProductRequired> preqList){
        //System.debug(' entered PREQ Created edited ');
        updateCCT(preqList);
    }
    
    public void PREQ_deleted(List<ProductRequired> oldPreqRecList){
        //System.debug(' entered preq deleted ');
        //System.debug(' entered preq deleted this exclude idset-->'+this.exclude_IdSet);
        for(ProductRequired rec: oldPreqRecList){
            this.exclude_IdSet.add(rec.id);
        }
        //System.debug(' entered preq deleted this exclude idset 1 -->'+this.exclude_IdSet);
        updateCCT(oldPreqRecList);
    }
    
    public void updateCCT(List<ProductRequired> preqRecList){
        //System.debug(' entered updateCCT-->'+preqRecList);
        //System.debug(' entered updateCCT size-->'+preqRecList.size());
        //System.debug(' entered updateCCT index 0-->'+preqRecList[0]);
        
        
        Set<Id> parentIdSet = new Set<Id>();
        Set<Id> workOrdertIdSet = new Set<Id>();
        Set<Id> costAndChargesIdSet = new Set<Id>();
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        Map<Id, Costs_and_Charges__c> costChagesMap = new Map<Id, Costs_and_Charges__c>();
        Map<Id, Id> ccWORecIdMap = new Map<Id, Id>();
        Map<Id, List<ProductRequired>> woIdAndProdReqRecMap = new Map<Id, List<ProductRequired>>();
        List<Costs_and_Charges__c> ccListToUpdate = new List<Costs_and_Charges__c>();
        List<WorkOrder> woListToUpdate = new List<WorkOrder>();
        
        for(ProductRequired prodReqRec: preqRecList){
            parentIdSet.add(prodReqRec.ParentRecordId);
        }
        //System.debug(' entered updateCCT  parentIdSet-->'+parentIdSet);
        List<WorkOrder> woList = [SELECT Id, Costs_and_Charges__c, Sum_of_WO_PO_Product_Required__c, 
                                  Sum_of_WO_Scaffolding_Product_Required__c, Sum_of_WO_Van_Stock_Product_Required__c
                                  FROM WorkOrder WHERE Id IN: parentIdSet];
        //System.debug( ' entered updateCCT woList-->'+WoList);
        //SYstem.debug(' entered udpateCCT woList index 0 -->'+WoList[0]);
        
        system.debug('Size of woList - ' +woList.size());
        for(WorkOrder woRec : woList){
            //System.debug(' entered updateCCT woRec iteration entered');
            workOrdertIdSet.add(woRec.Id);
            costAndChargesIdSet.add(woRec.Costs_and_Charges__c);
            workOrderMap.put(woRec.Id, woRec);
            ccWORecIdMap.put(woRec.Id, woRec.Costs_and_Charges__c);
        }
        //SYstem.debug('workOrderIdSet-->'+WOrkOrdertIdSet);
        //SYstem.debug(' costAndChargesIdSet-->'+ costAndChargesIdSet);
        //SYstem.debug('workOrderMap-->'+workOrderMap);
        //System.debug('ccWORecIdMap-->'+ccWORecIdMap);
        List<Costs_and_Charges__c> cctList = [SELECT Id, Charge_Total_PO_Product_Required__c, 
                                              Charge_Total_Scaffold_Product_Required__c, 
                                              Charge_Total_Van_Stock_Product_Required__c,
                                              Cost_Total_Scaffold_Product_Required__c,
                                              Cost_Total_Van_Stock_Product_Required__c,
                                              Cost_Total_PO_Product_Required__c FROM Costs_and_Charges__c
                                              WHERE Id IN: costAndChargesIdSet];
        //system.debug('Size of cctList - ' +cctList.size());
        //SYstem.debug(' cctList -->'+cctLIst);
        //SYstem.debug( ' ccList index-->'+cctList[0]);
        for(Costs_and_Charges__c ccRec: cctList){
            costChagesMap.put(ccRec.Id, ccRec);
        }
        //System.debug('costChangesMap-->'+costChagesMap);
        //SYstem.debug('costChangesMap keySet()-->'+costChagesMap.keySet());
        //SYstem.debug('costChangesMap values-->'+costChagesMap.values());
        List<ProductRequired> preqList = [SELECT Id, Total_Costs__c, Total_Markup_60__c,
                                          Product2Id, Product_Category__c, ParentRecordId FROM ProductRequired 
                                          WHERE ParentRecordId IN: workOrdertIdSet AND Id NOT IN: exclude_IdSet];
        //system.debug('Size of preqList - ' +preqList.size());
        //System.debug(' predList'+preqlist[0]);
        for(ProductRequired prRec: preqList){
            //System.debug('prRec-->'+prRec);
            if(woIdAndProdReqRecMap.containsKey(prRec.ParentRecordId)){
                List<ProductRequired> peRecList = new List<ProductRequired>();
                peRecList = woIdAndProdReqRecMap.get(prRec.ParentRecordId);
                peRecList.add(prRec);
                woIdAndProdReqRecMap.put(prRec.ParentRecordId, peRecList);
                //System.debug('prRec.parentRecordId-->'+prRec.parentRecordId);
                //SYstem.debug('peRecList-->'+peReclist);
            }else{
                woIdAndProdReqRecMap.put(prRec.ParentRecordId, new List<ProductRequired>{prRec});
                //System.debug('prRec.parentRecordId else -->'+prRec.parentRecordId);
                //SYstem.debug('peRecList else-->'+prRec);
            }
        }
        
        for(Id parRecId : woIdAndProdReqRecMap.keySet())
        {
            decimal charge_po = 0, charge_van = 0, charge_scaf = 0;
            decimal cost_po = 0, cost_van = 0, cost_scaf = 0;
            //system.debug('Value of parRecId --- '+parRecId);
            //SYstem.debug(' values '+woIdAndProdReqRecMap.get(parRecId));
            if(woIdAndProdReqRecMap.containsKey(parRecId)){
                List<ProductRequired> prodReqRecList = woIdAndProdReqRecMap.get(parRecId);
                //SYstem.debug(' prodReqRecList-->'+prodReqRecList);
                //SYstem.debug(' prodReqRecList- index 0 ->'+prodReqRecList[0]);
                for(ProductRequired prodReqRec: prodReqRecList)
                {
                    //System.debug('prodReqRec-->'+prodReqRec);
                    string prod_id = prodReqRec.Product_Category__c;
                    system.debug('prod_id --- '+prod_id);
                    switch on prod_id
                    {
                        when 'Van Stock'
                        {
                            //van stock
                            if(prodReqRec.Total_Costs__c != null)// Added for Null Point Exception
                            {
                                //System.debug('cost_van-->'+cost_van);
                                //System.debug('prodReqRec.Total_Costs__c--->'+prodReqRec.Total_Costs__c);
                                cost_van += prodReqRec.Total_Costs__c;
                                //System.debug('cost_van after-->'+cost_van);
                                //System.debug('prodReqRec.Total_Costs__c after--->'+prodReqRec.Total_Costs__c);
                                
                            }
                            if(prodReqRec.Total_Markup_60__c != null)// Added for Null Point Exception
                            {
                                //System.debug('charge_van-->'+charge_van);
                                //System.debug('prodReqRec.Total_Markup_60__c--->'+prodReqRec.Total_Markup_60__c);
                                charge_van += prodReqRec.Total_Markup_60__c;
                                //System.debug('charge_van after-->'+charge_van);
                                //System.debug('prodReqRec.Total_Markup_60__c--->'+prodReqRec.Total_Markup_60__c);
                            }
                        }
                        when 'Purchase Order'
                        {
                            if(prodReqRec.Total_Costs__c != null)// Added for Null Point Exception
                            {
                                //System.debug('cost_po-->'+cost_po);
                                //System.debug('prodReqRec.Total_Costs__c--->'+prodReqRec.Total_Costs__c);
                                cost_po += prodReqRec.Total_Costs__c;
                                //System.debug('cost_po after-->'+cost_po);
                                //  System.debug('prodReqRec.Total_Markup_60__c--->'+prodReqRec.Total_Markup_60__c);
                            }
                            if(prodReqRec.Total_Markup_60__c != null)// Added for Null Point Exception
                            {
                                //System.debug('charge_po-->'+charge_po);
                                //System.debug('prodReqRec.Total_Markup_60__c--->'+prodReqRec.Total_Markup_60__c);
                                charge_po += prodReqRec.Total_Markup_60__c;
                                // System.debug('charge_po-->'+charge_po);
                            }
                        }
                        when 'Scaffolding'
                        {
                            if(prodReqRec.Total_Costs__c != null)// Added for Null Point Exception
                            {
                                //System.debug('cost_scaf->'+cost_scaf);
                                //System.debug('prodReqRec.Total_Markup_60__c--->'+prodReqRec.Total_Markup_60__c);                                
                                cost_scaf += prodReqRec.Total_Costs__c;
                                //System.debug('cost_scaf after->'+cost_scaf);
                            }
                            if(prodReqRec.Total_Markup_60__c != null)// Added for Null Point Exception
                            {
                                //System.debug('charge_scaf-->'+charge_scaf);
                                //System.debug('prodReqRec.Total_Markup_60__c--->'+prodReqRec.Total_Markup_60__c);
                                charge_scaf += prodReqRec.Total_Markup_60__c;
                                //System.debug('charge_scaf after ->'+charge_scaf);
                            }
                        }
                    }
                }
                
                if(ccWORecIdMap.containsKey(parRecId)){
                    
                    Id ccRecId = ccWORecIdMap.get(parRecId);
                    System.debug('entered'+ccRecId);
                    if(costChagesMap.containsKey(ccRecId)){
                        Costs_and_Charges__c ccRec = costChagesMap.get(ccRecId);
                        //System.debug('ccRec-->'+ccRec);
                        //system.debug('ccRec ccRec value before --- '+ccRec);
                        //system.debug('ccRec charge_po value  before--- '+charge_po);
                        //system.debug('ccRec  charge_scaf value before--- '+charge_scaf);
                        //system.debug('ccRec charge_van value before--- '+charge_van);  
                        //system.debug('ccRec  cost_po value before--- '+cost_po);
                        //system.debug('ccRec cost_scaf  value before--- '+cost_scaf);
                        //system.debug('ccRec  cost_vanvalue before--- '+cost_van);
                        //system.debug('ccRec value before Charge_Total_PO_Product_Required__c--- '+ccRec.Charge_Total_PO_Product_Required__c);
                        //system.debug('ccRec value before Charge_Total_Scaffold_Product_Required__c--- '+ccRec.Charge_Total_Scaffold_Product_Required__c);  
                        //system.debug('ccRec value before Charge_Total_Van_Stock_Product_Required__c--- '+ccRec.Charge_Total_Van_Stock_Product_Required__c);
                        //system.debug('ccRec value  before Cost_Total_PO_Product_Required__c --- '+ccRec.Cost_Total_PO_Product_Required__c);
                        //system.debug('ccRec value before- Cost_Total_Scaffold_Product_Required__c-- '+ccRec.Cost_Total_Scaffold_Product_Required__c);  
                        //system.debug('ccRec value before Cost_Total_Van_Stock_Product_Required__c--- '+ccRec.Cost_Total_Van_Stock_Product_Required__c);
                        ccRec.Charge_Total_PO_Product_Required__c = charge_po;
                        ccRec.Charge_Total_Scaffold_Product_Required__c = charge_scaf;
                        ccRec.Charge_Total_Van_Stock_Product_Required__c = charge_van;
                        ccRec.Cost_Total_PO_Product_Required__c = cost_po;
                        ccRec.Cost_Total_Scaffold_Product_Required__c = cost_scaf;
                        ccRec.Cost_Total_Van_Stock_Product_Required__c = cost_van;
                        //system.debug('ccRec charge_po value  after--- '+charge_po);
                        //system.debug('ccRec  charge_scaf value after--- '+charge_scaf);
                        //system.debug('ccRec charge_van value after--- '+charge_van);  
                        //system.debug('ccRec  cost_po value after--- '+cost_po);
                        //system.debug('ccRec cost_scaf  value after--- '+cost_scaf);
                        system.debug('ccRec  cost_vanvalue after--- '+cost_van);
                        
                        ccListToUpdate.add(ccRec);
                    }
                }
                if(workOrderMap.containsKey(parRecId)){
                    WorkOrder workOrderRec = workOrderMap.get(parRecId);
                    system.debug('workOrderRec value --- '+workOrderRec);
                    workOrderRec.Sum_of_WO_PO_Product_Required__c = charge_po;
                    workOrderRec.Sum_of_WO_Scaffolding_Product_Required__c = charge_scaf;
                    workOrderRec.Sum_of_WO_Van_Stock_Product_Required__c = charge_van;
                    woListToUpdate.add(workOrderRec);
                }
            }
        }
        
        //system.debug('Size of ccListToUpdate  -- '+ccListToUpdate.size());
        if(!ccListToUpdate.isEmpty()){
            //System.debug('ccListToUpdate-->'+ccListToUpdate);
            Database.Update(ccListToUpdate, false);
            //System.debug('ccListToUpdate after-->'+ccLIstToUpdate);
        }
        
        //system.debug('Size of woListToUpdate  -- '+woListToUpdate.size());
        if(!woListToUpdate.isEmpty()){
            Database.Update(woListToUpdate, false);
        }
    }
}