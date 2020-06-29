global class ekotropeUpload implements Database.Batchable<Unit_Takeoff__c>, Database.AllowsCallouts, Database.Stateful{
    
    global String authorization = '';
    global List<Unit_Takeoff__c> projectsToUpdate = new List<Unit_Takeoff__c>();
    global void setAuthorization(String auth){
        authorization = auth;        
    }
    
    global Iterable<Unit_Takeoff__c> start(Database.BatchableContext bc){ 
        system.debug('ekotropeUpload.start Start');
        system.debug(Limits.getCpuTime());
        for(Unit_Takeoff__c existingUnit : [Select Ekotrope_ID__c,Id, Name, RESNET_Registry_ID__c,
                                            Energy_Star_Pass__c, HERS_Rater__c,
                                            Field_Inspector_1__c, Field_Inspector_2__c, Field_Inspector_3__c, 
                                            Building_Specification__r.Project__c
                                          FROM Unit_Takeoff__c
                                          WHERE (RESNET_Registry_ID__c = null and Ekotrope_ID__c != null 
                                          and QA_Status__c = 'Complete') 
                                            or (RESNET_Registry_ID__c = null and  Ekotrope_ID__c != null and QA_Status__c = 'Not-Selected') ])
            {projectsToUpdate.add(existingUnit);}  
        system.debug('ekotropeUpload.start Finish');
        system.debug(Limits.getCpuTime());
        return projectsToUpdate;
    }
    
    global void execute(Database.BatchableContext bc, List<Unit_Takeoff__c> projectsToUpdate){
        //list<Unit_Takeoff__c> updateUnits = new list<Unit_Takeoff__c>();
         map<string, boolean> idMap = new Map<string, boolean>();
        for(Contact autoUploadstatus : [select Auto_Process_On__c, id, RTIN_RFIN__c
                                        from contact
                                       where RTIN_RFIN__c != '']){
                                            idMap.put(autoUploadStatus.RTIN_RFIN__c, autoUploadStatus.Auto_Process_On__c);
                                            //rtinSFIdMap.put(autoUploadStatus.RTIN_RFIN__c, autoUploadStatus.Id);
                                        }
        system.debug('ekotropeUpload.execute Start');
        List<Log__c> errorLogs = new List<Log__c>();
        List<Unit_Takeoff__c> projects = new List<Unit_Takeoff__c>();
        system.debug(Limits.getCpuTime());
        System.debug(projectsToUpdate);
        Date uploadDate = Date.today();
        for(Unit_Takeoff__c currentProj : projectsToUpdate){
            boolean rater;
            boolean rfi_1;
            boolean rfi_2;
            boolean rfi_3;                 
            if(idMap.get(currentProj.HERS_Rater__c)== null){
                
                  rater = false;
            } else{
                rater = idMap.get(currentProj.HERS_Rater__c);
            }                 
            if(idMap.get(currentProj.Field_Inspector_1__c)==null){
                if(currentProj.Field_Inspector_1__c == null){
                    rfi_1= true;
                }else{
                     rfi_1 = false;
                }
               
            } else{
                rfi_1 = idMap.get(currentProj.Field_Inspector_1__c);
            }
            if(idMap.get(currentProj.Field_Inspector_2__c)==null){
                 if(currentProj.Field_Inspector_2__c == null){
                    rfi_2= true;
                }else{
                     rfi_2 = false;
                }
            } else{
                rfi_2 = idMap.get(currentProj.Field_Inspector_2__c);
            }
            if(idMap.get(currentProj.Field_Inspector_3__c)==null){
               if(currentProj.Field_Inspector_3__c == null){
                    rfi_3= true;
                }else{
                     rfi_3 = false;
                }
            } else{
                rfi_3 = idMap.get(currentProj.Field_Inspector_3__c);
            }

            
            
            if(rater && rfi_1 && rfi_2 && rfi_3){
                boolean uploadNow = true;
                Date holdDate = Date.newInstance(2020,6,30);
                if (!Test.isRunningTest()) {
                    uploadNow =  holdDate < Date.today();
                }
                if(uploadNow){
                    system.debug('ekotropeUpload.execute.putToBuildingRegistry Start');
                    system.debug(Limits.getCpuTime());
                    if(Test.isRunningTest()) {
                        Test.setMock(HttpCalloutMock.class, new ekotropePutCalloutMock());
                        System.Debug('Setting test mock YourHttpPutCalloutMockImpl');
                    }
                    HttpResponse uploadResponse = ekotropeSync.putToBuildingRegistry(authorization, currentProj.Ekotrope_ID__c);
                    system.debug(uploadResponse);
                    system.debug(uploadResponse.getStatusCode());
                    system.debug(uploadResponse.getBody());
                    if(uploadResponse.getStatusCode() == 200){
                    String plan = String.valueOf(uploadResponse.getBody());
                    uploadResponseJSON2Apex upload = uploadResponseJSON2Apex.parse(plan);
                    system.debug('SERH_uploadToBuildingRegistry.execute.SERH.putToBuildingRegistry Finish');
                    system.debug(Limits.getCpuTime());
                    system.debug(upload);
                    if(upload.registryId != null){
                        currentProj.RESNET_Registry_ID__c = upload.registryId;
                        currentProj.RESNET_Registration_Date__c = uploadDate;
                        currentProj.QA_Status__c = 'Registered';
                        projects.add(currentProj);
                    } 
                    else{
                        //If actual error, make inspection record.         
                        // Write rawRegistryResponse and errorMessage to notes field of autoQaRecord
                        // automaticQaStatus = Fail, Warn, NotChecked, Pass
                        system.debug('here');
                        system.debug(uploadResponse.getStatusCode());
                        /*
                        List<recordtype> recordTypeList = [select name, id from recordtype where name= 'Auto QA' and sobjecttype = 'Inspection__c'];
                        id recordId = recordTypeList.get(0).id;
                        */
                        string year;
                        year = String.valueOf(datetime.now().year());
                        boolean estar = false;
                        
                        if(currentProj.Energy_Star_Pass__c == True){
                            estar = true;
                        }
                        File_QA__c inspectionRecord = new File_QA__c(
                            Project__c = currentProj.Building_Specification__r.Project__c,
                            Project_Temporary_Name__c = currentProj.Name, 
                            QA_Year__c = year,
                            Status__c = 'Needs Review',
                            Energy_STAR__c = estar
                        );
                        
                        
                        inspectionRecord.Building_Registry_QA_Error__c = TRUE;
                        inspectionRecord.Inspection_Notes__c = upload.rawRegistryResponse;
                        
                        if(upload.automaticQaStatus == 'Fail' || upload.automaticQaStatus == 'NotChecked'){//or upload.automaticQaStatus == 'Warn'
                            inspectionRecord.Ekotrope_QA_Error__c = TRUE;
                            //need to add errorMessage to uploadResponseJSON2Apex so 
                            //we can write those notes to the inspection record
                        }
                        currentProj.QA_Status__c = 'On Hold';
                        //update currentProj;
                        insert inspectionRecord; 
                    }
                } else if(uploadResponse.getStatusCode() == 418){
                    //currentProj.QA_Status__c = 'Complete';
                    Log__c errorLog = ekotropeSync.constructErrorLog('uploadResponse','uploadResponse', uploadResponse, currentProj.Ekotrope_ID__c, '');
                    errorLogs.add(errorLog);
                } else{
                    string errorMessage = String.Valueof(currentProj.Ekotrope_ID__c);
                    system.debug('project status code not 418 and not 200');
                    Log__c errorLog = ekotropeSync.constructErrorLog('uploadResponse','uploadResponse', uploadResponse, currentProj.Ekotrope_ID__c, '');
                    errorLogs.add(errorLog);
                    System.debug(errorMessage);
                    System.debug(uploadResponse.getStatusCode());                
                }
                }
            } else{
                //not approved for autoProcess
                //place the project on hold
                currentProj.QA_Status__c = 'On Hold';
                projects.add(currentProj);
            }
            
        system.debug('SERH_uploadToBuildingRegistry.execute Finish');
        system.debug(Limits.getCpuTime());
        system.debug(projects);
        update projects;
        insert errorLogs;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        system.debug(projectsToUpdate);
    }
    

}