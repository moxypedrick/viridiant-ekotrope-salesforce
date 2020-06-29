@isTest 
public class hersQaReportWrapperClassTest {
    
   static testMethod void TestPager(){ 
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
       
       
       
       //bogus account
       Account duckedEsting = new Account(Name = 'Ducked Esting');
       Account viridiant = new Account(Name = 'Viridiant', Ekotrope_Password__c = 'alkj13', Ekotrope_Username__c='2nkjl');
       insert(duckedEsting);
       insert(viridiant);
       
       
       list<Contact> toIns = new list<Contact>();
       Contact estarFileNoRegFile = new Contact(RTIN_RFIN__c = '1213',FirstName = 'Bill', LastName = 'DingEnvelope',  accountid=duckedEsting.id);       
       toIns.add(estarFileNoRegFile);
       //toIns.add(noEstarFileRegFile);
       
       insert(toIns);
       
       
       
       list<File_QA__c> insertInsp = new list<File_QA__c>();
       list<Unit_Takeoff__c> insertUnits = new list<Unit_Takeoff__c>();
      
       //estarFileNoRegFile 
       //one estar file
       //one reg file qa
       //no estar file qa
       
       
       Unit_Takeoff__c estarFile = new Unit_Takeoff__c(Sync_Status__c = 'complete', Building_Specification__c = placeholderBuildingSpec.id, Name = '123 Main', Energy_Star_Pass__c = True,Ekotrope_Id__c = 'b2JRnwW7', Field_Inspector_1__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_2__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_3__c = estarFileNoRegFile.RTIN_RFIN__c, HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c, RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
       Unit_Takeoff__c estarFile2 = new Unit_Takeoff__c(Sync_Status__c = 'complete',Building_Specification__c = placeholderBuildingSpec.id,Name = '123 Main', Energy_Star_Pass__c = False,Ekotrope_Id__c = 'b2JRnwW8', Field_Inspector_1__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_2__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_3__c = estarFileNoRegFile.RTIN_RFIN__c, HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c,RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
       Unit_Takeoff__c estarFile3 = new Unit_Takeoff__c(Sync_Status__c = 'complete',Building_Specification__c = placeholderBuildingSpec.id,Name = '123 Main', Energy_Star_Pass__c = True,Ekotrope_Id__c = 'b2JRnwW9', Field_Inspector_1__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_2__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_3__c = estarFileNoRegFile.RTIN_RFIN__c, HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c,RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
       Unit_Takeoff__c estarFile4 = new Unit_Takeoff__c(Sync_Status__c = 'complete',Building_Specification__c = placeholderBuildingSpec.id,Name = '123 Main', Energy_Star_Pass__c = False,Ekotrope_Id__c = 'b2JRnwW10', Field_Inspector_1__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_2__c = estarFileNoRegFile.RTIN_RFIN__c,Field_Inspector_3__c = estarFileNoRegFile.RTIN_RFIN__c, HERS_Rater__c = estarFileNoRegFile.RTIN_RFIN__c,RESNET_Registration_Date__c = date.newInstance(2020, 4, 3));
       
       //noEstarFileRegFile 
       //one reg file
       //no reg file qa
       //no estar file qa

       insertUnits.add(estarFile);
       insertUnits.add(estarFile2);
       insertUnits.add(estarFile3);
       insertUnits.add(estarFile4);
       
       
       insert insertUnits;
       
       
       
       insertInsp.add(new File_QA__c(Project__c = placeholderProjectId, Rater_Name__r = estarFileNoRegFile, QA_Year__c = '2020'));    
       insertInsp.add(new File_QA__c(Project__c = placeholderProjectId, Energy_Star__c = True, Rater_Name__r = estarFileNoRegFile, QA_Year__c = '2020'));
       
       insert insertInsp;
             
       
       Test.startTest();
           hersQaReportWrapperClass clss3 = new hersQaReportWrapperClass();
           System.Debug(clss3.getContacts().size());
           for (hersQaReportWrapperClass.cContact n : clss3.contactList){
               System.Debug(n.name);
               System.Debug('checking'+ n.name);
               system.debug(n.ESTARfiles);
               system.debug(n.ESTARfield);
               system.debug(n.TotalFiles);
               system.debug(n.TotalFields);
               
               //System.assert(condition)
           }
       
       Test.stopTest();
    }

}