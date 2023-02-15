public without sharing class PORTAL_ProfilePictureController {
    @AuraEnabled 
    public static user fetchUserDetail(){
        return [Select id,Name,SmallPhotoUrl, FullPhotoUrl
                From User
                Where Id =: Userinfo.getUserId()];
    }
    @AuraEnabled
    public static string saveAttachment(String parentId,String fileName,String base64Data,String contentType){
        String isSuccess ='Success';
        Blob beforeblob = Blob.valueOf(base64Data);
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        Blob afterblob = EncodingUtil.base64Decode(paramvalue);
        
        blob body=EncodingUtil.base64Decode(base64Data);
        String communityId = null;
        
        ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(body, contentType, fileName);  
        ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), Userinfo.getUserId(), fileUpload);
        
        
        //  ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(body, contentType, fileName);  
        //  ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), Userinfo.getUserId(), fileUpload);
        // ConnectApi.Photo photoProfile = ConnectApi.ChatterUsers.setPhoto(ConnectApi.Communities.getCommunities(), , fileUpload);
        
        
        return isSuccess;
    }
     @AuraEnabled
    public static string uploadFile(String fileName, String base64Data, String contentType) { 
          String isSuccess ='Success';
         blob body=EncodingUtil.base64Decode(base64Data);
         ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(body, contentType, fileName);  
        ConnectApi.Photo photoProfile = ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(), Userinfo.getUserId(), fileUpload);
        return  isSuccess;
    }
}