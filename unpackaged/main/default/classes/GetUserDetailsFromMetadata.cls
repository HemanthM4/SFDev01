public class GetUserDetailsFromMetadata {
    public static wrapUser getUserEmailIds(){
        wrapUser wrap = new wrapUser();
        Set<String> userId = new Set<String>();
        Set<String> userEmailids = new Set<String>();
        List< EmailNotificationUserDef__c> emailNoti = [SELECT id,User_name__c from  EmailNotificationUserDef__c ];
        List<String> userName = new List<String>();
        if(emailNoti.size() !=0 && emailNoti[0].User_name__c!=null){
            if(emailNoti[0].User_name__c.contains(',')){
                userName = emailNoti[0].User_name__c.split(',');
            }else{
                userName.add(emailNoti[0].User_name__c);     
            }
        }
        for(User usr: [SELECT id,Email from user where Name  IN :userName]){
            wrap.userIds.add(usr.id);
            if(usr.Email !=null && usr.Email != '')
                wrap.userEmailIds.add(usr.Email);
        }
        return wrap;
    }
    public class wrapUser {
        public Set<String> userEmailIds {get; set;}
        public Set<String> userIds {get; set;}
        
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapUser() {
            userEmailIds = new Set<String>();
            userIds = new Set<String>();
        }
    }
    
}