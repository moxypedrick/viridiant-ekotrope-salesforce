global class ecmfSync implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful  {
   
    
    global List<String> projectIdList = new List<String>();
    global String authorization = '';
    private List<string> ekotropeStages = new List<string>();
    global List<Object> newResults = new List<Object>();
    global Map<String, String> existingViridiantMfProjectsMap = new Map<String, String>();
    global Map<String, List<String>> existingViridiantMFProjectsMapSfID = new Map<String, List<String>>(); 
    global Map<String, String> ekoIdMap = new Map<String, String>();
    
    private final List<string> codesToCheck = new List<string>();
    private List<string> buildingsToCheck = new List<string>();
    private string baselineBuilding = '';
    private string referenceBuilding = '';
    private string designBuilding = '';
    private string dataPrefix = '';
    
    global List<Project__c> ekotropeIdList = new List<Project__c>();
    global List<Building_Specifications__c> buildingSpecList = new List<Building_Specifications__c>();
    global List<Unit_Takeoff__c> unitTakeoffList = new List<Unit_Takeoff__c>();
    global List<HERS_Data__c> hersDataList = new List<HERS_Data__c>();
    
    
    
    global Iterable<String> start(Database.BatchableContext bc){
         
        //just add records where they do not exist and update records where they do
        //if ekotrope_self is blank, then add
        //if ekotrope_self is filled, check to see if update is necessary      
        // Now we need to get the MF ratings that have specified EkoIds          
        
   
        
        
        for(Unit_Takeoff__c existingMfProject : [Select Ekotrope_Model_ID__c, Ekotrope_selfOrPlanLastSavedAt__c, ID, Name   
                FROM Unit_Takeoff__c
                where Ekotrope_Model_ID__c != null and Ekotrope_selfOrPlanLastSavedAt__c = null])
                {
                    existingViridiantMfProjectsMap.put(existingMfProject.Id, 'add-record-details');
                    system.debug(existingMfProject.id);
                }
      
          for(Unit_Takeoff__c existingMfProject : [
                Select Ekotrope_Model_ID__c, Ekotrope_selfOrPlanLastSavedAt__c, ID, Name   
                FROM Unit_Takeoff__c
                where Ekotrope_Model_ID__c != null and Ekotrope_selfOrPlanLastSavedAt__c != null])
                {
                    List<String> updateStatusList = new List<String>();
                     system.debug(existingMfProject.id);
                    updateStatusList.add(existingMfProject.Ekotrope_Model_ID__c);
                    updateStatusList.add(existingMfProject.Id);
                    updateStatusList.add(existingMfProject.Ekotrope_selfOrPlanLastSavedAt__c);
                    existingViridiantMFProjectsMapSfID.put(existingMFProject.Id, updateStatusList);
                }
     system.debug(existingViridiantMFProjectsMapSfID);
        for(string ekoStage : ekotropeStages){       
            if(test.isRunningTest()){Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpProjListCallout());}  
            HttpResponse projectListResponse = ekotropeSync.getProjectList(authorization, ekoStage);        
            if(projectListResponse.getStatusCode() == 200){
                String newProjectList = String.valueOf(projectListResponse.getBody());
                if(projectListResponse.getBody() != ''){
                    newResults = (List<Object>)JSON.deserializeUntyped(newProjectList);                  
                    //iterate over all projects in ekotrope and add them to map          
                    for(Object project : newResults){
                        Map<String, Object> projectData = (Map<String, Object>)project;
                        //load ekotrope results into a map
                        ekoIdMap.put(String.valueOf(projectData.get('id')),String.valueOf(projectData.get('selfOrPlanLastSavedAt')));
                    }
                }
            }
        }
        //iterate over existingViridiantMFProjectsMapSfID
        //query the ekoIdMap and see if any selfOrPlanLastSavedAt are different 
        //to determine if any projects need updated
        system.debug(existingViridiantMfProjectsMap.keySet());
        system.debug('iterating over all of the existingViridiantMFProjectsMapSfIDs. This is may add a duplicate');           
        for(string salesforceID : existingViridiantMFProjectsMapSfID.keySet()){
            system.debug(salesforceID);
            
            //get the eko Id for this project
            String ekoId = existingViridiantMFProjectsMapSfID.get(salesforceID)[0];
            //get the lastplansaved date for this proejct
            String saveDate = existingViridiantMFProjectsMapSfID.get(salesforceID)[2];
            //get ekotropes' lastplansaved date
            String ekoSaveDate = ekoIdMap.get(ekoId);
            if(saveDate != ekoSaveDate){
                existingViridiantMfProjectsMap.put(salesforceID, 'update-record');
            }  
        }                          
    	system.debug(existingViridiantMfProjectsMap.keySet());
        projectIdList.addAll(existingViridiantMfProjectsMap.keySet());        
        // List of salesforce ids which need to be updated or added to salesforce
        // these are all ecmf projects so just the worst case model is added
        // they do not count towards  
        system.debug(projectIdList);
        return projectIdList;
    }
   
    global void execute(Database.BatchableContext bc, List<String> projectsToUpdate){
        List<Unit_Takeoff__c> addUnits = new List<Unit_Takeoff__c>();
        List<Project__c> addProjects = new List<Project__c>();
        List<HERS_Data__C> addHersData = new List<HERS_Data__c>();
        List<HERS_Data__C> upsertHersData = new List<HERS_Data__c>();
        //Use the salesforce ids to get update or add the necessary energy model data
        //
        //iterate through ids
        //each id review the map to determine if they are to to updated or added
        //
        //construct the HERS record, unit record, building record, and project for each
        //upsert the records
        List<Log__c> errorLogs = new List<Log__c>();
        
        String raterId = null;
        String RFI_Rater = null;
        String project_status = null;
        Map<String, String> raterMap = new Map<String, String>();
    
        for(Contact existingContact : [
                Select RTIN_RFIN__c, name, id
                FROM contact
                WHERE RTIN_RFIN__c != null ])
            {raterMap.put(existingContact.RTIN_RFIN__c, existingContact.id);}
        list<RecordType> recordTypes = [select id, name from RecordType where name like '%Multifamily%'];
        id multiFamRecordId;
        
                        
        if(recordTypes.size()>0){
            multiFamRecordId = recordTypes.get(0).id; 
        } 
        
        
        system.debug('iterate over projectsToUpdate:');
        system.debug(projectsToUpdate);
        for(String projectId:projectsToUpdate){
            
            //we update the data or create the new records
			system.debug(projectId);
            Unit_Takeoff__c unitTakeoff;
            unitTakeoff = [SELECT Ekotrope_Model_ID__c, Ekotrope_selfOrPlanLastSavedAt__c,
                             ID, Name, Building_Specification__r.id
                             FROM Unit_Takeoff__c WHERE Id = :projectId];
            
            Building_Specifications__c buildingSpec;
            string buildId = unitTakeoff.Building_Specification__r.id;
            buildingSpec = [Select Id, Name, Project__r.id
                           from Building_Specifications__C
                           where id = :buildId];
            Project__c project;
            string projId = buildingSpec.Project__r.id;
            project = [Select Id, Name
                      from Project__c
                      where id = :projId];
            
           
            
            String ekoProjectId = unitTakeoff.Ekotrope_Model_ID__c;
            //system.debug(ekoProjectId);
            // first get all of the necessary information from ekotrope
            if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpProjectCallout() ); }           
            HttpResponse projectResponse = ekotropeSync.getProject(authorization, ekoProjectId);
            //system.debug(projectResponse.getBody());
            
            if(projectResponse.getStatusCode() == 418){
                system.debug('Project has status code 418: '+projectId);
                //system.debug(projectResponse.getBody());
                Log__c errorLog = ekotropeSync.constructErrorLog('getProject','getProject', projectResponse, ekoProjectId, projectResponse.getBody());  
                errorLogs.add(errorLog);
            } else if(projectResponse.getStatusCode() == 200){
                String newProject = String.valueOf(projectResponse.getBody());
                projectJSON2Apex.aProjectJSON2Apex qProject = projectJSON2Apex.parse(newProject);

              
                //if this is a test method we need to set the appropriate mock class
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpDesignCallout() ); }
                //system.debug(qProject.masterPlanId);
                HttpResponse planResponse = ekotropeSync.getHousePlan(authorization, qProject.masterPlanId);  
                //system.debug(planResponse.getBody());
                
                
                //if this is a test method we need to set the appropriate mock class
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse analysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EkotropeAsModeled', codesToCheck);
                //system.debug(analysisResponse.getBody());
               
                //if this is a test method we need to set the appropriate mock class
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse ReferenceAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'HERSReference', codesToCheck);
                //system.debug(ReferenceAnalysisResponse.getBody());
            
                
                 //if this is a test method we need to set the appropriate mock class
                // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse doeAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'DOEZeroEnergyReadyTarget', codesToCheck);
				//system.debug(DesignanalysisResponse.getBody());
                            
                
                // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse ieccAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'IECC2015_5ACH50Reference', codesToCheck);
				//system.debug(DesignanalysisResponse.getBody());
                
                // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse virginiaAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'Virginia2015Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
         		 // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse estar = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EnergyStarV3Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
				 // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse estar31 = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EnergyStarV31Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
				 // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse estarMF = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EnergyStarMFV11Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
                
                
                //Complete the response parsing and record creation only if all HTTP callouts were successful
                if(estar.getStatusCode() == 200 && estar31.getStatusCode() == 200 && estarMF.getStatusCode() == 200 && planResponse.getStatusCode() == 200 && analysisResponse.getStatusCode() == 200 && referenceAnalysisResponse.getStatusCode() == 200 && doeAnalysisResponse.getStatusCode()==200 && ieccAnalysisResponse.getStatusCode() == 200 && virginiaAnalysisResponse.getStatusCode() == 200){
                   	system.debug(Limits.getCpuTime());
                    String plan = String.valueOf(planResponse.getBody());
                    housePlanJSON2Apex qplan = housePlanJSON2Apex.parse(plan);
                    
                    String AsIsAnalysis = String.valueOf(analysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex AsIsAnalysisResults = analysisJson2Apex.parse(AsIsAnalysis);                
                    
                    String ReferenceAnalysis = String.valueOf(ReferenceAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex ReferencenalysisResults = analysisJson2Apex.parse(ReferenceAnalysis);
                    
                    String doeAnalysis = String.valueOf(doeAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex doeAnalysisResults = analysisJson2Apex.parse(doeAnalysis);
                    
                    String ieccAnalysis = String.valueOf(ieccAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex ieccAnalysisResults = analysisJson2Apex.parse(ieccAnalysis);
                    
                    String virginiaAnalysis = String.valueOf(virginiaAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex virginiaAnalysisResults = analysisJson2Apex.parse(virginiaAnalysis);
                    
                    String estarAnalysis = String.valueOf(estar.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex estarAnalysisResults = analysisJson2Apex.parse(estarAnalysis);
                    
                    Sglobal class ekotropeSync implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    global String newProjectsList = '';
    private String ekotropeStatus = '';
    private String updateStatus = '';
    private List<string> ekotropeStages = new List<string>();
    private boolean regularRun = True;
    private string baselineBuilding = '';
    private string referenceBuilding = '';
    private string designBuilding = '';
    private string doeBuilding = '';
    private string iecc2015Building = '';
    private string virginiaBuilding = '';
    private string dataPrefix = '';
    global String authorization = ''; //('Basic ' + EncodingUtil.base64Encode(headerValue));


    global List<Project__c> ekotropeIdList = new List<Project__c>();
    global List<String> projectIdList = new List<String>();
	//global HttpResponse projectListResponse = new HttpResponse();
	global List<Object> newResults = new List<Object>();
    
    global Map<String, String> accountsMap = new Map<String, String>();
    global Map<String, String> raterMap = new Map<String, String>();
    
    global Map<String, String> existingViridiantProjectsMap = new Map<String, String>(); // Used for selfOrPlanLastSavedDate
    global Map<String, String> existingViridiantMfProjectsMap = new Map<String, String>();
    global Map<String, String> existingViridiantProjectsMapSfID = new Map<String, String>();// Used to store UnitTakeoff - Building Spec relationships
    
    private final Map<String, String> globalProjectUpdateStatusList = new Map<String, String>();
    
    global List<Log__c> errorLogs = new List<Log__c>();
   
    
    private final List<string> codesToCheck = new List<string>();
    private List<string> buildingsToCheck = new List<string>();
 
    
    global Iterable<String> start(Database.BatchableContext bc){
        
       
        //This gets SF and MF-Shadow that are already connected for the list to compare the Ekotrope Project List Results against
        for(Unit_Takeoff__c existingProject : [Select Ekotrope_ID__c, Ekotrope_selfOrPlanLastSavedAt__c, ID, Name, Building_Specification__c   
                                            	FROM Unit_Takeoff__c
                                           		WHERE Ekotrope_ID__c != null])
        {
            existingViridiantProjectsMap.put(existingProject.Ekotrope_ID__c, existingProject.Ekotrope_selfOrPlanLastSavedAt__c); 
            existingViridiantProjectsMapSfID.put(existingProject.Ekotrope_ID__c, existingProject.Building_Specification__c);
        }
    
        //iterate through the requested ekotrope stages and query the getProjectList API endpoint
        //For each response, check to see if salesforce has the ekotrope project
        //if it does, check to see if needs to be updated. if it doesn't, add the project to database
        for(string ekoStage : ekotropeStages){
            if(test.isRunningTest()){Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpProjListCallout());}  
            //HttpResponse projectListResponse = getProjectListWithDate(authorization, ekoStage, '2020-01-01', '2020-06-27');      
            HttpResponse projectListResponse = getProjectList(authorization, ekoStage);  
            system.debug(projectListResponse.getStatusCode());
            if(projectListResponse.getStatusCode() == 200){
                String newProjectList = String.valueOf(projectListResponse.getBody());  
                if(projectListResponse.getBody() != ''){
                    newResults = (List<Object>)JSON.deserializeUntyped(newProjectList);
                    //iterate over the projects in Ekotrope           
                    for(Object project : newResults){
                        Map<String, Object> projectData = (Map<String, Object>)project;
                        List<String> updateStatusList = new List<String>();
                        //Check to see if the project exists in existing Viridiant projects map (sf and mf-shadow) 
                        
                        if(existingViridiantProjectsMap.get(String.valueOf(projectData.get('id')))==null){
                            //ekotrope id does not exist in salesforce. so we add it to the add list
                            //we do not know if it is sf or mf. We add the mf projects to the shadow data structure
                            globalProjectUpdateStatusList.put(String.valueOf(projectData.get('id')), 'create-project');
                        } //If the id exists, then we check to see if it has changed
                        else if(projectData.get('selfOrPlanLastSavedAt') != existingViridiantProjectsMap.get(String.valueOf(projectData.get('id')))){
                            globalProjectUpdateStatusList.put(String.valueOf(projectData.get('id')), 'update-project');                      
                        }     
                    }
                } else{
                    system.debug('getProjectList returned a blank body');
                    if(!Test.isRunningTest()){
                        Log__c errorLog =  constructErrorLog('getProjectList', 'getProjectList', projectListResponse, ekoStage, projectListResponse.getBody());
                    	errorLogs.add(errorLog);
                    }
                }
            } else{
                system.debug('getProjectList returned a non-200 status');
                system.debug(projectListResponse.getBody());
                if(!Test.isRunningTest()){
                    Log__c errorLog = constructErrorLog('getProjectList','getProjectList', projectListResponse, ekoStage, projectListResponse.getBody());
                    errorLogs.add(errorLog);
                }
            } 
        }

        projectIdList.addAll(globalProjectUpdateStatusList.keySet()); 
        system.debug(projectIdList);
        system.debug('Number of Projects to update:: ' + projectIdList.size());
        //insert errorLogs;
        return projectIdList;
    }

    global void execute(Database.BatchableContext bc, List<String> projectsToUpdate){
        system.debug('ekotropeSync.execute Start: '+Limits.getCpuTime());
        map<string, boolean> ectaMap = new map<string, boolean>();
        for(Contact existingContact : [
                Select RTIN_RFIN__c, name, id, Earthcraft_TA__c
                FROM contact
                WHERE RTIN_RFIN__c != null ])
            {
               
                ectaMap.put(existingContact.RTIN_RFIN__c, existingContact.Earthcraft_TA__c);
            }
        
        List<Unit_Takeoff__c> addUnits = new List<Unit_Takeoff__c>();
        List<Project__c> addProjects = new List<Project__c>();
        List<HERS_Data__C> addHers = new List<HERS_Data__C>();
        List<Building_Specifications__C> addBuildings = new List<Building_Specifications__C>();
        List<Log__c> errorLogs = new List<Log__c>();
        List<string> autoQaList = new List<string>();
        //List<Inspections__c> autoQaRecordList = new List<Inspections__c>();
        String raterId = null;
        String RFI_Rater = null;
        String project_status = null;
        
        Project__c placeHolderProject = new Project__c();
        list<RecordType> recordTypes = [select id, name from RecordType where name like '%Multifamily%'];
        id multiFamRecordId;
        
                        
        if(recordTypes.size()>0){
            multiFamRecordId = recordTypes.get(0).id; 
        } 
        
        list<Project__c> placeholderProjects = [Select Name, ID From Project__c
                                                                Where RESNET_Registry_ID__c = 'placeHolderProjectForAuto'
                                                               And recordTypeId = :multiFamRecordId
                                                               And Status_Multifamily__c = 'Pre-Review'];
        
                        
        if(placeholderProjects.size()>0){
            placeHolderProject = placeholderProjects.get(0);
            placeHolderProject.Name = 'Placeholder Project for Ekotrope Integration';
            placeHolderProject.Status_Multifamily__c = 'Pre-Review';
            placeHolderProject.RecordTypeId = multiFamRecordId;
            //update placeHolderProject;
        }else{
            //placeHolderProject = new Project__c();
            placeHolderProject.Resnet_Registry_ID__c = 'placeHolderProjectForAuto';
            placeHolderProject.Name = 'Placeholder Project for Ekotrope Integration';
            placeHolderProject.Status_Multifamily__c = 'Pre-Review';
            placeHolderProject.RecordTypeId = multiFamRecordId;
            addProjects.add(placeHolderProject);
            //insert placeHolderProject;
        }
        string placeholderProjectId = placeHolderProject.id;
        list<Building_Specifications__c> placeholderBuildingSpecs = [Select Name, ID From Building_Specifications__c
                                                                     Where Project__c = :placeholderProjectId];
        Building_Specifications__c placeholderBuildingSpec = new Building_Specifications__c();
                        
        if(placeholderBuildingSpecs.size()>0){
            placeholderBuildingSpec = placeholderBuildingSpecs.get(0);
        }else{
            placeholderBuildingSpec.Name = 'Placeholder Project for Ekotrope Integration';
            placeholderBuildingSpec.Project__c = placeholderProjectId;
            addBuildings.add(placeholderBuildingSpec);
            //insert placeholderBuildingSpec;
        }
        
        for(Contact existingContact : [
                Select RTIN_RFIN__c, name, id
                FROM contact
                WHERE RTIN_RFIN__c != null ])
            {raterMap.put(existingContact.RTIN_RFIN__c, existingContact.id);}

        
        for(String projectId:projectsToUpdate){
            system.debug(projectId);
            // first get all of the necessary information from ekotrope
            
            if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpProjectCallout() );}           
            HttpResponse projectResponse = ekotropeSync.getProject(authorization, projectId);
            system.debug(projectResponse.getStatusCode());
            
            if(projectResponse.getStatusCode() == 418){
                system.debug('Project has status code 418: '+projectId);
                system.debug(projectResponse.getBody());
                Log__c errorLog = ekotropeSync.constructErrorLog('getProject','getProject', projectResponse, projectId, projectResponse.getBody());  
                errorLogs.add(errorLog);
            } else if(projectResponse.getStatusCode() == 200){
                system.debug('projectResponse == 200');
                String newProject = String.valueOf(projectResponse.getBody());
                projectJSON2Apex.aProjectJSON2Apex qProject = projectJSON2Apex.parse(newProject);

              	system.debug(qProject.masterPlanId);
                //if this is a test method we need to set the appropriate mock class
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpDesignCallout() ); }
                HttpResponse planResponse = ekotropeSync.getHousePlan(authorization, qProject.masterPlanId);  
                system.debug(planResponse.getBody());
                
                //if this is a test method we need to set the appropriate mock class
                //get the energy data for the base model and to check all of the codes
                //add to getHousePlanAnalysis to comment out the building type if == 'EkotropeAsModeled'
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse analysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EkotropeAsModeled', codesToCheck);
                system.debug(analysisResponse.getBody());
                
                //if this is a test method we need to set the appropriate mock class
                // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse referenceAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'HERSReference', codesToCheck);
                //system.debug(ReferenceAnalysisResponse.getBody());
                
                //if this is a test method we need to set the appropriate mock class
                // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse doeAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'DOEZeroEnergyReadyTarget', codesToCheck);
				//system.debug(DesignanalysisResponse.getBody());
                
                // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse ieccAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'IECC2015_5ACH50Reference', codesToCheck);
				//system.debug(DesignanalysisResponse.getBody());
                
                // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse virginiaAnalysisResponse = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'Virginia2015Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
				//
				 // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse estar = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EnergyStarV3Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
				 // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse estar31 = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EnergyStarV31Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
				 // add to getHousePlanAnalysis if building type != 'EkotropeAsModeled' do not include the building type
                if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpAnalysisCallout() ); }
                HttpResponse estarMF = ekotropeSync.getHousePlanAnalysis(authorization, qProject.masterPlanId, 'EnergyStarMFV11Reference', codesToCheck);
				//system.debug(virginiaAnalysisResponse.getBody());
                
                
                //Complete the response parsing and record creation only if all HTTP callouts were successful
                if(estar.getStatusCode() == 200 && estar31.getStatusCode() == 200 && estarMF.getStatusCode() == 200 && planResponse.getStatusCode() == 200 && analysisResponse.getStatusCode() == 200 && referenceAnalysisResponse.getStatusCode() == 200 && doeAnalysisResponse.getStatusCode()==200 && ieccAnalysisResponse.getStatusCode() == 200 && virginiaAnalysisResponse.getStatusCode() == 200){
                    String plan = String.valueOf(planResponse.getBody());
                    
                    system.debug('before house plan parse');
                    system.debug(Limits.getCpuTime());
                    housePlanJSON2Apex qplan = housePlanJSON2Apex.parse(plan);
                    system.debug('after house plan parse');
                    system.debug(Limits.getCpuTime());
                    
                    system.debug('before analysis parse');
                    system.debug(Limits.getCpuTime());
                    String AsIsAnalysis = String.valueOf(analysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex AsIsAnalysisResults = analysisJson2Apex.parse(AsIsAnalysis);
                    String ReferenceAnalysis = String.valueOf(ReferenceAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex ReferencenalysisResults = analysisJson2Apex.parse(ReferenceAnalysis);
                    String doeAnalysis = String.valueOf(doeAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex doeAnalysisResults = analysisJson2Apex.parse(doeAnalysis);
                    String ieccAnalysis = String.valueOf(ieccAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex ieccAnalysisResults = analysisJson2Apex.parse(ieccAnalysis);
                    String virginiaAnalysis = String.valueOf(virginiaAnalysisResponse.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex virginiaAnalysisResults = analysisJson2Apex.parse(virginiaAnalysis);
                    String estarAnalysis = String.valueOf(estar.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex estarAnalysisResults = analysisJson2Apex.parse(estarAnalysis);
                    String estar31Analysis = String.valueOf(estar31.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex estar31AnalysisResults = analysisJson2Apex.parse(estar31Analysis);
                    String estarMFAnalysis = String.valueOf(estarMF.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex estarMFAnalysisResults = analysisJson2Apex.parse(estarMFAnalysis);
                    system.debug('after analysis parse');
                    system.debug(Limits.getCpuTime());
                    
                    
                    if(globalProjectUpdateStatusList.get(projectId) == 'update-project'){
                        /*Notes: 
                         *  - Ekotrope ID is in Salesforce on the Unit Takeoff Record
                         *  - Update the Project__c, Building_Specification__c, Unit_Takeoff__c, HERS_Data__c
                         *  - Project should not pass through QA Selection
                         *  - Project should be checked for Matching 
						*/
                        
                        string buildingSpecId = existingViridiantProjectsMapSfId.get(qProject.Id);
                        
                        
                        Unit_Takeoff__c newUnitTakeoff = constructTakeoffRecord(qProject, qplan, AsIsAnalysisResults, buildingSpecId);
                        HERS_Data__c newHERSData = constructEnergyDataRecord(qProject, qplan, AsIsAnalysisResults,ReferencenalysisResults, doeAnalysisResults,ieccAnalysisResults,virginiaAnalysisResults, 'HERS');
                        Project__c updateProjectData = constructProjectRecord(qProject, AsIsAnalysisResults, raterId);
                        
                        Unit_Takeoff__c placeholderUnit = new Unit_Takeoff__c(
            				Ekotrope_ID__c = qProject.Id
                        );
                        
                        newUnitTakeoff.Ekotrope_ID__c = qProject.Id;
                        newUnitTakeoff.Building_Specification__c = placeholderBuildingSpec.Id;
    					
                        newHERSData.Ekotrope_Plan_ID__c = qProject.id;
                        newHERSData.HERS_Project__r = placeholderUnit;
                        newHERSData.Energy_Star_V3_Target_HERS__c = string.valueOf(estarAnalysisResults.hersScore);
                        newHERSData.Energy_Star_V3_1_Target_HERS__c = string.valueOf(estar31AnalysisResults.hersScore);
                        newHERSData.Energy_Star_MF_1_Target_HERS__c = string.valueOf(estarMFAnalysisResults.hersScore);
                        
                        addUnits.add(newUnitTakeoff);
                        addHers.add(newHERSData);
                    } else{ 
                        /*
                         * project is not in Ekotrope as Unit Takeoff.
                         * Which means it should be processed through the 
                         * Determine QA - QA_Status = 'Un-determined'
                         * If the project has an ECTA than do matching - Sync_Status = 'new', 
                         * if not do not do matching - Sync_Status = 'create'
						*/
                        
                        Unit_Takeoff__c newUnitTakeoff = constructTakeoffRecord(qProject, qplan, AsIsAnalysisResults, placeholderBuildingSpec.Id);
                        newUnitTakeoff.Building_Specification__c = placeholderBuildingSpec.id;
                        HERS_Data__C newHERSData = constructEnergyDataRecord(qProject, qplan, AsIsAnalysisResults,ReferencenalysisResults, doeAnalysisResults,ieccAnalysisResults,virginiaAnalysisResults, 'HERS');
                                             
                        Unit_Takeoff__c placeholderUnit = new Unit_Takeoff__c(
            				Ekotrope_ID__c = qProject.Id
                        );
						newUnitTakeoff.QA_Status__c = 'Un-determined';                        
                        system.debug(qproject.Id);
                        newHERSData.HERS_Project__r = placeholderUnit; 
                        newHERSData.Ekotrope_Plan_ID__c = qProject.id;
						newUnitTakeoff.Ekotrope_ID__c = qProject.Id; 
                        newUnitTakeoff.Sync_Status__c = 'new';
                        if(ectaMap.get(newUnitTakeoff.HERS_Rater__c)==null){
                            newUnitTakeoff.Sync_Status__c = 'create';
                            newUnitTakeoff.QA_Status__c = 'On Hold';
                        }else{
                            if(ectaMap.get(newUnitTakeoff.HERS_Rater__c) == false){
                                newUnitTakeoff.Sync_Status__c = 'create';
                            } 
                        }
                         
                        addUnits.add(newUnitTakeoff);
                        addHers.add(newHERSData);
                        
  
                    }             
                } // not all callouts were successfull
                else{
                    system.debug('Not all http callouts were successfull. Project == 200, others ?');
                    if(planResponse.getStatusCode() != 200){
                        system.debug('planResponse code:');
                        system.debug(planResponse.getStatusCode());
                        Log__c errorLog = ekotropeSync.constructErrorLog('getHousePlan','getHousePlan', planResponse, projectId, planResponse.getBody());
                        errorLogs.add(errorLog);
                    } 
                    if(analysisResponse.getStatusCode() != 200){
                        system.debug('analysisResponse code:');
                        system.debug(analysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - EkotropeAsModeled','getHousePlanAnalysis', analysisResponse, projectId, analysisResponse.getBody());
                        errorLogs.add(errorLog);
                        
                    } 
                    if(ReferenceAnalysisResponse.getStatusCode() != 200){
                        system.debug('ReferenceAnalysisResponse code:');
                        system.debug(ReferenceAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - HERSReference','getHousePlanAnalysis', ReferenceAnalysisResponse, projectId, ReferenceAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    } 
                    if(doeAnalysisResponse.getStatusCode() != 200){
                        system.debug('doeAnalysisResponse code:');
                        system.debug(doeAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - DOE','getHousePlanAnalysis', doeAnalysisResponse, projectId, doeAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    }
                    if(ieccAnalysisResponse.getStatusCode() != 200){
                        system.debug('ieccAnalysisResponse code:');
                        system.debug(ieccAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - IECC','getHousePlanAnalysis', ieccAnalysisResponse, projectId, ieccAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    }
                    if(virginiaAnalysisResponse.getStatusCode() != 200){
                        system.debug('virginiaAnalysisResponse code:');
                        system.debug(virginiaAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - Virginia','getHousePlanAnalysis', virginiaAnalysisResponse, projectId, virginiaAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    }
                } 
            } // projectResponse was not statusCode == 200
            else{
                Log__c errorLog = EkotropeSync.constructErrorLog('getProject','getProject', projectResponse, projectId, projectResponse.getBody());
                errorLogs.add(errorLog);
                system.debug(projectId);
                system.debug(projectResponse.getBody());
            }
            
        }
       
        
        system.debug(addHers);
        upsert addUnits Unit_Takeoff__c.Fields.Ekotrope_ID__c;
        upsert addProjects;
        upsert addHers HERS_Data__c.Fields.Ekotrope_Plan_ID__c;
            
        addProjects.clear();  
    }
       
    global void finish(Database.BatchableContext bc){
        batchMatching matchProjects = new batchMatching();       
        //will need to make different energy data records
        // one for HERS data or we put everything HERS (3) plus the three additional records.
        matchProjects.setSyncStatus('new');
        Id newProjectBatchId = Database.executeBatch(matchProjects,300);
        
        determineQa();
        
        
        ekotropeUpload uploadProjects = new ekotropeUpload();
        uploadProjects.setAuthorization(authorization);
        Id uploadProjectBatchId = Database.executeBatch(uploadProjects, 2);  
        insert errorLogs;
    }
    
    public static Project__c constructProjectRecord(projectJSON2Apex.aProjectJSON2Apex aProject, analysisJson2Apex.pAnalysisJson2Apex bAnalysis, string cRater){
        //MF I don't know what to do
        projectJSON2APex.aProjectJSON2Apex a = aProject;
        analysisJson2Apex.pAnalysisJson2Apex b =  bAnalysis;
        string rater = cRater;
        string ekoId = a.id;
        string street = a.location.streetAddress;
        string city = a.location.city;
        string state = a.location.state;
        string zip = a.location.zip;
        string registryId = a.hersRatingDetails.registryId;
        string index = string.valueOf(b.hersScore);
        
        Project__c projectRecord = new Project__c(
           SF_Ekotrope_ID__c = ekoId,
           //Name= '',
            Street_Address__c= street,
            City__c = city,
            State__c = state,
            zip_code__c = zip,
            RESNET_Registry_ID__c = zip,
            Rater__c = rater,
           // Registration_Date__c ='',
           // Rating_Date__c = '',
            HERS_Index__c = index
            
            
        );
        return projectRecord;
        
    }

    public static Unit_Takeoff__c constructTakeoffRecord(projectJSON2Apex.aProjectJSON2Apex aProject, housePlanJSON2Apex rplan, analysisJson2Apex.pAnalysisJson2Apex analysis, string buildingSpecId){
        
		string Water_Heating, Water_Heating_Capacity, Water_Heating_Efficiency, Hot_Water, Mechanical_Ventilation; 
        string Ventilation_CFM, Ventilation_Watts;
        string floorRvalue, predominantFloorId, predomFloorName;
        string foundationType, foundationRValue, predomFoundationName;
        boolean energyStar, estarV31, estarMFV1;
        string Solar_Hot_Water;
        string predomWallDetails, predomWallR, predomWallId, predomWallName, predomWallSpacing, predomWallDepth;
        string predomCeilingR, predominantCeilingId, predomCeilingName;
        string predomDoorR, predominantDoorId, predomDoorName, lastSaved;
        string windowDetail, predomWindowU, predominantWindowId, predomWindowName, predomWindowSHGC;
        string selfOrPlan, fuel;
        
        
        
        analysisJson2Apex.pAnalysisJson2Apex hersAnalysis = analysis;
        housePlanJSON2Apex thisHousePlan = rplan;
        projectJSON2Apex.aProjectJSON2Apex thisProject = aProject;
        //planJson2Apex.aPlanJson2Apex thisHousePlan = rplan;
        selfOrPlan = thisProject.selfOrPlanLastSavedAt;
        
        try{
            fuel = thisHousePlan.mechanicals.summary.dominantHeatingEquipmentType.fuel;
        } catch(exception e){
            fuel = '';
        }
        
		Date RESNET_Registration_Date = Date.newInstance(1999,1,1);
        if (thisProject.hersRatingDetails.ratingDate != null){
            RESNET_Registration_Date =  Date.newInstance(
                Integer.valueOf(String.valueOf(thisProject.hersRatingDetails.ratingDate).substring(0,4)),
                Integer.valueOf(String.valueOf(thisProject.hersRatingDetails.ratingDate).substring(5,7)),
                Integer.valueOf(String.valueOf(thisProject.hersRatingDetails.ratingDate).substring(8,10)));
        }else{
            RESNET_Registration_Date = null;
        }
        string houseType = '';
        if(thisHousePlan.Details.residenceType != null){
            string residenceTypeString = thisHousePlan.Details.residenceType;
            if(residenceTypeString == 'SingleFamilyHouse' | residenceTypeString == 'TownhouseEndUnit' | residenceTypeString == 'TownhouseInsideUnit' | residenceTypeString == 'DuplexSingleUnit' | residenceTypeString == 'DuplexWholeBuilding'){
                houseType = 'singlefamily';
            }
            else{
                houseType = 'multifamily';
            }
        }
        
        string levenString = normalizeLechString(thisProject.name, thisProject.location.StreetAddress, thisProject.location.City , thisProject.location.state);
        
        
        integer count2 = 0;
        
        string Heating_Sys_1,Heating_Fuel,Heating_Capacity,HSPF_AFUE_COP,Cooling_Sys_1;
        string Cooling_Capacity,SEER_EER, Ductless, Ducts_100_w_in_conditioned_space;
        string Total_Duct_Leakage, LtO, Area_Served;
        string Heating_Sys_4, Heating_Fuel_Sys_4, Heating_Capacity_Sys_4, HSPF_AFUE_COP_Sys_4;
        string Cooling_Sys_4, Cooling_Capacity_Sys_4, SEER_EER_Sys_4;
        boolean Ductless_Sys_4;
        Ductless_Sys_4 = false;
        boolean Ducts_100_w_in_conditioned_space_Sys_4;
        Ducts_100_w_in_conditioned_space_Sys_4 = false;
        string Total_Duct_Leakage_Sys_4, LtO_Sys_4, Area_Served_Sys_4;
        string Heating_Sys_3, Heating_Fuel_Sys_3, Heating_Capacity_Sys_3, HSPF_AFUE_COP_Sys_3;
        string Cooling_Sys_3, Cooling_Capacity_Sys_3, SEER_EER_Sys_3;
        boolean Ductless_Sys_3;
        Ductless_Sys_3 = false; 
        boolean Ducts_100_w_in_conditioned_space_Sys_3;
         Ducts_100_w_in_conditioned_space_Sys_3 = false;
        string Total_Duct_Leakage_Sys_3, LtO_Sys_3, Area_Served_Sys_3;
        string Heating_Sys_2, Heating_Fuel_Sys_2, Heating_Capacity_Sys_2, HSPF_AFUE_COP_Sys_2;
        string Cooling_Sys_2, Cooling_Capacity_Sys_2, SEER_EER_Sys_2;
        boolean Ductless_Sys_2;
        boolean Ducts_100_w_in_conditioned_space_Sys_2;
        Ducts_100_w_in_conditioned_space_Sys_2 = false;
        string Total_Duct_Leakage_Sys_2, LtO_Sys_2, Area_Served_Sys_2;
        integer heatCounter = 0;
        integer coolCounter = 0;
        Ductless_Sys_2 = false;
        string Thermostat = string.valueOf(thisHousePlan.Details.programmableThermostat);
        integer i2 = thisHousePlan.mechanicals.equipment.size();
        
        while (count2 < i2){
			//system.debug(count2);
			//system.debug(thisHousePlan.mechanicals.equipment[count2].equipmentType); 
            if (Test.isRunningTest()) {
                if(coolCounter == 4){
                    coolCounter =0;
                }
                if(heatCounter == 4){
                    heatCounter = 0;
                }
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'AIR_CONDITIONER'){
                if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                   // system.debug('ac system');
                    if(coolCounter == 0){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_1 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                        SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                        SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3= SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    
                }
                
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'AIR_SOURCE_HEAT_PUMP'){
                if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                  //  system.debug('ac system');
                    if(coolCounter == 0){
                        
                        Cooling_Sys_1 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        
                        Cooling_Sys_2 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                        //coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    coolCounter = coolCounter + 1;
                }
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'BOILER'){
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                   // system.debug('heat system');
                    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                    
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'FURNACE'){
                 if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                   // system.debug('heat system');
                     
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
               
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'GROUND_SOURCE_HEAT_PUMP'){
                if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                 //   system.debug('ac system');
                    
                    if(coolCounter == 0){
                        
                        Cooling_Sys_1 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                    }
                    if(coolCounter == 1){
                        ////coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    coolCounter = coolCounter + 1;
                }
                 if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                     
                    if(heatCounter == 0){
                       
                        Heating_Sys_1 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                     heatCounter = heatCounter + 1;
                }
               
                
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'HOT_WATER_HEATER'){
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'RADIANT_FLOOR_ELECTRIC'){
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                  //  system.debug('heat system');    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
               
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'RADIANT_FLOOR_HYDRONIC'){
                 if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                   // system.debug('ac system');
                     
                    if(coolCounter == 0){
                       
                        Cooling_Sys_1 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        //coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                     coolCounter = coolCounter + 1;
                }
                 if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                     
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
               
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'RESISTANCE_HEATER'){
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                   // system.debug('heat system');
                    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'CUSTOM'){
                 if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                   // system.debug('ac system');
                     
                    if(coolCounter == 0){
                        
                        Cooling_Sys_1 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        //coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    coolCounter = coolCounter + 1;
                }
                  if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                      
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        heatCounter = heatCounter + 1;
                        //Heating_Sys_2 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        heatCounter = heatCounter + 1;
                        //Heating_Sys_3 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
            }
            count2++;
        }
        integer count3 = 0;
        integer i3 = thisHousePlan.mechanicals.distributionSystems.size();
        try{
         while (count3 < i3){            
            //thisHousePlan.mechanicals.distributionSystems[count2])
             if(count3==0){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless = 'Yes';
                 } else(Ductless = 'No');
                 
                 //Ducts_100_w_in_conditioned_space_Sys_2 = false;
        		 Total_Duct_Leakage = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25); 
             } 
             if(count3==1){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless_Sys_2 = True;
                 } 
                 
                 //Ducts_100_w_in_conditioned_space_Sys_2 = false;
        		 Total_Duct_Leakage_Sys_2 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO_Sys_2 =string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served_Sys_2 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25);  
             }  
             if(count3==2){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless_Sys_3 = true;
                 } else(Ductless_Sys_3 = false);
                 
                 //Ducts_100_w_in_conditioned_space_Sys_3 = false;
        		 Total_Duct_Leakage_Sys_3 =  string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO_Sys_3 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served_Sys_3 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25); 
             }  
             if(count3==3){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless_Sys_4 = true;
                 } else(Ductless_Sys_4 = false);
                 
                 //Ducts_100_w_in_conditioned_space_Sys_2 = false;
        		 Total_Duct_Leakage_Sys_4 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO_Sys_4= string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served_Sys_4 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25);
             }  
            count3++;
            
         }
        } catch(exception e){
            system.debug('catch error on distribution systems');
        }
        
        
        try{// try to get the dominant framed floor type and 
            //system.debug(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType);
            floorRValue = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.assemblyDetails.cavityR).abbreviate(25);
            predominantFloorId = thisHousePlan.thermalEnvelope.summary.DominantFramedFloorType.id.abbreviate(25); 
        }catch(exception e){
           // selfOrPlan='';
        }
        
        
        try{// try to get the dominant agw type and 
            foundationType = thisHousePlan.thermalEnvelope.foundationType.abbreviate(25);
            //system.debug(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType);
            foundationRValue = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantFoundationWallType.rFactor).abbreviate(25);
            predomFoundationName = thisHousePlan.thermalEnvelope.summary.dominantFoundationWallType.name.abbreviate(25); 
        }catch(exception e){
            //selfOrPlan='';
            foundationRValue = '';
            foundationType = '';
            predomFoundationName = '';
			//system.debug(e);
            //system.debug('not here');
        }
        
        
        //boolean Frame_Floor_Over = true;
       
        
        integer count = 0;
        integer i = hersAnalysis.Compliance.size();
        while (count < i){
            List<string> codesToCheck = new List<string>();
            
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV3'){
                if(hersAnalysis.Compliance[count].complianceStatus == 'Pass'){
                    energyStar = True;
                }else{
                    energyStar = False;
                }
                //energyStar = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //energyStarIndex = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV31'){
                 if(hersAnalysis.Compliance[count].complianceStatus == 'Pass'){
                    estarV31 = True;
                }else{
                    estarV31 = False;
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarMFV1'){
                 if(hersAnalysis.Compliance[count].complianceStatus == 'Pass'){
                    estarMFV1 = True;
                }else{
                    estarMFV1 = False;
                }
                //estarMFV1 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarMFV1Index = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            count++;
        }
        try{
            predominantFloorId = thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.id.abbreviate(25);
            predomFloorName = thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.name.abbreviate(25); 
            floorRValue = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.assemblyDetails.cavityR).abbreviate(25);
        } catch(exception e){
           // selfOrPlan='';
            //system.debug('no dominantFramedFloorType ID or NAME');
        }
        try{
            predomWallId = thisHousePlan.thermalEnvelope.summary.dominantWallType.id.abbreviate(25);
            predomWallName = thisHousePlan.thermalEnvelope.summary.dominantWallType.name.abbreviate(25); 
            predomWallR = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWallType.assemblyDetails.cavityR).abbreviate(25);           
			predomWallSpacing = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWallType.assemblyDetails.framingSpacing).abbreviate(25); 
       		predomWallDepth = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWallType.assemblyDetails.framingDepth).abbreviate(25);
            predomWallDetails = predomWallDepth + '" deep, '+predomWallSpacing + '" o.c.';
            predomWallDetails = predomWallDetails.abbreviate(25);
        } catch(exception e){
            //selfOrPlan='';
            //system.debug('no dominantWallType ID or NAME');
        }
        
        try{
             predominantCeilingId = thisHousePlan.thermalEnvelope.summary.dominantCeilingType.id.abbreviate(25);
            predomCeilingName = thisHousePlan.thermalEnvelope.summary.dominantCeilingType.name.abbreviate(25);
             predomCeilingR = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantCeilingType.assemblyDetails.cavityR).abbreviate(25);
        } catch(exception e){
            //selfOrPlan='';
            //system.debug('no ceiling information');
        }

        try{
            predominantDoorId = thisHousePlan.thermalEnvelope.summary.dominantDoorType.id.abbreviate(25);
            predomDoorName = thisHousePlan.thermalEnvelope.summary.dominantDoorType.name.abbreviate(25);
            predomDoorR = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantDoorType.uFactor).abbreviate(25);
        } catch(exception e){
           // selfOrPlan='';
           // system.debug('no door information');
        }       
        try{
             predominantWindowId = thisHousePlan.thermalEnvelope.summary.dominantWindowType.id.abbreviate(25);
            predomWindowName = thisHousePlan.thermalEnvelope.summary.dominantWindowType.name.abbreviate(25);
             predomWindowU = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWindowType.uFactor).abbreviate(25);
       		predomWindowSHGC = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWindowType.SHGC).abbreviate(25);
        	windowDetail = 'U:'+ predomWindowU + ' S:' + predomWindowSHGC;
            windowDetail = windowDetail.abbreviate(25);
        }catch(exception e){
            //selfOrPlan='';
            //system.debug('no window info');
        }
        try{
            Water_Heating_Capacity = string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.tankSize).abbreviate(25);
            Water_Heating = thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.fuel.abbreviate(25);
            Water_Heating_Efficiency = string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.efficiency).abbreviate(25);
            //if(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.equipmentType)
            //Solar_Hot_Water = thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.equipmentType;   
        }catch(exception e){
            //selfOrPlan='';
          //  system.debug('no hot water tank size');
        }
        try{
			Mechanical_Ventilation = thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.ventilationType.abbreviate(25);
            Ventilation_CFM = string.valueOf(thisHousePlan.mechanicals.summary.mechanicalVentilationRate).abbreviate(25);
            Ventilation_Watts = string.valueOf(thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.watts).abbreviate(25); //prolly should be total            
        }catch(exception e){
            //selfOrPlan='';
            //system.debug('no mech information');
        }
        lastSaved = thisProject.selfOrPlanLastSavedAt.abbreviate(25);

        string HW_Pipe_Length, Recirculation, Recirculation_System_Control_type, Water_Fixture_Type;
        try{
            HW_Pipe_Length = string.valueOf(thisHousePlan.waterSystem.hotWaterPipeLength).abbreviate(25);
            Recirculation = string.valueOf((thisHousePlan.waterSystem.recircSystem != null)).abbreviate(25);
            Recirculation_System_Control_type = thisHousePlan.waterSystem.recircSystem.systemControl.abbreviate(25);
            Water_Fixture_Type = thisHousePlan.waterSystem.fixtureEffectiveness.abbreviate(25);
        }catch(exception e){
           // selfOrPlan='';
            HW_Pipe_Length = '';
            Recirculation = '';
            Recirculation_System_Control_type = '';
            Water_Fixture_Type = '';
        }
        string solar;
        try{
            if(thisHousePlan.onsiteGenerations.summary.hasSolarGeneration){
                solar = 'Yes';
            }
        } catch(exception e){
            //selfOrPlan='';
            solar = 'No';
        }
		string Ext_CFL_percentage, Ext_LED_Percentage;
        try{
            Ext_CFL_percentage = string.valueOf(thisHousePlan.lighting.percentEfficient.exterior).abbreviate(25);
            Ext_LED_Percentage = string.valueOf(thisHousePlan.lighting.percentLED.exterior).abbreviate(25);
        } catch(exception e){
            //selfOrPlan='';
            Ext_CFL_percentage = string.valueOf(0);
            Ext_LED_Percentage = string.valueOf(0);
        }     
        string infil;
        try{
            infil = string.valueOf(thisHousePlan.thermalEnvelope.infiltration.ach50).abbreviate(25);
        }catch(exception e){
           // selfOrPlan='';
            
        }
        string Field1, Field2, Field3;
        try{
            integer numRaters = thisProject.hersRatingDetails.associatedUsers.size();
            integer raterCounter = 0; 
            while (raterCounter < numRaters){
                if(raterCounter == 0){
                    if(thisProject.hersRatingDetails.associatedUsers[raterCounter].userType == 'FieldInspector'){
                        Field1 = thisProject.hersRatingDetails.associatedUsers[raterCounter].fieldInspectorId;
                    } else{
                        Field1 = thisProject.hersRatingDetails.associatedUsers[raterCounter].resnetRaterId;
                        }
                }
                if(raterCounter == 1){
                    if(thisProject.hersRatingDetails.associatedUsers[raterCounter].userType == 'FieldInspector'){
                        Field2 = thisProject.hersRatingDetails.associatedUsers[raterCounter].fieldInspectorId;
                    } else{
                        Field2 = thisProject.hersRatingDetails.associatedUsers[raterCounter].resnetRaterId;
                        }
                }
                if(raterCounter == 2){
                    if(thisProject.hersRatingDetails.associatedUsers[raterCounter].userType == 'FieldInspector'){
                        Field3 = thisProject.hersRatingDetails.associatedUsers[raterCounter].fieldInspectorId;
                    } else{
                        Field3 = thisProject.hersRatingDetails.associatedUsers[raterCounter].resnetRaterId;
                    }
                }
                raterCounter = raterCounter + 1;
            }
            
            if(numRaters ==0){
                Field1 = thisProject.hersRatingDetails.rater.resnetRaterId;
            }
        }catch(exception e){
            system.debug('no associated users');
            //selfOrPlan = '';
        }
        
       
       

		/// Figure out Mechanicals and Duct systems :(

        Unit_Takeoff__c unitTakeoffRecord = new Unit_Takeoff__c(
            
            bedrooms__c = thisHousePlan.Details.bedrooms,
            //Band_Height__c = 1, not possible to accurately determine
            HERS_Rater__c = thisProject.hersRatingDetails.rater.resnetRaterId,
            Field_Inspector_1__c = Field1,
            Field_Inspector_2__c = Field2,
            Field_Inspector_3__c = Field3,
            Street__c = thisProject.location.streetAddress,
            City__c = thisProject.location.City,
            Zip_Code__c = thisProject.location.zip,
            State__c = thisProject.location.state,
            RESNET_Registration_Date__c = RESNET_Registration_Date,
            RESNET_Registry_ID__c = thisProject.hersRatingDetails.registryId,
            Unit_Type__c = 'interior',
            Name = thisProject.location.StreetAddress,
            Residence_Type__c = houseType,
            Levenshtein_String__c = levenString,
            Energy_Star_pass__c = True,
            Ekotrope_URL__c = 'https://app.ekotrope.com/#project:'+thisProject.id,
            //Ekotrope_Model_ID__c = string.valueOf(thisProject.id),
            Ekotrope_selfOrPlanLastSavedAt__c = selfOrPlan,
            Housing_Type__c = lastSaved,
            Stories__c = string.valueOf(thisHousePlan.Details.numberOfFloorsOnOrAboveGrade),
            Conditioned_Floor_Area__c = string.valueOf(thisHousePlan.thermalEnvelope.Summary.conditionedArea),
            //volume__c = string.valueof(thisHousePlan.ThermalEnvelope.summary.conditionedVolume),
            //Attached_Garage__c = '', --- not currently in API
            Foundation_Type__c = foundationType,
            Foundation_Insulation__c = foundationRValue,
            Foundation_Insulation_Name__c = predomFoundationName,
            //Floors_Over_Unconditioned_Space__c = string.valueOf(Frame_Floor_Over),
            //Frame_Floor_Over__c = '', --- not currently in API
            Frame_Floor_Insulation__c = floorRValue,
            Frame_Floor_Insulation_Name__c = predomFloorName,
            Above_grade_walls__c = predomWallR,
            AGW_Insulation_Name__c = predomWallName,
            AGW_Framing__c = predomWallDetails,
            Ceiling__c = predomCeilingR,
            Ceiling_Insulation_Name__c = predomCeilingName,
            Roof_Condition__c = '',
            Exterior_Door__c = predomDoorR,
            Windows__c = windowDetail,
            Skylights__c = '',
            Infiltration__c = infil,
            Thermostat__c = Thermostat,
            Heating_Sys_1__c = Heating_Sys_1, 
            Heating_Fuel__c = Heating_Fuel,
            Heating_Capacity__c = Heating_Capacity, 
            HSPF_AFUE_COP__c = HSPF_AFUE_COP,
            Cooling_Sys_1__c = Cooling_Sys_1,
            Cooling_Capacity__c = Cooling_Capacity,
            SEER_EER__c = SEER_EER,
            Ductless__c = Ductless,
            Ducts_100_w_in_conditioned_space__c = Ducts_100_w_in_conditioned_space,
            Total_Duct_Leakage__c = Total_Duct_Leakage,
            LtO__c = LtO,
            Area_Served__c = Area_Served,
            
            Heating_Sys_2__c = Heating_Sys_2, 
            Heating_Fuel_Sys_2__c =Heating_Fuel_Sys_2,
            Heating_Capacity_Sys_2__c = Heating_Capacity_Sys_2, 
            HSPF_AFUE_COP_Sys2__c = HSPF_AFUE_COP_Sys_2,
            Cooling_Sys_2__c = Cooling_Sys_2,
            Cooling_Capacity_Sys_2__c = Cooling_Capacity_Sys_2,
            SEER_EER_Sys_2__c = SEER_EER_Sys_2,
            Ductless_Sys_2__c = Ductless_Sys_2,
            Ducts_100_w_in_conditioned_space_Sys_2__c = Ducts_100_w_in_conditioned_space_Sys_2,
            Total_Duct_Leakage_Sys_2__c = Total_Duct_Leakage_Sys_2,
            LtO_Sys_2__c = LtO_Sys_2,
            Area_Served_Sys_2__c = Area_Served_Sys_2,
            Heating_Sys_3__c = Heating_Sys_3, 
            Heating_Fuel_Sys_3__c = Heating_Fuel_Sys_3,
            Heating_Capacity_Sys_3__c = Heating_Capacity_Sys_3, 
            HSPF_AFUE_COP_Sys_3__c = HSPF_AFUE_COP_Sys_3,
            Cooling_Sys_3__c = Cooling_Sys_3,
            Cooling_Capacity_Sys_3__c = Cooling_Capacity_Sys_3,
            SEER_EER_Sys_3__c = SEER_EER_Sys_3,
            Ductless_Sys_3__c = Ductless_Sys_3,
            Ducts_100_w_in_conditioned_space_Sys_3__c = Ducts_100_w_in_conditioned_space_Sys_3,
            Total_Duct_Leakage_Sys_3__c = Total_Duct_Leakage_Sys_3,
            LtO_Sys_3__c = LtO_Sys_3,
            Area_Served_Sys_3__c = Area_Served_Sys_3,
            
			Heating_Sys_4__c = Heating_Sys_4, 
            Heating_Fuel_Sys_4__c = Heating_Fuel_Sys_4,
            Heating_Capacity_Sys_4__c = Heating_Capacity_Sys_4, 
            HSPF_AFUE_COP_Sys_4__c =HSPF_AFUE_COP_Sys_4,
            Cooling_Sys_4__c =Cooling_Sys_4,
            Cooling_Capacity_Sys_4__c = Cooling_Capacity_Sys_4,
            SEER_EER_Sys_4__c = SEER_EER_Sys_4,
            Ductless_Sys_4__c = Ductless_Sys_4,
            Ducts_100_w_in_conditioned_space_Sys_4__c = Ducts_100_w_in_conditioned_space_Sys_4,
            Total_Duct_Leakage_Sys_4__c = Total_Duct_Leakage_Sys_4,
            LtO_Sys_4__c = LtO_Sys_4,
            Area_Served_Sys_4__c = Area_Served_Sys_4,
            Water_Heating__c = Water_Heating, //thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.fuel,
            Water_Heating_Capacity__C = Water_Heating_Capacity, //string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.tankSize),
            Water_Heating_Efficiency__c = Water_Heating_Efficiency, //string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.efficiency),
            Solar_Hot_Water__c = Solar_Hot_Water, //thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.equipmentType,
            Mechanical_Ventilation__c = Mechanical_Ventilation, //thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.ventilationType,
            Ventilation_CFM__c = Ventilation_CFM, //string.valueOf(thisHousePlan.mechanicals.summary.mechanicalVentilationRate),
            Ventilation_Watts__c = Ventilation_Watts, // string.valueOf(thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.watts), //prolly should be total
            HW_Pipe_Length__c = HW_Pipe_Length,
            Recirculation__c = Recirculation,
            Recirculation_System_Control_type__c = Recirculation_System_Control_type,
            Ceiling_fans__c = '',
            Water_Fixture_Type__c = Water_Fixture_Type,
            Ext_CFL_percentage__c = Ext_CFL_percentage,
            Ext_LED_Percentage__c = Ext_LED_percentage,
            Fridge__c = string.valueOf(thisHousePlan.appliances.refrigeratorConsumption).abbreviate(25),
            Dishwasher__c = string.valueOf(thisHousePlan.appliances.dishwasherEfficiency).abbreviate(25),
            Dryer__c = string.valueOf(thisHousePlan.appliances.clothesDryer.fuel).abbreviate(25),
            Washer__c = string.valueOf(thisHousePlan.appliances.clothesWasher.labeledEnergyRating).abbreviate(25),
            Range__c = string.valueOf(thisHousePlan.appliances.rangeOven.fuel).abbreviate(25),
            Solar__c = solar
            
            
        );
        
         if(buildingSpecId != 'null'){
            unitTakeoffRecord.Building_Specification__c = buildingSpecId;
        }
       
      
        return unitTakeoffRecord;
        
    }
           
    public static Unit_Takeoff__c updateTakeoffRecord(Unit_Takeoff__c unit, projectJSON2Apex.aProjectJSON2Apex aProject, housePlanJSON2Apex rplan, analysisJson2Apex.pAnalysisJson2Apex analysis, string buildingSpecId){
        
		string Water_Heating, Water_Heating_Capacity, Water_Heating_Efficiency, Hot_Water, Mechanical_Ventilation; 
        string Ventilation_CFM, Ventilation_Watts;
        string floorRvalue, predominantFloorId, predomFloorName;
        string foundationType, foundationRValue, predomFoundationName;
        boolean energyStar, estarV31, estarMFV1;
        string Solar_Hot_Water;
        string predomWallDetails, predomWallR, predomWallId, predomWallName, predomWallSpacing, predomWallDepth;
        string predomCeilingR, predominantCeilingId, predomCeilingName;
        string predomDoorR, predominantDoorId, predomDoorName, lastSaved;
        string windowDetail, predomWindowU, predominantWindowId, predomWindowName, predomWindowSHGC;
        string selfOrPlan, fuel;
        
        
        
        analysisJson2Apex.pAnalysisJson2Apex hersAnalysis = analysis;
        housePlanJSON2Apex thisHousePlan = rplan;
        projectJSON2Apex.aProjectJSON2Apex thisProject = aProject;
        //planJson2Apex.aPlanJson2Apex thisHousePlan = rplan;
        selfOrPlan = thisProject.selfOrPlanLastSavedAt;
        
        try{
            fuel = thisHousePlan.mechanicals.summary.dominantHeatingEquipmentType.fuel;
        } catch(exception e){
            fuel = '';
        }
        
		Date RESNET_Registration_Date = Date.newInstance(1999,1,1);
        if (thisProject.hersRatingDetails.ratingDate != null){
            RESNET_Registration_Date =  Date.newInstance(
                Integer.valueOf(String.valueOf(thisProject.hersRatingDetails.ratingDate).substring(0,4)),
                Integer.valueOf(String.valueOf(thisProject.hersRatingDetails.ratingDate).substring(5,7)),
                Integer.valueOf(String.valueOf(thisProject.hersRatingDetails.ratingDate).substring(8,10)));
        }else{
            RESNET_Registration_Date = null;
        }
        string houseType = '';
        if(thisHousePlan.Details.residenceType != null){
            string residenceTypeString = thisHousePlan.Details.residenceType;
            if(residenceTypeString == 'SingleFamilyHouse' | residenceTypeString == 'TownhouseEndUnit' | residenceTypeString == 'TownhouseInsideUnit' | residenceTypeString == 'DuplexSingleUnit' | residenceTypeString == 'DuplexWholeBuilding'){
                houseType = 'singlefamily';
            }
            else{
                houseType = 'multifamily';
            }
        }
        
        string levenString = normalizeLechString(thisProject.name, thisProject.location.StreetAddress, thisProject.location.City , thisProject.location.state);
        
        
        integer count2 = 0;
        
        string Heating_Sys_1,Heating_Fuel,Heating_Capacity,HSPF_AFUE_COP,Cooling_Sys_1;
        string Cooling_Capacity,SEER_EER, Ductless, Ducts_100_w_in_conditioned_space;
        string Total_Duct_Leakage, LtO, Area_Served;
        string Heating_Sys_4, Heating_Fuel_Sys_4, Heating_Capacity_Sys_4, HSPF_AFUE_COP_Sys_4;
        string Cooling_Sys_4, Cooling_Capacity_Sys_4, SEER_EER_Sys_4;
        boolean Ductless_Sys_4;
        Ductless_Sys_4 = false;
        boolean Ducts_100_w_in_conditioned_space_Sys_4;
        Ducts_100_w_in_conditioned_space_Sys_4 = false;
        string Total_Duct_Leakage_Sys_4, LtO_Sys_4, Area_Served_Sys_4;
        string Heating_Sys_3, Heating_Fuel_Sys_3, Heating_Capacity_Sys_3, HSPF_AFUE_COP_Sys_3;
        string Cooling_Sys_3, Cooling_Capacity_Sys_3, SEER_EER_Sys_3;
        boolean Ductless_Sys_3;
        Ductless_Sys_3 = false; 
        boolean Ducts_100_w_in_conditioned_space_Sys_3;
         Ducts_100_w_in_conditioned_space_Sys_3 = false;
        string Total_Duct_Leakage_Sys_3, LtO_Sys_3, Area_Served_Sys_3;
        string Heating_Sys_2, Heating_Fuel_Sys_2, Heating_Capacity_Sys_2, HSPF_AFUE_COP_Sys_2;
        string Cooling_Sys_2, Cooling_Capacity_Sys_2, SEER_EER_Sys_2;
        boolean Ductless_Sys_2;
        boolean Ducts_100_w_in_conditioned_space_Sys_2;
        Ducts_100_w_in_conditioned_space_Sys_2 = false;
        string Total_Duct_Leakage_Sys_2, LtO_Sys_2, Area_Served_Sys_2;
        integer heatCounter = 0;
        integer coolCounter = 0;
        Ductless_Sys_2 = false;
        //integer DuctCounter = 0;
        string Thermostat = string.valueOf(thisHousePlan.Details.programmableThermostat);
        integer i2 = thisHousePlan.mechanicals.equipment.size();
        //system.debug('i2'+i2);
        while (count2 < i2){
			//system.debug(count2);
			//system.debug(thisHousePlan.mechanicals.equipment[count2].equipmentType); 
            if (Test.isRunningTest()) {
                if(coolCounter == 4){
                    coolCounter =0;
                }
                if(heatCounter == 4){
                    heatCounter = 0;
                }
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'AIR_CONDITIONER'){
                if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                   // system.debug('ac system');
                    if(coolCounter == 0){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_1 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                        SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                        SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3= SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                        coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'Air Conditioner';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    
                }
                
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'AIR_SOURCE_HEAT_PUMP'){
                if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                  //  system.debug('ac system');
                    if(coolCounter == 0){
                        
                        Cooling_Sys_1 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        
                        Cooling_Sys_2 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                        //coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    coolCounter = coolCounter + 1;
                }
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'AIR_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'BOILER'){
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                   // system.debug('heat system');
                    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'BOILER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                    
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'FURNACE'){
                 if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                   // system.debug('heat system');
                     
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'FURNACE';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
               
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'GROUND_SOURCE_HEAT_PUMP'){
                if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                 //   system.debug('ac system');
                    
                    if(coolCounter == 0){
                        
                        Cooling_Sys_1 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                    }
                    if(coolCounter == 1){
                        ////coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    coolCounter = coolCounter + 1;
                }
                 if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                     
                    if(heatCounter == 0){
                       
                        Heating_Sys_1 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'GROUND_SOURCE_HEAT_PUMP';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                     heatCounter = heatCounter + 1;
                }
               
                
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'HOT_WATER_HEATER'){
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'RADIANT_FLOOR_ELECTRIC'){
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                  //  system.debug('heat system');    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'RADIANT_FLOOR_ELECTRIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
               
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'RADIANT_FLOOR_HYDRONIC'){
                 if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                   // system.debug('ac system');
                     
                    if(coolCounter == 0){
                       
                        Cooling_Sys_1 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        //coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                     coolCounter = coolCounter + 1;
                }
                 if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                     
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'RADIANT_FLOOR_HYDRONIC';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
               
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'RESISTANCE_HEATER'){
                if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                   // system.debug('heat system');
                    
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_2 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_3 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                       // heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'RESISTANCE_HEATER';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (thisHousePlan.mechanicals.equipment[count2].equipmentType == 'CUSTOM'){
                 if(thisHousePlan.mechanicals.equipment[count2].cooling.percentLoad > 0){
                   // system.debug('ac system');
                     
                    if(coolCounter == 0){
                        
                        Cooling_Sys_1 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER = SEER_EER.abbreviate(25);
                    }
                    if(coolCounter == 1){
                        //coolCounter = coolCounter + 1;
                        Cooling_Sys_2 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_2 = SEER_EER_Sys_2.abbreviate(25);
                    }
                    
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_3 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' ' +
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_3 = SEER_EER_Sys_3.abbreviate(25);
                    }
                    if(coolCounter == 2){
                       // coolCounter = coolCounter + 1;
                        Cooling_Sys_4 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        SEER_EER_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].cooling.efficiencyType) ;
                            SEER_EER_Sys_4 = SEER_EER_Sys_4.abbreviate(25);
                    }
                    coolCounter = coolCounter + 1;
                }
                  if(thisHousePlan.mechanicals.equipment[count2].heating.percentLoad > 0){
                    system.debug('heat system');
                      
                    if(heatCounter == 0){
                        
                        Heating_Sys_1 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP = HSPF_AFUE_COP.abbreviate(25);
                    }
                    if(heatCounter == 1){
                        heatCounter = heatCounter + 1;
                        //Heating_Sys_2 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_2 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_2 = HSPF_AFUE_COP_Sys_2.abbreviate(25);
                    }
                    if(heatCounter == 2){
                        heatCounter = heatCounter + 1;
                        //Heating_Sys_3 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_3 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_3 = HSPF_AFUE_COP_Sys_3.abbreviate(25);
                    }
                    if(heatCounter == 3){
                        //heatCounter = heatCounter + 1;
                        Heating_Sys_4 = 'CUSTOM';
                        //Cooling_Capacity = '';
                        //Heating_Fuel
                        HSPF_AFUE_COP_Sys_4 = string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiency) + ' '+
                            string.valueOf(thisHousePlan.mechanicals.equipment[count2].heating.efficiencyType) ;
                            HSPF_AFUE_COP_Sys_4 = HSPF_AFUE_COP_Sys_4.abbreviate(25);
                    }
                    heatCounter = heatCounter + 1;
                }
            }
            count2++;
        }
        integer count3 = 0;
        integer i3 = thisHousePlan.mechanicals.distributionSystems.size();
        try{
         while (count3 < i3){            
            //thisHousePlan.mechanicals.distributionSystems[count2])
             if(count3==0){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless = 'Yes';
                 } else(Ductless = 'No');
                 
                 //Ducts_100_w_in_conditioned_space_Sys_2 = false;
        		 Total_Duct_Leakage = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25); 
             } 
             if(count3==1){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless_Sys_2 = True;
                 } 
                 
                 //Ducts_100_w_in_conditioned_space_Sys_2 = false;
        		 Total_Duct_Leakage_Sys_2 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO_Sys_2 =string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served_Sys_2 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25);  
             }  
             if(count3==2){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless_Sys_3 = true;
                 } else(Ductless_Sys_3 = false);
                 
                 //Ducts_100_w_in_conditioned_space_Sys_3 = false;
        		 Total_Duct_Leakage_Sys_3 =  string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO_Sys_3 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served_Sys_3 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25); 
             }  
             if(count3==3){
                 if(thisHousePlan.mechanicals.distributionSystems[count3].systemType == 'ForcedAirDuctless'){
                     Ductless_Sys_4 = true;
                 } else(Ductless_Sys_4 = false);
                 
                 //Ducts_100_w_in_conditioned_space_Sys_2 = false;
        		 Total_Duct_Leakage_Sys_4 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.totalLeakage).abbreviate(25);
                 LtO_Sys_4= string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.leakageToOutside).abbreviate(25);
                 Area_Served_Sys_4 = string.valueOf(thisHousePlan.mechanicals.distributionSystems[count3].testedDetails.sqFtServed).abbreviate(25);
             }  
            count3++;
            
         }
        } catch(exception e){
            //selfOrPlan='';
        }
        
        
        try{// try to get the dominant framed floor type and 
            //system.debug(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType);
            floorRValue = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.assemblyDetails.cavityR).abbreviate(25);
            predominantFloorId = thisHousePlan.thermalEnvelope.summary.DominantFramedFloorType.id.abbreviate(25); 
        }catch(exception e){
           // selfOrPlan='';
        }
        
        
        try{// try to get the dominant agw type and 
            foundationType = thisHousePlan.thermalEnvelope.foundationType.abbreviate(25);
            //system.debug(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType);
            foundationRValue = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantFoundationWallType.rFactor).abbreviate(25);
            predomFoundationName = thisHousePlan.thermalEnvelope.summary.dominantFoundationWallType.name.abbreviate(25); 
        }catch(exception e){
            //selfOrPlan='';
            foundationRValue = '';
            foundationType = '';
            predomFoundationName = '';
			//system.debug(e);
            //system.debug('not here');
        }
        
        
        //boolean Frame_Floor_Over = true;
       
        
        integer count = 0;
        integer i = hersAnalysis.Compliance.size();
        while (count < i){
            List<string> codesToCheck = new List<string>();
            
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV3'){
                if(hersAnalysis.Compliance[count].complianceStatus == 'Pass'){
                    energyStar = True;
                }else{
                    energyStar = False;
                }
                //energyStar = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //energyStarIndex = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV31'){
                 if(hersAnalysis.Compliance[count].complianceStatus == 'Pass'){
                    estarV31 = True;
                }else{
                    estarV31 = False;
                }
                //estarV31 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarMFV1'){
                 if(hersAnalysis.Compliance[count].complianceStatus == 'Pass'){
                    estarMFV1 = True;
                }else{
                    estarMFV1 = False;
                }
                //estarMFV1 = boolean.valueOf(hersAnalysis.Compliance[count].complianceStatus);
                //estarMFV1Index = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            count++;
        }
        try{
            predominantFloorId = thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.id.abbreviate(25);
            predomFloorName = thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.name.abbreviate(25); 
            floorRValue = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantFramedFloorType.assemblyDetails.cavityR).abbreviate(25);
        } catch(exception e){
           // selfOrPlan='';
            //system.debug('no dominantFramedFloorType ID or NAME');
        }
        try{
            predomWallId = thisHousePlan.thermalEnvelope.summary.dominantWallType.id.abbreviate(25);
            predomWallName = thisHousePlan.thermalEnvelope.summary.dominantWallType.name.abbreviate(25); 
            predomWallR = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWallType.assemblyDetails.cavityR).abbreviate(25);           
			predomWallSpacing = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWallType.assemblyDetails.framingSpacing).abbreviate(25); 
       		predomWallDepth = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWallType.assemblyDetails.framingDepth).abbreviate(25);
            predomWallDetails = predomWallDepth + '" deep, '+predomWallSpacing + '" o.c.';
            predomWallDetails = predomWallDetails.abbreviate(25);
        } catch(exception e){
            //selfOrPlan='';
            //system.debug('no dominantWallType ID or NAME');
        }
        
        try{
             predominantCeilingId = thisHousePlan.thermalEnvelope.summary.dominantCeilingType.id.abbreviate(25);
            predomCeilingName = thisHousePlan.thermalEnvelope.summary.dominantCeilingType.name.abbreviate(25);
             predomCeilingR = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantCeilingType.assemblyDetails.cavityR).abbreviate(25);
        } catch(exception e){
            //selfOrPlan='';
            //system.debug('no ceiling information');
        }

        try{
            predominantDoorId = thisHousePlan.thermalEnvelope.summary.dominantDoorType.id.abbreviate(25);
            predomDoorName = thisHousePlan.thermalEnvelope.summary.dominantDoorType.name.abbreviate(25);
            predomDoorR = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantDoorType.uFactor).abbreviate(25);
        } catch(exception e){
           // selfOrPlan='';
           // system.debug('no door information');
        }       
        try{
             predominantWindowId = thisHousePlan.thermalEnvelope.summary.dominantWindowType.id.abbreviate(25);
            predomWindowName = thisHousePlan.thermalEnvelope.summary.dominantWindowType.name.abbreviate(25);
             predomWindowU = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWindowType.uFactor).abbreviate(25);
       		predomWindowSHGC = string.valueOf(thisHousePlan.thermalEnvelope.summary.dominantWindowType.SHGC).abbreviate(25);
        	windowDetail = 'U:'+ predomWindowU + ' S:' + predomWindowSHGC;
            windowDetail = windowDetail.abbreviate(25);
        }catch(exception e){
            //selfOrPlan='';
            //system.debug('no window info');
        }
        try{
            Water_Heating_Capacity = string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.tankSize).abbreviate(25);
            Water_Heating = thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.fuel.abbreviate(25);
            Water_Heating_Efficiency = string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.efficiency).abbreviate(25);
            //if(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.equipmentType)
            //Solar_Hot_Water = thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.equipmentType;   
        }catch(exception e){
            //selfOrPlan='';
          //  system.debug('no hot water tank size');
        }
        try{
			Mechanical_Ventilation = thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.ventilationType.abbreviate(25);
            Ventilation_CFM = string.valueOf(thisHousePlan.mechanicals.summary.mechanicalVentilationRate).abbreviate(25);
            Ventilation_Watts = string.valueOf(thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.watts).abbreviate(25); //prolly should be total            
        }catch(exception e){
            //selfOrPlan='';
            //system.debug('no mech information');
        }
        lastSaved = thisProject.selfOrPlanLastSavedAt.abbreviate(25);

        string HW_Pipe_Length, Recirculation, Recirculation_System_Control_type, Water_Fixture_Type;
        try{
            HW_Pipe_Length = string.valueOf(thisHousePlan.waterSystem.hotWaterPipeLength).abbreviate(25);
            Recirculation = string.valueOf((thisHousePlan.waterSystem.recircSystem != null)).abbreviate(25);
            Recirculation_System_Control_type = thisHousePlan.waterSystem.recircSystem.systemControl.abbreviate(25);
            Water_Fixture_Type = thisHousePlan.waterSystem.fixtureEffectiveness.abbreviate(25);
        }catch(exception e){
            selfOrPlan='';
            HW_Pipe_Length = '';
            Recirculation = '';
            Recirculation_System_Control_type = '';
            Water_Fixture_Type = '';
        }
        string solar;
        try{
            if(thisHousePlan.onsiteGenerations.summary.hasSolarGeneration){
                solar = 'Yes';
            }
        } catch(exception e){
            //selfOrPlan='';
            solar = 'No';
        }
		string Ext_CFL_percentage, Ext_LED_Percentage;
        try{
            Ext_CFL_percentage = string.valueOf(thisHousePlan.lighting.percentEfficient.exterior).abbreviate(25);
            Ext_LED_Percentage = string.valueOf(thisHousePlan.lighting.percentLED.exterior).abbreviate(25);
        } catch(exception e){
            selfOrPlan='';
            Ext_CFL_percentage = string.valueOf(0);
            Ext_LED_Percentage = string.valueOf(0);
        }     
        string infil;
        try{
            infil = string.valueOf(thisHousePlan.thermalEnvelope.infiltration.ach50).abbreviate(25);
        }catch(exception e){
           // selfOrPlan='';
            
        }
        string Field1, Field2, Field3;
        try{
            integer numRaters = thisProject.hersRatingDetails.associatedUsers.size();
            integer raterCounter = 0; 
            while (raterCounter < numRaters){
                if(raterCounter == 0){
                    if(thisProject.hersRatingDetails.associatedUsers[raterCounter].userType == 'FieldInspector'){
                        Field1 = thisProject.hersRatingDetails.associatedUsers[raterCounter].fieldInspectorId;
                    } else{
                        Field1 = thisProject.hersRatingDetails.associatedUsers[raterCounter].resnetRaterId;
                        }
                }
                if(raterCounter == 1){
                    if(thisProject.hersRatingDetails.associatedUsers[raterCounter].userType == 'FieldInspector'){
                        Field2 = thisProject.hersRatingDetails.associatedUsers[raterCounter].fieldInspectorId;
                    } else{
                        Field2 = thisProject.hersRatingDetails.associatedUsers[raterCounter].resnetRaterId;
                        }
                }
                if(raterCounter == 2){
                    if(thisProject.hersRatingDetails.associatedUsers[raterCounter].userType == 'FieldInspector'){
                        Field3 = thisProject.hersRatingDetails.associatedUsers[raterCounter].fieldInspectorId;
                    } else{
                        Field3 = thisProject.hersRatingDetails.associatedUsers[raterCounter].resnetRaterId;
                    }
                }
                raterCounter = raterCounter + 1;
            }
            
            if(numRaters ==0){
                Field1 = thisProject.hersRatingDetails.rater.resnetRaterId;
            }
        }catch(exception e){
            system.debug('no associated users');
            //selfOrPlan = '';
        }
        

        unit.bedrooms__c = thisHousePlan.Details.bedrooms;
        //Band_Height__c = 1; not possible to accurately determine
        unit.HERS_Rater__c = thisProject.hersRatingDetails.rater.resnetRaterId;
        unit.Field_Inspector_1__c = Field1;
        unit.Field_Inspector_2__c = Field2;
        unit.Field_Inspector_3__c = Field3;
        unit.Street__c = thisProject.location.streetAddress;
        unit.City__c = thisProject.location.City;
        unit.Zip_Code__c = thisProject.location.zip;
        unit.State__c = thisProject.location.state;
        unit.RESNET_Registration_Date__c = RESNET_Registration_Date;
        unit.RESNET_Registry_ID__c = thisProject.hersRatingDetails.registryId;
        unit.Unit_Type__c = 'interior';
        unit.Name = thisProject.location.StreetAddress;
        unit.Residence_Type__c = houseType;
        unit.Levenshtein_String__c = levenString;
        unit.Energy_Star_pass__c = True;
        unit.Ekotrope_URL__c = 'https://app.ekotrope.com/#project:'+thisProject.id;
        //Ekotrope_Model_ID__c = string.valueOf(thisProject.id);
        unit.Ekotrope_selfOrPlanLastSavedAt__c = selfOrPlan;
        unit.Housing_Type__c = lastSaved;
        unit.Stories__c = string.valueOf(thisHousePlan.Details.numberOfFloorsOnOrAboveGrade);
        unit.Conditioned_Floor_Area__c = string.valueOf(thisHousePlan.thermalEnvelope.Summary.conditionedArea);
        //volume__c = string.valueof(thisHousePlan.ThermalEnvelope.summary.conditionedVolume);
        //Attached_Garage__c = ''; --- not currently in API
        unit.Foundation_Type__c = foundationType;
        unit.Foundation_Insulation__c = foundationRValue;
        unit.Foundation_Insulation_Name__c = predomFoundationName;
        //Floors_Over_Unconditioned_Space__c = string.valueOf(Frame_Floor_Over);
        //Frame_Floor_Over__c = ''; --- not currently in API
        unit.Frame_Floor_Insulation__c = floorRValue;
        unit.Frame_Floor_Insulation_Name__c = predomFloorName;
        unit.Above_grade_walls__c = predomWallR;
        unit.AGW_Insulation_Name__c = predomWallName;
        unit.AGW_Framing__c = predomWallDetails;
        unit.Ceiling__c = predomCeilingR;
        unit.Ceiling_Insulation_Name__c = predomCeilingName;
        unit.Roof_Condition__c = '';
        unit.Exterior_Door__c = predomDoorR;
        unit.Windows__c = windowDetail;
        unit.Skylights__c = '';
        unit.Infiltration__c = infil;
        unit.Thermostat__c = Thermostat;
        unit.Heating_Sys_1__c = Heating_Sys_1; 
        unit.Heating_Fuel__c = Heating_Fuel;
        unit.Heating_Capacity__c = Heating_Capacity; 
        unit.HSPF_AFUE_COP__c = HSPF_AFUE_COP;
        unit.Cooling_Sys_1__c = Cooling_Sys_1;
        unit.Cooling_Capacity__c = Cooling_Capacity;
        unit.SEER_EER__c = SEER_EER;
        unit.Ductless__c = Ductless;
        unit.Ducts_100_w_in_conditioned_space__c = Ducts_100_w_in_conditioned_space;
        unit.Total_Duct_Leakage__c = Total_Duct_Leakage;
        unit.LtO__c = LtO;
        unit.Area_Served__c = Area_Served;
        
        unit.Heating_Sys_2__c = Heating_Sys_2; 
        unit.Heating_Fuel_Sys_2__c =Heating_Fuel_Sys_2;
        unit.Heating_Capacity_Sys_2__c = Heating_Capacity_Sys_2; 
        unit.HSPF_AFUE_COP_Sys2__c = HSPF_AFUE_COP_Sys_2;
        unit.Cooling_Sys_2__c = Cooling_Sys_2;
        unit.Cooling_Capacity_Sys_2__c = Cooling_Capacity_Sys_2;
        unit.SEER_EER_Sys_2__c = SEER_EER_Sys_2;
        unit.Ductless_Sys_2__c = Ductless_Sys_2;
        unit.Ducts_100_w_in_conditioned_space_Sys_2__c = Ducts_100_w_in_conditioned_space_Sys_2;
        unit.Total_Duct_Leakage_Sys_2__c = Total_Duct_Leakage_Sys_2;
        unit.LtO_Sys_2__c = LtO_Sys_2;
        unit.Area_Served_Sys_2__c = Area_Served_Sys_2;
        unit.Heating_Sys_3__c = Heating_Sys_3; 
        unit.Heating_Fuel_Sys_3__c = Heating_Fuel_Sys_3;
        unit.Heating_Capacity_Sys_3__c = Heating_Capacity_Sys_3; 
        unit.HSPF_AFUE_COP_Sys_3__c = HSPF_AFUE_COP_Sys_3;
        unit.Cooling_Sys_3__c = Cooling_Sys_3;
        unit.Cooling_Capacity_Sys_3__c = Cooling_Capacity_Sys_3;
        unit.SEER_EER_Sys_3__c = SEER_EER_Sys_3;
        unit.Ductless_Sys_3__c = Ductless_Sys_3;
        unit.Ducts_100_w_in_conditioned_space_Sys_3__c = Ducts_100_w_in_conditioned_space_Sys_3;
        unit.Total_Duct_Leakage_Sys_3__c = Total_Duct_Leakage_Sys_3;
        unit.LtO_Sys_3__c = LtO_Sys_3;
        unit.Area_Served_Sys_3__c = Area_Served_Sys_3;
        
        unit.Heating_Sys_4__c = Heating_Sys_4; 
        unit.Heating_Fuel_Sys_4__c = Heating_Fuel_Sys_4;
        unit.Heating_Capacity_Sys_4__c = Heating_Capacity_Sys_4; 
        unit.HSPF_AFUE_COP_Sys_4__c =HSPF_AFUE_COP_Sys_4;
        unit.Cooling_Sys_4__c =Cooling_Sys_4;
        unit.Cooling_Capacity_Sys_4__c = Cooling_Capacity_Sys_4;
        unit.SEER_EER_Sys_4__c = SEER_EER_Sys_4;
        unit.Ductless_Sys_4__c = Ductless_Sys_4;
        unit.Ducts_100_w_in_conditioned_space_Sys_4__c = Ducts_100_w_in_conditioned_space_Sys_4;
        unit.Total_Duct_Leakage_Sys_4__c = Total_Duct_Leakage_Sys_4;
        unit.LtO_Sys_4__c = LtO_Sys_4;
        unit.Area_Served_Sys_4__c = Area_Served_Sys_4;
        unit.Water_Heating__c = Water_Heating; //thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.fuel;
        unit.Water_Heating_Capacity__C = Water_Heating_Capacity; //string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.tankSize);
        unit.Water_Heating_Efficiency__c = Water_Heating_Efficiency; //string.valueOf(thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.HotWater.efficiency);
        unit.Solar_Hot_Water__c = Solar_Hot_Water; //thisHousePlan.mechanicals.summary.dominantHotWaterEquipment.equipmentType;
        unit.Mechanical_Ventilation__c = Mechanical_Ventilation; //thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.ventilationType;
        unit.Ventilation_CFM__c = Ventilation_CFM; //string.valueOf(thisHousePlan.mechanicals.summary.mechanicalVentilationRate);
        unit.Ventilation_Watts__c = Ventilation_Watts; // string.valueOf(thisHousePlan.mechanicals.summary.dominantMechanicalVentilationType.watts); //prolly should be total
        unit.HW_Pipe_Length__c = HW_Pipe_Length;
        unit.Recirculation__c = Recirculation;
        unit.Recirculation_System_Control_type__c = Recirculation_System_Control_type;
        unit.Ceiling_fans__c = '';
        unit.Water_Fixture_Type__c = Water_Fixture_Type;
        unit.Ext_CFL_percentage__c = Ext_CFL_percentage;
        unit.Ext_LED_Percentage__c = Ext_LED_percentage;
        unit.Fridge__c = string.valueOf(thisHousePlan.appliances.refrigeratorConsumption).abbreviate(25);
        unit.Dishwasher__c = string.valueOf(thisHousePlan.appliances.dishwasherEfficiency).abbreviate(25);
        unit.Dryer__c = string.valueOf(thisHousePlan.appliances.clothesDryer.fuel).abbreviate(25);
        unit.Washer__c = string.valueOf(thisHousePlan.appliances.clothesWasher.labeledEnergyRating).abbreviate(25);
        unit.Range__c = string.valueOf(thisHousePlan.appliances.rangeOven.fuel).abbreviate(25);
        unit.Solar__c = solar;
            
            
            
        
        if(buildingSpecId != 'null'){
            unit.Building_Specification__c = buildingSpecId;
        }

        return unit;
        
    }
        
    public static HERS_Data__c constructEnergyDataRecord(projectJSON2Apex.aProjectJSON2Apex project, housePlanJSON2Apex plan, analysisJson2Apex.pAnalysisJson2Apex a, analysisJson2Apex.pAnalysisJson2Apex b, analysisJson2Apex.pAnalysisJson2Apex c, analysisJson2Apex.pAnalysisJson2Apex d, analysisJson2Apex.pAnalysisJson2Apex e, string recordType){

        projectJSON2Apex.aProjectJSON2Apex house = project;
        housePlanJSON2Apex housePlan = plan;	
        analysisJson2Apex.pAnalysisJson2Apex hersAnalysis = a;
        analysisJson2Apex.pAnalysisJson2Apex refAnalysis = b;
        analysisJson2Apex.pAnalysisJson2Apex doeAnalysis = c;
        analysisJson2Apex.pAnalysisJson2Apex ieccAnalysis = d;
        analysisJson2Apex.pAnalysisJson2Apex virginiaAnalysis = e;
        
       
        
        //string recordType = arecordType;
        Date registryDate = Date.newInstance(1999, 1, 1);
        Date ratingDate = Date.newInstance(1999, 1, 1);
        string masterPlan = null;
        string hersRater = '';
        string field1 = '';
        string field2 = '';
        string field3 = '';
        
        //hersRater = raterMap.get(house.hersRatingDetails.registryId);
 
        if(recordType == 'HERS'){
            masterPlan = house.MasterPlanId;
        }
        else{
            masterPlan = null;
        }
        
        if (house.hersRatingDetails.ratingDate != null){
            registryDate =  Date.newInstance(
                Integer.valueOf(String.valueOf(house.hersRatingDetails.ratingDate).substring(0,4)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.ratingDate).substring(5,7)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.ratingDate).substring(8,10)));
        }else{
            registryDate = null;
        }
        if (house.hersRatingDetails.fieldRatingDate != null){
            ratingDate = Date.newInstance(
                Integer.valueOf(String.valueOf(house.hersRatingDetails.fieldRatingDate).substring(0,4)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.fieldRatingDate).substring(5,7)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.fieldRatingDate).substring(8,10)));
        }else{
            ratingDate = null;
        }

		integer i = hersAnalysis.Compliance.size();
        integer count = 0;
        
        string iecc2015 = 'False';
        string energyStar = 'False';
        string doeZERH = 'False';
        string dukeHero= 'False';
        string virginia2015 = 'False';
        String virginia2015Performance = 'False';
        String iecc2015Performance = 'False';
        String virginia2015ERI = 'False';
        String estarV31 = 'False';
        String estarMFV1 = 'False';
        String taxCredit = 'False';
        
        String estarMFV1Index = 'False';
        String energyStarIndex = 'False';
        String doeZERHIndex = 'False';
        String estarV31Index = 'False';
        
        
        //system.debug(doeAnalysis.emissions.summary);
        
        while (count < i){
            List<string> codesToCheck = new List<string>();
            If (hersAnalysis.Compliance[count].code == 'Virginia2015Prescriptive'){
                virginia2015 = hersAnalysis.Compliance[count].complianceStatus;
                //virginia2015Index = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV3'){
                energyStar = hersAnalysis.Compliance[count].complianceStatus;
                energyStarIndex = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'IECC2015Perscriptive'){
                iecc2015 = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'DOEZeroEnergyReady'){
                doeZERH = hersAnalysis.Compliance[count].complianceStatus;
                doeZERHIndex = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'Virginia2015Performance'){
                virginia2015 = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'IECC2015Performance'){
                iecc2015Performance = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'Virginia2015ERI'){
                virginia2015ERI = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV31'){
                estarV31 = hersAnalysis.Compliance[count].complianceStatus;
                estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarMFV1'){
                estarMFV1 = hersAnalysis.Compliance[count].complianceStatus;
                estarMFV1Index = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'TaxCredit45L'){
                taxCredit = hersAnalysis.Compliance[count].complianceStatus;
                //estarMFV1Index = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            count++;
        }

        HERS_Data__c hersEnergyRecord = new HERS_Data__c(
            Name = recordType + '-' + house.name.abbreviate(79-recordType.length()),
            RESNET_Registry_ID__c = house.hersRatingDetails.registryId,
            Building_Run_Type__c= hersAnalysis.buildingType.abbreviate(10),
            HERS_Index__c= string.valueOf(hersAnalysis.hersScore),
            //complaince 
            Virginia_2015_ERI__c= virginia2015ERI,
            Virginia_2015_Performance__c= virginia2015Performance,
            Virginia_2015_Prescriptive__c= virginia2015 ,
            Doe_Zero_Energy_Ready__c=  doeZERH,
            Energy_Star_MF_1__c = estarMFV1,
            Energy_Star_V3__c= energyStar,
            //Energy_Star_Compliance__c=     'duplicate field'     , 
            Energy_Star_V3_1__c = estarV31,
            IECC_2015_Performance__c=  iecc2015Performance,
            IECC_2015_Prescriptive__c=   iecc2015,
			X45L_Tax_Credit__c= taxCredit,
            
            //DOEZeroEnergyReadyTarget_HERS__c=     ' '     ,
            //Ekotrope_selfOrPlanLastSavedAt__c=     ' '     ,
            //Energy_Star_MF_1_Target_HERS__c=     ' '     ,
            //Energy_Star_V3_Target_HERS__c=     ' '     ,
            //Energy_Star_V3_1_Target_HERS__c=     ' '     ,
            
            
            
            
            //DOE Zero Energy Ready Energy --- building type
            DOEZeroEnergyReadyTarget_Annual_Energy_C__c =   string.valueOf(doeAnalysis.energy.summary.cost),
            DOEZeroEnergyReadyTarget_Ref_CO2_lbs__c=  string.valueOf(doeAnalysis.emissions.summary.totalCo2),
            DOEZeroEnergyReadyTarget_Ref_Total_Rated__c = string.valueOf(doeAnalysis.energy.summary.coolingConsumption +
                doeAnalysis.energy.summary.heatingConsumption +
                doeAnalysis.energy.summary.waterHeatingConsumption +
                doeAnalysis.energy.summary.lightingAndAppliancesConsumption),
            
           
            
            
            //as built energy
            CO2_lbs__c = string.valueOf(hersAnalysis.emissions.summary.totalCo2),
            NOX_lbs__c = string.valueOf(hersAnalysis.emissions.summary.totalNox),
            SO2_lbs__c = string.valueOf(hersAnalysis.emissions.summary.totalSo2),
            
            Cooling_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.coolingConsumption),
            Heating_MMBtu_Total__c = string.valueOf(hersAnalysis.energy.summary.heatingConsumption),
            DHW_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.waterHeatingConsumption),
            PV_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.solarGeneration),
            LA_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.lightingAndAppliancesConsumption),
            Total_Rated_Consumption_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.coolingConsumption +
            hersAnalysis.energy.summary.heatingConsumption +
            hersAnalysis.energy.summary.waterHeatingConsumption +
            hersAnalysis.energy.summary.lightingAndAppliancesConsumption),

            Electricity_Consumption_kWh__c = string.valueOf(293.07 * (hersAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
            hersAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
            hersAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
            hersAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption)),

            Fuel_Oil_Consumption_gallons__c = string.valueOf(7.22 * (hersAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
            hersAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
            hersAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
            hersAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption)),

            Natural_Gas_Consumption_therms__c = string.valueOf(10 * (hersAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
            hersAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
            hersAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
            hersAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption)),

            Propane_Consumption_gallons__c = string.valueOf(10.95 *(hersAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                hersAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                hersAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                hersAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption)),          
            Heating_MMBtu_Electric__c= string.valueOf(hersAnalysis.energy.breakdown.byFuel[1].heatingConsumption),
            Heating_MMBtu_Gas__c= string.valueOf(hersAnalysis.energy.breakdown.byFuel[0].heatingConsumption),
            
            
            //iecc 2015 energy
            //IECC2015_5ACH50Reference_Annual_Energy_C__c=     ' '     , duplicate
            
            IECC2015_5ACH50Reference_Ref_annual_ener__c= string.valueOf(ieccAnalysis.energy.summary.coolingConsumption +
                ieccAnalysis.energy.summary.heatingConsumption +
                ieccAnalysis.energy.summary.waterHeatingConsumption +
                ieccAnalysis.energy.summary.lightingAndAppliancesConsumption),

            IECC2015_5ACH50Reference_Ref_CO2_lbs__c= string.valueOf(ieccAnalysis.emissions.summary.totalCo2) ,
            IECC2015_5ACH50Reference_Ref_Electricity__c=  string.valueOf(293.07 * (ieccAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption)),
            IECC2015_5ACH50Reference_Ref_Fuel_Oil_co__c= string.valueOf(7.22 * (ieccAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption)),

            IECC2015_5ACH50Reference_Ref_Natural_Gas__c= string.valueOf(10 * (ieccAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption)),
            IECC2015_5ACH50Reference_Ref_Propane_Con__c= string.valueOf(10.95 *(ieccAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption)),  
            IECC2015_5ACH50Reference_Ref_Total_Rated__c=string.valueOf(ieccAnalysis.energy.summary.coolingConsumption +
                ieccAnalysis.energy.summary.heatingConsumption +
                ieccAnalysis.energy.summary.waterHeatingConsumption +
                ieccAnalysis.energy.summary.lightingAndAppliancesConsumption),
     
            //HERS Reference Energy
            Ref_CO2_lbs__c = string.valueOf(refAnalysis.emissions.summary.totalCo2),
            Ref_NOX_lbs__c = string.valueOf(refAnalysis.emissions.summary.totalNox),
            Ref_SO2_lbs__c = string.valueOf(refAnalysis.emissions.summary.totalSo2),
            
            Ref_Cooling_MMBtu__c = string.valueOf(refAnalysis.energy.summary.coolingConsumption),
            Ref_Heating_MMBtu__c = string.valueOf(refAnalysis.energy.summary.heatingConsumption),
            Ref_DHW_MMBtu__c = string.valueOf(refAnalysis.energy.summary.waterHeatingConsumption),
            Ref_PV_MMBtu__c = string.valueOf(refAnalysis.energy.summary.solarGeneration),
            Ref_LA_MMBtu__c = string.valueOf(refAnalysis.energy.summary.lightingAndAppliancesConsumption),
            Ref_Total_Rated_Consumption_MMBtu__c = string.valueOf(refAnalysis.energy.summary.coolingConsumption +
                refAnalysis.energy.summary.heatingConsumption +
                refAnalysis.energy.summary.waterHeatingConsumption +
                refAnalysis.energy.summary.lightingAndAppliancesConsumption),
            
            Ref_Electricity_Consumption_kWh__c = string.valueOf(293.07 * (refAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption)),
            
            Ref_Fuel_Oil_Consumption_gallons__c = string.valueOf(7.22 * (refAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption)),
            
            Ref_Natural_Gas_Consumption_therm__c = string.valueOf(10 * (refAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption)),
            
            Ref_Propane_Consumption_gallons__c = string.valueOf(10.95 *(refAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption)),          
            //Ref_Heating_MMBtu_Electric__c= string.valueOf(refAnalysis.energy.breakdown.byFuel[1].heatingConsumption),
            //Ref_Heating_MMBtu_Gas__c= string.valueOf(refAnalysis.energy.breakdown.byFuel[0].heatingConsumption),
                        
            //Virginia IECC 2016 Reference Energy
            Virginia2015Reference_Ref_CO2_lbs__c= string.valueOf(virginiaAnalysis.emissions.summary.totalCo2) ,
            Virginia2015Reference_Ref_Electricity_co__c=  string.valueOf(293.07 * (virginiaAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption)),
            Virginia2015Reference_Ref_Fuel_Oil_consu__c= string.valueOf(7.22 * (virginiaAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption)),
            Virginia2015Reference_Ref_Natural_Gas_Co__c= string.valueOf(10 * (virginiaAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption)),
            Virginia2015Reference_Ref_Propane_Consum__c= string.valueOf(10.95 *(virginiaAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption)),  
            Virginia2015Reference_Ref_Total_Rated_Co__c=string.valueOf(virginiaAnalysis.energy.summary.coolingConsumption +
                virginiaAnalysis.energy.summary.heatingConsumption +
                virginiaAnalysis.energy.summary.waterHeatingConsumption +
                virginiaAnalysis.energy.summary.lightingAndAppliancesConsumption)        
        );          
        return hersEnergyRecord;
    }
   
    public static HERS_Data__c updateEnergyDataRecord(HERS_Data__c data, projectJSON2Apex.aProjectJSON2Apex project, housePlanJSON2Apex plan, analysisJson2Apex.pAnalysisJson2Apex a, analysisJson2Apex.pAnalysisJson2Apex b, analysisJson2Apex.pAnalysisJson2Apex c, analysisJson2Apex.pAnalysisJson2Apex d, analysisJson2Apex.pAnalysisJson2Apex e, string recordType){

        projectJSON2Apex.aProjectJSON2Apex house = project;
        housePlanJSON2Apex housePlan = plan;	
        analysisJson2Apex.pAnalysisJson2Apex hersAnalysis = a;
        analysisJson2Apex.pAnalysisJson2Apex refAnalysis = b;
        analysisJson2Apex.pAnalysisJson2Apex doeAnalysis = c;
        analysisJson2Apex.pAnalysisJson2Apex ieccAnalysis = d;
        analysisJson2Apex.pAnalysisJson2Apex virginiaAnalysis = e;
        
       
        
        //string recordType = arecordType;
        Date registryDate = Date.newInstance(1999, 1, 1);
        Date ratingDate = Date.newInstance(1999, 1, 1);
        string masterPlan = null;
        string hersRater = '';
        string field1 = '';
        string field2 = '';
        string field3 = '';
        
        //hersRater = raterMap.get(house.hersRatingDetails.registryId);
 
        if(recordType == 'HERS'){
            masterPlan = house.MasterPlanId;
        }
        else{
            masterPlan = null;
        }
        
        if (house.hersRatingDetails.ratingDate != null){
            registryDate =  Date.newInstance(
                Integer.valueOf(String.valueOf(house.hersRatingDetails.ratingDate).substring(0,4)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.ratingDate).substring(5,7)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.ratingDate).substring(8,10)));
        }else{
            registryDate = null;
        }
        if (house.hersRatingDetails.fieldRatingDate != null){
            ratingDate = Date.newInstance(
                Integer.valueOf(String.valueOf(house.hersRatingDetails.fieldRatingDate).substring(0,4)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.fieldRatingDate).substring(5,7)),
                Integer.valueOf(String.valueOf(house.hersRatingDetails.fieldRatingDate).substring(8,10)));
        }else{
            ratingDate = null;
        }

		integer i = hersAnalysis.Compliance.size();
        integer count = 0;
        
        string iecc2015 = 'False';
        string energyStar = 'False';
        string doeZERH = 'False';
        string dukeHero= 'False';
        string virginia2015 = 'False';
        String virginia2015Performance = 'False';
        String iecc2015Performance = 'False';
        String virginia2015ERI = 'False';
        String estarV31 = 'False';
        String estarMFV1 = 'False';
        String taxCredit = 'False';
        
        String estarMFV1Index = 'False';
        String energyStarIndex = 'False';
        String doeZERHIndex = 'False';
        String estarV31Index = 'False';
        
        
        //system.debug(doeAnalysis.emissions.summary);
        
        while (count < i){
            List<string> codesToCheck = new List<string>();
            If (hersAnalysis.Compliance[count].code == 'Virginia2015Prescriptive'){
                virginia2015 = hersAnalysis.Compliance[count].complianceStatus;
                //virginia2015Index = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV3'){
                energyStar = hersAnalysis.Compliance[count].complianceStatus;
                energyStarIndex = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'IECC2015Perscriptive'){
                iecc2015 = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'DOEZeroEnergyReady'){
                doeZERH = hersAnalysis.Compliance[count].complianceStatus;
                doeZERHIndex = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'Virginia2015Performance'){
                virginia2015 = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'IECC2015Performance'){
                iecc2015Performance = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'Virginia2015ERI'){
                virginia2015ERI = hersAnalysis.Compliance[count].complianceStatus;
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarV31'){
                estarV31 = hersAnalysis.Compliance[count].complianceStatus;
                estarV31Index = string.valueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'EnergyStarMFV1'){
                estarMFV1 = hersAnalysis.Compliance[count].complianceStatus;
                estarMFV1Index = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            If (hersAnalysis.Compliance[count].code == 'TaxCredit45L'){
                taxCredit = hersAnalysis.Compliance[count].complianceStatus;
                //estarMFV1Index = string.ValueOf(hersAnalysis.Compliance[count].targetHers);
            }
            count++;
        }

        
            data.Name = recordType + '-' + house.name.abbreviate(79-recordType.length());
            data.RESNET_Registry_ID__c = house.hersRatingDetails.registryId;
            data.Building_Run_Type__c= hersAnalysis.buildingType.abbreviate(10);
            data.HERS_Index__c= string.valueOf(hersAnalysis.hersScore);
            //complaince 
            data.Virginia_2015_ERI__c= virginia2015ERI;
            data.Virginia_2015_Performance__c= virginia2015Performance;
            data.Virginia_2015_Prescriptive__c= virginia2015 ;
            data.Doe_Zero_Energy_Ready__c=  doeZERH;
            data.Energy_Star_MF_1__c = estarMFV1;
            data.Energy_Star_V3__c= energyStar;
            //Energy_Star_Compliance__c=     'duplicate field'     ; 
            data.Energy_Star_V3_1__c = estarV31;
            data.IECC_2015_Performance__c=  iecc2015Performance;
            data.IECC_2015_Prescriptive__c=   iecc2015;
			data.X45L_Tax_Credit__c= taxCredit;
            
            //DOEZeroEnergyReadyTarget_HERS__c=     ' '     ;
            //Ekotrope_selfOrPlanLastSavedAt__c=     ' '     ;
            //Energy_Star_MF_1_Target_HERS__c=     ' '     ;
            //Energy_Star_V3_Target_HERS__c=     ' '     ;
            //Energy_Star_V3_1_Target_HERS__c=     ' '     ;
            
            
            
            
            //DOE Zero Energy Ready Energy --- building type
            data.DOEZeroEnergyReadyTarget_Annual_Energy_C__c =   string.valueOf(doeAnalysis.energy.summary.cost);
            data.DOEZeroEnergyReadyTarget_Ref_CO2_lbs__c=  string.valueOf(doeAnalysis.emissions.summary.totalCo2);
            data.DOEZeroEnergyReadyTarget_Ref_Total_Rated__c = string.valueOf(doeAnalysis.energy.summary.coolingConsumption +
                doeAnalysis.energy.summary.heatingConsumption +
                doeAnalysis.energy.summary.waterHeatingConsumption +
                doeAnalysis.energy.summary.lightingAndAppliancesConsumption);
            
           
            
            
            //as built energy
            data.CO2_lbs__c = string.valueOf(hersAnalysis.emissions.summary.totalCo2);
            data.NOX_lbs__c = string.valueOf(hersAnalysis.emissions.summary.totalNox);
            data.SO2_lbs__c = string.valueOf(hersAnalysis.emissions.summary.totalSo2);
            
            data.Cooling_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.coolingConsumption);
            data.Heating_MMBtu_Total__c = string.valueOf(hersAnalysis.energy.summary.heatingConsumption);
            data.DHW_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.waterHeatingConsumption);
            data.PV_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.solarGeneration);
            data.LA_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.lightingAndAppliancesConsumption);
            data.Total_Rated_Consumption_MMBtu__c = string.valueOf(hersAnalysis.energy.summary.coolingConsumption +
                hersAnalysis.energy.summary.heatingConsumption +
                hersAnalysis.energy.summary.waterHeatingConsumption +
                hersAnalysis.energy.summary.lightingAndAppliancesConsumption);

            data.Electricity_Consumption_kWh__c = string.valueOf(293.07 * (hersAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
                hersAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
                hersAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
                hersAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption));

            data.Fuel_Oil_Consumption_gallons__c = string.valueOf(7.22 * (hersAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
                hersAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
                hersAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
                hersAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption));

            data.Natural_Gas_Consumption_therms__c = string.valueOf(10 * (hersAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
            hersAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
            hersAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
            hersAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption));

            data.Propane_Consumption_gallons__c = string.valueOf(10.95 *(hersAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                hersAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                hersAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                hersAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption));          
            data.Heating_MMBtu_Electric__c= string.valueOf(hersAnalysis.energy.breakdown.byFuel[1].heatingConsumption);
            data.Heating_MMBtu_Gas__c= string.valueOf(hersAnalysis.energy.breakdown.byFuel[0].heatingConsumption);
            
            
            //iecc 2015 energy
            //IECC2015_5ACH50Reference_Annual_Energy_C__c=     ' '     ; duplicate
            
            data.IECC2015_5ACH50Reference_Ref_annual_ener__c= string.valueOf(ieccAnalysis.energy.summary.coolingConsumption +
                ieccAnalysis.energy.summary.heatingConsumption +
                ieccAnalysis.energy.summary.waterHeatingConsumption +
                ieccAnalysis.energy.summary.lightingAndAppliancesConsumption);

            data.IECC2015_5ACH50Reference_Ref_CO2_lbs__c= string.valueOf(ieccAnalysis.emissions.summary.totalCo2) ;
            data.IECC2015_5ACH50Reference_Ref_Electricity__c=  string.valueOf(293.07 * (ieccAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption));
            data.IECC2015_5ACH50Reference_Ref_Fuel_Oil_co__c= string.valueOf(7.22 * (ieccAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption));

            data.IECC2015_5ACH50Reference_Ref_Natural_Gas__c= string.valueOf(10 * (ieccAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption));
            data.IECC2015_5ACH50Reference_Ref_Propane_Con__c= string.valueOf(10.95 *(ieccAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                ieccAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                ieccAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption));  
            data.IECC2015_5ACH50Reference_Ref_Total_Rated__c=string.valueOf(ieccAnalysis.energy.summary.coolingConsumption +
                ieccAnalysis.energy.summary.heatingConsumption +
                ieccAnalysis.energy.summary.waterHeatingConsumption +
                ieccAnalysis.energy.summary.lightingAndAppliancesConsumption);
     
            //HERS Reference Energy
            data.Ref_CO2_lbs__c = string.valueOf(refAnalysis.emissions.summary.totalCo2);
            data.Ref_NOX_lbs__c = string.valueOf(refAnalysis.emissions.summary.totalNox);
            data.Ref_SO2_lbs__c = string.valueOf(refAnalysis.emissions.summary.totalSo2);
            
            data.Ref_Cooling_MMBtu__c = string.valueOf(refAnalysis.energy.summary.coolingConsumption);
            data.Ref_Heating_MMBtu__c = string.valueOf(refAnalysis.energy.summary.heatingConsumption);
            data.Ref_DHW_MMBtu__c = string.valueOf(refAnalysis.energy.summary.waterHeatingConsumption);
            data.Ref_PV_MMBtu__c = string.valueOf(refAnalysis.energy.summary.solarGeneration);
            data.Ref_LA_MMBtu__c = string.valueOf(refAnalysis.energy.summary.lightingAndAppliancesConsumption);
            data.Ref_Total_Rated_Consumption_MMBtu__c = string.valueOf(refAnalysis.energy.summary.coolingConsumption +
                refAnalysis.energy.summary.heatingConsumption +
                refAnalysis.energy.summary.waterHeatingConsumption +
                refAnalysis.energy.summary.lightingAndAppliancesConsumption);
            
            data.Ref_Electricity_Consumption_kWh__c = string.valueOf(293.07 * (refAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption));
            
            data.Ref_Fuel_Oil_Consumption_gallons__c = string.valueOf(7.22 * (refAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption));
            
            data.Ref_Natural_Gas_Consumption_therm__c = string.valueOf(10 * (refAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption));
            
            data.Ref_Propane_Consumption_gallons__c = string.valueOf(10.95 *(refAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                refAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                refAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                refAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption));          
            //Ref_Heating_MMBtu_Electric__c= string.valueOf(refAnalysis.energy.breakdown.byFuel[1].heatingConsumption);
            //Ref_Heating_MMBtu_Gas__c= string.valueOf(refAnalysis.energy.breakdown.byFuel[0].heatingConsumption);
                        
            //Virginia IECC 2016 Reference Energy
            data.Virginia2015Reference_Ref_CO2_lbs__c= string.valueOf(virginiaAnalysis.emissions.summary.totalCo2) ;
            data.Virginia2015Reference_Ref_Electricity_co__c=  string.valueOf(293.07 * (virginiaAnalysis.energy.breakdown.byFuel[1].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[1].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[1].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[1].waterHeatingConsumption));
            data.Virginia2015Reference_Ref_Fuel_Oil_consu__c= string.valueOf(7.22 * (virginiaAnalysis.energy.breakdown.byFuel[2].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[2].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[2].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[2].waterHeatingConsumption));
            data.Virginia2015Reference_Ref_Natural_Gas_Co__c= string.valueOf(10 * (virginiaAnalysis.energy.breakdown.byFuel[0].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[0].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[0].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[0].waterHeatingConsumption));
            data.Virginia2015Reference_Ref_Propane_Consum__c= string.valueOf(10.95 *(virginiaAnalysis.energy.breakdown.byFuel[3].coolingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[3].heatingConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[3].lightingAndAppliancesConsumption+
                virginiaAnalysis.energy.breakdown.byFuel[3].waterHeatingConsumption));  
            data.Virginia2015Reference_Ref_Total_Rated_Co__c=string.valueOf(virginiaAnalysis.energy.summary.coolingConsumption +
                virginiaAnalysis.energy.summary.heatingConsumption +
                virginiaAnalysis.energy.summary.waterHeatingConsumption +
                virginiaAnalysis.energy.summary.lightingAndAppliancesConsumption);        
                  
        return data;
    }
    
    public static File_QA__c constructInspectionRecord(ID unitTakeoffId, string rater) {
        Unit_Takeoff__c unitTakeoffRecord;
        unitTakeoffRecord = [SELECT Name, Building_Specification__r.Project__c,Energy_Star_Pass__c, RESNET_Registration_Date__c FROM Unit_Takeoff__c WHERE ID = :unitTakeoffId];
        //unitTakeoffRecord.QA_Status__c = 'selected';
        //update unitTakeoffRecord;
        string year;
        
        if(unitTakeoffRecord.RESNET_Registration_Date__c != null){
            year = String.valueOf(unitTakeoffRecord.RESNET_Registration_Date__c.year()); //
        } else {
            year = String.valueOf(datetime.now().year());
        }

  
        boolean estar = false;
		string projectId = unitTakeoffRecord.Building_Specification__r.Project__c;
        File_QA__c inspectionRecord = new File_QA__c(
            Project__c = projectID,
            Project_Temporary_Name__c = unitTakeoffRecord.Name,
            QA_Year__c = year,
            Rater_Name__c = rater,
            Status__c = 'New',
            Energy_STAR__c = unitTakeoffRecord.Energy_Star_Pass__c
            //RecordTypeId = fileQaId
        );

        return inspectionRecord;
	}
   
    public static File_QA__c constructAutoQaRecord(ID unitTakeoffId, string rater) {
        Unit_Takeoff__c unitTakeoffRecord;
        unitTakeoffRecord = [SELECT Name, Building_Specification__r.Project__c,Energy_Star_Pass__c, RESNET_Registration_Date__c FROM Unit_Takeoff__c WHERE ID = :unitTakeoffId];
        //unitTakeoffRecord.QA_Status__c = 'selected';
        //update unitTakeoffRecord;
        string year;
        
        if(unitTakeoffRecord.RESNET_Registration_Date__c != null){
            year = String.valueOf(unitTakeoffRecord.RESNET_Registration_Date__c.year()); //
        } else {
            year = String.valueOf(datetime.now().year());
        }
/*
        list<RecordType> recordTypes = [select id, name from RecordType where name like '%auto%'];
        id fileQaId;
        
                        
        if(recordTypes.size()>0){
            fileQaId = recordTypes.get(0).id; 
        }     */  
        
        boolean estar = false;
		string projectId = unitTakeoffRecord.Building_Specification__r.Project__c;
        File_QA__c inspectionRecord = new File_QA__c(
            Project__c = projectID,
            Project_Temporary_Name__c = unitTakeoffRecord.Name,
            QA_Year__c = year,
            Rater_Name__c = rater,
            Status__c = 'New',
            Energy_STAR__c = unitTakeoffRecord.Energy_Star_Pass__c
        );

        return inspectionRecord;
	}
   
    public static void determineQA(){
        //1. get all unit takeoffs
        // select id, RESNET_Registration_Date__c, Building_Specification__r.Name, Street__c, Residence_Type__c, Ekotrope_ID__c, Sync_Status__c, name
			//from Unit_Takeoff__c 
			//where Ekotrope_ID__c != '' 
			//and (Residence_Type__c = 'multifamily' or (Residence_Type__c = 'singlefamily' and Sync_Status__c = 'complete'))
			//and QA_Status__c = 'Un-determined'
 
        //2. build map of who needs QA
        //3. randomly select qa from the available projects
        list<RecordType> recordTypes = [select id, name from RecordType where name like '%file%'];
        id fileQaId;
        if(recordTypes.size()>0){
            fileQaId = recordTypes.get(0).id; 
        }       
        

        integer year;
        year = datetime.now().year();
        Date Start_Date = Date.newInstance(year, 1, 1);
        Date End_Date = Date.newInstance(year, 12, 31);
        String yearStr = string.valueof(year);
        system.debug(yearStr);
        List<File_QA__c> addInspections = new List<File_QA__c>();
        List<Unit_Takeoff__c> updateUnits = new List<Unit_Takeoff__c>();
        map<string, boolean> idMap = new Map<string, boolean>();
        map<string, id> rtinSFIdMap = new Map<string, id>();
        for(Contact autoUploadstatus : [select Auto_Process_On__c, id, RTIN_RFIN__c
                                        from contact
                                       where RTIN_RFIN__c != '']){
                                            idMap.put(autoUploadStatus.RTIN_RFIN__c, autoUploadStatus.Auto_Process_On__c);
                                            rtinSFIdMap.put(autoUploadStatus.RTIN_RFIN__c, autoUploadStatus.Id);
                                        }

        Map<String, map<string,Double>> raterMap = new Map<String, map<string,Double>>();
    	map<string, boolean> ectaMap = new map<string, boolean>();
        for(Contact existingContact : [
                Select RTIN_RFIN__c, name, id, Earthcraft_TA__c
                FROM contact
                WHERE RTIN_RFIN__c != null ])
            {
                map<string, Double> fileMap = new map<string, Double>();
                raterMap.put(existingContact.RTIN_RFIN__c, fileMap);
                ectaMap.put(existingContact.RTIN_RFIN__c, existingContact.Earthcraft_TA__c);
            }
        
        for(AggregateResult pRegFile: [
             select HERS_Rater__c,count(id)
             from Unit_Takeoff__c 
                where 
                (RESNET_Registration_Date__c = THIS_YEAR) 
            or (//Energy_Star_Pass__c = True 
                RESNET_Registration_Date__c = null 
                and Sync_Status__c != null 
                and Ekotrope_ID__c != null 
                and QA_Status__c != null)
             group by HERS_Rater__c]){
                 if(raterMap.get(string.valueOf(pRegFile.get('HERS_Rater__c'))) != null){
                     raterMap.get(string.valueOf(pRegFile.get('HERS_Rater__c'))).put('pRegFile', Double.valueof(pRegFile.get('expr0')));
                 }else{
                     map<string, Double> fileMap = new map<string, Double>();
                     fileMap.put('pRegFile', integer.valueOf(pRegFile.get('expr0')));
                     raterMap.put(string.valueof(pRegFile.get('HERS_Rater__c')),fileMap);
                 }
             }
        
        for(AggregateResult pEstarFile: [
            select HERS_Rater__c,count(id)
            from Unit_Takeoff__c 
            where 
                (Energy_Star_Pass__c = True and RESNET_Registration_Date__c = THIS_YEAR) 
            or (Energy_Star_Pass__c = True 
                and RESNET_Registration_Date__c = null 
                and Sync_Status__c != null 
                and Ekotrope_ID__c != null 
                and QA_Status__c != null)
             group by HERS_Rater__c]){
                if(raterMap.get(string.valueOf(pEstarFile.get('HERS_Rater__c'))) != null){
                     raterMap.get(string.valueOf(pEstarFile.get('HERS_Rater__c'))).put('pEstarFile', Double.valueof(pEstarFile.get('expr0')));
                 }else{
                     map<string, Double> fileMap = new map<string, Double>();
                     fileMap.put('pEstarFile', Double.valueOf(pEstarFile.get('expr0')));
                     raterMap.put(string.valueof(pEstarFile.get('HERS_Rater__c')),fileMap);
                 }
            }
        
        for(AggregateResult pEstarFileQA: [
                select Rater_Name__r.RTIN_RFIN__c, count(id)
                from File_QA__c
                Where QA_Year__c = :yearStr
                and Energy_Star__c = TRUE
                Group By Rater_Name__r.RTIN_RFIN__c]){
                    if(raterMap.get(string.valueOf(pEstarFileQA.get('RTIN_RFIN__c'))) != null){
                     	raterMap.get(string.valueOf(pEstarFileQA.get('RTIN_RFIN__c'))).put('pEstarFileQA', Double.valueof(pEstarFileQA.get('expr0')));
                    }else{
                        map<string, Double> fileMap = new map<string, Double>();
                        fileMap.put('pEstarFileQA', Double.valueOf(pEstarFileQA.get('expr0')));
                        raterMap.put(string.valueof(pEstarFileQA.get('RTIN_RFIN__c')),fileMap);
                    }
                }
                                           
        for(AggregateResult pFileQA: [
                 select Rater_Name__r.RTIN_RFIN__c, count(id)
                 from File_QA__c
                 Where QA_Year__c = :yearStr
                 Group By Rater_Name__r.RTIN_RFIN__c]){
                     if(raterMap.get(string.valueOf(pFileQA.get('RTIN_RFIN__c'))) != null){
                     	raterMap.get(string.valueOf(pFileQA.get('RTIN_RFIN__c'))).put('pFileQA', Double.valueof(pFileQA.get('expr0')));
                    }else{
                        map<string, Double> fileMap = new map<string, Double>();
                        fileMap.put('pFileQA', Double.valueOf(pFileQA.get('expr0')));
                        raterMap.put(string.valueof(pFileQA.get('RTIN_RFIN__c')),fileMap);
                    }

                 }
        
        system.debug(raterMap);
        
        for(Unit_Takeoff__c unit : 
            [select id, RESNET_Registration_Date__c,RESNET_Registry_ID__c, Selected_Project_Match__c, Building_Specification__r.Name, QA_Status__c,
             Street__c, Field_Inspector_1__c, Field_Inspector_2__c, Field_Inspector_3__c,
             Residence_Type__c, Ekotrope_ID__c, HERS_Rater__c, Energy_Star_Pass__c, Sync_Status__c, name
             from Unit_Takeoff__c 
             where Ekotrope_ID__c != ''
             and (Residence_Type__c = 'multifamily' 
                  or (Residence_Type__c = 'singlefamily' and Sync_Status__c = 'complete'))
             and QA_Status__c = 'Un-determined']){
                 unit.QA_Status__c = 'Complete';
                 updateUnits.add(unit);
                 //iterate over each of these units
                 //determine qa need for each
                 //RTIN_RFIN__c
                 string hersRater = unit.HERS_Rater__c;
                 string rfi1 = unit.Field_Inspector_1__c;
                 string rfi2 = unit.Field_Inspector_2__c;
                 string rfi3 = unit.Field_Inspector_3__c;
                 system.debug(unit);
                 try{
                     //see if the hersRater is in the map
                     system.debug(raterMap.get(string.valueOf(hersRater)));
                 }catch(exception e){
                     map<string, Double> fileMap = new map<string, Double>();
                     fileMap.put('pFileQA', 0);
                     fileMap.put('pRegFile', 0);
                     fileMap.put('pEstarFileQA', 0);
                     fileMap.put('pEstarFile', 0);
                     raterMap.put(string.valueof(hersRater),fileMap);
                 }
                               
                 system.debug(unit.name);
                 if(raterMap.get(string.valueOf(hersRater)).get('pFileQA')==null){
                     raterMap.get(string.valueOf(hersRater)).put('pFileQA',0);
                 } 
                 if(raterMap.get(string.valueOf(hersRater)).get('pEstarFileQA') == null){
                     raterMap.get(string.valueOf(hersRater)).put('pEstarFileQA',0);
                 }
                 if(raterMap.get(string.valueOf(hersRater)).get('pRegFile')== null){
                     raterMap.get(string.valueOf(hersRater)).put('pRegFile',0);
                 }
                 if(raterMap.get(string.valueOf(hersRater)).get('pEstarFile') == null){
                     raterMap.get(string.valueOf(hersRater)).put('pEstarFile',0);
                 }
                   
                 boolean skipQaCheck = false;
                 Date holdDate = Date.newInstance(2020,6,30);
                 if(!Test.isRunningTest()){
                     if(unit.RESNET_Registration_Date__c != null && unit.RESNET_Registration_Date__c < holdDate){
                     skipQaCheck = true;
                 	}
                 }
                 if(!skipQaCheck){
                     boolean estarStatus = unit.Energy_Star_Pass__c;
                     double regFiles = raterMap.get(string.valueOf(hersRater)).get('pRegFile');
                     double regFileQA = raterMap.get(string.valueOf(hersRater)).get('pFileQA');
                     Double TotalQaNeed = math.ceil(double.valueOf(regFiles)/10);
                     boolean ecStatus = (unit.Selected_Project_Match__c != null);
                     
                     if(ectaMap.get(unit.HERS_Rater__c)==null){
                         ecStatus = false;
                     }else{
                         ecStatus = ectaMap.get(unit.HERS_Rater__c);
                     }
                     
                     double eStarFiles, eStarFileQA;
                     Double TotalEstarQaNeed, eStarFileQaLeft;
                     Double TotalFileQaNeed, regFileQaLeft;
                     try{
                         eStarFiles = raterMap.get(string.valueOf(hersRater)).get('pEstarFile');
                         eStarFileQA = raterMap.get(string.valueOf(hersRater)).get('pEstarFileQA');          	
                         TotalEstarQaNeed = Math.ceil(double.valueOf(eStarFiles)/10);
                         eStarFileQaLeft = TotaleStarQaNeed - eStarFileQa;
                         TotalFileQaNeed = math.ceil(double.valueOf(regFiles)/10);
                         regFileQaLeft = TotalFileQaNeed - regFileQa;
                     }
                     catch(exception e){
                         system.debug(e);
                         estarFiles = 0.0;
                         estarFileQA = -1.0;
                         TotalEstarQANeed = 0.0;
                         eStarFileQaLeft = 0.0;
                         TotalFileQaNeed = 0.0;
                         regFileQaLeft = 0.0;
                         
                     }
                     
                     boolean rater;
                     boolean rfi_1;
                     boolean rfi_2;
                     boolean rfi_3;                 
                     if(idMap.get(unit.HERS_Rater__c)== null){
                         rater = false;
                     } else{
                         rater = idMap.get(unit.HERS_Rater__c);
                     }
                     
                     
                     if(idMap.get(unit.Field_Inspector_1__c)==null){
                         rfi_1 = false;
                     } else{
                         rfi_1 = idMap.get(unit.Field_Inspector_1__c);
                     }
                     if(idMap.get(unit.Field_Inspector_2__c)==null){
                         rfi_2 = false;
                     } else{
                         rfi_2 = idMap.get(unit.Field_Inspector_2__c);
                     }
                     if(idMap.get(unit.Field_Inspector_3__c)==null){
                         rfi_3 = false;
                     } else{
                         rfi_3 = idMap.get(unit.Field_Inspector_3__c);
                     }
                     
                     
                     double rand1, rand2, rand3, rand4, rand5, rand6;
                     if(test.isRunningTest()){
                         rand1 = 0.3;
                         rand2 = 0.1;
                         rand3 = 0.1;
                         rand4 = 0.6;
                         rand5 = 0.3;
                         rand6 = 0.7;                 
                     } else{
                         rand1 = math.random();
                         rand2 = math.random();
                         rand3 = math.random();
                         rand4 = math.random();
                         rand5 = math.random();
                         rand6 = math.random();
                     }   
                     if(ecStatus){  
                         if(rater && rfi_1 && rfi_2 && rfi_3){
                             unit.QA_Status__c = 'Complete';
                         }
                         else{//not approved for autoProcess //place the project on hold
                             unit.QA_Status__c = 'On Hold';
                         }
                         if(unit.Energy_Star_Pass__c){
                             
                             if(eStarFileQA == 0){
                                 system.debug('made inspection');
                                 File_QA__c newInspection = constructInspectionRecord(unit.Id, rtinSFIdMap.get(hersRater));
                                 addInspections.add(newInspection);
                                 //raterMap.get(string.valueOf(pFileQA.get('Rater_Name__r.RTIN_RFIN__c'))).put('pFileQA', integer.valueof(pFileQA.get('expr0')));
                                 Double newQaTotal = eStarFileQA + 1;
                                 Double newFileQA = regFileQA + 1;
                                 raterMap.get(string.valueOf(hersRater)).put('pEstarFileQA', newQaTotal);
                                 raterMap.get(string.valueOf(hersRater)).put('pFileQA', newFileQA);
                                 
                             } else if(rand1 > 0.2) {
                                 //flip coin
                                 system.debug('First Coin Flip was greater than 0.2');
                                 
                                 //if eStarFileQaLeft > 0 == TRUE then we can create a QA
                                 if(TotaleStarQaNeed - eStarFileQa >= 0){
                                     system.debug('made inspection');
                                     File_QA__c newInspection = constructInspectionRecord(unit.Id, rtinSFIdMap.get(hersRater));
                                     addInspections.add(newInspection);
                                     //insert newInspection;
                                     //
                                     //raterMap.get(string.valueOf(pFileQA.get('Rater_Name__r.RTIN_RFIN__c'))).put('pFileQA', integer.valueof(pFileQA.get('expr0')));
                                     Double newQaTotal = eStarFileQA + 1;
                                     Double newFileQA = regFileQA + 1;
                                     raterMap.get(string.valueOf(hersRater)).put('pEstarFileQA', newQaTotal);
                                     raterMap.get(string.valueOf(hersRater)).put('pFileQA', newFileQA);
                                     //unit.QA_Status__c = 'Complete';
                                     
                                     //updateUnits.add(unit);
                                     //update unit;
                                 }
                             }	
                         }
                         regFileQA = raterMap.get(string.valueOf(hersRater)).get('pFileQA');
                         if(regFileQA == 0){
                             system.debug('made inspection');
                             File_QA__c newInspection = constructInspectionRecord(unit.Id, rtinSFIdMap.get(hersRater));
                             addInspections.add(newInspection);
                             Double newQaTotal = regFileQA + 1;
                             raterMap.get(string.valueOf(hersRater)).put('pFileQA', newQaTotal);
                             unit.QA_Status__c = 'Complete';
                         } else if(rand3 < 0.2){
                             system.debug(idMap.get(unit.HERS_Rater__c));
                             if(rater && rfi_1 && rfi_2 && rfi_3){
                                 unit.QA_Status__c = 'Complete';
                                 //updateUnits.add(unit);//update unit;
                             }
                             else{
                                 //not approved for autoProcess
                                 //place the project on hold
                                 unit.QA_Status__c = 'On Hold';
                                 //updateUnits.add(unit);
                             }
                         }
                         else{
                             system.debug('second coin greater than 0.8; therefore selected for QA');
                             system.debug(TotalFileQaNeed);
                             system.debug(regFileQa);
                             if(TotalFileQaNeed - regFileQa >= 0){
                                 system.debug('made inspection');
                                 File_QA__c newInspection = constructInspectionRecord(unit.id, rtinSFIdMap.get(hersRater));
                                 addInspections.add(newInspection);
                                 Double newQaTotal = regFileQA + 1;
                                 raterMap.get(string.valueOf(hersRater)).put('pFileQA', newQaTotal);
                                 unit.QA_Status__c = 'Complete';
                             }
                             else{unit.QA_Status__c = 'Complete';}
                             //updateUnits.add(unit);
                         }         
                     } 
                     else{
                         if(unit.Energy_Star_Pass__c){
                             if(eStarFileQA == 0){
                                 system.debug('made inspection');
                                 File_QA__c newInspection = constructInspectionRecord(unit.Id, rtinSFIdMap.get(hersRater));
                                 addInspections.add(newInspection);
                                 Double newQaTotal = eStarFileQA + 1;
                                 Double newFileQA = regFileQA + 1;
                                 raterMap.get(string.valueOf(hersRater)).put('pEstarFileQA', newQaTotal);
                                 raterMap.get(string.valueOf(hersRater)).put('pFileQA', newFileQA);
                             } else if(rand4 > 0.5) {
                                 //if eStarFileQaLeft > 0 == TRUE then we can create a QA
                                 if(eStarFileQaLeft >= 0){
                                     system.debug('made inspection');
                                     File_QA__c newInspection = constructInspectionRecord(unit.Id, rtinSFIdMap.get(hersRater));
                                     addInspections.add(newInspection);
                                     
                                     Double newQaTotal = eStarFileQA + 1;
                                     Double newFileQA = regFileQA + 1;
                                     raterMap.get(string.valueOf(hersRater)).put('pEstarFileQA', newQaTotal);
                                     raterMap.get(string.valueOf(hersRater)).put('pFileQA', newFileQA);
                                     unit.QA_Status__c = 'Complete';
                                     //updateUnits.add(unit);
                                 }
                             }	
                         }
                         
                         regFileQA = raterMap.get(string.valueOf(hersRater)).get('pFileQA');
                         
                         if(regFileQA == 0){
                             system.debug('made inspection');
                             File_QA__c newInspection = constructInspectionRecord(unit.Id, rtinSFIdMap.get(hersRater));
                             addInspections.add(newInspection);
                             Double newQaTotal = regFileQA + 1;
                             raterMap.get(string.valueOf(hersRater)).put('pFileQA', newQaTotal);
                             unit.QA_Status__c = 'Selected';
                         } else if(rand5 < 0.5){
                             system.debug(idMap.get(unit.HERS_Rater__c));
                             if(rater && rfi_1 && rfi_2 && rfi_3){
                                 unit.QA_Status__c = 'Complete';
                                 //updateUnits.add(unit);
                             }
                             else{
                                 //not approved for autoProcess
                                 //place the project on hold
                                 unit.QA_Status__c = 'On Hold';
                                 //updateUnits.add(unit);
                             }
                         } else{
                             system.debug('second coin greater than 0.8; therefore selected for QA');
                             if(TotalFileQaNeed - regFileQa >= 0){
                                 system.debug('made inspection');
                                 File_QA__c newInspection = constructInspectionRecord(unit.id, rtinSFIdMap.get(hersRater));
                                 addInspections.add(newInspection);//insert newInspection;
                                 unit.QA_Status__c = 'Complete';
                                 Double newQaTotal = regFileQA + 1;
                                 raterMap.get(string.valueOf(hersRater)).put('pFileQA', newQaTotal);
                             }
                             else{unit.QA_Status__c = 'Complete';}
                             //updateUnits.add(unit);
                         }
                     }

                     
                 }
                 else{
                     unit.QA_Status__c = 'Complete';
                 	system.debug('skipped QA check');
                     system.debug(unit.RESNET_Registration_Date__c);
                     system.debug(unit.RESNET_Registry_ID__c);
                 }
             }
        system.debug(raterMap);
        insert addInspections;
        update updateUnits;
    }
    
    public static string normalizeLechString(String projName, String street, String city, String state){//,String City, String State, String zipCode
        //project name - first token
        //street - second token
        //city - third
        //state - fourth
        //zipcode - fifth
        Map<String, String> stopWords = new Map<String, String>{'xing '=>'crossing','wy'=>'way','wls'=>'wells','wells'=>'wells',
            'well'=>'well','ways'=>'ways','way'=>'way','wall'=>'wall','walks'=>'walks','walk'=>'walk','vws'=>'views','vw'=>'view',
            'vsta'=>'vista','vst'=>'vista','vlys'=>'valleys','vly'=>'valley','vlly'=>'valley','vlgs'=>'villages','vlg'=>'village',
            'vl'=>'ville','vista'=>'vista','vist'=>'vista','vis'=>'vista','villiage'=>'village','villg'=>'village','ville'=>'ville',
            'villages'=>'villages','village'=>'village','villag'=>'village','vill'=>'village','views'=>'views','view'=>'view',
            'viaduct'=>'viaduct','viadct'=>'viaduct','via'=>'viaduct','vdct'=>'viaduct','vally'=>'valley','valleys'=>'valleys',
            'valley'=>'valley','unions'=>'unions','union'=>'union','underpass'=>'underpass','un'=>'union','turnpk'=>'turnpike',
            'turnpike'=>'turnpike','tunnl'=>'tunnel','tunnels'=>'tunnel','tunnel'=>'tunnel','tunls'=>'tunnel','tunl'=>'tunnel',
            'tunel'=>'tunnel','trnpk'=>'turnpike','trls'=>'trail','trlrs'=>'trailer','trlr'=>'trailer','trl'=>'trail',
            'trks'=>'track','trk'=>'track','trce'=>'trace','trak'=>'track','trails'=>'trail','trailer'=>'trailer','trail'=>'trail',
            'trafficway'=>'trafficway','tracks'=>'track','track'=>'track','traces'=>'trace','trace'=>'trace',
            'throughway'=>'throughway','terrace'=>'terrace','terr'=>'terrace','ter'=>'terrace','summit'=>'summit',
            'sumitt'=>'summit','sumit'=>'summit','strvnue'=>'stravenue','strvn'=>'stravenue','strt'=>'street','strm'=>'stream',
            'streme'=>'stream','streets'=>'streets','street'=>'street','stream'=>'stream','stravn'=>'stravenue',
            'stravenue'=>'stravenue','straven'=>'stravenue','strav'=>'stravenue','stra'=>'stravenue','str'=>'street',
            'stn'=>'station','statn'=>'station','station'=>'station','sta'=>'station','st'=>'street','squares'=>'squares',
            'square'=>'square','squ'=>'square','sqrs'=>'squares','sqre'=>'square','sqr'=>'square','sq'=>'square','spurs'=>'spurs',
            'spur'=>'spur','sprngs'=>'springs','sprng'=>'spring','springs'=>'springs','spring'=>'spring','spngs'=>'springs',
            'spng'=>'spring','spgs'=>'springs','spg'=>'spring','smt'=>'summit','skyway'=>'skyway','shrs'=>'shores','shr'=>'shore',
            'shores'=>'shores','shore'=>'shore','shoars'=>'shores','shoar'=>'shore','shoals'=>'shoals','shoal'=>'shoal',
            'shls'=>'shoals','shl'=>'shoal','rvr'=>'river','run'=>'run','rue'=>'rue','rst'=>'rest','rpds'=>'rapids','rpd'=>'rapid',
            'row'=>'row','route'=>'route','roads'=>'roads','road'=>'road','rnchs'=>'ranch','rnch'=>'ranch','rivr'=>'river',
            'river'=>'river','riv'=>'river','ridges'=>'ridges','ridge'=>'ridge','rest'=>'rest','rds'=>'roads','rdgs'=>'ridges',
            'rdge'=>'ridge','rdg'=>'ridge','rd'=>'road','rapids'=>'rapids','rapid'=>'rapid','ranches'=>'ranch','ranch'=>'ranch',
            'ramp'=>'ramp','radl'=>'radial','radiel'=>'radial','radial'=>'radial','rad'=>'radial','pts'=>'points','pt'=>'point',
            'prts'=>'ports','prt'=>'port','prr'=>'prairie','prk'=>'park','prairie'=>'prairie','pr'=>'prairie','ports'=>'ports',
            'port'=>'port','points'=>'points','point'=>'point','pnes'=>'pines','plza'=>'plaza','plz'=>'plaza','plns'=>'plains',
            'pln'=>'plain','plaza'=>'plaza','plains'=>'plains','plain'=>'plain','pl'=>'place','pky'=>'parkway','pkwys'=>'parkways',
            'pkwy'=>'parkway','pkway'=>'parkway','pines'=>'pines','pine'=>'pine','pikes'=>'pike','pike'=>'pike','paths'=>'path',
            'path'=>'path','passage'=>'passage','pass'=>'pass','parkwy'=>'parkway','parkways'=>'parkways','parkway'=>'parkway',
            'parks'=>'parks','park'=>'park','ovl'=>'oval','overpass'=>'overpass','oval'=>'oval','orchrd'=>'orchard','orchard'=>
            'orchard','orch'=>'orchard','neck'=>'neck','nck'=>'neck','mtn'=>'mountain','mtin'=>'mountain','mt'=>'mount',
            'mssn'=>'mission','mountin'=>'mountain','mountains'=>'mountains','mountain'=>'mountain','mount'=>'mount',
            'motorway'=>'motorway','mntns'=>'mountains','mntn'=>'mountain','mntain'=>'mountain','mnt'=>'mount','mnrs'=>'manors',
            'mnr'=>'manor','missn'=>'mission','mills'=>'mills','mill'=>'mill','mews'=>'mews','medows'=>'meadows','meadows'=>'meadows',
            'meadow'=>'meadow','mdws'=>'meadows','mdw'=>'meadows','manors'=>'manors','manor'=>'manor','mall'=>'mall','loops'=>'loop',
            'loop'=>'loop','lodge'=>'lodge','lodg'=>'lodge','locks'=>'locks','lock'=>'lock','loaf'=>'loaf','lndng'=>'landing',
            'lndg'=>'landing','ln'=>'lane','lks'=>'lakes','lk'=>'lake','lights'=>'lights','light'=>'light','lgt'=>'light',
            'lf'=>'loaf','ldge'=>'lodge','ldg'=>'lodge','lcks'=>'locks','lck'=>'lock','lane'=>'lane','landing'=>'landing',
            'land'=>'land','lakes'=>'lakes','lake'=>'lake','kys'=>'keys','ky'=>'key','knolls'=>'knolls','knoll'=>'knoll',
            'knol'=>'knoll','knls'=>'knolls','knl'=>'knoll','keys'=>'keys','key'=>'key','juncton'=>'junction','junctn'=>'junction',
            'junctions'=>'junctions','junction'=>'junction','jcts'=>'junctions','jctns'=>'junctions','jctn'=>'junction',
            'jction'=>'junction','jct'=>'junction','iss'=>'islands','islnds'=>'islands','islnd'=>'island','isles'=>'isle',
            'isle'=>'isle','islands'=>'islands','island'=>'island','is'=>'island','inlt'=>'inlet','hwy'=>'highway','hway'=>'highway',
            'hvn'=>'haven','hts'=>'heights','ht'=>'heights','hrbor'=>'harbor','holws'=>'hollow','holw'=>'hollow',
            'hollows'=>'hollow','hollow'=>'hollow','hls'=>'hills','hllw'=>'hollow','hl'=>'hill','hiwy'=>'highway',
            'hiway'=>'highway','hills'=>'hills','hill'=>'hill','highwy'=>'highway','highway'=>'highway','hbr'=>'harbor',
            'haven'=>'haven','harbr'=>'harbor','harbors'=>'harbors','harbor'=>'harbor','harb'=>'harbor','gtwy'=>'gateway',
            'gtway'=>'gateway','grv'=>'grove','groves'=>'groves','grove'=>'grove','grov'=>'grove','grn'=>'green','greens'=>'greens',
            'green'=>'green','grdns'=>'gardens','grdn'=>'garden','grden'=>'garden','gln'=>'glen','glens'=>'glens','glen'=>'glen',
            'gdns'=>'gardens','gatway'=>'gateway','gatewy'=>'gateway','gateway'=>'gateway','gardn'=>'garden','gardens'=>'gardens',
            'garden'=>'garden','fwy'=>'freeway','ft'=>'fort','fry'=>'ferry','frwy'=>'freeway','frway'=>'freeway','frt'=>'fort',
            'frst'=>'forest','frry'=>'ferry','frks'=>'forks','frk'=>'fork','frg'=>'forge','freewy'=>'freeway','freeway'=>'freeway',
            'frd'=>'ford','fort'=>'fort','forks'=>'forks','fork'=>'fork','forges'=>'forges','forge'=>'forge','forg'=>'forge',
            'forests'=>'forest','forest'=>'forest','fords'=>'fords','ford'=>'ford','flts'=>'flats','flt'=>'flat','fls'=>'falls',
            'flds'=>'fields','fld'=>'field','flats'=>'flats','flat'=>'flat','fields'=>'fields','field'=>'field','ferry'=>'ferry',
            'falls'=>'falls','fall'=>'fall','exts'=>'extensions','extnsn'=>'extension','extn'=>'extension','extension'=>'extension',
            'ext'=>'extension','expy'=>'expressway','expw'=>'expressway','expressway'=>'expressway','express'=>'expressway',
            'expr'=>'expressway','exp'=>'expressway','ests'=>'estates','estates'=>'estates','estate'=>'estate','est'=>'estate',
            'dvd'=>'divide','dv'=>'divide','drv'=>'drive','drives'=>'drives ','drive'=>'drive','driv'=>'drive','dr'=>'drive',
            'dm '=>'dam','dl '=>'dale','divide'=>'divide','div'=>'divide','dam '=>'dam','dale '=>'dale','cv'=>'cove',
            'curve '=>'curve ','cts'=>'courts','ctr'=>'center','ct'=>'court','cswy'=>'causeway','crssng '=>'crossing',
            'crsnt'=>'crescent','crsent'=>'crescent','crse'=>'course','crossroads'=>'crossroads','crossroad'=>'crossroad',
            'crossing '=>'crossing','crk'=>'creek','crest'=>'crest','crescent'=>'crescent','cres'=>'crescent','creek'=>'creek',
            'crcle'=>'circle','crcl'=>'circle','cpe'=>'cape','cp'=>'camp','coves'=>'coves','cove'=>'cove','courts'=>'courts',
            'court'=>'court','course'=>'course','cors'=>'corners','corners'=>'corners','corner'=>'corner','cor'=>'corner',
            'commons'=>'commons','common'=>'common','cnyn'=>'canyon','cntr'=>'center','cnter'=>'center','cmp'=>'camp','club'=>'club',
            'cliffs'=>'cliffs','cliff'=>'cliff','clfs'=>'cliffs','clf'=>'cliff','clb'=>'club','circles'=>'circles','circle'=>'circle',
            'circl'=>'circle','circ'=>'circle','cir'=>'circle','centre'=>'center','centr'=>'center','centers '=>'centers',
            'center'=>'center','cent'=>'center','cen'=>'center','causwa'=>'causeway','causeway'=>'causeway','cape'=>'cape',
            'canyon'=>'canyon','canyn'=>'canyon','camp'=>'camp','byps'=>'bypass','bypass'=>'bypass','bypas'=>'bypass','bypa'=>'bypass',
            'byp'=>'bypass','burgs'=>'burgs','burg'=>'burg','btm'=>'bottom','brooks '=>'brooks','brook'=>'brook','brnch'=>'branch',
            'brk'=>'brook','bridge'=>'bridge','brg'=>'bridge','brdge'=>'bridge','branch'=>'branch','br'=>'branch','boulv'=>'boulevard',
            'boulevard '=>'boulevard','boul'=>'boulevard','bottom'=>'bottom','bottm'=>'bottom','bot'=>'bottom','bnd'=>'bend',
            'blvd'=>'boulevard','bluffs '=>'bluffs','bluff'=>'bluff','bluf'=>'bluff','blf'=>'bluff','bend'=>'bend','beach'=>'beach',
            'bch'=>'beach','bayou'=>'bayou','bayoo'=>'bayou','avnue'=>'avenue','avn'=>'avenue','avenue'=>'avenue','avenu'=>'avenue',
            'aven'=>'avenue','ave'=>'avenue','av'=>'avenue','arcade '=>'arcade','arc '=>'arcade','anx'=>'anex','annx'=>'anex',
            'annex'=>'anex','anex'=>'anex','aly'=>'alley','ally'=>'alley','alley'=>'alley','allee'=>'alley'};
        string projectName, streetAddress, cityName, stateName;       
        
        if(street != null & street != ''){
            streetAddress = street.toLowerCase();
        } else{
            streetAddress = '';
        }
        if(city != null & city != ''){
            cityName = city.toLowerCase();
        } else{
            cityName = '';
        }
        if(state != null & state != ''){
            stateName = state.toLowerCase();
        } else{
            stateName = '';
        }
        
        if(streetAddress == '' & cityName == '' & stateName == ''){
            string levenString = 'n/a';
            return levenString;
        } else{      
            // Remove abbreviations, non-alphanumeric characters
            Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9 ]');
            String cleanStreetAddress = nonAlphanumeric.matcher(streetAddress).replaceAll('');  
            //String cleanProjectName = nonAlphanumeric.matcher(projectName).replaceAll('');
            String cleanCityName = nonAlphanumeric.matcher(cityName).replaceAll('');
            String cleanStateName = nonAlphanumeric.matcher(stateName).replaceAll('');
            
            // Split and then keep only portions of each string
            List<string> splitStreetAddress = cleanStreetAddress.split(' ', 0);
            //List<string> splitProjectName = cleanProjectName.split(' ',0);
            List<string> splitCityName = cleanCityName.split(' ',0);
            List<string> splitStateName = cleanStateName.split(' ',0);
            
            //iterate over lists of items in each name, remove abbreviations, 
            //and select only a portion of each names
            map<string, list<string>> keyString = new map<string, list<string>>();
            
            keyString.put('streetAddress', splitStreetAddress);
            //keyString.put('projectName', splitProjectName);
            keyString.put('cityName', splitCityName);
            keyString.put('stateName', splitStateName);
            
            List<string> keptWords = new List<string>();
            
            for(integer n=0,p=0;n<splitStreetAddress.size();n++){
                integer addressCounter = 0;
                if(!stopWords.containsKey(splitStreetAddress.get(n))){
                    if(n<math.min(2,splitStreetAddress.size())){
                        keptWords.add(splitStreetAddress.get(n).left(5));
                    }
                }
            }
            
            for(integer n=0,p=0;n<splitCityName.size();n++){
                integer counter = 0;
                if(!stopWords.containsKey(splitCityName.get(n))){
                    if(n< math.min(2,splitCityName.size())){
                        //system.debug(splitStreetAddress.get(addressCounter));
                        keptWords.add(splitCityName.get(n).left(5));
                        //n = counter + 1;
                    }
                }
            }
            
            for(integer n=0,p=0;n<splitStateName.size();n++){
                integer counter = 0;
                if(!stopWords.containsKey(splitStateName.get(n))){
                    if(n< math.min(2,splitStateName.size())){
                        //system.debug(splitStreetAddress.get(addressCounter));
                        keptWords.add(splitStateName.get(n).left(5));
                        //counter = counter + 1;
                    }
                }
            }
            
            
            
            List<List<String>> nameList = new List<List<String>>();
            nameList.add(splitStreetAddress);
            nameList.add(splitCityName);
            nameList.add(splitStateName);        
            
            //concatenate all keptWords together
            integer keptWordListLength = keptWords.size();
            string levenString = '';
            for(integer i=0,j=0;i<keptWordListLength;i++){
                levenString = levenString + keptWords.get(i);
            }
            if(keptWordListLength == null | keptWordListLength == 0){
                levenString = 'n/a';
            }
            system.debug(levenString);
            return levenString;	
            
            
        }
        
              
    } 
  
    public static HttpResponse getProjectList(String authorization, String statusType){
        //Get list of projects from ekotrope that have stage: statusType
        //    -statusType options are: Registered with Resnet, Submitted for QA, Shared with Provider, unregistered
        //    -This queries ekotrope for a project list
        //    -If no response or api call errors it returns a httpResponse with an error code to be processed later
        //
        
        if(test.isRunningTest()){
                    Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpProjListCallout());
                }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setEndpoint('https://api.ekotrope.com/api/v1/projects?status='+statusType);//SUBMITTED_TO_REGISTRY');
        request.setMethod('GET');
        request.setHeader('authorization', authorization);
        request.setTimeout(60000);
        try {
			system.debug('trying to get response from get project list');
            response = http.send(request);
            } 
        catch(Exception e) {
            system.debug('getProjectList except');
            system.debug(e.getMessage());
            response = new HttpResponse();
            response.setStatus(e.getMessage());
            response.setStatusCode(418);
            response.setBody('{}');
            system.debug(response);
        }
        
        return response;
   	}
 
	public static HttpResponse getProjectListWithDate(String authorization, String statusType, String createdAfter, String createdBefore){
        
        if(test.isRunningTest()){
                    Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpProjListCallout());
                }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        system.debug('https://api.ekotrope.com/api/v1/projects?status='+statusType+'&created_after='+createdAfter+'&created_before='+createdBefore);
        request.setEndpoint('https://api.ekotrope.com/api/v1/projects?status='+statusType+'&created_after='+createdAfter+'&created_before='+createdBefore);
        request.setMethod('GET');
        request.setHeader('authorization', authorization);
        request.setTimeout(60000);
        try {
			system.debug('trying to get response from get project list');
            response = http.send(request);
            } 
        catch(Exception e) {
            system.debug('getProjectList except');
            system.debug(e.getMessage());
            response = new HttpResponse();
            response.setStatus(e.getMessage());
            response.setStatusCode(418);
            response.setBody('{}');
            system.debug(response);
        }
        
        return response;
    }

    public static HttpResponse getProject(String authorization, String ekotropeId){
        String project = ekotropeId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse projectResponse;
		request.setEndpoint('https://api.ekotrope.com/api/v1/projects/'+project);
		request.setMethod('GET');
        request.setTimeout(60000);
		request.setHeader('authorization', authorization);
		
        try{
            if (Test.isRunningTest()) {Test.setMock(HttpCalloutMock.class, new ekotropeMockHttpProjectCallout() );} 
            projectResponse = http.send(request);
           
        } catch(Exception e){
            system.debug('getProject exception');
            system.debug(e.getMessage());
            projectResponse = new HttpResponse();
            projectResponse.setStatus(e.getMessage());
            projectResponse.setStatusCode(418);
            projectResponse.setBody('{}');
            
            
        }
        return projectResponse;

    }

    public static HttpResponse getHousePlan(String authorization, String ekotropeMasterPlanId){
        String planID = ekotropeMasterPlanId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse planResponse;
		request.setEndpoint('https://api.ekotrope.com/api/v1/houseplans/' + planID);
		request.setMethod('GET');
        request.setTimeout(60000);
        request.setHeader('authorization', authorization);
        try{
            planResponse = http.send(request);
        } catch(Exception e){
            system.debug('getHousePlan except');
            system.debug(e.getMessage());
            planResponse = new HttpResponse();
            planResponse.setStatus(e.getMessage());
            planResponse.setStatusCode(418);
            planResponse.setBody('{}');
        }
		
        return planResponse;

    }

    public static HttpResponse getHousePlanAnalysis(String authorization, String ekotropeMasterPlanId, String buildingType, List<String> codesToCheck){
        String planID = ekotropeMasterPlanId;
        String building = buildingType;
        
        string urlString = '';
        string codeString = '';
        if(codesToCheck.size()>0){
            codeString = 'codesToCheck=' + codesToCheck[0];
            for(integer i = 1, j=0; i<codesToCheck.size();i++){
            codeString =  codeString + '&codesToCheck=' + codesToCheck[i];
            }
        }
        
		//system.debug(codeString);
        
        if(building == 'EkotropeAsModeled'){
            urlString = 'https://api.ekotrope.com/api/v1/planAnalysis/' + planId + '?' + codeString;
            system.debug(codeString);
            system.debug(urlString);
        }
        if(building != 'EkotropeAsModeled'){
            urlString = 'https://api.ekotrope.com/api/v1/planAnalysis/' + planId+'?' + 'buildingType='+ buildingType;
            system.debug(buildingType);
            system.debug(urlString);
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse planAnalysisResponse;
        request.setEndpoint(urlString);
		request.setMethod('GET');
        request.setTimeout(20000);
		request.setHeader('authorization', authorization);
		
        try{
            planAnalysisResponse = http.send(request);
            
        } catch(Exception e){
            system.debug('getHousePlanAnalysis except');
            system.debug(e.getMessage());
            planAnalysisResponse = new HttpResponse();
            planAnalysisResponse.setStatus(e.getMessage());
            planAnalysisResponse.setStatusCode(418);
            planAnalysisResponse.setBody('{}');
           
        }
        return planAnalysisResponse;

    }
   
    public static HttpResponse putToBuildingRegistry(String authorization, String ekotropeId){
        //make this a method which returns a Map<String, String>
        //This method should take an authorization and a list of project ids or ekotrope ids
        //It then uploads each individually and returns a status or does it handle the status internally
        //I think it handles the status internally and then it can just be a terminal function
        //Otherwise it takes one id at a time uploads and returns the response. That's pretty clean
        //
        //
        String planID = ekotropeId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse putResponse;//https://api.ekotrope.com/api/v1/resnet/registeredProjects/kLZ8GRnv
        system.debug('https://api.ekotrope.com/api/v1/resnet/registeredProjects/'+planID);
        request.setEndpoint('https://api.ekotrope.com/api/v1/resnet/registeredProjects/'+planID);
        request.setMethod('PUT');
        request.setHeader('authorization', authorization);
        request.setTimeout(60000);
        try{
            putResponse = http.send(request);
            //return putResponse;
        } catch(Exception e){
            system.debug('putToBuildingRegistry except');
            system.debug(e.getMessage());
            putResponse = new HttpResponse();
            putResponse.setStatus(e.getMessage());
            putResponse.setStatusCode(418);
            putResponse.setBody('{}');
            String json = '{\"registryId\":\"null\",\"rawRegistryResponse\":\"<?xml version=\\\"1.0\\\" encoding=\\\"utf-8\\\"?>\\r\\n<RegistryResponse>\\r\\n  <ResponseCode>null</ResponseCode>\\r\\n  <ResponseMessage><![CDATA[Rating imported unsuccessfully!]]></ResponseMessage>\\r\\n  <RegistryID>null</RegistryID>\\r\\n</RegistryResponse>\",\"automaticQaStatus\":\"null\"}';
            system.debug(putResponse);
			//return putResponse;
        }
        return putResponse;
    }
    
    public static Log__c constructErrorLog(String nameString, String apexClass, HttpResponse newHTTP, String projectId, String descriptionLong){
        Log__c errorLog = new Log__c(
            Name = nameString,
            Status_Code__c = string.valueOf(newHTTP.getStatusCode()),
            Class_Name__c = apexClass,
            Record_Id__c = projectId,
            Description__c = newHTTP.getStatus().abbreviate(40)
            //Description_long__c = descriptionLong
        );
        return errorLog;
    }
    
    global void setVariables(list<string> stage){
        //This sets which Ekotrope Status this code queries from the Project List API
    	//The options are: "SUBMITTED_FOR_QA", "SUBMITTED_TO_REGISTRY", "UNREGISTERED",
    	//"REGISTERED_WITH_PROVIDER"
        ekotropeStages = stage;
    }

    global void setAuthorization(){
       
        
        Account credentials = [Select id, Ekotrope_Password__c, Ekotrope_Username__c from Account WHERE Name = 'Viridiant'];//, Ekotrope_Password__c, Ekotrope_Username__c
        //system.debug(credentials.Ekotrope_Password__c);
        
        String username = credentials.Ekotrope_Username__c;
        String password = credentials.Ekotrope_Password__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        authorization = ('Basic ' + EncodingUtil.base64Encode(headerValue));  
        
        system.debug(authorization);
    }
    
    global void setEnergyDataName(string prefix){
        
        dataPrefix = prefix;
        //System.Debug('Set prefix to '+prefix);
    }  

    global void setCodesToCheck(List<string> codes){
        //Sets codes which will be evaluated for compliance
    	//in the Ekotrope calculation engine.
        integer i = codes.size();
        integer beg = 0;
        while(beg < i){
            codesToCheck.add(codes[beg]);
            beg++;
        }
    }  
    
    global void setBuildingRun(list<string> buildingTypes){ // baseline, string reference, string doeBuildingInput, string iecc2015BuildingInput, string virginiaBuildingInput){
        buildingsToCheck = buildingTypes;
        
    }
    
    
}tring estar31Analysis = String.valueOf(estar31.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex estar31AnalysisResults = analysisJson2Apex.parse(estar31Analysis);
                    
                    String estarMFAnalysis = String.valueOf(estarMF.getBody());
                    analysisJson2Apex.pAnalysisJson2Apex estarMFAnalysisResults = analysisJson2Apex.parse(estarMFAnalysis);
                    system.debug(Limits.getCpuTime());
                    
                    //Now have project, design, and three analysis responses
                    //
                    //lets do update first: 
                    //update-record should mean the sync has already occured. we don't need to create
                    //any records. just update the fields. Don't need to specify the parent records on any field
                    system.debug(projectId);
                    system.debug(existingViridiantMfProjectsMap.get(projectId));
                    
                    
                    unitTakeoff = ekotropeSync.updateTakeoffRecord(unitTakeoff, qProject, qplan, AsIsAnalysisResults, 'null');
                    unitTakeoff.Ekotrope_Model_ID__c = string.valueOf(qproject.id);
                    unitTakeoff.Ekotrope_selfOrPlanLastSavedAt__c = qProject.selfOrPlanLastSavedAt;
                    
                    Id unitId = unitTakeoff.id;
                    HERS_Data__c hersData;
                    list<HERS_Data__c> hersDataList = new list<HERS_Data__c>();
                    hersDataList = [Select id, name from HERS_Data__c where HERS_Project__c = :unitId];
                    
                    if(hersDataList.size()>0){
                        hersData = ekotropeSync.updateEnergyDataRecord(hersDataList.get(0), qProject, qplan, AsIsAnalysisResults,ReferencenalysisResults, doeAnalysisResults,ieccAnalysisResults,virginiaAnalysisResults, 'HERS');
            
                    } else{
                        hersData = ekotropeSync.constructEnergyDataRecord(qProject, qplan, AsIsAnalysisResults,ReferencenalysisResults, doeAnalysisResults,ieccAnalysisResults,virginiaAnalysisResults, 'HERS');
                    	hersData.HERS_Project__c = unitTakeoff.id;
                    }
                    
                    hersData.Energy_Star_V3_Target_HERS__c = string.valueOf(estarAnalysisResults.hersScore);
                    hersData.Energy_Star_V3_1_Target_HERS__c = string.valueOf(estar31AnalysisResults.hersScore);
                    hersData.Energy_Star_MF_1_Target_HERS__c = string.valueOf(estarMFAnalysisResults.hersScore);
                    addUnits.add(unitTakeoff);
                    //addProjects.add(project);
                    addHersData.add(hersData);             
                    
                }
                else{
                    system.debug('Not all http callouts were successfull. Project == 200, others ?');
                    if(planResponse.getStatusCode() != 200){
                        system.debug('planResponse code:');
                        system.debug(planResponse.getStatusCode());
                        Log__c errorLog = ekotropeSync.constructErrorLog('getHousePlan','getHousePlan', planResponse, ekoProjectId, planResponse.getBody());
                        errorLogs.add(errorLog);
                    } 
                    if(analysisResponse.getStatusCode() != 200){
                        system.debug('analysisResponse code:');
                        system.debug(analysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - EkotropeAsModeled','getHousePlanAnalysis', analysisResponse, ekoProjectId, analysisResponse.getBody());
                        errorLogs.add(errorLog);
                        
                    } 
                    if(ReferenceAnalysisResponse.getStatusCode() != 200){
                        system.debug('ReferenceAnalysisResponse code:');
                        system.debug(ReferenceAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - HERSReference','getHousePlanAnalysis', ReferenceAnalysisResponse, ekoProjectId, ReferenceAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    } 
                    if(doeAnalysisResponse.getStatusCode() != 200){
                        system.debug('doeAnalysisResponse code:');
                        system.debug(doeAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - HERSRated','getHousePlanAnalysis', doeAnalysisResponse, ekoProjectId, doeAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    }
                    if(virginiaAnalysisResponse.getStatusCode() != 200){
                        system.debug('virginiaAnalysisResponse code:');
                        system.debug(virginiaAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - HERSRated','getHousePlanAnalysis', virginiaAnalysisResponse, ekoProjectId, virginiaAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    }
                    if(ieccAnalysisResponse.getStatusCode() != 200){
                        system.debug('ieccAnalysisResponse code:');
                        system.debug(ieccAnalysisResponse.getStatusCode());
                        Log__c errorLog = EkotropeSync.constructErrorLog('getHousePlanAnalysis - HERSRated','getHousePlanAnalysis', ieccAnalysisResponse, ekoProjectId, ieccAnalysisResponse.getBody());
                        errorLogs.add(errorLog);
                    }
                } 
            }
            else{
                Log__c errorLog = EkotropeSync.constructErrorLog('getProject','getProject', projectResponse, ekoProjectId, projectResponse.getBody());
                errorLogs.add(errorLog);
                system.debug(projectId);
                system.debug(projectResponse.getBody());
            } 
        }
        system.debug('===============================');
        system.debug(addUnits);
        system.debug(addHersData);
        system.debug(addProjects);
        //upsert addProjects;
        for(Unit_Takeoff__c unit: addUnits){
            system.debug(unit.id);
        }
		upsert addProjects;        
        upsert addUnits;
        upsert addHersData;
        addProjects.clear(); 
    }
    
    global void finish(Database.BatchableContext bc){
        system.debug('finish ecmfSync');
    }
    
    global void setVariables(list<string> stage){
        //This sets which Ekotrope Status this code queries from the Project List API
    	//The options are: "SUBMITTED_FOR_QA", "SUBMITTED_TO_REGISTRY", "UNREGISTERED",
    	//"REGISTERED_WITH_PROVIDER"
        ekotropeStages = stage;
    }
    
    global void setCodesToCheck(List<string> codes){
        //Sets codes which will be evaluated for compliance
    	//in the Ekotrope calculation engine.
        integer i = codes.size();
        integer beg = 0;
        while(beg < i){
            codesToCheck.add(codes[beg]);
            beg++;
        }
    }

    global void setBuildingRun(list<string> buildingTypes){// baseline, string reference, string design){
        buildingsToCheck = buildingTypes;
        
        }

    global void setEnergyDataName(string prefix){
        dataPrefix = prefix;
    }  
      
    global void setAuthorization(){
       
        Account credentials = [Select id, Ekotrope_Password__c, Ekotrope_Username__c from Account WHERE Name = 'Viridiant'];
        system.debug(credentials.Ekotrope_Password__c);
        
        String username = credentials.Ekotrope_Username__c;
        String password = credentials.Ekotrope_Password__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        authorization = ('Basic ' + EncodingUtil.base64Encode(headerValue));  
        
        system.debug(authorization);
    }


}