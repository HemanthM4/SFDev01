public class AccountStatementController {

    public list<Customer_Invoice__c> invoices {get; set;}
    public Account account {get;set;}
    public Decimal TotalDue{get; set;}
    public Decimal NotDue {get; set;}
    public Decimal OneMonthDue {get; set;}
    public Decimal TwoMonthsDue {get; set;}
    public Decimal ThreeMonthsDue {get; set;}
    public Decimal OverDue {get; set;}
    public Decimal BalanceOutstanding {get;set;}
//test
    public AccountStatementController( ) 
    {
        account = [
            SELECT id, Name, BillingStreet,BillingCity,BillingPostalCode,BillingCountry, Outstanding_Balance_Incl_VAT__c,Account_Reference__c
            FROM Account
            WHERE id = :ApexPages.currentPage().getParameters().get('id')
        ];
        invoices = [
            SELECT id, Name, Date__c, Job_Number__c, Site_Address__c, Charge_Net__c,Property_Address__c ,
            Charge_VAT__c,Charge_Gross__c, Balance_Outstanding__c
            FROM Customer_Invoice__c 
            WHERE Account__c = :ApexPages.currentPage().getParameters().get('id')
            AND Balance_Outstanding__c > 0
            ORDER BY Date__c ASC
        ];
        
        Apexpages.currentPage().getHeaders().put(
            'content-disposition', 
            'inline; filename=Aspect-Statement-'
            +account.Name.replaceAll(' ','-')+'-'
            +DateTime.newInstance(Date.Today(), Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
            +'.pdf'
        );
        TotalDue = 0;
        OverDue = 0;
     	NotDue = 0;
        OneMonthDue = 0;
        TwoMonthsDue = 0;
        ThreeMonthsDue = 0;
        BalanceOutstanding = 0;

        for(customer_Invoice__c ci:invoices)
        {
            BalanceOutstanding += ci.Balance_Outstanding__c;
            if(ci.date__c >= Date.today()-30 ){
                NotDue += ci.Balance_Outstanding__c;
            }
            if(ci.date__c < Date.today()-30 ){
                TotalDue += ci.Balance_Outstanding__c;
            }
            if(ci.date__c < Date.today()-30 && ci.date__c >= Date.today()-60 ){
                OneMonthDue += ci.Balance_Outstanding__c;
            }
            if(ci.date__c < Date.today()-60 && ci.date__c >= Date.today()-90 ){
                TwoMonthsDue += ci.Balance_Outstanding__c;
            }
            if(ci.date__c < Date.today()-90 && ci.date__c >= Date.today()-120 ){
                ThreeMonthsDue += ci.Balance_Outstanding__c;
            }
            if(ci.date__c < Date.today() - 120 ){
                ThreeMonthsDue += ci.Balance_Outstanding__c;
                OverDue += ci.Balance_Outstanding__c;
            }
        }
        
    }   
}