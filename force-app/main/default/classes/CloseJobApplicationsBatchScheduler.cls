global class CloseJobApplicationsBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CloseJobApplicationsBatch batch = new CloseJobApplicationsBatch();
        Database.executeBatch(batch, 200);
    }
}