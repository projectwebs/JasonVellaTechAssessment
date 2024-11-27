@isTest
private class CaseTriggerHandlerTest {
    @TestSetup
    static void setupTestData() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        Case testCase1 = new Case(
            AccountId = acct.Id,
            Reason = 'Initial Reason',
            Reason_Description__c = 'Old description',
            Reason_Details__c = 'Old details'
        );
        Case testCase2 = new Case(
            AccountId = acct.Id,
            Reason = 'Initial Reason',
            Reason_Description__c = 'Another old description',
            Reason_Details__c = 'Another old details'
        );
        insert new List<Case>{ testCase1, testCase2 };
    }

    @isTest
    static void testProcessCases_TriggerScenario() {
        Case testCase = [SELECT Id, Reason FROM Case WHERE Reason = 'Initial Reason' LIMIT 1];
        testCase.Reason = 'Service';
        update testCase;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobs.size(), 'A batch job should be enqueued when a case Reason is updated to Service.');
    }

    @isTest
    static void testProcessCases_BatchProcess_TriggerLogic() {

        Case testCase = [SELECT Id, Reason FROM Case WHERE Reason = 'Initial Reason' LIMIT 1];
        testCase.Reason = 'Service';
        update testCase;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.stopTest();

        testCase = [SELECT Reason, Reason_Description__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Service', testCase.Reason, 'The Reason field should be updated to Service.');
    }

    @isTest
    static void testStartBatchFromButton() {
        Case testCase = [SELECT Id, Reason FROM Case WHERE Reason = 'Initial Reason' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CaseTriggerHandler.startBatchFromButton(testCase.Id);
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobs.size(), 'The batch job should be executed for the button-triggered case.');
    }
}