@istest
public class BatchMassUpdateRatecardIdTest {
    
    static testmethod void testMethodDelete() {
        BatchMassUpdateRatecardId bdt = new BatchMassUpdateRatecardId();
        bdt.methodToBeDelete();
        createRateCardsandRate obj2 = new createRateCardsandRate();
        obj2.methodToBeDelete();
    }
}