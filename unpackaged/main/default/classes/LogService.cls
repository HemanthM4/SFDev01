/**
 * @author      Andrey Gorun
 * @version     1.0
 */

/**
 *  @description
 *   LogService.Log newLog = LogService.createLog();
 *   newLog.addError(Label.SOMETHING_WENT_WRONG + String.join(pPaymentBatchIds, ''));
 *   newLog.save();
 *
 */

public with sharing class LogService {
     public LogService() {}
   /* public static final Integer LOG_LEVEL_ERROR = 2;
    public static final Integer LOG_LEVEL_WARNING = 3;
    public static final Integer LOG_LEVEL_INFO = 4;
    public static final Integer LOG_LEVEL_DEBUG = 5;

    public static final Map<Integer, String> LOG_LEVEL_NAMES = new Map<Integer, String> {
        LOG_LEVEL_ERROR => 'ERROR',
        LOG_LEVEL_WARNING => 'WARNING',
        LOG_LEVEL_INFO => 'INFO',
        LOG_LEVEL_DEBUG => 'DEBUG'
    };

   

    public static Log createLog() {
        return new Log();
    }

    public without sharing class Log {
        private List<String> logDescriptions;
        public Id paymentBatchId;
        public Id workOrderId;
        public Id deductionId;
        public Id refundId;
        public Id fixedCostId;

        public Log() {
            logDescriptions = new List<String>();
        }

        public void addError(String message) {
            String prefix = LOG_LEVEL_NAMES.get(LOG_LEVEL_ERROR);
            logDescriptions.add('\n' + prefix + ': ' + message);
        }
        public void addError(Exception e) {
            String prefix = LOG_LEVEL_NAMES.get(LOG_LEVEL_ERROR);
            logDescriptions.add('\n' + prefix + ': ' + e.getMessage() + e.getLineNumber() + '\n' + e.getStackTraceString());
        }

        public void save() {
            save(true);
        }

        public Error_Log__c save(Boolean isInsert) {
            String logDescription = getGeneralInfo();
            logDescription += String.join(logDescriptions, '\n');
            Error_Log__c logToInsert = new Error_Log__c (
                Engineer_Deduction__c = deductionId,
                Engineer_Refund__c = refundId,
                Error_Code__c = null,
                Error_Message__c = logDescription,
                Fixed_Costs_Engineer_Pay__c = fixedCostId,
                Payment_Batch__c = paymentBatchId,
                Run_Date__c = System.now().Date(),
                Work_Order__c = workOrderId
            );
            if (isInsert == true) {
                insert logToInsert;
            }
            return logToInsert;
        }

        public String getGeneralInfo() {
            String message = '';
            String endl = '\n';
            message += 'USER_ID: ' + UserInfo.getUserId() + endl;
            message += (paymentBatchId == null) ? '' : 'PAYMENT_BATCH_ID: ' + paymentBatchId + endl;
            return message;
        }
    }*/
}