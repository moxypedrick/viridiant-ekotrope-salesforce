@IsTest
global class ekotropePutCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req){
        // Create a fake response
        
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('err')){
            system.debug('ERR project');
            res.setHeader('Content-Type', 'application/json');
        	res.setBody('{"rawRegistryResponse":"yaGotIt", "automaticQaStatus":"Pass", "errorMessage":"happiness"}');//registryId":, 
        	res.setStatusCode(404);
            return res;
        }
            
        else if(req.getEndpoint().contains('null_id')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"rawRegistryResponse":"yaGotIt", "automaticQaStatus":"Pass", "errorMessage":"happiness"}');//"registryId":"null", 
            res.setStatusCode(200);
            return res;
        }
        else{
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"registryId":null, "rawRegistryResponse":"yaGotIt", "automaticQaStatus":"Pass", "errorMessage":"happiness"}');
            res.setStatusCode(200);
            return res;      
    	}
	}
}