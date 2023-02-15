@isTest
public class InactiveUserTest {
    @isTest
    static void getUserTest(){
        List<User> userL = [select id, name from user where Profile.Name='System Administrator' AND Deactivated_Date__c=TODAY ];
        InactiveUser.getUser();
    }

}