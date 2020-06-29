@IsTest
public class ecmfSyncTest {
    
    @testSetup static void insertProjectsECMFTest(){
         Account viridiant = new Account(Name = 'Viridiant', Ekotrope_Password__c = 'alkj13', Ekotrope_Username__c='2nkjl');
        insert(viridiant);
        
        
        //list<Contact> newContacts = new list<Contact>();
        //Contact estarFileNoRegFile = new Contact(RTIN_RFIN__c = '1213',FirstName = 'Bill', LastName = 'DingEnvelope',  accountid=viridiant.id);
        Contact noEstarFileRegFile = new Contact(RTIN_RFIN__c = '1212', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        insert noEstarFileRegFile;
        /*Contact rfi1 = new Contact(RTIN_RFIN__c = 'rfi1', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        Contact rfi2 = new Contact(RTIN_RFIN__c = 'rfi2', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        Contact rfi3 = new Contact(RTIN_RFIN__c = 'rfi3', FirstName = 'Sir', LastName = 'H',  accountid=viridiant.id);
        
        newContacts.add(estarFileNoRegFile);
        newContacts.add(noEstarFileRegFile);
        newContacts.add(rfi1);
        newContacts.add(rfi2);
        newContacts.add(rfi3);
        insert(newContacts);
        
        */
        
        Project__c ecProject = new Project__c();
        ecProject.Resnet_Registry_ID__c = 'placeHolderProjectForAuto';
        ecProject.Name = 'Placeholder Project for Ekotrope Integration';
        ecProject.Status_Multifamily__c = 'Pre-Review';
        ecProject.RecordTypeId = '012o0000000StpfAAC';
        //ecProject.Selected_Project_Match__c = 'match1';
        /*
        Project__c nonEcProject = new Project__c();
        nonEcProject.Resnet_Registry_ID__c = 'nonEC';
        nonEcProject.Name = 'Placeholder Project for Ekotrope Integration';
        nonEcProject.Status_Multifamily__c = 'Pre-Review';
        nonEcProject.RecordTypeId = '012o0000000StpfAAC';
        //nonEcProject.Selected_Project_Match__c = '';*/
        
        insert ecProject;
        //insert nonEcProject;
        
        Building_Specifications__c ecBuilding = new Building_Specifications__c();
        string ecBuildingID = ecProject.id;
        ecBuilding.Name = 'Placeholder Project for Ekotrope Integration';
        ecBuilding.Project__c = ecBuildingID;
        insert ecBuilding;
        /*
        Building_Specifications__c nonEcBuilding = new Building_Specifications__c();
        string nonEcBuildingID = nonEcProject.id;
        nonEcBuilding.Name = 'Placeholder Project for Ekotrope Integration';
        nonEcBuilding.Project__c = nonEcBuildingID;
        insert nonEcBuilding;
        */
        
        //list<inspection__c> insertInsp = new list<Inspection__c>();
        list<Unit_Takeoff__c> insertProjects = new list<Unit_Takeoff__c>();
        list<string> projectList = new list<string>();
       
        
        Unit_Takeoff__c estarFile = new Unit_Takeoff__c(Ekotrope_selfOrPlanLastSavedAt__c = null, Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = ecBuilding.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Model_Id__c = 'b2JRnwW7', HERS_Rater__c = noEstarFileRegFile.id, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        //Unit_Takeoff__c estarFileA = new Unit_Takeoff__c(Ekotrope_selfOrPlanLastSavedAt__c = null, Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = ecBuilding.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Model_Id__c = 'b2JRnwW8',HERS_Rater__c = noEstarFileRegFile.id, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        //Unit_Takeoff__c estarFileB = new Unit_Takeoff__c(Ekotrope_selfOrPlanLastSavedAt__c = null, Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', QA_Status__c = 'Un-determined', Building_Specification__c = ecBuilding.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Id__c = 'b2JRnwW9',HERS_Rater__c = noEstarFileRegFile.id, Selected_Project_Match__c = '');
        
        
        Unit_Takeoff__c estarFileC = new Unit_Takeoff__c(Ekotrope_selfOrPlanLastSavedAt__c = 'asdfads', Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = ecBuilding.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Model_Id__c = 'break1', HERS_Rater__c = noEstarFileRegFile.id, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        //Unit_Takeoff__c estarFileD = new Unit_Takeoff__c(Ekotrope_selfOrPlanLastSavedAt__c = 'asdfads',Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', Building_Specification__c = ecBuilding.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Model_ID__c = 'b2JRnwW2',HERS_Rater__c = estarFileNoRegFile.id, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
        //Unit_Takeoff__c estarFileE = new Unit_Takeoff__c(Ekotrope_selfOrPlanLastSavedAt__c = 'asdfads',Residence_Type__c = 'singlefamily', Sync_Status__c = 'complete', QA_Status__c = 'Un-determined', Building_Specification__c = ecBuilding.id, Name = '123 Main', Energy_Star_Pass__c = True, Ekotrope_Model_Id__c = 'b2JRnwW3',HERS_Rater__c = estarFileNoRegFile.id, Selected_Project_Match__c = 'Match 1');
        
        insertProjects.add(estarFile);
        //insertProjects.add(estarFileA);
        //insertProjects.add(estarFileB);
        insertProjects.add(estarFileC);
        //insertProjects.add(estarFileD);
        //insertProjects.add(estarFileE);
        
        
        insert insertProjects;
        for(Unit_Takeoff__c existingMfProject : [Select Ekotrope_Model_ID__c, Ekotrope_selfOrPlanLastSavedAt__c, ID, Name   
                FROM Unit_Takeoff__c
                where Ekotrope_Model_ID__c != null and Ekotrope_selfOrPlanLastSavedAt__c = null])
                {
                    
                    system.debug(existingMfProject.id);
                }
      
          for(Unit_Takeoff__c existingMfProject : [
                Select Ekotrope_Model_ID__c, Ekotrope_selfOrPlanLastSavedAt__c, ID, Name   
                FROM Unit_Takeoff__c
                where Ekotrope_Model_ID__c != null and Ekotrope_selfOrPlanLastSavedAt__c != null])
                {
                    //List<String> updateStatusList = new List<String>();
                     system.debug(existingMfProject.id);
                   
                }

        
        
        
        
    }
    
     static testMethod void ecmfTest(){

       
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
            ecmfSync updater = new ecmfSync();
            updater.setAuthorization();//'basic --'
            updater.setVariables(statusList);
            updater.setCodesToCheck(codes);
         	updater.setEnergyDataName('hers');
            updater.setBuildingRun(buildingTypes);    
            
            Id batchId = Database.executeBatch(updater,10);

        Test.stopTest();
        
    }
         
    
    
}