public class ContactTriggerHandler {
    
    
    
    @future(callout=true)
    public static void insertContact(){
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.hubapi.com/crm/v3/objects/contacts');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer pat-na1-adf3b388-ff00-4f2c-a354-b10ea4e6718a');
       request.setBody('{ "properties": { "email": "Testing12@hubspot.com", "firstname": "Ahsan", "lastname": "Usmani", "phone": "9999999", "company": "Cyntexa", "website": "Cyntexa.com", "lifecyclestage": "marketingqualifiedlead" } }');
        HttpResponse response = http.send(request);
        System.debug('code: '+response.getStatusCode());
        System.debug('getStatus: '+response.getStatus());
        System.debug('body: '+response.getBody());
        

    }
    
    public static void forUpdate(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String contactId='29417886789';
        request.setEndpoint('https://api.hubapi.com/crm/v3/objects/contacts/'+contactId);
        request.setMethod('PATCH');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer pat-na1-adf3b388-ff00-4f2c-a354-b10ea4e6718a');
        request.setBody('{ "properties": { "email": "Testing12@hubspot.com", "firstname": "Ahsan", "lastname": "Usmani", "phone": "9999999", "company": "Cyntexa", "website": "Cyntexa.com", "lifecyclestage": "marketingqualifiedlead" } }');
        HttpResponse response = http.send(request);
        System.debug('code: '+response.getStatusCode());
        System.debug('getStatus: '+response.getStatus());
        System.debug('body: '+response.getBody());
    }
    
    
    public static void forDelete(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String contactId='29417886789';
        request.setEndpoint('https://api.hubapi.com/crm/v3/objects/contacts/'+contactId);
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer pat-na1-adf3b388-ff00-4f2c-a354-b10ea4e6718a');
       // request.setBody('{ "properties": { "email": "Testing12@hubspot.com", "firstname": "Ahsan", "lastname": "Usmani", "phone": "9999999", "company": "Cyntexa", "website": "Cyntexa.com", "lifecyclestage": "marketingqualifiedlead" } }');
        HttpResponse response = http.send(request);
        System.debug('code: '+response.getStatusCode());
        System.debug('getStatus: '+response.getStatus());
        System.debug('body: '+response.getBody());
    }
    
}