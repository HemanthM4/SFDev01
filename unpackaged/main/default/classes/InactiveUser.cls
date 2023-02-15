public class InactiveUser {
    @AuraEnabled
    public static List<User> getUser(){
        List<user> userList = [ select id, name, Deactivated_Date__c,IsActive, LastModifiedBy.Name from user where Deactivated_Date__c=TODAY ];
        return userList;
    }

}