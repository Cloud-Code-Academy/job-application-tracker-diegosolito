public with sharing class JoobleApiCallout {

        public static void callJoobleApi() {
        if (Test.isRunningTest()) {
            // In test context, call synchronously (allows mocking)
            postJoobleApi();
        } else {
            // In real execution, call asynchronously
            postJoobleApiAsync();
        }
    }
    @future(callout=true)
    public static void postJoobleApiAsync() {
        postJoobleApi();
    }

    public static void postJoobleApi() {
        
        Date twoDaysAgo = Date.today().addDays(-2);
        String twoDaysAgoStr = twoDaysAgo.format(); 
        String key = 'b0109c29-f6fa-4deb-81da-98ab7c03d7ad';
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://jooble.org/api/'+ key);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"keywords": "salesforce developer", "location": "Washington DC", "datecreatedfrom": "' + twoDaysAgo + '"}');

        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            System.debug(response.getStatusCode());
            System.debug(response.getStatus());

            if (response.getStatusCode() >= 200 && response.getStatusCode() <= 299) {
                System.debug('Success');
                System.debug(response.getBody());
                String body = response.getBody();
                createJobApplicationsFromJson(body);
            }
        } catch (Exception e) {
            System.debug('Callout failed: ' + e.getMessage());
        }
        
    }

    public static void createJobApplicationsFromJson(String jsonResponse) {
        Map<String,Object> jobsData = (Map<String,Object>) JSON.deserializeUntyped(jsonResponse);
        List<Object> listOfJobs = (List<Object>) jobsData.get('jobs');
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>();
        for (Object j : listOfJobs) {

            Map<String,Object> job = (Map<String,Object>) j;
            Job_Application__c app = new Job_Application__c();
            String position = (String)job.get('title');
            String location = (String)job.get('location');
            String url = (String)job.get('link');
            String joobleId = String.valueOf(job.get('id'));
            String company = (String)job.get('company');

            app.Position_Title__c = position;
            app.Location__c = location;
            app.URL__c = url;
            app.Jooble_Id__c = joobleId;
            app.Status__c = 'Saved';

            if (checkIfCompanyExists(company) != null) {
                app.Company_Name__c = checkIfCompanyExists(company);
            } else {
                if (company != null) {
                    app.Company_Name__c = createCompany(company);
                }
                
            }
            if (checkIfJobApplicationExists(joobleId) == false) {
                appsToInsert.add(app);
            }
            
        }

        insert appsToInsert;
    }

    public static Id checkIfCompanyExists(String companyName){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name =:companyName Limit 1];
        if (!accounts.isEmpty()) {
            return accounts[0].Id;
        } else {
            return null;
        }

    }

    public static Id createCompany (String companyName) {
        Account newAccount = new Account(Name = companyName);
        insert newAccount;
        
        return newAccount.Id;
    }

    public static Boolean checkIfJobApplicationExists(String Id) {
        List<Job_Application__c> jobApps = [SELECT Id, Jooble_Id__c FROM Job_Application__c WHERE Jooble_Id__c =:Id];
        if (!jobApps.isEmpty()) {
            return true;
        } else {
            return false;
        }
    }
}