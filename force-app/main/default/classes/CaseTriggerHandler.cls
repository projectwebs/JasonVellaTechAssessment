public without sharing class CaseTriggerHandler {

    private static final String REASON = 'Service';
    private static Boolean isTriggerExecuted = false;

    public static void processCases(list<case> newCases, map<id, case> oldCases, System.TriggerOperation operationType) {
        if (isTriggerExecuted) {
            return; 
        }

        isTriggerExecuted = true;

        switch on operationType {
            when AFTER_UPDATE {
                onCaseReasonUpdate(newCases, oldCases);
            }
        }
        
        isTriggerExecuted = false;
    }

    public static void onCaseReasonUpdate(list<case> newCases, map<id, case> oldCases){
        List<Id> caseIds = new List<Id>();

        for (Case c : newCases) {
            if (c.Reason == REASON && oldCases.get(c.Id).Reason != REASON) {
                caseIds.add(c.id);
            }
        }
    
        if (!caseIds.isEmpty()) {
            startBatchProcess(caseIds);
        }
    }

    public static void startBatchProcess(List<Id> casesToProcess) {
        BatchCalloutJokeAPI batch = new BatchCalloutJokeAPI(casesToProcess, False);
        Database.executeBatch(batch, 50);
    }

    @AuraEnabled
    public static void startBatchFromButton(String caseId) {
        List<Id> casesToProcess = new List<Id>{ caseId };
        
        BatchCalloutJokeAPI batch = new BatchCalloutJokeAPI(casesToProcess, True);
        Database.executeBatch(batch, 1);
    }
}