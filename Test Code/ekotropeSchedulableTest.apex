@isTest
private class ekotropeSchedulableTest {
 	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    static testmethod void testserhSchedulableTest(){
       /*
        Select name, id, zip_code__c, state__c, 
                                          city__c, street_address__c   
                                            	FROM Project__c where Levenshtein_String__c = null*/
        Project__c placeHolderProject = new Project__c();
                        
       
    
        placeHolderProject.Name = 'Placeholder Project for Ekotrope Integration';
        placeHolderProject.Status_Multifamily__c = 'Pre-Review';
        placeHolderProject.Levenshtein_String__c = null;
        insert placeHolderProject;
        

        Account testacct = new Account(name='viridiant', Ekotrope_ID__c='PKYGl435', Ekotrope_Password__c='asfasdf', Ekotrope_Username__c='asdfsad');
        insert(testacct);
        
        /**
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        serhSchedulable.SchedulerMethod('Sample_Heading', CRON_EXP, new serhSchedulable () );   
        Test.stopTest();
**/
        Test.StartTest();
        ekotropeSchedulable sh1 = new ekotropeSchedulable();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', CRON_EXP, sh1);
        Test.stopTest(); }	    
}