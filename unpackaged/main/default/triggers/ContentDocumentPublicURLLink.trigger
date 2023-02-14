trigger ContentDocumentPublicURLLink on ContentDocumentLink (after insert) {
    
    if(Trigger.isAfter){ 
        //call apex class
        ContentDocumentURL.createPublicUrlLink(Trigger.new);
    }   
}