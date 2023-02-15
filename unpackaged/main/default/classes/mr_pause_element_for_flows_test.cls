@isTest
public class mr_pause_element_for_flows_test {

    static testmethod void testpause(){
        
        Test.startTest();
        long start_time = System.now().gettime();
        mr_pause_element_for_flows.pause();
        long end_time = System.now().gettime();        
        System.assert( (end_time-start_time) >= 2000 );
        Test.stopTest();
    }
    
}