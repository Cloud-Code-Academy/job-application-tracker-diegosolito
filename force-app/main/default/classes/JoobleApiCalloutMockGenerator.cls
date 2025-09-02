global with sharing class JoobleApiCalloutMockGenerator implements HttpCalloutMock {
    
    Date dateFrom = Date.today().addDays(-2);
    String dateFromStr = dateFrom.format();
    String updatedIso  = dateFromStr + 'T00:00:00.0000000';

    // build one job
    Map<String, Object> job = new Map<String, Object>{
        'title'   => 'Junior Salesforce Developer',
        'location'=> 'Washington DC',
        'snippet' => 'We are seeking a Junior Salesforce Developer...',
        'salary'  => '',
        'source'  => 'wayup.com',
        'type'    => 'Full-time',
        'link'    => 'https://jooble.org/desc/2570080932128472823',
        'company' => 'Maximus',
        'updated' => updatedIso,
        'id'      => 2570080932128472823L
    };

    // response body map
    Map<String, Object> body = new Map<String, Object>{
        'totalCount'      => 1,
        'jobs'            => new List<Object>{ job },
        'datecreatedfrom' => dateFromStr
    };
    public HttpResponse respond(HttpRequest req) {
        //create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody(JSON.serialize(body));

        return res;
    }
}