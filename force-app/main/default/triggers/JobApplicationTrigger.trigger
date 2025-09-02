trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, before update, after update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            JobApplicationHelper.calculateCompensationAndTaxes(Trigger.new, null);
        }
        when AFTER_INSERT {
            JobApplicationHelper.createTaskBasedOnStatus(Trigger.new);
            JobApplicationHelper.setPrimaryContact(Trigger.new);
        }
        when BEFORE_UPDATE {
            JobApplicationHelper.checkTaskCompletionBeforeUpdate(Trigger.new, Trigger.oldMap);
            JobApplicationHelper.calculateCompensationAndTaxes(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            if(!System.isBatch()) {
                JobApplicationHelper.createTaskBasedOnStatus(Trigger.new);
            }
            
            JobApplicationHelper.setPrimaryContact(Trigger.new);
        }
    }

}