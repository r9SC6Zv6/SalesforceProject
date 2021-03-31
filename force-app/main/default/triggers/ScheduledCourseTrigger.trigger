trigger ScheduledCourseTrigger on Opportunity (after insert, after update) {
    SWITCH ON Trigger.OperationType {
		WHEN AFTER_INSERT {
			ScheduledCourseTriggerHandler.grantInstructorAccess(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
            ScheduledCourseTriggerHandler.createCourseEvent(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
		}
        WHEN AFTER_UPDATE {
            ScheduledCourseTriggerHandler.grantInstructorAccess(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
            ScheduledCourseTriggerHandler.createCourseEvent(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
		}
	}
}