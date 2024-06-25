trigger ContactTrigger on Contact (after insert,after update) {
    
    
    if(Trigger.isAfter){
        Set<Id> setOfNonAccountIds=new Set<Id>();
        Set<Id> setOfAccountIds=new Set<Id>();
        Set<Id> setOfUpdatedConAccountIds=new Set<Id>();
        if(Trigger.isInsert){
            for(Contact con: Trigger.new){
                if(con.AccountId==null){ setOfNonAccountIds.add(con.Id);  }
            }    
        }
        if(Trigger.isUpdate){
            for(Contact con: Trigger.new){
                if(con.AccountId==null && con.HubSpot_Contact_Id__c==null ){ setOfNonAccountIds.add(con.Id); }
                if(con.AccountId!=null && con.HubSpot_Contact_Id__c!=null){ setOfAccountIds.add(con.Id); }
                if(con.AccountId==null && (con.FirstName !=Trigger.oldMap.get(con.Id).FirstName || con.LastName !=Trigger.oldMap.get(con.Id).LastName || 
                                           con.Email !=Trigger.oldMap.get(con.Id).Email || con.Phone !=Trigger.oldMap.get(con.Id).Phone)){ 
                                               setOfUpdatedConAccountIds.add(con.Id);
                                           }
            }
        }
        
        if(!setOfNonAccountIds.isEmpty()){ System.enqueueJob(new HubSpotContactQueueable(setOfNonAccountIds, 'ContactInsert'));  } 
        if(!setOfAccountIds.isEmpty()){   System.enqueueJob(new HubSpotContactQueueable(setOfAccountIds, 'ContactDelete'));  } 
        if(!setOfUpdatedConAccountIds.isEmpty()){  System.enqueueJob(new HubSpotContactQueueable(setOfUpdatedConAccountIds, 'ContactUpdate'));  } 
        
    }
    
    
    
}