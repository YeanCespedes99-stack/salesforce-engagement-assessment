public class EngagementSummaryController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEngagementData(Id recordId) {
        Map<String, Object> result = new Map<String, Object>();
        
        // Get Engagement with related Opportunity
        Engagement__c eng = [
            SELECT Id, Name, OportunidadRelacionada__c,
                   OportunidadRelacionada__r.Amount
            FROM Engagement__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        
        // Opportunity Amount
        result.put('opportunityAmount', eng.OportunidadRelacionada__r != null ? 
                   eng.OportunidadRelacionada__r.Amount : 0);
        
        // Count completed Tasks
        Integer completedTasks = [
            SELECT COUNT() FROM Task
            WHERE WhatId = :recordId AND Status = 'Completed'
        ];
        result.put('completedTasks', completedTasks);
        
        // Count upcoming Events
        Integer upcomingEvents = [
            SELECT COUNT() FROM Event
            WHERE WhatId = :recordId AND StartDateTime >= TODAY
        ];
        result.put('upcomingEvents', upcomingEvents);
        
        return result;
    }
    
    @AuraEnabled
    public static void createFollowUpCall(Id recordId, String engagementName) {
        Task t = new Task();
        t.Subject = 'Follow-up on ' + engagementName;
        t.Type = 'Call';
        t.Status = 'Not Started';
        t.ActivityDate = Date.today().addDays(1);
        t.WhatId = recordId;
        insert t;
    }
}