public class GoogleMeetController {
    
    @AuraEnabled(cacheable=true)
    public static GoogleMeetCredentials__c getGoogleMeetCredentials(){
        return [Select id,Access_Token__c,Refresh_Token__c,Client_Id__c,Client_Secret__c,Redirect_uri__c,Scope__c from GoogleMeetCredentials__c where Name__c='testAccountCred'];
        
    }
    
    @AuraEnabled
    public static Boolean isAccessTokenExpire(GoogleMeetCredentials__c gmC){
        Http httpGet = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/primary/events?timeMin=2015-06-13T00:00:00Z&timeMax=2015-06-13T00:00:00Z&singleEvents=true&maxResults=1&orderBy=startTime');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+gmC.Access_Token__c); 
        HttpResponse res = httpGet.send(req);
         System.debug('res status: '+res.getStatus());
         System.debug(' res Code: '+res.getStatusCode());
        if(res.getStatusCode()!=200){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://oauth2.googleapis.com/token');
             request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setMethod('POST');
            String requestBody = 'client_id=' + EncodingUtil.urlEncode(gmC.Client_Id__c, 'UTF-8');
            requestBody += '&client_secret=' + EncodingUtil.urlEncode(gmC.Client_Secret__c, 'UTF-8');
            requestBody += '&refresh_token=' + EncodingUtil.urlEncode(gmC.Refresh_Token__c, 'UTF-8');
            requestBody += '&grant_type=refresh_token';
            request.setBody(requestBody);
           
            HttpResponse response = http.send(request);
            if(response.getStatusCode()==200){
                 System.debug('status: '+response.getStatus());
            System.debug('Code: '+response.getStatusCode());
                System.debug('Body: '+response.getBody());
                Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                gmC.Access_Token__c=(String) tokenResponse.get('access_token');
                gmc.Refresh_Token__c=(String) tokenResponse.get('refresh_token');
                System.debug('gmC.Access_Token__c: '+gmC.Access_Token__c);
                 update gmC;
                
            }
            else{  return true;   }
            
           
        }
       
        return false;
        
    }
    
    @AuraEnabled
    public static List<Google_Event__c> getGoogleMeetings(String accountId){
        return [Select id,Title__c,Start_Time__c,End_Time__c,Description__c,Meeting_Link__c from Google_Event__c where AccountId__c=:accountId];
    }

}