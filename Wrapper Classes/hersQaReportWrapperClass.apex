public class hersQaReportWrapperClass {

    public List<cContact> contactList{get; set;}

    public Integer year{get;set;}

    public List<cContact> getContacts(){
        map<String, cContact> mapNametoWrapper = new map<String, cContact>();
        contactList = null;
        
        
        Map<String, String> raterMap = new Map<String, String>();
    
        for(Contact existingContact : [
                Select RTIN_RFIN__c, name, id
                FROM contact
                WHERE RTIN_RFIN__c != null ])
            {raterMap.put(existingContact.RTIN_RFIN__c, existingContact.name);}
                
        
        
        //year = System.Today().year();
        system.debug(year);
        if(year == null){
            year = System.Today().year();
        } else {
            year = year;
        }

        Date Start_Date = Date.newInstance(year, 1, 1);
        Date End_Date = Date.newInstance(year, 12, 31);
        String yearStr = string.valueof(year);
        system.debug(yearStr);

        if(contactList == null){

            contactList = new List<cContact>();

            for(AggregateResult pRegFile: [select HERS_Rater__c,count(id)
                                                from Unit_Takeoff__c 
                                                where
                                           (Sync_Status__c != '' and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null)
                                                group by HERS_Rater__c]){
                                               String RaterName = raterMap.get(string.valueof(pRegFile.get('HERS_Rater__c')));
                                               // String RaterName = string.valueof(pRegFile.get('HERS_Rater__c'));
    
                                               if(mapNametoWrapper.get(RaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.TotalFiles = Double.valueOf(pRegFile.get('expr0'));
                                                   Contact.Name = RaterName;
                                                   mapNametoWrapper.put(RaterName, Contact);
                                               } else{
                                                   mapNametoWrapper.get(RaterName).TotalFiles = Double.valueOf(pRegFile.get('expr0'));
                                                  }
                                           }
            for(AggregateResult pRegField: [select Field_Inspector_1__c, count(id)
                                           from Unit_Takeoff__c 
                                            where (Sync_Status__c != ''  and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null)
                                            group by Field_Inspector_1__c]){
                                               //String FieldRaterName = string.valueof(pRegField.get('Field_Inspector_1__c'));
                                               String FieldRaterName = raterMap.get(string.valueof(pRegField.get('Field_Inspector_1__c')));
                                               if(mapNametoWrapper.get(FieldRaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.TotalFields = Double.valueOf(pRegField.get('expr0'));
                                                   Contact.Name = FieldRaterName;
                                                   mapNametoWrapper.put(FieldRaterName, Contact);
                                               } else{
                                                   system.debug(FieldRaterName);
                                                   system.debug(pRegField.get('expr0'));
                                                   system.debug(mapNametoWrapper.get(FieldRaterName));
                                                   double initial;
                                                   if(mapNametoWrapper.get(FieldRaterName).TotalFields==null){
                                                       initial = 0.0;
                                                   } else{initial = mapNametoWrapper.get(FieldRaterName).TotalFields;}
                                                   mapNametoWrapper.get(FieldRaterName).TotalFields =  initial + Double.valueOf(pRegField.get('expr0'));
                                                   }
                                           }
            for(AggregateResult pEstarField: [select Field_Inspector_1__c,count(id)
                                                from Unit_Takeoff__c 
                                                where 
                                              (Sync_Status__c != '' and Energy_Star_Pass__c = True and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Energy_Star_Pass__c = True and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null)
                                              group by Field_Inspector_1__c]){
                                               String FieldRaterName = raterMap.get(string.valueof(pEstarField.get('Field_Inspector_1__c')));
                                               //String FieldRaterName = string.valueof(pEstarField.get('Field_Inspector_1__c'));
                                               if(mapNametoWrapper.get(FieldRaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.ESTARfield = Double.valueOf(pEstarField.get('expr0'));
                                                   Contact.Name = FieldRaterName;
                                                   mapNametoWrapper.put(FieldRaterName, Contact);
                                               } else{
                                                   double initial;
                                                   if(mapNametoWrapper.get(FieldRaterName).ESTARfield==null){
                                                       initial = 0.0;
                                                   } else{initial = mapNametoWrapper.get(FieldRaterName).ESTARfield;}
                                                   mapNametoWrapper.get(FieldRaterName).ESTARfield = initial + Double.valueOf(pEstarField.get('expr0'));
                                                   }
                                               //mapNametoWrapper.get(FieldRaterName).ESTARfield = Double.valueOf(pEstarField.get('expr0'));
                                           }
            
                        for(AggregateResult pRegField: [select Field_Inspector_2__c, count(id)
                                           from Unit_Takeoff__c 
                                            where 
                                                        (Sync_Status__c != '' and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null)
                                                        group by Field_Inspector_2__c]){
                                               //String FieldRaterName = string.valueof(pRegField.get('Field_Inspector_1__c'));
                                               String FieldRaterName = raterMap.get(string.valueof(pRegField.get('Field_Inspector_2__c')));
                                               if(mapNametoWrapper.get(FieldRaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.TotalFields = Double.valueOf(pRegField.get('expr0'));
                                                   Contact.Name = FieldRaterName;
                                                   mapNametoWrapper.put(FieldRaterName, Contact);
                                               } else{
                                                   double initial;
                                                   if(mapNametoWrapper.get(FieldRaterName).TotalFields==null){
                                                       initial = 0.0;
                                                   } else{initial = mapNametoWrapper.get(FieldRaterName).TotalFields;}
                                                   mapNametoWrapper.get(FieldRaterName).TotalFields =  initial + Double.valueOf(pRegField.get('expr0'));
                                                   }
                                           }
            for(AggregateResult pEstarField: [select Field_Inspector_2__c,count(id)
                                                from Unit_Takeoff__c 
                                                where 
                                              (Sync_Status__c != '' and Energy_Star_Pass__c = True and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Energy_Star_Pass__c = True and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null)
                                              group by Field_Inspector_2__c]){
                                               String FieldRaterName = raterMap.get(string.valueof(pEstarField.get('Field_Inspector_2__c')));
                                               //String FieldRaterName = string.valueof(pEstarField.get('Field_Inspector_1__c'));
                                               if(mapNametoWrapper.get(FieldRaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.ESTARfield = Double.valueOf(pEstarField.get('expr0'));
                                                   Contact.Name = FieldRaterName;
                                                   mapNametoWrapper.put(FieldRaterName, Contact);
                                               } else{
                                                    double initial;
                                                   if(mapNametoWrapper.get(FieldRaterName).ESTARfield==null){
                                                       initial = 0.0;
                                                   } else{initial = mapNametoWrapper.get(FieldRaterName).ESTARfield;}
                                                   mapNametoWrapper.get(FieldRaterName).ESTARfield = initial + Double.valueOf(pEstarField.get('expr0'));
                                                   }
                                               //mapNametoWrapper.get(FieldRaterName).ESTARfield = Double.valueOf(pEstarField.get('expr0'));
                                           }
            
                        for(AggregateResult pRegField: [select Field_Inspector_3__c, count(id)
                                           from Unit_Takeoff__c 
                                            where 
                                                        (Sync_Status__c != '' and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null)
                                                        group by Field_Inspector_3__c]){
                                               //String FieldRaterName = string.valueof(pRegField.get('Field_Inspector_1__c'));
                                               String FieldRaterName = raterMap.get(string.valueof(pRegField.get('Field_Inspector_3__c')));
                                               if(mapNametoWrapper.get(FieldRaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.TotalFields = Double.valueOf(pRegField.get('expr0'));
                                                   Contact.Name = FieldRaterName;
                                                   mapNametoWrapper.put(FieldRaterName, Contact);
                                               } else{
                                                    double initial;
                                                   if(mapNametoWrapper.get(FieldRaterName).TotalFields==null){
                                                       initial = 0.0;
                                                   } else{initial = mapNametoWrapper.get(FieldRaterName).TotalFields;}
                                                   mapNametoWrapper.get(FieldRaterName).TotalFields =  initial + Double.valueOf(pRegField.get('expr0'));
                                                   }
                                           }
            for(AggregateResult pEstarField: [select Field_Inspector_3__c,count(id)
                                                from Unit_Takeoff__c 
                                                where 
                                              (Sync_Status__c != '' and Energy_Star_Pass__c = True and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null and Energy_Star_Pass__c = True) 
                                              group by Field_Inspector_3__c]){
                                               String FieldRaterName = raterMap.get(string.valueof(pEstarField.get('Field_Inspector_3__c')));
                                               //String FieldRaterName = string.valueof(pEstarField.get('Field_Inspector_1__c'));
                                               if(mapNametoWrapper.get(FieldRaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.ESTARfield = Double.valueOf(pEstarField.get('expr0'));
                                                   Contact.Name = FieldRaterName;
                                                   mapNametoWrapper.put(FieldRaterName, Contact);
                                               } else{
                                                    double initial;
                                                   if(mapNametoWrapper.get(FieldRaterName).ESTARfield==null){
                                                       initial = 0.0;
                                                   } else{initial = mapNametoWrapper.get(FieldRaterName).ESTARfield;}
                                                   mapNametoWrapper.get(FieldRaterName).ESTARfield = initial + Double.valueOf(pEstarField.get('expr0'));
                                                   }
                                               //mapNametoWrapper.get(FieldRaterName).ESTARfield = Double.valueOf(pEstarField.get('expr0'));
                                           }
            
            for(AggregateResult pEstarFile: [select HERS_Rater__c,count(id)
                                                from Unit_Takeoff__c 
                                                where 
                                             (Sync_Status__c != '' and Ekotrope_ID__c != '' and RESNET_Registration_Date__c >= :Start_Date and RESNET_Registration_Date__c <= :End_Date)
                                           or (RESNET_Registration_Date__c = null and Sync_Status__c != '' and Ekotrope_ID__c != ''
                                              and QA_Status__c != null)
                                             group by HERS_Rater__c]){
                                               //String RaterName = string.valueof(pEstarFile.get('HERS_Rater__c'));
                                               String RaterName = raterMap.get(string.valueof(pEstarFile.get('HERS_Rater__c')));
                                                    if(mapNametoWrapper.get(RaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.ESTARfiles = Double.valueOf(pEstarFile.get('expr0'));
                                                   Contact.Name = RaterName;
                                                   mapNametoWrapper.put(RaterName, Contact);
                                               } else{
                                                   
                                                   mapNametoWrapper.get(RaterName).ESTARfiles = Double.valueOf(pEstarFile.get('expr0'));
                                                   }
                                               //mapNametoWrapper.get(RaterName).ESTARfiles = Double.valueOf(pEstarFile.get('expr0'));
                                             }
            
            /// 
            for(AggregateResult pEstarFileQA: [select Rater_Name__r.RTIN_RFIN__c, count(id)
                                           from File_QA__c
                                           Where QA_Year__c = :yearStr
                                           and Energy_Star__c = TRUE
                                           Group By Rater_Name__r.RTIN_RFIN__c]){
                                               String RaterName = raterMap.get(string.valueof(pEstarFileQA.get('RTIN_RFIN__c')));
                                               //String RaterName = string.valueof(pEstarFileQA.get('RTIN_RFIN__c'));

                                               if(mapNametoWrapper.get(RaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.ESTARfileQaComplete = Double.valueOf(pEstarFileQA.get('expr0'));
                                                   Contact.Name = RaterName;
                                                   mapNametoWrapper.put(RaterName, Contact);
                                               } else{
                                                   mapNametoWrapper.get(RaterName).ESTARfileQaComplete = Double.valueOf(pEstarFileQA.get('expr0'));
                                                  }


                                               //mapNametoWrapper.get(RaterName).ESTARfileQaComplete = Double.valueOf(pEstarFileQA.get('expr0'));
                                           }
                                           
             for(AggregateResult pFileQA: [select Rater_Name__r.RTIN_RFIN__c, count(id)
                                           from File_QA__c
                                           Where QA_Year__c = :yearStr
                                           Group By Rater_Name__r.RTIN_RFIN__c]){
                                               String RaterName = raterMap.get(string.valueof(pFileQA.get('RTIN_RFIN__c')));
                                              // String RaterName = string.valueof(pFileQA.get('RTIN_RFIN__c'));
                                               if(mapNametoWrapper.get(RaterName)==null){
                                                   //make a cContact
                                                   cContact Contact = new cContact();
                                                   Contact.TotalFileQaComplete = Double.valueOf(pFileQA.get('expr0'));
                                                   Contact.Name = RaterName;
                                                   mapNametoWrapper.put(RaterName, Contact);
                                               } else{
                                                   mapNametoWrapper.get(RaterName).TotalFileQaComplete = Double.valueOf(pFileQA.get('expr0'));
                                                   //mapNametoWrapper.get(RaterName).ESTARfileQaNeed = Math.ceil(mapNametoWrapper.get(RaterName).ESTARfield/10);
                                               }
                                           }
            for(String key: mapNametoWrapper.keySet()){
                mapNametoWrapper.get(key).doMath();
                contactList.add(mapNametoWrapper.get(key));
            }
        }
        return contactList;
    }

    public class cContact {
        Public String Name {get; set;}
        Public Double ESTARfiles {get; set;}
        Public Double ESTARfileQaNeed {get; set;}
        Public Double ESTARfileQaComplete {get; set;}
        Public Double ESTARfileQaLeft {get; set;}

        Public Double ESTARfield {get; set;}
        Public Double ESTARfieldQaNeed {get;set;}
        Public Double ESTARfieldQaComplete {get;set;}
        Public Double ESTARfieldQaLeft {get; set;}

        Public Double TotalFiles {get; set;}
        Public Double TotalFileQaNeed {get; set;}
        Public Double TotalFileQaComplete {get; set;}
        Public Double TotalFileQaLeft {get; set;}

        Public Double TotalFields {get; set;}
        Public Double TotalFieldQaNeed {get; set;}
        Public Double TotalFieldQaComplete {get; set;}
        Public Double TotalFieldQaLeft {get; set;}

        Public void doMath(){
            if (ESTARfiles == null){
                ESTARfiles = 0;
            }
            if (ESTARfield == null){
                ESTARfield = 0;
            }
            if (Totalfiles == null){
                Totalfiles = 0;
            }
            if (TotalFields == null){
                TotalFields = 0;
            }

            if (ESTARfileQaNeed == null){
                ESTARfileQaNeed = 0;
            }
            if(ESTARfileQaComplete == null){
                ESTARfileQaComplete = 0;
            }
            if(ESTARfieldQANeed==null){
                ESTARfieldQANeed=0;
            }
            if(ESTARfieldQaComplete==null){
                ESTARfieldQaComplete=0;
            }
            if(TotalFileQaNeed==null){
                TotalFileQaNeed=0;
            }
            if(TotalFileQaComplete==null){
                TotalFileQaComplete=0;
            }
            if(TotalFieldQaNeed==null){
                TotalFieldQaNeed=0;
            }
            if(TotalFieldQaComplete==null){
                TotalFieldQaComplete=0;
            }

            ESTARfileQaNeed = Math.ceil(ESTARfiles/10);
            ESTARfieldQaNeed = Math.ceil(ESTARfield/100);
            TotalFileQaNeed = Math.ceil(TotalFiles/10);
            TotalFieldQaNeed = Math.ceil(TotalFields/100);

            ESTARfileQaLeft = ESTARfileQaNeed - ESTARfileQaComplete;
       		ESTARfieldQaLeft = ESTARfieldQANeed - ESTARfieldQaComplete;

            TotalFileQaLeft = TotalFileQaNeed - TotalFileQaComplete;
            TotalFieldQaLeft = TotalFieldQaNeed - TotalFieldQaComplete;
        }


        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public cContact() {

        }
    }

    public void getResult() {
        system.debug(''+this.year);
    }



}