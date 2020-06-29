global class batchMatching implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    //List<matchWrapper> units {get;set;}
    global List<Unit_Takeoff__c> unitTakeoffs = new list<Unit_Takeoff__c>();
    
    //private String state = '';
    //public String lastRefresh {get; set;}
    //public map<id, id> ContoUser {get; set;}
    //public map<string, string> levenMap {get; set;}
    global String syncStatus = '';
    
    global void setSyncStatus(string status){
        syncStatus = status;  
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        //create the list of all projects in sf to iterate over
        //in execute; iterate over subsets of this project list and then 
        //loop over the unit takeoffs that are new
        //
        
     	unitTakeoffs = [Select id, Levenshtein_String__c, Project_Option_1_Score__c, Project_Option_2_Score__c, Project_Option_3_Score__c, 
                        Project_Option_4_Score__c, Project_Option_1__c, Project_Option_2__c, Project_Option_3__c, Project_Option_4__c, 
                        Street__c, City__c, Zip_Code__c, Ekotrope_ID__c, RESNET_Registry_ID__c, State__c, Name, HERS_Rater__c, 
                        Building_Specification__c, Ekotrope_selfOrPlanLastSavedAt__c from Unit_Takeoff__c 
                        where Sync_Status__c= :syncStatus and Residence_Type__c = 'singlefamily' and Levenshtein_String__c != ''
                        limit 10];
        
        return Database.getQueryLocator([
            select id, Street_Address__c, Levenshtein_String__c, City__c, Zip_Code__c, Project_Record_Type__c, 
            Project_Type_del__c, name, recordTypeId, State__c 
            from Project__c 
            where Project_Type_del__c = 'Single Family' and id Not IN (SELECT Project__c FROM Building_Specifications__c)
        and Levenshtein_String__c != '']);     
    }
   
    global void execute(Database.BatchableContext bc, List<Project__c> projectsToCheck){
        map<string, map<string,list<string>>> matchMap = new map<string,map<string,list<string>>>();
		
        for(Unit_Takeoff__c unit : unitTakeoffs){
            Map<string, list<string>> subMap = new map<string, list<string>>();
        	string id = unit.id;
             
            string leven1, leven2, leven3, leven4;
            string leven1project, leven2project, leven3project, leven4project;
            
            leven1 = unit.Project_Option_1_Score__c;
            leven2 = unit.Project_Option_2_Score__c;
            leven3 = unit.Project_Option_3_Score__c;
            leven4 = unit.Project_Option_4_Score__c;
            leven1project = unit.Project_Option_1__c;
            leven2project = unit.Project_Option_2__c;
            leven3project = unit.Project_Option_3__c;
            leven4project = unit.Project_Option_4__c;
            
            if(leven1==null){
                leven1project = 'x';
                leven1='9.0';
            }
            if(leven2==null){
                leven2project = 'v';
                leven2='9.0';
            }
            if(leven3==null){
                leven3project = 's';
                leven3='9.0';
            }
            if(leven4==null){
                leven4project = 'a';
                leven4='9.0';
            }
            
            list<string> subList1 = new list<string>();
            subList1.add(leven1project);
            subList1.add(leven1);
            list<string> subList2 = new list<string>();
            subList2.add(leven2project);
            subList2.add(leven2);
            //system.debug(leven3project);
            ///system.debug(leven3);
            list<string> subList3 = new list<string>();
            subList3.add(leven3project);
            subList3.add(leven3);
            
            list<string> subList4 = new list<string>();
            subList4.add(leven4project);
            subList4.add(leven4);
            subMap.put('match1', subList1);
            subMap.put('match2', subList2);
            subMap.put('match3', subList3);
            subMap.put('match4', subList4);
        	matchMap.put(id, subMap);
        }

		system.debug(matchMap); 
        
        
        for(Project__c existingProjects:projectsToCheck){
            string levenString = existingProjects.Levenshtein_String__c;   
            for(Unit_Takeoff__c newProject : unitTakeoffs){
                string levenValueNewProject = newProject.Levenshtein_String__c;
                
                Integer similarity = levenValueNewProject.getLevenshteinDistance(levenString);
                double ratio1 = ((double) similarity) / (Math.max(levenValueNewProject.length(), levenString.length()));
                map<string, list<string>> valueMap = new map<string, list<string>>();
                
                if(ratio1 < 0.8){            
                    list<string> tempList = new list<string>();
                    tempList.add(string.valueOf(existingProjects.id));
                    tempList.add(string.valueOf(ratio1));
                    tempList.add(existingProjects.Street_Address__c);
                    tempList.add(levenString);
                    tempList.add(existingProjects.name);
                    
                    //find if ratio1 is smaller than any value in the list for the id
                    // if it is replace the value and move the others up. 
                    //do so unitl you get to value 1
                    //system.debug(ratio1);
                    
                    //system.debug(matchMap.get(newProject.id));
                    try{
                        if(ratio1 < decimal.valueOf(matchMap.get(newProject.id).get('match4').get(1)) & ratio1 > decimal.valueOf(matchMap.get(newProject.id).get('match3').get(1))){
                            //place in match4 position
                            //disregard the value
                            list<string> new4 = new list<string>();
                            new4.add(existingProjects.id);
                            new4.add(string.valueOf(ratio1));
                            matchMap.get(newProject.id).remove('match4');
                            matchMap.get(newProject.id).put('match4', new4);
                        }
                        
                        if(ratio1 < decimal.valueOf(matchMap.get(newProject.id).get('match3').get(1)) & ratio1 > decimal.valueOf(matchMap.get(newProject.id).get('match2').get(1))){
                            list<string> old3 = new list<string>();
                            old3 = matchMap.get(newProject.id).get('match3');
                            matchMap.get(newProject.id).remove('match4');
                            matchMap.get(newProject.id).put('match4', old3);
                            
                            list<string> new3 = new list<string>();
                            new3.add(existingProjects.id);
                            new3.add(string.valueOf(ratio1));
                            
                            matchMap.get(newProject.id).remove('match3');
                            matchMap.get(newProject.id).put('match3',new3);
                        }
                        
                        if(ratio1 < decimal.valueOf(matchMap.get(newProject.id).get('match2').get(1)) & ratio1 > decimal.valueOf(matchMap.get(newProject.id).get('match1').get(1))){
                            list<string> moveList = new list<string>();
                            moveList = matchMap.get(newProject.id).get('match3');
                            matchMap.get(newProject.id).remove('match4');
                            matchMap.get(newProject.id).put('match4', moveList);
                            list<string> moveList2 = new list<string>();
                            moveList2 = matchMap.get(newProject.id).get('match2');
                            matchMap.get(newProject.id).remove('match3');
                            matchMap.get(newProject.id).put('match3', moveList2);
                            list<string> newList = new list<string>();
                            newList.add(existingProjects.id);
                            newList.add(string.valueOf(ratio1));
                            matchMap.get(newProject.id).remove('match2');
                            matchMap.get(newProject.id).put('match2',newList);
                        }
                        
                        if(ratio1 < decimal.valueOf(matchMap.get(newProject.id).get('match1').get(1))){
                            list<string> new4 = new list<string>();
                            new4 = matchMap.get(newProject.id).get('match3');
                            matchMap.get(newProject.id).remove('match4');
                            matchMap.get(newProject.id).put('match4', new4);
                            
                            
                            
                            list<string> new3= new list<string>();
                            new3 = matchMap.get(newProject.id).get('match2');
                            //system.debug(new3);
                            matchMap.get(newProject.id).remove('match3');
                            matchMap.get(newProject.id).put('match3', new3);
                            
                            list<string> new2 = new list<string>();
                            new2 = matchMap.get(newProject.id).get('match1');
                            matchMap.get(newProject.id).remove('match2');
                            matchMap.get(newProject.id).put('match2', new2);
                            
                            list<string> new1 = new list<string>();
                            new1.add(existingProjects.id);
                            new1.add(string.valueOf(ratio1));
                            matchMap.get(newProject.id).remove('match1');
                            matchMap.get(newProject.id).put('match1',new1);
                        }
                    }
                    catch(exception e){
                        system.debug(e);
                        system.debug(matchMap.get(newProject.id));
                    }
                }    
            }  
        } 
        
        list<Unit_Takeoff__c> matchString = new list<Unit_Takeoff__c>();

        for(Unit_Takeoff__c unit : unitTakeoffs){
            //iterate over units
            // look up info in map
            //apply new values to units
            
            string leven1, leven2, leven3, leven4;
            string leven1project, leven2project, leven3project, leven4project;
            leven1 = matchMap.get(unit.id).get('match1').get(1);
            leven2 = matchMap.get(unit.id).get('match2').get(1);
            leven3 = matchMap.get(unit.id).get('match3').get(1);
            leven4 = matchMap.get(unit.id).get('match4').get(1);
            leven1project = matchMap.get(unit.id).get('match1').get(0);
            leven2project = matchMap.get(unit.id).get('match2').get(0);
            leven3project = matchMap.get(unit.id).get('match3').get(0);
            leven4project = matchMap.get(unit.id).get('match4').get(0);

            unit.Project_Option_1_Score__c = leven1;
            unit.Project_Option_2_Score__c = leven2;
            unit.Project_Option_3_Score__c = leven3;
            unit.Project_Option_4_Score__c = leven4;
            unit.Project_Option_1__c = leven1project;
            unit.Project_Option_2__c = leven2project;
            unit.Project_Option_3__c = leven3project;
            unit.Project_Option_4__c = leven4project;   

            matchString.add(unit);
        }        
         //list<Unit_Takeoff__c> matchString = new list<Unit_Takeoff__c>();
		update matchString;
    }
    
    global void finish(Database.BatchableContext bc){
        list<Unit_Takeoff__c> matchString = new list<Unit_Takeoff__c>();
        for(Unit_Takeoff__c unit : unitTakeoffs){
            unit.Sync_Status__c = 'calculated';
            matchString.add(unit);
        }
        update matchString;
        
        
        List<Unit_Takeoff__c> unitTakeoffs = new list<Unit_Takeoff__c>();
        unitTakeoffs = [select Selected_Project_Match__c, Street__c, Ekotrope_ID__c, Sync_Status__c, id, name, Project_Option_1__c, Project_Option_2__c, Project_Option_3__c, Project_Option_4__c
                       from Unit_Takeoff__c 
                       where Sync_Status__c = 'matched'];
        system.debug(unitTakeoffs);
        List<Building_Specifications__c> buildingSpecs = new list<Building_Specifications__c>();
        List<Unit_Takeoff__c> units = new list<Unit_Takeoff__c>();
        
        for(Unit_Takeoff__c unit : unitTakeoffs){
            Building_Specifications__c buildingPlaceholder = new Building_Specifications__c(
            	SF_Ekotrope_ID__c = unit.Ekotrope_ID__c
            );
            unit.Building_Specification__r = buildingPlaceholder;
            
            
            
            Building_Specifications__c matchedBuildingSpec = new Building_Specifications__c(
                Name = unit.Street__c,
                SF_Ekotrope_ID__c = unit.Ekotrope_ID__c
            ); 
            
        	
            
            
            if(unit.Selected_Project_Match__c == 'Match 1'){
                matchedBuildingSpec.Project__c = unit.Project_Option_1__c;
            }
            if(unit.Selected_Project_Match__c == 'Match 2'){
            	matchedBuildingSpec.Project__c = unit.Project_Option_2__c;   
            }
            if(unit.Selected_Project_Match__c == 'Match 3'){
                matchedBuildingSpec.Project__c = unit.Project_Option_3__c;
            }
            if(unit.Selected_Project_Match__c == 'Match 4'){
                matchedBuildingSpec.Project__c = unit.Project_Option_4__c;
            }
            
            unit.Sync_Status__c = 'complete';
            units.add(unit);
            buildingSpecs.add(matchedBuildingSpec);
        }
        

        
		//List<Building_Specifications__c> buildingSpecs2 = new List<Building_Specifications__c>();
		List<Unit_Takeoff__c> createProjects = new list<Unit_Takeoff__c>();
        createProjects = [select Selected_Project_Match__c, Street__c, Ekotrope_ID__c, Sync_Status__c, id, name, Project_Option_1__c, Project_Option_2__c, Project_Option_3__c, Project_Option_4__c
                       from Unit_Takeoff__c 
                       where Sync_Status__c = 'create'];
        
        List<Project__c> createProjectList = new list<Project__c>();
        
        for(Unit_Takeoff__c unit : createProjects){
            Project__c placeholderProject = new Project__c(
            	SF_Ekotrope_ID__c = unit.Ekotrope_ID__c
                );

            Project__c newProject = new Project__c(
                Project_Type_del__c = 'Single Family',
                Name = unit.Street__c,
                SF_Ekotrope_ID__c = unit.Ekotrope_ID__c
            );
            
            Building_Specifications__c matchedBuildingSpec = new Building_Specifications__c(
            	Name = unit.Street__c,
                SF_Ekotrope_ID__c = unit.Ekotrope_ID__C,
                Project__r = placeholderProject
            );    
            
            
            Building_Specifications__c placeholderBuilding = new Building_Specifications__c(
                SF_Ekotrope_ID__c = unit.Ekotrope_ID__C
            );     
                         
            unit.Building_Specification__r = placeholderBuilding;
            unit.Sync_Status__c = 'complete';
            
                        
            createProjectList.add(newProject);
            buildingSpecs.add(matchedBuildingSpec);
            units.add(unit);    
        }
        
        system.debug(units);
        system.debug(buildingSpecs);
        system.debug(buildingSpecs);
        upsert createProjectList SF_Ekotrope_ID__c;
        upsert buildingSpecs SF_Ekotrope_ID__c;
        update units;
    }
}