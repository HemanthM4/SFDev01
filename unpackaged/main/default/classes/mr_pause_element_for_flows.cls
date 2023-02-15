public class mr_pause_element_for_flows {


    @InvocableMethod
    public static void pause() {
        long end_time = System.now().gettime() + 2000;
        while(  System.now().gettime() < end_time ) { 
        }
    }
    
}