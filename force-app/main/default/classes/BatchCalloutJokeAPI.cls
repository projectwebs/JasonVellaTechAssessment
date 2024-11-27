public class BatchCalloutJokeAPI extends AbstractBatchCallout {

    protected override String getEndpoint() { return 'callout:official_joke_api'; }
    protected override String getMethod() { return 'GET'; }

    public BatchCalloutJokeAPI(List<Id> cases, Boolean isButton) {
        super(cases, isButton);
    }

    protected override String getQuery() { return 'SELECT Id, Reason_Details__c, Reason_Description__c, AccountId FROM Case WHERE Id IN :recordsToProcess';}

    protected override void processResponse(SObject record, HttpResponse response, Map<Id, Set<String>> punchlinesByAccount) {
        Case ca = (Case) record;

        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        String punchline = (String) jsonResponse.get('punchline');

        Set<String> existingPunchlines = punchlinesByAccount.get(ca.AccountId);

        if (existingPunchlines != null && existingPunchlines.contains(punchline)) {
            System.debug('Punchline already exists for Account: ' + ca.AccountId + '. Skipping update for Case: ' + ca.Id);
        } else {
            if (isButton) {
                ca.Reason_Description__c = punchline;
            } else {
                ca.Reason_Details__c = punchline;
            }

            if (existingPunchlines == null) {
                existingPunchlines = new Set<String>();
                punchlinesByAccount.put(ca.AccountId, existingPunchlines);
            }
            existingPunchlines.add(punchline);
        }
    }
}