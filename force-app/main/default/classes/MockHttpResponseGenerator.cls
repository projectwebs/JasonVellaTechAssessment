public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"punchline": "This is the punchline"}'); 
        return res;
    }
}