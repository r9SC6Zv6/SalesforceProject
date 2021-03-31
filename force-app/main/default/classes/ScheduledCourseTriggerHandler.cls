public class ScheduledCourseTriggerHandler {

    public static void grantInstructorAccess(List<Opportunity> triggerNew,
			Map<Id, Opportunity> oldMap, Boolean isInsert, Boolean isUpdate) {

        /**
          *  When a new Scheduled Course object is assigned an
          *  instructor, or if an instructor changes on an existing
          *  object, give the new instructor access to the record by
          *  creating a share object, and remove access for the
          *  previous instructor (if it is an update of that field)
          */

        System.debug('Starting the Grant Instructor Access logic');

        // List of share records to insert in bulk
        List<OpportunityShare> sharesToCreate = new List<OpportunityShare>();

        // List of share records to delete in bulk
        List<OpportunityShare> sharesToDelete = new List<OpportunityShare>();

        // Map of the Opporunity ID to the Instructor User ID
        Map<Id, Id> courseToInstructorMap = new Map<Id, Id>();

        // Loop through all the records in the trigger
        for ( Opportunity scheduledCourse : triggerNew ) {

            // Check to see if this is an insert or the Instructor has changed
            if (isInsert || scheduledCourse.Instructor__c != oldMap.get(scheduledCourse.Id).Instructor__c) {
                // Create new Share record for the Instructor and add to list
                if (scheduledCourse.InstructorId__c != null) {
                    OpportunityShare scheduledCourseShare = new OpportunityShare(
                        opportunityId = scheduledCourse.Id,
                        userOrGroupId = scheduledCourse.InstructorId__c,
                        rowCause = 'Manual',
                        opportunityAccessLevel = 'Edit'
                    );
                    sharesToCreate.add(scheduledCourseShare);
                }
            }

            if (isUpdate) {
                // See the Instructor has changed
                if ( scheduledCourse.Instructor__c != oldMap.get(scheduledCourse.Id).Instructor__c ) {
                    // Add to map of Instructor changes
                    System.debug('scheduledCourse.Instructor__c is: ' + scheduledCourse.Instructor__c);
                    courseToInstructorMap.put(scheduledCourse.Id, scheduledCourse.Instructor__c);
                }
            }
        }

        if ( courseToInstructorMap.size() > 0 ) {

            System.debug('courseToInstructorMap is: ' + courseToInstructorMap);

            for (List<OpportunityShare> scheduledCourseShares :
						[SELECT UserOrGroupId, RowCause, OpportunityId, Id, OpportunityAccessLevel
						   FROM OpportunityShare
						  WHERE OpportunityId IN :courseToInstructorMap.keySet()
							AND RowCause = 'Manual']){
                for (OpportunityShare scheduledCourseShare : scheduledCourseShares) {
                    if (courseToInstructorMap.get(scheduledCourseShare.OpportunityId) != scheduledCourseShare.UserOrGroupId){
                        sharesToDelete.add(scheduledCourseShare);
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

    public static void createCourseEvent(List<Opportunity> triggerNew,
            Map<Id, Opportunity> oldMap, Boolean isInsert, Boolean isUpdate) {
        
        /**
          *  When a new Scheduled Course object is created or if the starting 
          *  or end date or location fields are changed on an existing object, 
          *  a new event record is created and assigned to the Instructor. If the 
          *  object is deleted or relevant fields are updated the old event is deleted.
          */

        System.debug('Starting the Create Course Event logic');

        // List of event records to insert in bulk
        List<Event> eventsToCreate = new List<Event>();

        // Map of relevant updated courses and operation type
        List<Id> coursesUpdated = new List<Id>();

        // List of event records to delete in bulk
        List<Event> eventsToDelete = new List<Event>();

        // Loop through all the records in the trigger
        for ( Opportunity scheduledCourse : triggerNew ) {

            Boolean isRelevantUpdate = isUpdate && (scheduledCourse.Instructor__c != oldMap.get(scheduledCourse.Id).Instructor__c ||
                                                    scheduledCourse.Course__c != oldMap.get(scheduledCourse.Id).Course__c ||
                                                    scheduledCourse.CloseDate != oldMap.get(scheduledCourse.Id).CloseDate ||
                                                    scheduledCourse.Location__c != oldMap.get(scheduledCourse.Id).Location__c);

            Boolean isCancelled = isUpdate && scheduledCourse.StageName != oldMap.get(scheduledCourse.Id).StageName && 
                        scheduledCourse.StageName == 'Cancelled';

            // Check to see if this is an insert or a relevant update
            if (isInsert || isRelevantUpdate) {
                // Create new event and add to list
                if (scheduledCourse.Instructor__c != null && scheduledCourse.CloseDate != null && 
                        scheduledCourse.End_Date__c != null && scheduledCourse.Location__c != null) {
                    Event scheduledCourseEvent = new Event(
                        OwnerId = scheduledCourse.InstructorId__c,
                        WhatId = scheduledCourse.Id,
                        Subject = scheduledCourse.Course_Code__c + ' - ' + scheduledCourse.Course_Title__c,
                        StartDateTime = scheduledCourse.CloseDate,
                        EndDateTime = scheduledCourse.End_Date__c,
                        Location = scheduledCourse.Location__c
                    );
                    eventsToCreate.add(scheduledCourseEvent);
                }
            }

            if (isRelevantUpdate || isCancelled) {
                coursesUpdated.add(scheduledCourse.Id);
            }
        }

        if ( coursesUpdated.size() > 0 ) {

            System.debug('coursesUpdated item is: ' + coursesUpdated);

            for (List<Event> courseEvents :
                        [SELECT Id, OwnerId, WhatId, Subject, StartDateTime, EndDateTime, Location
						   FROM Event
						  WHERE WhatId IN :coursesUpdated]){
                // Add events related to the deleted or updated course to the eventsToDelete list
                for (Event courseEvent : courseEvents) {
                    eventsToDelete.add(courseEvent);
                }
            }

        }

        try {
            if (eventsToDelete.size() > 0) {
                Database.delete(eventsToDelete, false);
            }
            if (eventsToCreate.size() > 0) {
                insert eventsToCreate;
            }
        } catch (System.DmlException ex) {
            Error_Log__c err = new Error_Log__c(Source__c = 'createCourseEvent', message__c = ex.getMessage());
            insert err;
        }
    }
}
