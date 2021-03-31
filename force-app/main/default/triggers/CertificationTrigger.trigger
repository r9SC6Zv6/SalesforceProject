trigger CertificationTrigger on Certification__c (after insert, after update) {
    SWITCH ON Trigger.OperationType {
		WHEN AFTER_INSERT {
			CertificationTriggerHandler.grantInstructorAccess(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
		}
        WHEN AFTER_UPDATE {
            CertificationTriggerHandler.grantInstructorAccess(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
		}
	}
}