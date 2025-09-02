@IsTest
public with sharing class CloseJobApplicationsBatchTest {
    
    @IsTest
    static void testBatchExecution() {
        Job_Application__c appSaved = new Job_Application__c (Status__c = 'Saved', Follow_Up_Date__c = Date.today().addDays(-35));
        Job_Application__c appApplying = new Job_Application__c (Status__c = 'Applying', Follow_Up_Date__c = Date.today().addDays(-35));
        Job_Application__c appApplied = new Job_Application__c (Status__c = 'Applied', Follow_Up_Date__c = Date.today().addDays(-35));
        Job_Application__c appInterviewing = new Job_Application__c (Status__c = 'Interviewing', Follow_Up_Date__c = Date.today().addDays(-35));
        Job_Application__c appNegotiating = new Job_Application__c (Status__c = 'Negotiating', Follow_Up_Date__c = Date.today().addDays(-35));
        Job_Application__c appAccepted = new Job_Application__c (Status__c = 'Accepted', Follow_Up_Date__c = Date.today().addDays(-35));        
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>{appSaved, appApplying, appApplied, appInterviewing, appNegotiating, appAccepted};
        insert appsToInsert;

        Test.startTest();
            CloseJobApplicationsBatch batch = new CloseJobApplicationsBatch();
            Id jobId = Database.executeBatch(batch, 200);
        Test.stopTest();

        List<Job_Application__c> closedApps = [
            SELECT Id, Status__c, Notes__c, Follow_Up_Date__c, Position_Title__c 
            FROM Job_Application__c 
            WHERE Status__c = 'Closed'
        ];

        System.assertEquals(5, closedApps.size(), 'Should have 5 closed applications');

        Set<Id> appIds = new Set<Id>();

        for (Job_Application__c job : closedApps) {
            appIds.add(job.Id);
        }

        List<Task> testTasks = [SELECT Id, WhatId, isClosed FROM Task WHERE WhatId IN :appIds AND isClosed != true];
        System.assertEquals(0, testTasks.size(), 'All tasks should be closed after batch execution');
    }
}