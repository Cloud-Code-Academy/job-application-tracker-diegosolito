@IsTest
private class JobApplicationHelperTest {
	@IsTest
    static void testCheckTaskCompletionBeforeUpdate() {
        Job_Application__c app = new Job_Application__c ();
        app.Position_Title__c = 'Junior Salesforce Developer';
        app.Location__c = 'Washington DC';
        app.URL__c = 'https://jooble.org/desc/2570080932128472823';
        app.Jooble_Id__c = '2570080932128472823';
        app.Status__c = 'Saved';
        insert app;
        
        Contact cont = new Contact(LastName = 'TestLastName');
        insert cont;
        
        Task tk = new Task(WhatId = app.Id, WhoId = cont.Id);
        insert tk;
        
        Test.startTest();
        app.Status__c = 'Applied';
        
        Database.SaveResult sr = Database.update(app,false);

        Test.stopTest();
        
        System.assertEquals(false, sr.isSuccess(), 'Update should fail due to open tasks.');
        
    }
    
    @IsTest
    static void testCreateTaskBasedOnStatus() {
        
        Job_Application__c appSaved = new Job_Application__c (Status__c = 'Saved');
        Job_Application__c appApplying = new Job_Application__c (Status__c = 'Applying');
        Job_Application__c appApplied = new Job_Application__c (Status__c = 'Applied');
        Job_Application__c appInterviewing = new Job_Application__c (Status__c = 'Interviewing');
        Job_Application__c appNegotiating = new Job_Application__c (Status__c = 'Negotiating');
        Job_Application__c appAccepted = new Job_Application__c (Status__c = 'Accepted');
        Job_Application__c appClosed = new Job_Application__c (Status__c = 'Closed');
        
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>{appSaved, appApplying, appApplied, appInterviewing, appNegotiating, appAccepted, appClosed};
        
        Test.startTest();
        insert appsToInsert;
        Test.stopTest();
        
        List<Task> tasksSaved = [SELECT Id, WhatId FROM Task WHERE WhatId =: appsToInsert[0].Id];
        List<Task> tasksApplying = [SELECT Id, WhatId FROM Task WHERE WhatId =: appsToInsert[1].Id];
        List<Task> tasksApplied = [SELECT Id, WhatId FROM Task WHERE WhatId =: appsToInsert[2].Id];
        List<Task> tasksInterviewing = [SELECT Id, WhatId FROM Task WHERE WhatId =: appsToInsert[3].Id];
        List<Task> tasksNegotiating = [SELECT Id, WhatId FROM Task WHERE WhatId =: appsToInsert[4].Id];
        List<Task> tasksAccepted = [SELECT Id, WhatId FROM Task WHERE WhatId =: appsToInsert[5].Id];
        List<Task> tasksClosed = [SELECT Id, WhatId FROM Task WHERE WhatId =: appsToInsert[6].Id];
        
        System.assertEquals(3, tasksSaved.size(), 'Exactly three tasks should be created');
        System.assertEquals(5, tasksApplying.size(), 'Exactly five tasks should be created');
        System.assertEquals(4, tasksApplied.size(), 'Exactly four tasks should be created');
        System.assertEquals(5, tasksInterviewing.size(), 'Exactly five tasks should be created');
        System.assertEquals(3, tasksNegotiating.size(), 'Exactly three tasks should be created');
        System.assertEquals(3, tasksAccepted.size(), 'Exactly three tasks should be created');
        System.assertEquals(2, tasksClosed.size(), 'Exactly two tasks should be created');
    }
    
