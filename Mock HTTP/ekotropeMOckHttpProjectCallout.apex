@isTest
global class ekotropeMockHttpProjectCallout implements HttpCalloutMock{
    global static HTTPResponse respond(HTTPRequest req){
        //System.assertEquals('https://app.ekotrope.com/api/v1/projects?status=SUBMITTED_FOR_QA', req.getEndpoint());
        //'EkotropeAsModeled', '2015 IECC'
        // Create a fake response
        system.debug('mockProject req.Endpoint---'+ req.getEndpoint());
        string breakkey = '';
        if(req.getEndpoint().contains('break')){
            breakkey = 'break';
        }
        Integer len = 10;
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String pwd = key.substring(0,len) + breakkey;  
        system.debug(pwd);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string body = '{  "id":'+'"'+pwd +'",  "name": "CHERS_LoudonHfH_234HopeWay_CondCrawl_5_30_18",  "createdAt": "2018-05-30T16:54:55.000+0000",  "createdBy": "jcooper",  "lastSavedAt": "2018-05-30T16:56:34.000+0000",  "lastSavedBy": "jcooper",  "selfOrPlanLastSavedAt": "2018-05-30T16:56:34.000+0000",  "isLocked": false,  "status": "REGISTERED_WITH_PROVIDER",  "location": {    "streetAddress": "234 Hope Way",    "city": "Loudon",    "state": "TN",    "zip": "37774",    "climateZone": {      "zone": 4,      "moistureRegime": "MOIST"    }  },  "notes": "JEC 5.22.18<br>Same plannHfH-243Ho_QAD<br><br>ARI Match #8996251",  "model": "2648 ",  "community": "Hope Haven",  "builder": "Loudon Co. Habitat",  "builderPermitDateOrNumber": "",  "hersRatingDetails": {    "rater": {      "name": "Joe Cooper",      "email": "joe@ecosouth.org",      "resnetRaterId": "9740236",      "resnetProviderId": "1998-057",      "ratingCompany": {        "name": "Ecosouth Green Building Services",        "id": "PKYGl435"      }    }, "registryId":"902299197","ratingDate":"2020-01-01T01:23:19.000+0000",   "fieldRatingDate": "2016-12-21T00:00:00.000+0000",    "ratingType": "CONFIRMED" , "associatedUsers": [{"name": "Chad Peaden", "userType": "FieldInspector","fieldInspectorId": "755HW3"}]},  "plans": [    {      "id": "l7RJKxK7",      "name": "CHERS_LoudonHfH_243HopeWay_CondCrawl_ES-LfH_12-21-16_QAD"    },    {      "id": "Q7E65eb3",      "name": "CHERS_LoudonHfH_230HopeWay_CondCrawl_"    },    {      "id": "G3M4JEv7",      "name": "CHERS_LoudonHfH_234HopeWay_CondCrawl_JEC"    }  ],  "masterPlanId":'+'"' +pwd +'"'+   ',  "resultsUnchangedSince": "2018-05-30T16:56:34.000+0000",  "utilityRates": [    {      "fuel": "ELECTRIC",      "name": "Loudon Electric"    }  ],  "algorithmVersion": "2.2.5"}'  ; 
        system.debug(body);
        res.setBody(body);//+',  "name": "CHERS_LoudonHfH_234HopeWay_CondCrawl_5_30_18",  "createdAt": "2018-05-30T16:54:55.000+0000",  "createdBy": "jcooper",  "lastSavedAt": "2018-05-30T16:56:34.000+0000",  "lastSavedBy": "jcooper",  "selfOrPlanLastSavedAt": "2018-05-30T16:56:34.000+0000",  "isLocked": false,  "status": "REGISTERED_WITH_PROVIDER",  "location": {    "streetAddress": "234 Hope Way",    "city": "Loudon",    "state": "TN",    "zip": "37774",    "climateZone": {      "zone": 4,      "moistureRegime": "MOIST"    }  },  "notes": "JEC 5.22.18<br>Same plannHfH-243Ho_QAD<br><br>ARI Match #8996251",  "model": "2648 ",  "community": "Hope Haven",  "builder": "Loudon Co. Habitat",  "builderPermitDateOrNumber": "",  "hersRatingDetails": {    "rater": {      "name": "Joe Cooper",      "email": "joe@ecosouth.org",      "resnetRaterId": "9740236",      "resnetProviderId": "1998-057",      "ratingCompany": {        "name": "Ecosouth Green Building Services",        "id": "PKYGl435"      }    },    "fieldRatingDate": "2016-12-21T00:00:00.000+0000",    "ratingType": "CONFIRMED" , "associatedUsers": [{"name": "Chad Peaden", "userType": "FieldInspector","fieldInspectorId": "755HW3"}]},  "plans": [    {      "id": "l7RJKxK7",      "name": "CHERS_LoudonHfH_243HopeWay_CondCrawl_ES-LfH_12-21-16_QAD"    },    {      "id": "Q7E65eb3",      "name": "CHERS_LoudonHfH_230HopeWay_CondCrawl_"    },    {      "id": "G3M4JEv7",      "name": "CHERS_LoudonHfH_234HopeWay_CondCrawl_JEC"    }  ],  "masterPlanId": "Q7E65eb3",  "resultsUnchangedSince": "2018-05-30T16:56:34.000+0000",  "utilityRates": [    {      "fuel": "ELECTRIC",      "name": "Loudon Electric"    }  ],  "algorithmVersion": "2.2.5"}' ) ; 
        res.setStatusCode(200);
        return res;      
    }
}