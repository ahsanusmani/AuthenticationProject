public class GoogleMeetConfigController {

    
    public static void getAccessTokenCode(){
        System.debug('currentPage '+Apexpages.currentPage());
        System.debug('Parameters '+Apexpages.currentPage().getParameters());
        GoogleMeetCredentials__c gmC= [Select id,Access_Token__c,Refresh_Token__c,Client_Id__c,Client_Secret__c,Redirect_uri__c,Scope__c from GoogleMeetCredentials__c where Name__c='testAccountCred'];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://oauth2.googleapis.com/token');
        req.setMethod('POST');
        String requestBody = 'code='+Apexpages.currentPage().getParameters().get('code') ;
        requestBody += '&client_id=' + EncodingUtil.urlEncode(gmC.Client_Id__c, 'UTF-8');
        requestBody += '&client_secret=' + EncodingUtil.urlEncode(gmC.Client_Secret__c, 'UTF-8');
        requestBody += '&redirect_uri=' + EncodingUtil.urlEncode(gmC.Redirect_uri__c, 'UTF-8');
        requestBody += '&grant_type=authorization_code';
        req.setBody(requestBody);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('statusCode'+res.getStatusCode());
        System.debug('statusCode'+res.getStatus());
        System.debug('statusCode'+res.getBody());
        if(res.getStatusCode()==200 || res.getStatusCode()==201){
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            gmC.Access_Token__c=(String) tokenResponse.get('access_token');
            gmc.Refresh_Token__c=(String) tokenResponse.get('refresh_token');
            update gmC;
        }
        
        
        
        
        
    }
    
}