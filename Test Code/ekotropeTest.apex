@IsTest
public class ekotropeTest {

    @testSetup static void insertProjectsTest3(){
        
        Account viridiant;     
        list<Account> viridiantAccount = [Select Name, ID From Account
                                                                Where Name = 'Viridiant'
                                                               And Ekotrope_Username__c = '2nkjl'
                                            ];
        if(viridiantAccount.size() > 0){
            viridiant = viridiantAccount.get(0);
        } else{
             viridiant = new Account(Name = 'Viridiant', Ekotrope_Password__c = 'alkj13', Ekotrope_Username__c='2nkjl');
             insert viridiant;
        }
        
         
        
        
        Project__c placeHolderProject = new Project__c();
        list<RecordType> recordTypes = [select id, name from RecordType where name like '%Multifamily%'];
        id multiRecordId;
        
                        
        if(recordTypes.size()>0){
            multiRecordId = recordTypes.get(0).id; 
        } 
        
        list<Project__c> placeholderProjects = [Select Name, ID From Project__c
                                                                Where RESNET_Registry_ID__c = 'placeHolderProjectForAuto'
                                                               And recordTypeId = :multiRecordId
                                                               And Status_Multifamily__c = 'Pre-Review'];
                        
        if(placeholderProjects.size()>0){
            placeHolderProject = placeholderProjects.get(0);
            placeHolderProject.Name = 'Placeholder Project for Ekotrope Integration';
            placeHolderProject.Status_Multifamily__c = 'Pre-Review';
            placeHolderProject.RecordTypeId = multiRecordId;
            //update placeHolderProject;
        }else{
            //placeHolderProject = new Project__c();
            placeHolderProject.Resnet_Registry_ID__c = 'placeHolderProjectForAuto';
            placeHolderProject.Name = 'Placeholder Project for Ekotrope Integration';
            placeHolderProject.Status_Multifamily__c = 'Pre-Review';
            placeHolderProject.RecordTypeId = multiRecordId;
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
         
        //Account viridiantPlaceholder = new Account(CnP_PaaS__CnP_Company_ID__c= '1234');     
        list<Contact> newContacts = new list<Contact>();
        Contact estarFileNoRegFile = new Contact(EarthCraft_TA__c = true, RTIN_RFIN__c = '1213',FirstName = 'Bill', LastName = 'DingEnvelope',  accountid=viridiant.id);
        Contact noEstarFileRegFile = new Contact(EarthCraft_TA__c = true, RTIN_RFIN__c = '1212', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        Contact rfi1 = new Contact(EarthCraft_TA__c = true, RTIN_RFIN__c = 'rfi1', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        Contact rfi2 = new Contact(EarthCraft_TA__c = true, RTIN_RFIN__c = 'rfi2', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        Contact rfi3 = new Contact(EarthCraft_TA__c = true, RTIN_RFIN__c = 'rfi3', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        
        newContacts.add(estarFileNoRegFile);
        newContacts.add(noEstarFileRegFile);
        newContacts.add(rfi1);
        newContacts.add(rfi2);
        newContacts.add(rfi3);
        
        list<RecordType> mfRecordTypes = [select id, name from RecordType where name like '%Multifamily%'];
        id multiFamRecordId;
        
                        
        if(mfRecordTypes.size()>0){
            multiFamRecordId = mfRecordTypes.get(0).id; 
        } 

       
        
        list<File_QA__c> insertInsp = new list<File_QA__c>();
        list<Unit_Takeoff__c> insertProjects = new list<Unit_Takeoff__c>();
        list<string> projectList = new list<string>();
       
        
        Unit_Takeoff__c estarFile = new Unit_Takeoff__c(Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = placeholderBuildingSpec.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Id__c = '1p1234k', Ekotrope_selfOrPlanLastSavedAt__c = 'adsf', HERS_Rater__c = noEstarFileRegFile.RTIN_RFIN__c, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        Unit_Takeoff__c estarFileA = new Unit_Takeoff__c(Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = placeholderBuildingSpec.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Id__c = 'b2JRnwW8',HERS_Rater__c = noEstarFileRegFile.RTIN_RFIN__c, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        Unit_Takeoff__c estarFileB = new Unit_Takeoff__c(Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', QA_Status__c = 'Un-determined', Building_Specification__c = placeholderBuildingSpec.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Id__c = 'b2JRnwW9',HERS_Rater__c = noEstarFileRegFile.RTIN_RFIN__c, Selected_Project_Match__c = '');
        
        
        Unit_Takeoff__c estarFileC = new Unit_Takeoff__c(Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = placeholderBuildingSpec.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Id__c = 'b2JRnwW1', HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        Unit_Takeoff__c estarFileD = new Unit_Takeoff__c(Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = placeholderBuildingSpec.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Id__c = 'breaknwW2',HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        Unit_Takeoff__c estarFileE = new Unit_Takeoff__c(Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', QA_Status__c = 'Un-determined', Building_Specification__c = placeholderBuildingSpec.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Id__c = 'break2',HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c, Selected_Project_Match__c = 'Match 1');
        
        insertProjects.add(estarFile);
        insertProjects.add(estarFileA);
        insertProjects.add(estarFileB);
        insertProjects.add(estarFileC);
        insertProjects.add(estarFileD);
        insertProjects.add(estarFileE);
     	insert insertProjects;
        insert(newContacts);
        
    }
   
    static testMethod void TestPager3(){
          
        Test.startTest();
        	list<string> codes = new list<string>();
            codes.add('EnergyStarV3');
            codes.add('IECC2009Performance');
            codes.add('IECC2012Performance');
            codes.add('DOEZeroEnergyReady');
            codes.add('DukeNCHEROPerformance');
             
            list<string> statusList = new list<string>();
            statusList.add('SUBMITTED_FOR_QA');
            //statusList.add('SUBMITTED_TO_REGISTRY');
            
            list<string> statusList2 = new list<string>();
            //statusList2.add('SUBMITTED_FOR_QA');
            statusList2.add('SUBMITTED_TO_REGISTRY');
            list<string> buildingTypes = new list<string>();
            buildingTypes.add('EkotropeAsModeled');
            buildingTypes.add('HERSReference');
            buildingTypes.add('DOEZeroEnergyReadyTarget');
            buildingTypes.add('IECC2015_5ACH50Reference');
            buildingTypes.add('Virginia2015Reference');
            
        
            //initialize the updater and give it some batches.
            ekotropeSync updater = new ekotropeSync();
            updater.setAuthorization();//'basic --'
            updater.setVariables(statusList);
        	updater.setEnergyDataName('hers');
            updater.setCodesToCheck(codes);
            updater.setBuildingRun(buildingTypes);    
            
            Id batchId = Database.executeBatch(updater,10);

        Test.stopTest();
        
    }
  
}