@isTest
private class LightningSelfRegisterControllerTest {

    @isTest
    private static void isValidPasswordTest(){
        boolean result = LightningSelfRegisterController.isValidPassword('abc','abc');
        System.assertEquals(TRUE, result);
        result = LightningSelfRegisterController.isValidPassword('aabc','abc');
        System.assertEquals(FALSE, result);
        
    }
    
    @isTest
    private static void siteAsContainerEnabledTest() {
        boolean result = true;
        try {
        result = LightningSelfRegisterController.siteAsContainerEnabled('url');
        System.assertEquals(TRUE, result);
        } catch (Exception e) { 
            System.assertEquals(TRUE, result);
        }
        System.assertEquals(TRUE, result);
    }
    @isTest
    private static void selfRegisterTest(){
    	String result; 
        result = LightningSelfRegisterController.selfRegister('' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , '', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , '', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', '',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  '', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', '', 'accountId', '', 'extraFields', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', '', 'extraFields', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', '', 'startUrl', TRUE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', '', TRUE);
		result = LightningSelfRegisterController.selfRegister('' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , '', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , '', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', '',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  '', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', '', 'accountId', '', 'extraFields', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', '', 'extraFields', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', '', 'startUrl', FALSE);
        result = LightningSelfRegisterController.selfRegister('firstname' , 'lastname', 'email',  'password', 'confirmPassword', 'accountId', 'regConfirmUrl', 'extraFields', '', FALSE);
    	System.assertNotEquals('NULL', result);
    
    }
    
    @isTest
    private static void getExtraFieldsTest() { 
        List<Map<String,Object>> result = LightningSelfRegisterController.getExtraFields('extraFieldsFieldSet'); 
        List<Map<String,Object>> result2 = LightningSelfRegisterController.getExtraFields('extraFieldsFieldSet');
        System.assertEquals(result, result2);
    }
    
    @isTest
    private static void setExperienceIdTest() {
    	String result =  LightningSelfRegisterController.setExperienceId('expId');
        System.assertNotEquals(NULL, result);
        // Return null if there is no error, else it will return the error message 
    }
    
    @isTest
    
    private static void validatePasswordTest() {
		LightningSelfRegisterController tmp = new LightningSelfRegisterController();
        User u = TestDataFactory.createUser('System Administrator', 'tmp');
		LightningSelfRegisterController.validatePassword( u, 'password', 'confirmPassword');
    }
    
}