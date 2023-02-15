global class CreateEPRforJob_Schedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        CreateEPRforJob_Batch bCon = new CreateEPRforJob_Batch();
        //Batch size is 200, records will be split into batches 
        Database.ExecuteBatch(bCon,10);
    } 
}