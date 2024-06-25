global class CountAuthSession{

    @InvocableMethod(label='Count AuthSession records for a User')
  public static List<SessionCount> getAuthSessions() {
     List<AuthSession> sessions;
       Integer no = 0;
        
        String userid   = UserInfo.getUserId();  
        
        sessions = [Select Id, ParentId, SessionType from AuthSession where UsersId=:userid];
        for (AuthSession s : sessions)
        {
            // Count only parent and non-temp sessions
            if(s.ParentId == null && s.SessionType != 'TempUIFrontdoor' )
            {
                    no++;
            }
        }
          List <SessionCount> sessionCount = new List <SessionCount>();
        SessionCount count = new SessionCount();
        count.no = no;
        sessionCount.add (count);
        return sessionCount;
  }
  global class SessionCount {
        
        @InvocableVariable
        global Integer no;
    }
    
}