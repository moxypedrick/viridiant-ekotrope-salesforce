public class projectMatching {
    /*
     * Pull in all unit_takeoff_c's that have status new
     * Iterate through all projects
     * suggest matches
     * switch unit_takeoff_c's build spec id to the match
     * 
*/
    List<matchWrapper> units {get;set;}
    List<Unit_Takeoff__c> unitTakeoffs {get;set;}
    
    private String state = '';
    public String lastRefresh {get; set;}
    public map<id, id> ContoUser {get; set;}
    public map<string, string> levenMap {get; set;}
    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select id, Levenshtein_String__c, Project_Option_1_Score__c, Project_Option_2_Score__c, Project_Option_3_Score__c, 
         Project_Option_4_Score__c, Project_Option_1__c, Project_Option_2__c, Project_Option_3__c, Project_Option_4__c, 
         Street__c, City__c, Zip_Code__c, Ekotrope_ID__c, RESNET_Registry_ID__c, State__c, Name, HERS_Rater__c, 
         Building_Specification__c from Unit_Takeoff__c where Sync_Status__c= 'calculated' and Residence_Type__c = 'singlefamily' limit 10]));
                // sets the number of records in each page set
                con.setPageSize(10);    
            }
            return con;
        }
        set;
    }

    // returns a list of wrapper objects for the sObjects in the current page set
    public List<matchWrapper> getUnitTakeoffs() {
        units = new List<matchWrapper>();
        map<string, matchWrapper> unitMap = new map<string, matchWrapper>();
        Map<string, matchWrapper> addProjects = new map<string, matchWrapper>();
        map<string, list<list<string>>> matchString = new map<string, list<list<string>>>();
        map<string, map<string,list<string>>> matchString2 = new map<string,map<string,list<string>>>();
        
        for (Unit_Takeoff__c unit : (List<Unit_Takeoff__c>)con.getRecords()){
            matchWrapper tempUnit = new matchWrapper(unit);
            Project__c project1 = [Select id, Street_Address__c from Project__c where id = :unit.Project_Option_1__c];
            Project__c project2 = [Select id, Street_Address__c from Project__c where id = :unit.Project_Option_2__c];
            Project__c project3 = [Select id, Street_Address__c from Project__c where id = :unit.Project_Option_3__c];
            Project__c project4 = [Select id, Street_Address__c from Project__c where id = :unit.Project_Option_4__c];
            tempUnit.match1Project = project1.Street_Address__c;
            tempUnit.match2Project = project2.Street_Address__c;
            tempUnit.match3Project = project3.Street_Address__c;
            tempUnit.match4Project = project4.Street_Address__c;
            units.add(tempUnit);
        }
        return units;
    }
    
    public class matchWrapper{
        public double match1{get; set;}
        public double match2{get; set;}
        public double match3{get; set;}
        public double match4{get; set;}
        public string levenValue{get;set;}
        public string match1Project{get; set;}
        public string match2Project{get; set;}
        public string match3Project{get; set;}
        public string match4Project{get; set;} 
        public string match1ProjectId{get; set;}
        public string match2ProjectId{get; set;}
        public string match3ProjectId{get; set;}
        public string match4ProjectId{get; set;} 
        public Unit_Takeoff__c matchee{get; set;}
        public String project {get; set;}
        public string rater {get; set;}
        public string street {get; set;}
        public string city {get; set;}
        public string state {get; set;}
        public string zipCode {get;set;}
        public string buildingSpec {get;set;}
        public Boolean checked1{ get; set; }
        public Boolean checked2{ get; set; }
        public Boolean checked3{ get; set; }
        public Boolean checked4{ get; set; }
        public Boolean checked5{get; set; }
        public string ekotropeId{ get; set; }
        public string projId {get; set;}
        
        
        public matchWrapper(Unit_Takeoff__c ut){
            matchee = ut;
            projId = ut.id;
            project = ut.Name;
            rater = ut.HERS_Rater__c;
            street = ut.street__c;
            city = ut.City__c;
            checked1 = false;
            checked2 = false;
            checked3 = false;
            checked4 = false;
            checked5 = false;
            ekotropeId = ut.Ekotrope_ID__c;
            match1 = decimal.valueOf(ut.project_Option_1_Score__c);
            match2 = decimal.valueOf(ut.project_Option_2_Score__c);
            match3 = decimal.valueOf(ut.project_Option_3_Score__c);
            match4 = decimal.valueOf(ut.project_Option_4_Score__c);
            match1ProjectId = ut.project_Option_1__c;
            match2ProjectId = ut.project_Option_2__c;
            match3ProjectId =ut.project_Option_3__c;
            match4ProjectId = ut.project_Option_4__c;
        }
    }
  	  
    public PageReference assign() {

         if (units.size() > 0){
             List<Unit_Takeoff__c> updateList = new List<Unit_Takeoff__c>();

             for (matchWrapper p : units) {
                 //.debug(p);
                 if(p.checked1 | p.checked2 | p.checked3 | p.checked4 | p.checked5){
                     if(p.checked1){
                         p.matchee.Selected_Project_Match__c = 'Match 1';
                         p.matchee.Sync_Status__c= 'matched';
                         updateList.add(p.matchee);
                 	}
                     if(p.checked2){
                         p.matchee.Selected_Project_Match__c = 'Match 2';
                         p.matchee.Sync_Status__c= 'matched';
                         updateList.add(p.matchee);
                     }
                     if(p.checked3){
                         p.matchee.Selected_Project_Match__c = 'Match 3';
                         p.matchee.Sync_Status__c= 'matched';
                         updateList.add(p.matchee);
                     }
                     if(p.checked4){
                         p.matchee.Selected_Project_Match__c = 'Match 4';
                         p.matchee.Sync_Status__c= 'matched';
                         updateList.add(p.matchee);
                     }
                     if(p.checked5){
                        p.matchee.Sync_Status__c= 'create';
                        updateList.add(p.matchee);
                    }  
                 }
             }
             update updateList;
         } 
        return null;
    }
         
    public PageReference refresh(){
        //system.debug(units.size());
        batchMatching matchProjects = new batchMatching(); 
        matchProjects.setSyncStatus('calculated');
        Id newProjectBatchId = Database.executeBatch(matchProjects,300);
		
        batchMatching matchNewProjects = new batchMatching(); 
        matchNewProjects.setSyncStatus('new');
        Id newProjectBatchIdNew = Database.executeBatch(matchNewProjects,300);
        
        return null;
    }
    
 
}