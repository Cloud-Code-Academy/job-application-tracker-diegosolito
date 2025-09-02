@IsTest
private class CloseJobApplicationsBatchSchedulerTest {
    @IsTest
    static void testCloseJobApplicationsBatchScheduler() {
        
        CloseJobApplicationsBatchScheduler jobSched = new CloseJobApplicationsBatchScheduler();
        
        // Test that the scheduler can be scheduled without errors
        Test.startTest();
        String jobId = System.schedule('Test Job Application Batch', '0 0 2 20 9 ?', jobSched);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
        
        // Verify the job is in the scheduled jobs
        List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, scheduledJobs.size(), 'Job should be found in scheduled jobs');
     
    }
}
