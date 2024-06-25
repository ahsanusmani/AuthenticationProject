public class HubSpotContactQueueable implements Queueable, Database.AllowsCallouts {
    
    public set<Id> setOfContactAccountId=new Set<Id>();
    public String checkAPIMethod;
    
    public HubSpotContactQueueable(set<Id> setOfContactAccountId, String checkAPIMethod){
        this.setOfContactAccountId=setOfContactAccountId;
        this.checkAPIMethod=checkAPIMethod;
    }
    
    
    public void execute(QueueableContext context) { 
        HubspotCredential__c hubCre=[Select id,Access_Token__c,Client_Id__c,Client_Secret__c, Refresh_Token__c from HubspotCredential__c LIMIT 1];
        String accessToken=getValidAccessToken(hubCre);
        String query='Select id, ';
        if(checkAPIMethod=='ContactInsert' || checkAPIMethod=='ContactUpdate'){
            query+=' FirstName, LastName, Phone,HubSpot_Contact_Id__c, Email ';
        }
        if(checkAPIMethod=='ContactDelete'){
            query+=' HubSpot_Contact_Id__c ';
        }
        query+=' From Contact where Id IN: setOfContactAccountId';
        System.debug('query: '+query);
        List<Contact> executedconList=new List<Contact>();
        Set<Id> remainingContactIds=new Set<Id>();
        for(Contact con: Database.query(query)){
            if(executedconList.size()<100){  executedconList.add(con); }
            else{  remainingContactIds.add(con.Id); }
        }
        List<Contact> updatedContactList=new List<Contact>();
        for(Contact con: executedconList){
            String endPoint='';
            String methodName='';
            String reqBody=null;
            if(checkAPIMethod=='ContactDelete'){
                methodName='DELETE';
                endPoint='https://api.hubapi.com/crm/v3/objects/contacts/'+con.HubSpot_Contact_Id__c;
            }
            if(checkAPIMethod=='ContactInsert'){
               methodName='POST';
               endPoint='https://api.hubapi.com/crm/v3/objects/contacts';
            }
            if(checkAPIMethod=='ContactUpdate'){
                methodName='PATCH';
                
                 endPoint='https://api.hubapi.com/crm/v3/objects/contacts/'+con.HubSpot_Contact_Id__c;
            }
            if(checkAPIMethod!='ContactDelete'){
                reqBody='{ "properties": { "lastname": "'+con.LastName+'", ';
                if(con.Email!=null){  reqBody+='"email": "'+con.Email+'",';  }
                if(con.FirstName!=null){  reqBody+='"firstname": "'+con.FirstName+'",';  }
                if(con.Phone!=null){  reqBody+='"phone": "'+con.Phone+'",';  }
                reqBody+='"company": "Cyntexa", "website": "Cyntexa.com", "lifecyclestage": "marketingqualifiedlead" } }';
            }
            System.debug('reqBody: '+reqBody);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer '+accessToken);  
            request.setMethod(methodName);
            request.setEndpoint(endPoint);
            if(reqBody!=null){ request.setBody(reqBody);   }
            HttpResponse response = http.send(request);
            System.debug('code: '+response.getStatusCode());
            System.debug('getStatus: '+response.getStatus());
            System.debug('body: '+response.getBody());
            if(checkAPIMethod=='ContactInsert' || checkAPIMethod=='ContactDelete' ){
                if(response.getStatusCode()==200 || response.getStatusCode()==201 || response.getStatusCode()==204 || response.getStatusCode()==202 ){
                    String contactId='';
                    if(checkAPIMethod!='ContactDelete'){  
                       Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        contactId=(String) parsedData.get('id');
                    }
                    updatedContactList.add(new Contact(Id=con.Id,HubSpot_Contact_Id__c= contactId) );
                }
            }
        }
        if(!updatedContactList.isEmpty()) {update updatedContactList;}
        if(!remainingContactIds.isEmpty()) { System.enqueueJob(new HubSpotContactQueueable(remainingContactIds, checkAPIMethod)); }
        if(accessToken!=hubCre.Access_Token__c){
            hubCre.Access_Token__c=accessToken;
            update hubCre;
        }
        
    }
    
    
    public static String getValidAccessToken(HubspotCredential__c hubCre){
        Http checkHttp = new Http();
        HttpRequest checkRequest = new HttpRequest();
        checkRequest.setHeader('Content-Type', 'application/json');
        checkRequest.setHeader('Authorization', 'Bearer '+EncodingUtil.urlEncode(hubCre.Access_Token__c, 'UTF-8')); 
        checkRequest.setMethod('GET');
        checkRequest.setEndpoint('https://api.hubapi.com/crm/v3/objects/contacts?Content-Type=application/json&limit=1');
        HttpResponse checkResponse = checkHttp.send(checkRequest);
        System.debug('Check code: '+checkResponse.getStatusCode());
        System.debug('Check getStatus: '+checkResponse.getStatus());
        System.debug('Check body: '+checkResponse.getBody());
        if(checkResponse.getStatusCode()==200){ return hubCre.Access_Token__c; }
        else{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('https://api.hubapi.com/oauth/v1/token');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String requestBody='grant_type=refresh_token&client_id='+EncodingUtil.urlEncode(hubCre.Client_Id__c, 'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(hubCre.Client_Secret__c, 'UTF-8')
            +'&refresh_token=' + EncodingUtil.urlEncode(hubCre.Refresh_Token__c, 'UTF-8');
            request.setBody(requestBody);
            HttpResponse response = http.send(request);
            System.debug('Access Token code: '+response.getStatusCode());
            System.debug('Access Token getStatus: '+response.getStatus());
            System.debug('Access Token body: '+response.getBody());
            if(response.getStatusCode()==200){
                Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return (String) parsedData.get('access_token');
            }
        }
        return null;
    }
}