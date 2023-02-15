@isTest
private class LightningForgotPasswordControllerTest {

    @isTest
    private static void forgotPasswordTest() {
        String result;
        result = LightningForgotPasswordController.forgotPassword('a','c');
        System.AssertNotEquals('NULL',result);
        result = LightningForgotPasswordController.forgotPassword(null,null);
        System.AssertNotEquals('NULL',result);
    }
    
    @isTest
    private static void setExperienceIdTest() {
    	string result = LightningForgotPasswordController.setExperienceId('expId');
        System.assertNotEquals(null, result);
    }
    
    @isTest
    private static void constructorTest() {
        LightningForgotPasswordController tmp = new LightningForgotPasswordController();
       // System.assertNotEquals(tmp1, tmp2);
    }
    
}