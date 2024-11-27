@isTest
private class BatchCalloutJokeAPITest {

    @TestSetup
    static void makeData(){
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        Account acct2 = new Account(Name = 'Test Account2');
        insert acct2;

        Case testCase1 = new Case(
            Subject = 'Test 1',
            AccountId = acct.Id,
            Reason_Description__c = 'Old description',
            Reason_Details__c = 'Old details'
        );

        Case testCase2 = new Case(
            Subject = 'Test 2',
            AccountId = acct2.Id,
            Reason_Description__c = 'Another old description',
            Reason_Details__c = 'Another old details'
        );

        insert new List<Case>{testCase1, testCase2};
    }

    @isTest
    static void testBatchExecutionWithoutButton() {
        List<Case> caseList = [SELECT ID FROM CASE LIMIT 2];
        List<Id> caseIds = new List<Id>();

        for(Case c : caseList){
            caseIds.add(c.id);
        }

        BatchCalloutJokeAPI batch = new BatchCalloutJokeAPI(caseIds, false); 

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Database.executeBatch(batch);
        Test.stopTest();

        Case testCase1 = [SELECT Reason_Description__c, Reason_Details__c FROM Case WHERE Subject = 'Test 1'];
        Case testCase2 = [SELECT Reason_Description__c, Reason_Details__c FROM Case WHERE Subject = 'Test 2'];

        System.assertEquals('This is the punchline', testCase1.Reason_Details__c, 'Reason_Details__c should be updated with the punchline.');
        System.assertEquals('This is the punchline', testCase2.Reason_Details__c, 'Reason_Details__c should be updated with the punchline.');

        System.assertEquals('Old description', testCase1.Reason_Description__c, 'Reason_Description__c should not change.');
        System.assertEquals('Another old description', testCase2.Reason_Description__c, 'Reason_Description__c should not change.');
    }

    @isTest
    static void testBatchExecutionWithButton() {
        List<Case> caseList = [SELECT ID FROM CASE LIMIT 2];
        List<Id> caseIds = new List<Id>();

        for(Case c : caseList){
            caseIds.add(c.id);
        }

        BatchCalloutJokeAPI batch = new BatchCalloutJokeAPI(caseIds, true); 

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Database.executeBatch(batch);
        Test.stopTest();

        Case testCase1 = [SELECT Reason_Description__c, Reason_Details__c FROM Case WHERE Subject = 'Test 1'];
        Case testCase2 = [SELECT Reason_Description__c, Reason_Details__c FROM Case WHERE Subject = 'Test 2'];

        System.assertEquals('This is the punchline', testCase1.Reason_Description__c, 'Reason_Description__c should be updated with the punchline.');
        System.assertEquals('This is the punchline', testCase2.Reason_Description__c, 'Reason_Description__c should be updated with the punchline.');

        System.assertEquals('Old details', testCase1.Reason_Details__c, 'Reason_Details__c should not change.');
        System.assertEquals('Another old details', testCase2.Reason_Details__c, 'Reason_Details__c should not change.');
    }

    @isTest
    static void testBatchExecutionWithPunchlineAlready() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        Case testCase1 = new Case(
            AccountId = acct.Id,
            Reason_Description__c = 'Old description',
            Reason_Details__c = 'Old details'
        );
        Case testCase2 = new Case(
            AccountId = acct.Id,
            Reason_Description__c = 'Another old description',
            Reason_Details__c = 'Another old details'
        );
        insert new List<Case>{testCase1, testCase2};

        List<Id> caseIds = new List<Id>{testCase1.Id, testCase2.Id};
        BatchCalloutJokeAPI batch = new BatchCalloutJokeAPI(caseIds, false); 

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Database.executeBatch(batch);
        Test.stopTest();

        testCase1 = [SELECT Reason_Description__c, Reason_Details__c FROM Case WHERE Id = :testCase1.Id];
        testCase2 = [SELECT Reason_Description__c, Reason_Details__c FROM Case WHERE Id = :testCase2.Id];

        System.assertEquals('This is the punchline', testCase1.Reason_Details__c, 'Reason_Details__c should be updated with the punchline.');
        System.assertEquals('Another old details', testCase2.Reason_Details__c, 'Reason_Details__c should not update.');

        System.assertEquals('Old description', testCase1.Reason_Description__c, 'Reason_Description__c should not change.');
        System.assertEquals('Another old description', testCase2.Reason_Description__c, 'Reason_Description__c should not change.');
    }
}