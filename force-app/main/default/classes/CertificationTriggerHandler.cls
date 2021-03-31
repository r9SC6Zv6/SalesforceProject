public with sharing class CertificationTriggerHandler {
    
    public static void grantInstructorAccess(List<Certification__c> triggerNew,
			Map<Id, Certification__c> oldMap, Boolean isInsert, Boolean isUpdate) {

        /**
          *  When a new Certification object is assigned an
          *  instructor, or if an instructor changes on an existing
          *  object, give the new instructor access to the record by
          *  creating a share object, and remove access for the
          *  previous instructor (if it is an update of that field)
          */

        System.debug('Starting the Grant Instructor Access logic');

        // List of share records to insert in bulk
        List<Certification__Share> sharesToCreate = new List<Certification__Share>();

        // List of share records to delete in bulk
        List<Certification__Share> sharesToDelete = new List<Certification__Share>();

        // Map of the Certification ID to the Instructor User ID
        Map<Id, Id> certificationToInstructorMap = new Map<Id, Id>();

        // Loop through all the records in the trigger
        for ( Certification__c certification : triggerNew ) {

            // Check to see if this is an insert or the Instructor has changed
            if (isInsert || certification.Instructor__c != oldMap.get(certification.Id).Instructor__c) {
                // Create new Share record for the Instructor and add to list
                if (certification.Instructor__c != null) {
                    Certification__Share certificationShare = new Certification__Share(
                        ParentId = certification.Id,
                        userOrGroupId = certification.Instructor__c,
                        rowCause = 'Manual',
                        AccessLevel = 'Read'
                    );
                    sharesToCreate.add(certificationShare);
                }
            }

            if (isUpdate) {
                // See the Instructor has changed
                if ( certification.Instructor__c != oldMap.get(certification.Id).Instructor__c ) {
                    // Add to map of Instructor changes
                    System.debug('certification.Instructor__c is: ' + certification.Instructor__c);
                    certificationToInstructorMap.put(certification.Id, certification.Instructor__c);
                }
            }
        }

        if ( certificationToInstructorMap.size() > 0 ) {

            System.debug('certificationToInstructorMap is: ' + certificationToInstructorMap);

            for (List<Certification__Share> certificationShares :
						[SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel
						   FROM Certification__Share
						  WHERE ParentId IN :certificationToInstructorMap.keySet()
							AND RowCause = 'Manual']){
                for (Certification__Share certificationShare : certificationShares) {
                    if (certificationToInstructorMap.get(certificationShare.ParentId) != certificationShare.UserOrGroupId){
                        sharesToDelete.add(certificationShare);
                    }
                }
            }

        }

        try {
            if ( sharesToCreate.size() > 0 ) {
                insert sharesToCreate;
            }
            if ( sharesToDelete.size() > 0) {
                delete sharesToDelete;
            }
        } catch (System.DmlException ex) {
            Error_Log__c err = new Error_Log__c(Source__c = 'grantInstructorAccess', message__c = ex.getMessage());
            insert err;
        }
    }
}
