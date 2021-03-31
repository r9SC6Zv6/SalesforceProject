@isTest
private class CertificationTriggerHnadler_Test {
    
    @TestSetup
    static void setupData(){
        List<User> testInstructors = LoadDataTestFactory.createUsers();
        List<Course__c> testCourses = LoadDataTestFactory.loadCourses();
        List<Certification__c> testCertifications = LoadDataTestFactory.loadCertifications();
        insert testInstructors;
    }

    @isTest
    static void insertCertification() {
        List<Course__c> activeCourse = [SELECT Id
                                        FROM Course__c
                                        LIMIT 1];
        Course__c course = activeCourse[0];

        Profile instructorP = [SELECT Id FROM Profile WHERE Name='Instructor'];
        List<User> instructors = [SELECT Id, Username FROM User WHERE profileId = :instructorP.Id LIMIT 2];

        Integer preCertCount = 0;
        Integer postCertCount = 0;
        Integer preCertCountInst2 = 0;
        Integer postCertCountInst2 = 0;

        System.runAs(instructors[0]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++preCertCount;
                }
            }
        }

        System.runAs(instructors[1]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++preCertCountInst2;
                }
            }
        }

        Test.startTest();

        Certification__c certification = new Certification__c();
        certification.Course__c = course.Id;
        certification.Instructor__c = instructors[0].Id;
        certification.Daily_Rate__c = 1;
        certification.Certification_Date__c = Date.today();

        List<Certification__c> certifications = new List<Certification__c>();
        certifications.add(certification);
        Database.SaveResult[] saveResults = Database.insert(certifications, false);

        Test.stopTest();

        Integer errorCount = 0;
        Integer insertCount = 0;

        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                ++errorCount;
            } else {
                ++insertCount;
            }
        }

        System.runAs(instructors[0]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++postCertCount;
                }
            }
        }

        System.runAs(instructors[1]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++postCertCountInst2;
                }
            }
        }

        // System.debug(preCertCount);
        // System.debug(postCertCount);
        // System.debug(preCertCountInst2);
        // System.debug(postCertCountInst2);
        // System.debug(insertCount);

        System.assertEquals(0, errorCount);
        System.assertEquals(1, insertCount);
        System.assertEquals(1, postCertCount - preCertCount);
        System.assertEquals(0, postCertCountInst2 - preCertCountInst2);

    }

    @isTest
    static void insertCertificationBulk() {
        List<Course__c> activeCourse = [SELECT Id
                                        FROM Course__c
                                        LIMIT 1];
        Course__c course = activeCourse[0];

        Profile instructorP = [SELECT Id FROM Profile WHERE Name='Instructor'];
        List<User> instructors = [SELECT Id, Username FROM User WHERE profileId = :instructorP.Id LIMIT 2];

        Integer preCertCount = 0;
        Integer postCertCount = 0;
        Integer preCertCountInst2 = 0;
        Integer postCertCountInst2 = 0;

        System.runAs(instructors[0]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++preCertCount;
                }
            }
        }

        System.runAs(instructors[1]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++preCertCountInst2;
                }
            }
        }

        Test.startTest();

        List<Certification__c> certifications = new List<Certification__c>();

        for (Integer i = 0; i < 205; i++) {
            Certification__c certification = new Certification__c();
            certification.Course__c = course.Id;
            certification.Instructor__c = instructors[0].Id;
            certification.Daily_Rate__c = 1;
            certification.Certification_Date__c = Date.today();   
            
            certifications.add(certification);
        }
        
        Database.SaveResult[] saveResults = Database.insert(certifications, false);

        Test.stopTest();

        Integer errorCount = 0;
        Integer insertCount = 0;

        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                ++errorCount;
            } else {
                ++insertCount;
            }
        }

        System.runAs(instructors[0]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++postCertCount;
                }
            }
        }

        System.runAs(instructors[1]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++postCertCountInst2;
                }
            }
        }

        // System.debug(preCertCount);
        // System.debug(postCertCount);
        // System.debug(preCertCountInst2);
        // System.debug(postCertCountInst2);
        // System.debug(insertCount);

        System.assertEquals(0, errorCount);
        System.assertEquals(205, insertCount);
        System.assertEquals(205, postCertCount - preCertCount);
        System.assertEquals(0, postCertCountInst2 - preCertCountInst2);

    }

    @isTest
    static void updateCertification() {
        List<Certification__c> activeCert = [SELECT Id, Certification_Date__c, Course__c, CreatedById, CreatedDate, Daily_Rate__c, IsDeleted, Name, Instructor__c, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, OwnerId, SystemModstamp
                                             FROM Certification__c
                                             LIMIT 1];
        Certification__c certToUpdate = activeCert[0];

        Profile instructorP = [SELECT Id FROM Profile WHERE Name='Instructor'];
        List<User> instructors = [SELECT Id, Username FROM User WHERE profileId = :instructorP.Id LIMIT 2];
        USER originalInstructor = [SELECT Id FROM User WHERE Id = :certToUpdate.Instructor__c LIMIT 1];

        Integer preCertCount = 0;
        Integer postCertCount = 0;
        Integer preCertCountInst2 = 0;
        Integer postCertCountInst2 = 0;

        System.runAs(originalInstructor) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++preCertCount;
                }
            }
        }

        System.runAs(instructors[0]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++preCertCountInst2;
                }
            }
        }

        Test.startTest();

        certToUpdate.Instructor__c = instructors[0].Id;

        List<Certification__c> certifications = new List<Certification__c>();
        certifications.add(certToUpdate);
        Database.SaveResult[] saveResults = Database.update(certifications, false);

        Test.stopTest();

        Integer errorCount = 0;
        Integer insertCount = 0;

        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                ++errorCount;
                System.debug(sr.getErrors()[0].getMessage());
            } else {
                ++insertCount;
            }
        }

        System.runAs(originalInstructor) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++postCertCount;
                }
            }
        }

        System.runAs(instructors[0]) {
            for (List<Certification__c> certs : [SELECT Id FROM Certification__c]) {
                for (Certification__c cert : certs) {
                    ++postCertCountInst2;
                }
            }
        }

        // System.debug(preCertCount);
        // System.debug(postCertCount);
        // System.debug(preCertCountInst2);
        // System.debug(postCertCountInst2);
        // System.debug(insertCount);

        System.assertEquals(0, errorCount);
        System.assertEquals(1, insertCount);
        System.assertEquals(-1, postCertCount - preCertCount);
        System.assertEquals(1, postCertCountInst2 - preCertCountInst2);

    }

    
}
