@isTest
private class ekotropeUploadTest {
    
    @testSetup static void insertProjectsTest3(){
         Account duckedEsting = new Account(Name = 'Ducked Esting');
        Account southface = new Account(Name = 'Viridiant', Ekotrope_Password__c = 'alkj13', Ekotrope_Username__c='2nkjl');
        insert(duckedEsting);
        insert(southface);
        
        
        list<Contact> toIns = new list<Contact>();
        Contact estarFileNoRegFile = new Contact(RTIN_RFIN__c = '1213',Auto_Process_On__c=true,FirstName = 'Bill', LastName = 'DingEnvelope',  accountid=duckedEsting.id);
        Contact noEstarFileRegFile = new Contact(RTIN_RFIN__c = '1212', Auto_Process_On__c=true,FirstName = 'Sir', LastName = 'H',  accountid=duckedEsting.id);
        
        toIns.add(estarFileNoRegFile);
        toIns.add(noEstarFileRegFile);
        
        insert(toIns);
        
         Building_Specifications__c placeholderBuildingSpec = new Building_Specifications__c();
        Project__c placeHolderProject = new Project__c();
                        
        
            //placeHolderProject = new Project__c();
        placeHolderProject.Resnet_Registry_ID__c = 'placeHolderProjectForAuto';
        placeHolderProject.Name = 'Placeholder Project for Ekotrope Integration';
        placeHolderProject.Status_Multifamily__c = 'Pre-Review';
        placeHolderProject.RecordTypeId = '012o0000000StpfAAC';
        insert placeHolderProject;
        
        string placeholderProjectId = placeHolderProject.id;
        placeholderBuildingSpec.Name = 'Placeholder Project for Ekotrope Integration';
        placeholderBuildingSpec.Project__c = placeholderProjectId;
        insert placeholderBuildingSpec;
             
       
        Unit_Takeoff__c estarFile = new Unit_Takeoff__c(
            Building_Specification__c = placeholderBuildingSpec.id, 
            Name = '123 Main', Energy_Star_Pass__c = True,
            Ekotrope_Id__c = 'eightdig', 
            HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c, 
            QA_Status__c = 'Complete'
        );
        
        Unit_Takeoff__c estarFile2 = new Unit_Takeoff__c(
            Building_Specification__c = placeholderBuildingSpec.id, 
            Name = '123 Main', Energy_Star_Pass__c = True,
            Ekotrope_Id__c = 'enull_id', 
            HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c, 
            QA_Status__c = 'Not-Selected'
        );
                
        insert (estarFile);
        insert (estarFile2);
        
    }
    
    static testMethod void batchableTest(){
               
        
        Test.startTest();
        	//initialize the updater and give it some batches.
            ekotropeUpload updater = new ekotropeUpload();
        	updater.setAuthorization('authorization token');	
        	Id batchId = Database.executeBatch(updater,3);
            
        Test.stopTest();
        //check the records were updated correctly

        System.debug([select count() from Unit_Takeoff__c where RESNET_Registration_Date__c = today]);
    }	 
}