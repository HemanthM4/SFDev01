global   class   ScheduleAccountUpdate implements Schedulable {
    global  void execute(SchedulableContext sc) {
        //Database.executeBatch takes in the class, and then the size of batches.
        ScheduleBatchAccountUpdate bdt = new ScheduleBatchAccountUpdate();
        ID BatchId = Database.executeBatch(bdt);
    }
}