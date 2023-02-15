public without sharing class FileUploadController {
    @AuraEnabled
    public static String saveFile(Id parentId, String fileName, String base64Data, String contentType, String fileId,String ServiceAppointmentforPopup) {
        String isSuccess ='Success';
        System.debug('entered APex ');
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title =fileName; 
        testContentInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        testContentInsert.PathOnClient='/' + fileName ;
        try{
            insert testContentInsert; 
        }catch(Exception ex){
            isSuccess = ex.getMessage();
            System.debug('isSuccess'+isSuccess);
        }
        
        testContentInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: testContentInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = testContentInsert.ContentDocumentId;
        cl.LinkedEntityId = ServiceAppointmentforPopup; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        
        try{
            insert cl;
        }catch(Exception ex){
            isSuccess = ex.getMessage();
        }
        
        return isSuccess;
    }
    
    
}