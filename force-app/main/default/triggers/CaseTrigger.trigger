trigger CaseTrigger on Case (after update) {
    CaseTriggerHandler.processCases(Trigger.new, Trigger.oldMap, Trigger.operationType);
}