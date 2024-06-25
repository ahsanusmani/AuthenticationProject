public class GoogleEventTriggerController {
    
    
    @future(callout=true)
    public static void googleCloudEventApi(Set<Id> setOfEventIds){
        GoogleMeetCredentials__c gmC= [Select id,Access_Token__c,Refresh_Token__c,Client_Id__c,Client_Secret__c,Redirect_uri__c,Scope__c from GoogleMeetCredentials__c where Name__c='testAccountCred'];
        List<Google_Event__c> eventList=new List<Google_Event__c>();
        for(Google_Event__c goEvent:[Select id,Title__c,Start_Time__c,End_Time__c,Description__c,Meeting_Link__c from Google_Event__c where Id IN:setOfEventIds]){
            System.debug('Start Time'+goEvent.Start_Time__c);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/primary/events?conferenceDataVersion=1');
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('POST');
            String requestBody='{ "summary": "'+goEvent.Title__c+'", "description": "'+goEvent.Description__c+'", "start": { "dateTime": "'+goEvent.Start_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')+'+05:30", "timeZone": "Asia/Kolkata" }, "end": { "dateTime": "'+goEvent.End_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')+'+05:30", "timeZone": "Asia/Kolkata" }, "conferenceData": { "createRequest": { "requestId": "sample123", "conferenceSolutionKey": { "type": "hangoutsMeet" } } } }';
            request.setHeader('Authorization', 'Bearer '+gmC.Access_Token__c); 
             request.setBody(requestBody);
            HttpResponse response = http.send(request);
            Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String hangoutLink = (String) parsedResponse.get('hangoutLink');
            eventList.add(new Google_Event__c(Id=goEvent.Id, Meeting_Link__c=(String) parsedResponse.get('hangoutLink')));
            System.debug('status: '+response.getStatus());
            System.debug('Code: '+response.getStatusCode());
            System.debug('body: '+response.getBody());
        }
        if(!eventList.isEmpty()){   update eventList;   }
      
        
    }

}