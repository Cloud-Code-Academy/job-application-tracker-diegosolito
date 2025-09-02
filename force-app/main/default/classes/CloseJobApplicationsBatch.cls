public with sharing class CloseJobApplicationsBatch implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date thirtyDays = Date.today().addDays(-30);
        return Database.getQueryLocator([SELECT Id, Status__c, Notes__c, Follow_Up_Date__c FROM Job_Application__c WHERE (Status__c != 'Closed' AND Status__c != 'Accepted') AND Follow_Up_Date__c <=:thirtyDays]);
    }

    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope) {
        Set<Id> jobIds = new Set<Id>();

        for (Job_Application__c job : scope) {
            jobIds.add(job.Id);
        }

        List<Task> tasksToCloseBeforeClosing = [SELECT Id, WhatId, Status, isClosed, Description FROM Task WHERE WhatId IN :jobIds AND isClosed = false];

        for(Task tk : tasksToCloseBeforeClosing) {
            tk.Status = 'Completed';
            tk.Description = tk.Description + '\n' + 'This task was closed because Follow-up date exceeded 30 days without closure';
        }

        update tasksToCloseBeforeClosing;

        for (Job_Application__c jobs : scope) {
            jobs.Status__c = 'Closed';
            jobs.Notes__c = 'This Job Application was closed automatically because it remained in an open status without acceptance or closure for more than 30 days past the follow-up date.';
        }

        update scope;

    }

    public void finish(Database.BatchableContext bc) {
        System.debug('CloseJobApplicationsBatch completed successfully');
    }
}