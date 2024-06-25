trigger GoogleEventTrigger on Google_Event__c (after insert) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        GoogleEventTriggerController.googleCloudEventApi(Trigger.newMap.keySet());
        
    }

}