    @IsTest
    static void testCalculateCompensationAndTaxes() {
 
        Job_Application__c RATE_10 = new Job_Application__c (Salary__c = 11900.00);
        Job_Application__c RATE_12 = new Job_Application__c (Salary__c = 30000);
        Job_Application__c RATE_22 = new Job_Application__c (Salary__c = 70000);
        Job_Application__c RATE_24 = new Job_Application__c (Salary__c = 150000);
        Job_Application__c RATE_24_2 = new Job_Application__c (Salary__c = 180000);
        Job_Application__c RATE_32 = new Job_Application__c (Salary__c = 200000);
        Job_Application__c RATE_32_2 = new Job_Application__c (Salary__c = 210000);
        Job_Application__c RATE_35 = new Job_Application__c (Salary__c = 500000);
        Job_Application__c RATE_37 = new Job_Application__c (Salary__c = 700000);
        
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>{RATE_10, RATE_12, RATE_22, RATE_24, RATE_24_2, RATE_32, RATE_32_2, RATE_35, RATE_37};
        
        insert appsToInsert;
		
        for (Job_Application__c app : appsToInsert) {
            JobApplicationHelper.SalaryBand band = JobApplicationHelper.getSalaryBand(app.Salary__c);
    		app = JobApplicationHelper.calculateBasedOnSalary(band, app);
        }
		        
        //test rate10
        System.assertEquals(1190.00, appsToInsert[0].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(9799.65, appsToInsert[0].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(737.80, appsToInsert[0].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(816.64, appsToInsert[0].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(172.55, appsToInsert[0].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');
        
        //test rate12
        System.assertEquals(3600.00, appsToInsert[1].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(24105.00, appsToInsert[1].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(1860.00, appsToInsert[1].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(2008.75, appsToInsert[1].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(435.00, appsToInsert[1].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');
        
        //test rate22
        System.assertEquals(15400.00, appsToInsert[2].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(49245.00, appsToInsert[2].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(4340.00, appsToInsert[2].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(4103.75, appsToInsert[2].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(1015.00, appsToInsert[2].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');

        //test rate24
        System.assertEquals(36000.00, appsToInsert[3].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(102525.00, appsToInsert[3].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(9300.00, appsToInsert[3].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(8543.75, appsToInsert[3].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(2175.00, appsToInsert[3].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');

        //test rate24 >SS Wage Base
        System.assertEquals(43200.00, appsToInsert[4].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(123271.80, appsToInsert[4].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, appsToInsert[4].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(10272.65, appsToInsert[4].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(2610.00, appsToInsert[4].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');
        
        //test rate32
        System.assertEquals(64000.00, appsToInsert[5].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(122181.80, appsToInsert[5].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, appsToInsert[5].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(10181.82, appsToInsert[5].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(2900.00, appsToInsert[5].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');

        //test rate32 > 200k
        System.assertEquals(67200.00, appsToInsert[6].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(128746.80, appsToInsert[6].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, appsToInsert[6].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(10728.90, appsToInsert[6].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(3135.00, appsToInsert[6].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');

        //test rate35
        System.assertEquals(175000.00, appsToInsert[7].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(304131.80, appsToInsert[7].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, appsToInsert[7].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(25344.32, appsToInsert[7].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(9950.00, appsToInsert[7].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly');

        //test rate37
        System.assertEquals(259000.00, appsToInsert[8].Federal_Income_Tax__c, 'Federal Income Tax was not calculated correctly');
        System.assertEquals(415431.80, appsToInsert[8].Net_Annual_Pay__c, 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, appsToInsert[8].Social_Security_Tax__c, 'Social Security Tax was not calculated correctly');
        System.assertEquals(34619.32, appsToInsert[8].Net_Monthly_Pay__c, 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(14650.00, appsToInsert[8].Medicare_Withholding__c, 'Medicare Withholding was not calculated correctly'); 
		
        
        
		
    }

    @IsTest
    static void testSetPrimaryContact() {
        
        //job application with no account or application contacts
        Job_Application__c appNoAccCont = new Job_Application__c (Position_Title__c = 'Junior Salesforce Developer');
        insert appNoAccCont;
        
        //job application with account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'AccountContact', AccountId = acc.Id);
        insert con;
        
        Job_Application__c app = new Job_Application__c (Position_Title__c = 'Sr Salesforce Developer', Company_Name__c = acc.Id);
        insert app;
        
        //job application with application contact
        Contact conApp = new Contact(LastName = 'AppContact');
        insert conApp;
        Job_Application__c appAccCon = new Job_Application__c (Position_Title__c = 'Lead Salesforce Developer');
        insert appAccCon;
		Application_Contact__c appCon = new Application_Contact__c(Name = 'Test Application Contact', Job_Application__c = appAccCon.Id, Contact__c = conApp.Id);
        insert appCon;
        
        //job application with application contact and account
        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;
        Contact con2 = new Contact(LastName = 'AccountContact 2', AccountId = acc2.Id);
        insert con2;
        
        Contact conApp2 = new Contact(LastName = 'AppContact2');
        insert conApp2;
        Job_Application__c appAccCon2 = new Job_Application__c (Position_Title__c = 'Sr Lead Salesforce Developer');
        insert appAccCon2;
		Application_Contact__c appCon2 = new Application_Contact__c(Name = 'Test Application Contact 2', Job_Application__c = appAccCon2.Id, Contact__c = conApp2.Id);
        insert appCon2;
        
        List<Job_Application__c> appsToTest = new List<Job_Application__c>{appNoAccCont, app, appAccCon, appAccCon2};
        
        Test.startTest();
        JobApplicationHelper.setPrimaryContact(appsToTest);
        Test.stopTest();
        List<Job_Application__c> updatedApps = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :appsToTest];
        
        System.assertEquals(null, updatedApps[0].Primary_Contact__c,'Primary Contact was not updated Correctly');
        System.assertEquals(con.Id, updatedApps[1].Primary_Contact__c,'Primary Contact was not updated Correctly');
        System.assertEquals(conApp.Id, updatedApps[2].Primary_Contact__c,'Primary Contact was not updated Correctly');
        System.assertEquals(conApp2.Id, updatedApps[3].Primary_Contact__c,'Primary Contact was not updated Correctly');
    }

    @IsTest
    static void testCalculateCompensationAndTaxes_LWC() {
 
        Decimal RATE_10 = 11900.00;
        Decimal RATE_12 = 30000;
        Decimal RATE_22 = 70000;
        Decimal RATE_24 = 150000;
        Decimal RATE_24_2 = 180000;
        Decimal RATE_32 = 200000;
        Decimal RATE_32_2 = 210000;
        Decimal RATE_35 = 500000;
        Decimal RATE_37 = 700000;

        //test null
        System.assertEquals(false, JobApplicationHelper.calculateCompensationAndTaxes(null).get('success'), 'Success must be false');
        System.assertEquals('Please enter a valid salary amount', JobApplicationHelper.calculateCompensationAndTaxes(null).get('error'), 'Must request a valid amount');

        //test rate10
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_10).get('success'), 'Success must be true');
        System.assertEquals(1190.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_10).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(9799.65, JobApplicationHelper.calculateCompensationAndTaxes(RATE_10).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(737.80, JobApplicationHelper.calculateCompensationAndTaxes(RATE_10).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(816.64, JobApplicationHelper.calculateCompensationAndTaxes(RATE_10).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(172.55, JobApplicationHelper.calculateCompensationAndTaxes(RATE_10).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('TEN', JobApplicationHelper.calculateCompensationAndTaxes(RATE_10).get('salaryBand'), 'Band was not calculated correctly');

        //test rate12
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_12).get('success'), 'Success must be true');
        System.assertEquals(3600.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_12).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(24105.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_12).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(1860.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_12).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(2008.75, JobApplicationHelper.calculateCompensationAndTaxes(RATE_12).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(435.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_12).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('TWELVE', JobApplicationHelper.calculateCompensationAndTaxes(RATE_12).get('salaryBand'), 'Band was not calculated correctly');

        //test rate22
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_22).get('success'), 'Success must be true');
        System.assertEquals(15400.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_22).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(49245.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_22).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(4340.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_22).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(4103.75, JobApplicationHelper.calculateCompensationAndTaxes(RATE_22).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(1015.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_22).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('TWENTY_TWO', JobApplicationHelper.calculateCompensationAndTaxes(RATE_22).get('salaryBand'), 'Band was not calculated correctly');

        //test rate24
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24).get('success'), 'Success must be true');
        System.assertEquals(36000.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(102525.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(9300.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(8543.75, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(2175.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('TWENTY_FOUR', JobApplicationHelper.calculateCompensationAndTaxes(RATE_24).get('salaryBand'), 'Band was not calculated correctly');

        //test rate24 >SS Wage Base
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24_2).get('success'), 'Success must be true');
        System.assertEquals(43200.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24_2).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(123271.80, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24_2).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24_2).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(10272.65, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24_2).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(2610.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_24_2).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('TWENTY_FOUR', JobApplicationHelper.calculateCompensationAndTaxes(RATE_24_2).get('salaryBand'), 'Band was not calculated correctly');

        //test rate32
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32).get('success'), 'Success must be true');
        System.assertEquals(64000.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(122181.80, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(10181.82, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(2900.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('THIRTY_TWO', JobApplicationHelper.calculateCompensationAndTaxes(RATE_32).get('salaryBand'), 'Band was not calculated correctly');

        //test rate32 > 200k
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32_2).get('success'), 'Success must be true');
        System.assertEquals(67200.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32_2).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(128746.80, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32_2).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32_2).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(10728.90, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32_2).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(3135.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_32_2).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('THIRTY_TWO', JobApplicationHelper.calculateCompensationAndTaxes(RATE_32_2).get('salaryBand'), 'Band was not calculated correctly');

        //test rate35
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_35).get('success'), 'Success must be true');
        System.assertEquals(175000.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_35).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(304131.80, JobApplicationHelper.calculateCompensationAndTaxes(RATE_35).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, JobApplicationHelper.calculateCompensationAndTaxes(RATE_35).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(25344.32, JobApplicationHelper.calculateCompensationAndTaxes(RATE_35).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(9950.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_35).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('THIRTY_FIVE', JobApplicationHelper.calculateCompensationAndTaxes(RATE_35).get('salaryBand'), 'Band was not calculated correctly');

        //test rate37
        System.assertEquals(true, JobApplicationHelper.calculateCompensationAndTaxes(RATE_37).get('success'), 'Success must be true');
        System.assertEquals(259000.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_37).get('federalIncomeTax'), 'Federal Income Tax was not calculated correctly');
        System.assertEquals(415431.80, JobApplicationHelper.calculateCompensationAndTaxes(RATE_37).get('netAnnualPay'), 'Net Annual Pay was not calculated correctly');
        System.assertEquals(10918.20, JobApplicationHelper.calculateCompensationAndTaxes(RATE_37).get('socialSecurityTax'), 'Social Security Tax was not calculated correctly');
        System.assertEquals(34619.32, JobApplicationHelper.calculateCompensationAndTaxes(RATE_37).get('netMonthlyPay'), 'Net Monthly Pay was not calculated correctly');
        System.assertEquals(14650.00, JobApplicationHelper.calculateCompensationAndTaxes(RATE_37).get('medicareWithholding'), 'Medicare Withholding was not calculated correctly');
        System.assertEquals('THIRTY_SEVEN', JobApplicationHelper.calculateCompensationAndTaxes(RATE_37).get('salaryBand'), 'Band was not calculated correctly');
 
    }
}