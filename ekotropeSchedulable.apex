/*was serhSchedulable */
global class ekotropeSchedulable implements Schedulable{
    global void execute(SchedulableContext sc){
        list<Project__c> updateLevenString = new list<Project__c>();
        for(Project__c existingProject : [Select name, id, zip_code__c, state__c, 
                                          city__c, street_address__c   
                                            	FROM Project__c where Levenshtein_String__c = null]) //and RecordTypeId='??????????????????'
        {
            String projName, street, city, state;
            projName = existingProject.name;
            street = existingProject.street_address__c;
            city = existingProject.city__c;
            state = existingProject.state__c;
            string levenString = ekotropeSync.normalizeLechString(projName, street, city, state);   
            //system.debug(lechString);
            existingProject.LevenShtein_String__c = levenString;
            updateLevenString.add(existingProject);       
        }
        update updateLevenString;
       
        
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
            //addProjects.add(placeHolderProject);
            insert placeHolderProject;
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
            //addBuildings.add(placeholderBuildingSpec);
            insert placeholderBuildingSpec;
        }
            
        
        list<string> buildingTypes = new list<string>();
        buildingTypes.add('EkotropeAsModeled');
        buildingTypes.add('HERSReference');
        buildingTypes.add('DOEZeroEnergyReadyTarget');
        buildingTypes.add('IECC2015_5ACH50Reference');
        buildingTypes.add('Virginia2015Reference');
        
        list<string> codes = new list<string>();
        codes.add('TaxCredit45L');
        codes.add('IECC2015Prescriptive');
        codes.add('IECC2015Performance');
        codes.add('Virginia2015Performance');
        codes.add('Virginia2015Prescriptive');
        codes.add('Virginia2015ERI');
        codes.add('EnergyStarV3');
        codes.add('EnergyStarV31');//just for mf? 
        codes.add('EnergyStarMFV1');	
        codes.add('DOEZeroEnergyReady'); 
        list<string> statusList = new list<string>();
        if (Test.isRunningTest()){
            system.debug('Need to write complicated test code, or I can do this');
        	statusList.add('SUBMITTED_FOR_QA');
        } else{
            statusList.add('SUBMITTED_FOR_QA');
            statusList.add('SUBMITTED_TO_REGISTRY');   
        }

        ekotropeSync updateNewProjects = new ekotropeSync();       
        updateNewProjects.setAuthorization();
        updateNewProjects.setCodesToCheck(codes);
        updateNewProjects.setVariables(statusList);
        updateNewProjects.setEnergyDataName('HERS');
        //will need to make different energy data records
        // one for HERS data or we put everything HERS (3) plus the three additional records.
        updateNewProjects.setBuildingRun(buildingTypes);
        System.debug('here');
        Id newProjectBatchId = Database.executeBatch(updateNewProjects,10);
        
        list<string> mfStatusList = new list<string>();
        if (Test.isRunningTest()){
            system.debug('Need to write complicated test code or I can do this');
        	mfStatusList.add('SUBMITTED_FOR_QA');
        } else{
            mfStatusList.add('SUBMITTED_FOR_QA');
            mfStatusList.add('SUBMITTED_TO_REGISTRY');
            mfStatusList.add('UNREGISTERED');  
            mfStatusList.add('REGISTERED_WITH_PROVIDER');     
        }
        
        ecmfSync updateECMF = new ecmfSync();
        updateECMF.setAuthorization();
        updateECMF.setCodesToCheck(codes);
        updateECMF.setVariables(mfStatusList);
        updateECMF.setBuildingRun(buildingTypes);
        System.debug('here');
        Id newProjectBatchId_ecmf = Database.executeBatch(updateECMF,15);
  
    }
}