@IsTest
global class ekotropeMockHttpProjListCallout implements HttpCalloutMock{
 global HTTPResponse respond(HTTPRequest req){
        //System.assertEquals('https://app.ekotrope.com/api/v1/projects?status=SUBMITTED_FOR_QA', req.getEndpoint());
     //'EkotropeAsModeled', '2015 IECC'
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[  {    "id": "1p1234k",  "selfOrPlanLastSavedAt": "2018-04-19T12:01:15.000+0000",  "name": "MoxyBuilders_241_Pine",    "createdAt": "2018-04-03T22:08:50.000+0000",    "createdBy": "egresham",  "selfOrPlanLastSavedAt":"aasdfasd",  "lastSavedAt": "2018-04-19T12:01:15.000+0000",    "lastSavedBy": "egresham",    "selfOrPlanLastSavedAt": "2018-04-19T12:01:15.000+0000",    "isLocked": false  },{    "id": "break",    "name": "MoxyBuilders_241_Pine", "selfOrPlanLastSavedAt": "2018-04-19T12:01:15.000+0000",   "createdAt": "2018-04-03T22:08:50.000+0000",    "createdBy": "egresham",    "lastSavedAt": "2018-04-19T12:01:15.000+0000",    "lastSavedBy": "egresham",    "selfOrPlanLastSavedAt": "2018-04-19T12:01:15.000+0000",    "isLocked": false  }]');
        res.setStatusCode(200);
        return res;      
    }
}