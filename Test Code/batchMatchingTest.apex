@IsTest
public class batchMatchingTest {
    
    static testMethod void TestPager(){
        Building_Specifications__c placeholderBuildingSpec = new Building_Specifications__c();
        Project__c placeHolderProject = new Project__c();
        
        placeHolderProject.Resnet_Registry_ID__c = 'placeHolderProjectForAuto';
        placeHolderProject.Name = 'Placeholder Project for Ekotrope Integration';
        placeHolderProject.Status_Multifamily__c = 'Pre-Review';
        placeHolderProject.RecordTypeId = '012o0000000StpfAAC';
        insert placeHolderProject;
        
        string placeholderProjectId = placeHolderProject.id;
        placeholderBuildingSpec.Name = 'Placeholder Project for Ekotrope Integration';
        placeholderBuildingSpec.Project__c = placeholderProjectId;
        insert placeholderBuildingSpec;
        
        
        
        //bogus account
        Account duckedEsting = new Account(Name = 'Ducked Esting');
        Account southface = new Account(Name = 'Viridiant', Ekotrope_Password__c = 'alkj13', Ekotrope_Username__c='2nkjl');
        insert(duckedEsting);
        insert(southface);
        
        
        list<Contact> toIns = new list<Contact>();
        Contact estarFileNoRegFile = new Contact(RTIN_RFIN__c = '1213',FirstName = 'Bill', LastName = 'DingEnvelope',  accountid=duckedEsting.id);
        Contact noEstarFileRegFile = new Contact(RTIN_RFIN__c = '1212', FirstName = 'Sir', LastName = 'H',  accountid=duckedEsting.id);
        
        toIns.add(estarFileNoRegFile);
        toIns.add(noEstarFileRegFile);
        
        insert(toIns);
        
        
        
        list<inspection__c> insertInsp = new list<Inspection__c>();
        list<Unit_Takeoff__c> insertProjects = new list<Unit_Takeoff__c>();
        list<string> projectList = new list<string>();
        //Id rtId5 = [SELECT Id from Recordtype where name like '%SERH Project%' limit 1][0].Id;
        
        //estarFileNoRegFile 
        //one estar file
        //one reg file qa
        //no estar file qa
        
        
        Unit_Takeoff__c estarFile = new Unit_Takeoff__c(
            Building_Specification__c = placeholderBuildingSpec.id,
            Name = '123 Main', 
            Energy_Star_Pass__c = True,
            Ekotrope_Id__c = 'b2JRnwW7', 
            HERS_Rater__c = estarFileNoRegFile.id, 
            RESNET_Registration_Date__c = date.newInstance(2018, 4, 3),
        	Sync_Status__c = 'new',
            Residence_Type__c = 'singlefamily', 
            Selected_Project_Match__c = 'Match 1',
            Project_Option_1__c = placeHolderProject.id,
            Levenshtein_String__c = '1jlmkl;kjq'
        );
        Unit_Takeoff__c estarFile2 = new Unit_Takeoff__c(Building_Specification__c = placeholderBuildingSpec.id,Name = '123 Main', Energy_Star_Pass__c = True,Ekotrope_Id__c = 'b2JRnwW8', HERS_Rater__c = estarFileNoRegFile.id,
        	Sync_Status__c = 'new',
            Residence_Type__c = 'singlefamily',
                                                         Selected_Project_Match__c = 'Match 2',
                                                         Project_Option_2__c = placeHolderProject.id,
                                                         
            Levenshtein_String__c = '1jlmkl;kjq');
        Unit_Takeoff__c estarFile3 = new Unit_Takeoff__c(Building_Specification__c = placeholderBuildingSpec.id,Name = '123 Main', Energy_Star_Pass__c = True,Ekotrope_Id__c = 'b2JRnwW9', HERS_Rater__c = estarFileNoRegFile.id,
        	Sync_Status__c = 'new',
            Residence_Type__c = 'singlefamily',
                                                         Selected_Project_Match__c = 'Match 3',
                                                         Project_Option_3__c = placeHolderProject.id,
            Levenshtein_String__c = '1jlmkl;kjq');
         Unit_Takeoff__c estarFile4 = new Unit_Takeoff__c(Building_Specification__c = placeholderBuildingSpec.id,Name = '123 Main', Energy_Star_Pass__c = True,Ekotrope_Id__c = 'b2JRnw19', HERS_Rater__c = estarFileNoRegFile.id,
        	Sync_Status__c = 'matched',
            Residence_Type__c = 'singlefamily', Selected_Project_Match__c = 'Match 4',
                                                          Project_Option_4__c = placeHolderProject.id,
            Levenshtein_String__c = '1jlmkl;kjq');
         
        
        Unit_Takeoff__c estarFile5 = new Unit_Takeoff__c(Building_Specification__c = placeholderBuildingSpec.id,Name = '123 Main', Energy_Star_Pass__c = True,Ekotrope_Id__c = 'b2JRnw29', HERS_Rater__c = estarFileNoRegFile.id,
        	Sync_Status__c = 'create',
            Residence_Type__c = 'singlefamily',
            Levenshtein_String__c = '1jlmkl;kjq');
        
        insertProjects.add(estarFile);
        insertProjects.add(estarFile2);
        insertProjects.add(estarFile3);
        insertProjects.add(estarFile4);
        insertProjects.add(estarFile5);
        
        insert insertProjects;
        
        
        list<Project__c> insertProjectsReally = new list<Project__c>();
        
        Project__c project1 = new Project__c(
            Resnet_Registry_ID__c = 'placeHolderProjectForAuto',
            Name = 'Placeholder Project for Ekotrope Integration',
            Status_Multifamily__c = 'Pre-Review',
            RecordTypeId = '012o0000000StpfAAC',
            Project_Type_del__c = 'Single Family',
            Levenshtein_String__c = '1jlmkl;kjq'
        );
        
        Project__c project2 = new Project__c(
            Resnet_Registry_ID__c = 'placeHolderProjectForAuto',
            Name = 'Placeholder Project for Ekotrope Integration',
            Status_Multifamily__c = 'Pre-Review',
            RecordTypeId = '012o0000000StpfAAC',
            Project_Type_del__c = 'Single Family',
            Levenshtein_String__c = '1oj12jl'
        );
        
        Project__c project3 = new Project__c(
            Resnet_Registry_ID__c = 'placeHolderProjectForAuto',
            Name = 'Placeholder Project for Ekotrope Integration',
            Status_Multifamily__c = 'Pre-Review',
            RecordTypeId = '012o0000000StpfAAC',
            Project_Type_del__c = 'Single Family',
            Levenshtein_String__c = 'asdflk12'
        );
		
        insertProjectsReally.add(project1);
        insertProjectsReally.add(project2);
        insertProjectsReally.add(project3);
        insert insertProjectsReally;
        
        test.startTest();
        	batchMatching matchProjects = new batchMatching();       
            matchProjects.setSyncStatus('new');
            Id newProjectBatchId = Database.executeBatch(matchProjects,300);
        test.stopTest();
        

        
    }
            

}