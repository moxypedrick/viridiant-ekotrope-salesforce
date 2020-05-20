# Ekotrope-Salesforce

This package syncs Ekotrope Home Energy Computer Models with Southface's Salesforce Instance.


SERH - this class holds all of the functionality needed to complete the sync with Ekotrope. In addition, it is a batchable which batches sync functions and completes all API requests, DML, and SOQL queries when resources are available. This batchable does the following:
1. Pulls in new files from Ekotrope. Each new file goes through our random file qa selection process. This process checks all files for basic errors. If it finds an error the file is pushed to an 'error pile.' All other files are randomly selected for File QA based on the HERS Rater's QA need. Each of these files is assigned a project status of Pending Review and an inspection record. The remainder of the files are given project status of In Progress.
2. This class finds all of the projects that have had edits in Ekotrope and no longer match our Salesforce instance of the file. These are updated in our database.
3. Finally, the class gathers all In Progress files and pushes them to the Building Registry. If at any point there is an error with Ekotrope or with RESNET, the file is set in the 'error pile.' This pile then has an inspection record assigned to it which collects the error information and passes it on to SERH.

The JSON2Apex classes are helper classes which parse the JSON response from Ekotrope.

Visual Force and Wrapper Classes is our user interface to interact with the SERH utility.
