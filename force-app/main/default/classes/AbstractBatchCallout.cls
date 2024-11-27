public abstract class AbstractBatchCallout implements Database.Batchable<SObject>, Database.AllowsCallouts {

    protected abstract String getEndpoint();
    protected abstract String getMethod();
    protected abstract String getQuery();

    protected abstract void processResponse(SObject record, HttpResponse response, Map<Id, Set<String>> punchlinesByAccount);

    protected List<Id> recordsToProcess;
    protected Boolean isButton;

    public AbstractBatchCallout(List<Id> records, Boolean isButton) {
        this.recordsToProcess = records;
        this.isButton = isButton;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(getQuery());
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        
        Map<Id, Set<String>> punchlinesByAccount = new Map<Id, Set<String>>();

        for (SObject record : records) {
            Case ca = (Case) record;
            if (ca.AccountId != null) {
                Set<String> punchlines = punchlinesByAccount.get(ca.AccountId);
                if (punchlines == null) {
                    punchlines = new Set<String>();
                    punchlinesByAccount.put(ca.AccountId, punchlines);
                }
                if (ca.Reason_Description__c != null) {
                    punchlines.add(ca.Reason_Description__c);
                }
                if (ca.Reason_Details__c != null) {
                    punchlines.add(ca.Reason_Details__c);
                }
            }
        }

        for (SObject record : records) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(getEndpoint());
            req.setMethod(getMethod());

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                processResponse(record, res, punchlinesByAccount);
            } else {
                System.debug('API callout failed with status code: ' + res.getStatusCode());
            }
        }

        update records;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing complete.');
    }
}