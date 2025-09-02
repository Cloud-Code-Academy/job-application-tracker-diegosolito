public with sharing class EmailHelper {
    
    public static void sendReminderEmails() {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Date today = Date.today();
        List<Event> nextdayEvents = [SELECT ActivityDate, Subject, Owner.Email, Owner.FirstName, WhatId, StartDateTime,EndDateTime, Location  FROM Event WHERE Subject = 'Meeting' AND ActivityDate = :today + 1 AND WhatId != null];
        Set<Id> appIds = new Set<Id>();
        for (Event ev: nextdayEvents) {
             if (ev.WhatId != null && ev.WhatId.getSObjectType() == Job_Application__c.SObjectType) {
                appIds.add(ev.WhatId);
            }
        }
        Map<Id,Job_Application__c> appsById = new Map<Id,Job_Application__c>([SELECT Id, Position_Title__c FROM Job_Application__c WHERE Id IN :appIds]);
        for (Event ev : nextdayEvents) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String [] {ev.Owner.Email});
            String position = appsById.get(ev.WhatId).Position_Title__c;
            email.setSubject('Reminder Interview for the position: ' + position);
            String emailBody = '<h2>Meeting Reminder</h2>';
            emailBody += '<p><strong>Meeting:</strong> ' + position + '</p>';
            emailBody += '<p><strong>Date:</strong> ' + ev.ActivityDate.format() + '</p>';
            emailBody += '<p><strong>Time:</strong> ' + ev.StartDateTime.format('h:mm a') + ' - ' + ev.EndDateTime.format('h:mm a') + '</p>';
            emailBody += '<p><strong>Location:</strong> ' + ev.Location + '</p>';
            email.setHtmlBody(emailBody);
            emailList.add(email);
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
}