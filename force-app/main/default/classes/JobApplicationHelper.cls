public with sharing class JobApplicationHelper {

    public enum SalaryBand { TEN, TWELVE, TWENTY_TWO, TWENTY_FOUR, THIRTY_TWO, THIRTY_FIVE, THIRTY_SEVEN }
    /* ==== Federal income tax rates (marginal) ==== */
    public static final Decimal RATE_10  = 0.10;
    public static final Decimal RATE_12  = 0.12;
    public static final Decimal RATE_22  = 0.22;
    public static final Decimal RATE_24  = 0.24;
    public static final Decimal RATE_32  = 0.32;
    public static final Decimal RATE_35  = 0.35;
    public static final Decimal RATE_37  = 0.37;

    /* ==== Social Security ==== */
    public static final Decimal SS_RATE = 0.062;        
    public static final Decimal SS_WAGE_BASE = 176100;  
    public static final Decimal SS_MAX = 10918.20;
    /* ==== Medicare ==== */
    public static final Decimal MEDICARE_RATE = 0.0145; 
    public static final Decimal MEDICARE_RATE_200K = 0.009;
    public static final Decimal MEDICARE200K = 200000;

    public static void checkTaskCompletionBeforeUpdate(List<Job_Application__c> jobApplicationList, Map<Id,Job_Application__c> oldValuesJobApplication) {
        Set<Id>changeIds = new Set<Id>();
        for(Job_Application__c newApp : jobApplicationList) {
            Job_Application__c oldApp = oldValuesJobApplication.get(newApp.Id);
            
            if (oldApp !=null && newApp.Status__c != oldApp.Status__c) {
                changeIds.add(newApp.Id);
            }
        }
        if (changeIds.isEmpty()) {
            return;
        }

        Map<Id,Boolean> hasOpenTasks = new Map<Id,Boolean>();
        List<Task> openTasks = [SELECT WhatId FROM Task WHERE WhatId IN :changeIds AND IsClosed = false];
        for (Task tk : openTasks) {
            if (tk.WhatId != null) {
                hasOpenTasks.put(tk.WhatId, true);
            }    
        }

        for (Job_Application__c newApp : jobApplicationList){
            if (hasOpenTasks.containsKey(newApp.Id)) {
                newApp.Status__c.addError('Close all related Tasks before changing Status.');
            }
        }
        
    }
    
    public static void createTaskBasedOnStatus(List<Job_Application__c> jobApplicationList){
        Set<Id> jobApplicationSavedStatus = new Set<Id>();
        Set<Id> jobApplicationApplyingStatus = new Set<Id>();
        Set<Id> jobApplicationAppliedStatus = new Set<Id>();
        Set<Id> jobApplicationInterviewingStatus = new Set<Id>();
        Set<Id> jobApplicationNegotiatingStatus = new Set<Id>();
        Set<Id> jobApplicationAcceptedStatus = new Set<Id>();
        Set<Id> jobApplicationClosedStatus = new Set<Id>();

        for(Job_Application__c app : jobApplicationList){
            if (app.Status__c == 'Saved'){
                jobApplicationSavedStatus.add(app.Id);
            } else if (app.Status__c == 'Applying'){
                jobApplicationApplyingStatus.add(app.Id);
            } else if (app.Status__c == 'Applied'){
                jobApplicationAppliedStatus.add(app.Id);
            } else if (app.Status__c == 'Interviewing') {
                jobApplicationInterviewingStatus.add(app.Id);
            } else if (app.Status__c == 'Negotiating') {
                jobApplicationNegotiatingStatus.add(app.Id);
            } else if (app.Status__c == 'Accepted') {
                jobApplicationAcceptedStatus.add(app.Id);
            } else if (app.Status__c == 'Closed') {
                jobApplicationClosedStatus.add(app.Id);
            }
        }

        if (!jobApplicationSavedStatus.isEmpty()) {
            createSavedTasks(jobApplicationSavedStatus);
        }
        if (!jobApplicationApplyingStatus.isEmpty()) {
            createApplyingTasks(jobApplicationApplyingStatus);
        }
        if (!jobApplicationAppliedStatus.isEmpty()) {
            createAppliedTasks(jobApplicationAppliedStatus);
        }
        if (!jobApplicationInterviewingStatus.isEmpty()) {
            createInterviewingTasks(jobApplicationInterviewingStatus);
        }
        if (!jobApplicationNegotiatingStatus.isEmpty()) {
            createNegotiatingTasks(jobApplicationNegotiatingStatus);
        }
        if (!jobApplicationAcceptedStatus.isEmpty()) {
            createAcceptedTasks(jobApplicationAcceptedStatus);
        }
        if (!jobApplicationClosedStatus.isEmpty()) {
            createClosedTasks(jobApplicationClosedStatus);
        }
    }

    private static void createSavedTasks(Set<Id> jobApplicationSet){
        List<Job_Application__c> applications = [SELECT Id, OwnerId, Status__c FROM Job_Application__c WHERE Id IN :jobApplicationSet];
        List<Task> saveTaskTemplates = new List<Task>{
            new Task(Subject='Job fit check',
             Description='Check if the job description aligns with your interests and values',
             Status='Not Started'),
            new Task(Subject='Skills review',
             Description='Review the highlighted skills to see if the role is a good fit',
             Status='Not Started'),
            new Task(Subject='Research Company',
             Description='Research the company or role and mark your excitement level',
             Status='Not Started')
        };
        List<Task> taskToInsert = new List<Task>();

        for(Job_Application__c app : applications){
            for(Task tk : saveTaskTemplates){
                Task copy = tk.clone(false);
                copy.WhatId = app.Id;
                copy.OwnerId = app.OwnerId;
                taskToInsert.add(copy);
            }
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }

    private static void createApplyingTasks(Set<Id> jobApplicationSet){
        List<Job_Application__c> applications = [SELECT Id, OwnerId, Status__c FROM Job_Application__c WHERE Id IN :jobApplicationSet];
        List<Task> applyingTaskTemplates = new List<Task>{
            new Task(Subject='Find company contact',
             Description='Find and research someone who works at the company and add them as a contact',
             Status='Not Started'),
            new Task(Subject='Informational interview',
             Description='Set up an informational interview to learn more about the role/company',
             Status='Not Started'),
            new Task(Subject='Identify referrals',
             Description='Identify potential referrals to help get your application on the top of the pile',
             Status='Not Started'),
            new Task(Subject='Customize achievements',
             Description='Customize your work achievements using the job description keywords',
             Status='Not Started'),
            new Task(Subject='Submit application',
             Description='Submit your application on the company website if possible',
             Status='Not Started')

        };
        List<Task> taskToInsert = new List<Task>();

        for(Job_Application__c app : applications){
            for(Task tk : applyingTaskTemplates){
                Task copy = tk.clone(false);
                copy.WhatId = app.Id;
                copy.OwnerId = app.OwnerId;
                taskToInsert.add(copy);
            }
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }
    
    private static void createAppliedTasks(Set<Id> jobApplicationSet){
        List<Job_Application__c> applications = [SELECT Id, OwnerId, Status__c FROM Job_Application__c WHERE Id IN :jobApplicationSet];
        List<Task> appliedTaskTemplates = new List<Task>{
            new Task(Subject='Reach out recruiter',
             Description='Reach out to the hiring manager or recruiter',
             Status='Not Started'),
            new Task(Subject='Follow Up Application',
             Description='Follow up on your application via email weekly',
             Status='Not Started'),
            new Task(Subject='Save similar jobs',
             Description='Continue identifying and saving similar job opportunities',
             Status='Not Started'),
            new Task(Subject='Set up calls',
             Description='Set up weekly networking calls to explore similar companies/roles',
             Status='Not Started')
        };
        List<Task> taskToInsert = new List<Task>();

        for(Job_Application__c app : applications){
            for(Task tk : appliedTaskTemplates){
                Task copy = tk.clone(false);
                copy.WhatId = app.Id;
                copy.OwnerId = app.OwnerId;
                taskToInsert.add(copy);
            }
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }

    private static void createInterviewingTasks(Set<Id> jobApplicationSet){
        List<Job_Application__c> applications = [SELECT Id, OwnerId, Status__c FROM Job_Application__c WHERE Id IN :jobApplicationSet];
        List<Task> interviewingTaskTemplates = new List<Task>{
            new Task(Subject='Prepare your blurb',
             Description='Prepare your blurb or “tell me about yourself” response',
             Status='Not Started'),
            new Task(Subject='Practice answers',
             Description='Practice answering behavioral interview questions',
             Status='Not Started'),
            new Task(Subject='Research Company',
             Description='Research the company and your interviewers',
             Status='Not Started'),
            new Task(Subject='Interview set up',
             Description='Set up your virtual interview space and test your tech',
             Status='Not Started'),
            new Task(Subject='Thank you email',
             Description='Send thank you emails within 24 hours',
             Status='Not Started')
        };
        List<Task> taskToInsert = new List<Task>();

        for(Job_Application__c app : applications){
            for(Task tk : interviewingTaskTemplates){
                Task copy = tk.clone(false);
                copy.WhatId = app.Id;
                copy.OwnerId = app.OwnerId;
                taskToInsert.add(copy);
            }
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }

    private static void createNegotiatingTasks(Set<Id> jobApplicationSet){
        List<Job_Application__c> applications = [SELECT Id, OwnerId, Status__c FROM Job_Application__c WHERE Id IN :jobApplicationSet];
        List<Task> negotiatingTaskTemplates = new List<Task>{
            new Task(Subject='Research Market Value',
             Description='Research your market value and know your numbers',
             Status='Not Started'),
            new Task(Subject='Negotiation scripts',
             Description='Prepare your negotiation scripts',
             Status='Not Started'),
            new Task(Subject='Evaluate offer',
             Description='Evaluate your offer and decline or accept',
             Status='Not Started')
        };
        List<Task> taskToInsert = new List<Task>();

        for(Job_Application__c app : applications){
            for(Task tk : negotiatingTaskTemplates){
                Task copy = tk.clone(false);
                copy.WhatId = app.Id;
                copy.OwnerId = app.OwnerId;
                taskToInsert.add(copy);
            }
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }

    private static void createAcceptedTasks(Set<Id> jobApplicationSet){
        List<Job_Application__c> applications = [SELECT Id, OwnerId, Status__c FROM Job_Application__c WHERE Id IN :jobApplicationSet];
        List<Task> acceptedTaskTemplates = new List<Task>{
            new Task(Subject='Plan your resignation',
             Description='Plan your resignation if applicable',
             Status='Not Started'),
            new Task(Subject='Relax Time!',
             Description='Take some time to relax and recharge',
             Status='Not Started'),
            new Task(Subject='First Day',
             Description='Prepare for your first day of onboarding',
             Status='Not Started')
        };
        List<Task> taskToInsert = new List<Task>();

        for(Job_Application__c app : applications){
            for(Task tk : acceptedTaskTemplates){
                Task copy = tk.clone(false);
                copy.WhatId = app.Id;
                copy.OwnerId = app.OwnerId;
                taskToInsert.add(copy);
            }
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }

    private static void createClosedTasks(Set<Id> jobApplicationSet){
        List<Job_Application__c> applications = [SELECT Id, OwnerId, Status__c FROM Job_Application__c WHERE Id IN :jobApplicationSet];
        List<Task> closedTaskTemplates = new List<Task>{
            new Task(Subject='Follow up email',
             Description='Send a follow-up email thanking the interviewer and asking for feedback',
             Status='Not Started'),
            new Task(Subject='Review Notes',
             Description='Review your notes and reflect on areas of improvement',
             Status='Not Started')
        };
        List<Task> taskToInsert = new List<Task>();

        for(Job_Application__c app : applications){
            for(Task tk : closedTaskTemplates){
                Task copy = tk.clone(false);
                copy.WhatId = app.Id;
                copy.OwnerId = app.OwnerId;
                taskToInsert.add(copy);
            }
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }

    public static void setPrimaryContact(List<Job_Application__c> jobAppList) {
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();
        for (Job_Application__c app : jobAppList) {
            if (app.Primary_Contact__c == null) {
                Contact c = findContact(app);
                if (c != null) {
                    Job_Application__c newApp = new Job_Application__c(Id = app.Id, Primary_Contact__c = c.Id); 
                    appsToUpdate.add(newApp);
                }
            }
        }
        if (!appsToUpdate.isEmpty()){
            update appsToUpdate;
        }
    }

    private static Contact findContact(Job_Application__c app){
        List<Application_Contact__c> appContact = [SELECT Id, Contact__c, Job_Application__c, CreatedDate FROM Application_Contact__c WHERE Job_Application__c =:app.Id AND Contact__c != null ORDER BY CreatedDate ASC Limit 1];
        List<Contact> companyContact = [SELECT Id, AccountId FROM Contact WHERE AccountId =:app.Company_Name__c AND AccountId != null ORDER BY CreatedDate ASC Limit 1];

        if (!appContact.isEmpty()){
            return new Contact(Id = appContact[0].Contact__c);
        } else if(!companyContact.isEmpty()){
            return companyContact[0];
        } else {
            return null;
        }
    }

    public static void calculateCompensationAndTaxes(List<Job_Application__c> jobAppList, Map<Id,Job_Application__c> oldValuesJobApplication) {

        for (Job_Application__c app : jobAppList) {
            Job_Application__c oldApp = new Job_Application__c();
            if (oldValuesJobApplication != null) {
                oldApp = oldValuesJobApplication.get(App.Id);
                
            } else {
                //oldApp = null;
            }
            if((app.Salary__c != null && oldApp.Id == null) || (oldApp.Salary__c != null && (app.Salary__c != oldApp.Salary__c)) || (oldApp.Salary__c == null && app.Salary__c != null)) {
                        SalaryBand band = getSalaryBand(app.Salary__c);
                        app = calculateBasedOnSalary(band, app);
            }                 
        }
    }
    @TestVisible
    private static SalaryBand getSalaryBand(Decimal salary) {

        if (salary == null || salary < 0) {
            return null;
        } else if (salary >=0 && salary <=11925) {
            return SalaryBand.TEN;
        } else if (salary > 11925 && salary <= 48475) {
            return SalaryBand.TWELVE;
        } else if (salary > 48475 && salary <= 103350) {
            return SalaryBand.TWENTY_TWO;
        } else if (salary > 103350 && salary <= 197300) {
            return SalaryBand.TWENTY_FOUR;
        } else if (salary > 197300 && salary <= 250525) {
            return SalaryBand.THIRTY_TWO;
        } else if (salary > 250525 && salary <= 626350) {
            return SalaryBand.THIRTY_FIVE;
        } else if (salary > 626350) {
            return SalaryBand.THIRTY_SEVEN;
        }
        return null;
    }
    @TestVisible
    private static Job_Application__c calculateBasedOnSalary(SalaryBand band, Job_Application__c app) {

        switch on band {
            when TEN {
                app.Federal_Income_Tax__c = (app.Salary__c * RATE_10).setScale(2, RoundingMode.HALF_UP);
                app.Social_Security_Tax__c = (app.Salary__c * SS_RATE).setScale(2, RoundingMode.HALF_UP);
                app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP);
                app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                return app;
                
            }
            when TWELVE {
                app.Federal_Income_Tax__c = (app.Salary__c * RATE_12).setScale(2, RoundingMode.HALF_UP);
                app.Social_Security_Tax__c = (app.Salary__c * SS_RATE).setScale(2, RoundingMode.HALF_UP);
                app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP);
                app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                return app;
                
            }
            when TWENTY_TWO {
                app.Federal_Income_Tax__c = (app.Salary__c * RATE_22).setScale(2, RoundingMode.HALF_UP);
                app.Social_Security_Tax__c = (app.Salary__c * SS_RATE).setScale(2, RoundingMode.HALF_UP);
                app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP);
                app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                return app;
            }
            when TWENTY_FOUR {
                if (app.Salary__c < SS_WAGE_BASE) {
                    app.Federal_Income_Tax__c = (app.Salary__c * RATE_24).setScale(2, RoundingMode.HALF_UP);
                    app.Social_Security_Tax__c = (app.Salary__c * SS_RATE).setScale(2, RoundingMode.HALF_UP);
                    app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                    return app;
                } else {
                    app.Federal_Income_Tax__c = (app.Salary__c * RATE_24).setScale(2, RoundingMode.HALF_UP);
                    app.Social_Security_Tax__c = SS_MAX;
                    app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                    return app;
                }

            }
            when THIRTY_TWO {
                if (app.Salary__c <= MEDICARE200K) {
                    app.Federal_Income_Tax__c = (app.Salary__c * RATE_32).setScale(2, RoundingMode.HALF_UP);
                    app.Social_Security_Tax__c = SS_MAX;
                    app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                    return app;
                } else {
                    app.Federal_Income_Tax__c = (app.Salary__c * RATE_32).setScale(2, RoundingMode.HALF_UP);
                    app.Social_Security_Tax__c = SS_MAX;
                    app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP) + ((app.Salary__c - MEDICARE200K) * MEDICARE_RATE_200K).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                    app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                    return app;
                }
            }
            when THIRTY_FIVE {
                app.Federal_Income_Tax__c = (app.Salary__c * RATE_35).setScale(2, RoundingMode.HALF_UP);
                app.Social_Security_Tax__c = SS_MAX;
                app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP) + ((app.Salary__c - MEDICARE200K) * MEDICARE_RATE_200K).setScale(2, RoundingMode.HALF_UP);
                app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                return app;

            }
            when THIRTY_SEVEN {
                app.Federal_Income_Tax__c = (app.Salary__c * RATE_37).setScale(2, RoundingMode.HALF_UP);
                app.Social_Security_Tax__c = SS_MAX;
                app.Medicare_Withholding__c = (app.Salary__c * MEDICARE_RATE).setScale(2, RoundingMode.HALF_UP) + ((app.Salary__c - MEDICARE200K) * MEDICARE_RATE_200K).setScale(2, RoundingMode.HALF_UP);
                app.Net_Annual_Pay__c = (app.Salary__c - app.Federal_Income_Tax__c - app.Social_Security_Tax__c - app.Medicare_Withholding__c).setScale(2, RoundingMode.HALF_UP);
                app.Net_Monthly_Pay__c = (app.Net_Annual_Pay__c / 12.00).setScale(2, RoundingMode.HALF_UP);

                return app;
            }
            when else {
                return app;
            }
        }
    }

    @AuraEnabled
    public static Map<String, Object> calculateCompensationAndTaxes(Decimal salary) {
        try {
            if (salary == null || salary <= 0) {
                return new Map<String, Object>{
                    'success' => false,
                    'error' => 'Please enter a valid salary amount'
                };
            }
            
            Job_Application__c tempApp = new Job_Application__c(Salary__c = salary);
            
            SalaryBand band = getSalaryBand(salary);
            tempApp = calculateBasedOnSalary(band, tempApp);
            
            return new Map<String, Object>{
                'success' => true,
                'federalIncomeTax' => tempApp.Federal_Income_Tax__c,
                'socialSecurityTax' => tempApp.Social_Security_Tax__c,
                'medicareWithholding' => tempApp.Medicare_Withholding__c,
                'netAnnualPay' => tempApp.Net_Annual_Pay__c,
                'netMonthlyPay' => tempApp.Net_Monthly_Pay__c,
                'salaryBand' => band?.name()
            };
        } catch (Exception e) {
            return new Map<String, Object>{
                'success' => false,
                'error' => 'Calculation error: ' + e.getMessage()
            };
        }
    }

}
