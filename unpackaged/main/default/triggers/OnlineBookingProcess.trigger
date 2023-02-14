trigger OnlineBookingProcess on Online_Bookings__c (after insert) {
    
    if(Trigger.isAfter){ 
        OnlineBookingProcessHelper.processOnlineBooking(Trigger.new); 
    }
}