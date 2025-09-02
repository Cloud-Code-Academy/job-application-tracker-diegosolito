@IsTest
private with sharing class JoobleApiCalloutTest {
    
    @IsTest
    static void testpostJoobleApi() {
        
        Test.setMock(HttpCalloutMock.class, new JoobleApiCalloutMockGenerator());

        Test.startTest();
        JoobleApiCallout.postJoobleApi();
        Test.stopTest();

        List<Job_Application__c> apps = [SELECT Position_Title__c, Location__c, URL__c, Jooble_Id__c, Status__c FROM Job_Application__c];

        System.assertEquals(1, apps.size(), 'Exactly one job application should be created');
        System.assertEquals('Junior Salesforce Developer', apps[0].Position_Title__c);
        System.assertEquals('Washington DC', apps[0].Location__c);
        System.assertEquals('https://jooble.org/desc/2570080932128472823', apps[0].URL__c);
        System.assertEquals('2570080932128472823', apps[0].Jooble_Id__c);
        System.assertEquals('Saved', apps[0].Status__c);
        
    }
    
}