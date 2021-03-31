@isTest
private class ScheduledCourseTriggerHandler_Test {
    
    @TestSetup
    static void setupData() {
        List<User> testInstructors = LoadDataTestFactory.createUsers();
        //insert testInstructors;
        List<Course__c> testCourses = LoadDataTestFactory.loadCourses();
        List<Account> testAccounts = LoadDataTestFactory.loadAccounts();
        List<Certification__c> testCertifications = LoadDataTestFactory.loadCertifications();
    }

    @isTest
    static void grantInstructorAccessInsert() {

        List<Account> activeAccount = [SELECT Id FROM Account LIMIT 1];
        Account anAccount = activeAccount[0];

        List<Course__c> activeCourse = [SELECT Id FROM Course__c LIMIT 1];
        Course__c aCourse = activeCourse[0];

        Profile instructorP = [SELECT Id FROM Profile WHERE Name='Instructor'];
        Profile instructorPP = [SELECT Id FROM Profile WHERE Name='Instructor_Platform'];
        List<User> instructors = [SELECT Id, Username FROM User WHERE profileId = :instructorP.Id OR profileId = :instructorPP.Id LIMIT 2];
        User anInstructor = instructors[1];
        User certInstructor = instructors[0];

        Certification__c newCert = new Certification__c(Course__c = aCourse.Id, Instructor__c = certInstructor.Id, Daily_Rate__c = 1, Certification_Date__c = Date.today());
        insert newCert;
        List<Certification__c> aCertList = [SELECT Id FROM Certification__c WHERE Instructor__c = :certInstructor.Id AND Course__c = :aCourse.Id LIMIT 1];
        Certification__c aCert = aCertList[0];
        

        Integer preScheduleCountInst1 = 0;
        Integer postScheduleCountInst1 = 0;
        Integer preScheduleCountInst2 = 0;
        Integer postScheduleCountInst2 = 0;

        System.runAs(certInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++preScheduleCountInst1;
                }
            }
        }

        System.runAs(anInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++preScheduleCountInst2;
                }
            }
        }

        Test.startTest();

        Opportunity newCourse = new Opportunity();
        newCourse.Name = 'Test';
        newCourse.Course__c = aCourse.Id;
        newCourse.AccountId = anAccount.Id;
        newCourse.Instructor__c = aCert.Id;
        newCourse.CloseDate = Date.today() + 5;
        newCourse.Location__c = 'Test Location';
        newCourse.StageName = 'Scheduled';

        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(newCourse);
        Database.SaveResult[] saveResults = Database.insert(opportunities, false);

        Test.stopTest();

        Integer errorCount = 0;
        Integer successCount = 0;

        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                ++errorCount;
                System.debug(sr.getErrors()[0].getMessage());
            } else {
                ++successCount;
            }
        }

        System.runAs(certInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++postScheduleCountInst1;
                }
            }
        }

        System.runAs(anInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++postScheduleCountInst2;
                }
            }
        }

        System.assertEquals(0, errorCount);
        System.assertEquals(1, successCount);
        System.assertEquals(1, postScheduleCountInst1 - preScheduleCountInst1);
        System.assertEquals(0, postScheduleCountInst2 - preScheduleCountInst2);

    }

    @isTest
    static void grantInstructorAccessInsertBulk() {

        List<Account> activeAccount = [SELECT Id FROM Account LIMIT 1];
        Account anAccount = activeAccount[0];

        List<Course__c> activeCourse = [SELECT Id FROM Course__c LIMIT 1];
        Course__c aCourse = activeCourse[0];

        Profile instructorP = [SELECT Id FROM Profile WHERE Name='Instructor'];
        Profile instructorPP = [SELECT Id FROM Profile WHERE Name='Instructor_Platform'];
        List<User> instructors = [SELECT Id, Username FROM User WHERE profileId = :instructorP.Id OR profileId = :instructorPP.Id LIMIT 2];
        User anInstructor = instructors[1];
        User certInstructor = instructors[0];

        Certification__c newCert = new Certification__c(Course__c = aCourse.Id, Instructor__c = certInstructor.Id, Daily_Rate__c = 1, Certification_Date__c = Date.today());
        insert newCert;
        List<Certification__c> aCertList = [SELECT Id FROM Certification__c WHERE Instructor__c = :certInstructor.Id AND Course__c = :aCourse.Id LIMIT 1];
        Certification__c aCert = aCertList[0];
        

        Integer preScheduleCountInst1 = 0;
        Integer postScheduleCountInst1 = 0;
        Integer preScheduleCountInst2 = 0;
        Integer postScheduleCountInst2 = 0;

        System.runAs(certInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++preScheduleCountInst1;
                }
            }
        }

        System.runAs(anInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++preScheduleCountInst2;
                }
            }
        }

        Test.startTest();

        List<Opportunity> opportunities = new List<Opportunity>();

        for (Integer i = 0; i < 205; i++) {
            Opportunity newCourse = new Opportunity();
            newCourse.Name = 'Test';
            newCourse.Course__c = aCourse.Id;
            newCourse.AccountId = anAccount.Id;
            newCourse.Instructor__c = aCert.Id;
            newCourse.CloseDate = Date.today() + 5;
            newCourse.Location__c = 'Test Location';
            newCourse.StageName = 'Scheduled';

            opportunities.add(newCourse);
        }
        

        Database.SaveResult[] saveResults = Database.insert(opportunities, false);

        Test.stopTest();

        Integer errorCount = 0;
        Integer successCount = 0;

        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                ++errorCount;
                System.debug(sr.getErrors()[0].getMessage());
            } else {
                ++successCount;
            }
        }

        System.runAs(certInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++postScheduleCountInst1;
                }
            }
        }

        System.runAs(anInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++postScheduleCountInst2;
                }
            }
        }

        System.assertEquals(0, errorCount);
        System.assertEquals(205, successCount);
        System.assertEquals(205, postScheduleCountInst1 - preScheduleCountInst1);
        System.assertEquals(0, postScheduleCountInst2 - preScheduleCountInst2);

    }

    @isTest
    static void grantInstructorAccessUpdate() {

        List<Account> activeAccount = [SELECT Id FROM Account LIMIT 1];
        Account anAccount = activeAccount[0];

        List<Course__c> activeCourse = [SELECT Id FROM Course__c LIMIT 1];
        Course__c aCourse = activeCourse[0];

        Profile instructorP = [SELECT Id FROM Profile WHERE Name='Instructor'];
        Profile instructorPP = [SELECT Id FROM Profile WHERE Name='Instructor_Platform'];
        List<User> instructors = [SELECT Id, Username FROM User WHERE profileId = :instructorP.Id OR profileId = :instructorPP.Id LIMIT 2];
        System.debug(instructors.size());
        User anInstructor = instructors[1];
        System.debug(instructors[0].Username);
        System.debug(instructors[1].Username);
        User certInstructor = instructors[0];

        Certification__c newCert = new Certification__c(Course__c = aCourse.Id, Instructor__c = certInstructor.Id, Daily_Rate__c = 1, Certification_Date__c = Date.today());
        Database.SaveResult newCertResult = Database.insert(newCert);
        List<Certification__c> aCertList = [SELECT Id FROM Certification__c WHERE Id = :newCertResult.getId() LIMIT 1];
        Certification__c aCert = aCertList[0];

        Certification__c newUpdateCert = new Certification__c(Course__c = aCourse.Id, Instructor__c = anInstructor.Id, Daily_Rate__c = 1, Certification_Date__c = Date.today());
        Database.SaveResult updateCertResult = Database.insert(newUpdateCert);
        List<Certification__c> updateCertList = [SELECT Id FROM Certification__c WHERE Id = :updateCertResult.getId() LIMIT 1];
        Certification__c updateCert = updateCertList[0];
       
        Opportunity newCourse = new Opportunity();
        newCourse.Name = 'Test';
        newCourse.Course__c = aCourse.Id;
        newCourse.AccountId = anAccount.Id;
        newCourse.Instructor__c = aCert.Id;
        newCourse.CloseDate = Date.today() + 5;
        newCourse.Location__c = 'Test Location';
        newCourse.StageName = 'Scheduled';
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(newCourse);
        Database.SaveResult[] newOppResult = Database.insert(opportunities, false);
        
        List<Opportunity> aScheduledCourseList = [SELECT  Id, AccountId, Amount, CampaignId, IsClosed, Course__c, Course_Title__c, CreatedById, CreatedDate, IsDeleted, Description, End_Date__c, ExpectedRevenue, Expense_Invoice_Amount__c, ExpenseInvoiceCreated__c, Fiscal, FiscalQuarter, FiscalYear, ForecastCategory, ForecastCategoryName, HasOpportunityLineItem, HasOpenActivity, HasOverdueTask, Instructor__c, InvoiceAutoNumber__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, LeadSource, Location__c, MainCompetitors__c, NextStep, Pricebook2Id, IsPrivate, TotalOpportunityQuantity, Name, OwnerId, Type, Service_Invoice_Amount__c, ServiceInvoiceCreated__c, StageName, Stage_graphical__c, CloseDate, SystemModstamp, TrackingNumber__c, IsWon
                                                  FROM Opportunity
                                                  WHERE Id = :newOppResult[0].getId()
                                                  LIMIT 1];
        Opportunity aScheduledCourse = aScheduledCourseList[0];
        

        Integer preScheduleCountInst1 = 0;
        Integer postScheduleCountInst1 = 0;
        Integer preScheduleCountInst2 = 0;
        Integer postScheduleCountInst2 = 0;

        System.runAs(certInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++preScheduleCountInst1;
                }
            }
        }

        System.runAs(anInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++preScheduleCountInst2;
                }
            }
        }

        Test.startTest();

        aScheduledCourse.Instructor__c = updateCert.Id;
        List<Opportunity> updateList = new List<Opportunity>();
        updateList.add(aScheduledCourse);
        Database.SaveResult[] saveResults = Database.update(updateList);

        Test.stopTest();

        Integer errorCount = 0;
        Integer successCount = 0;

        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                ++errorCount;
                System.debug(sr.getErrors()[0].getMessage());
            } else {
                ++successCount;
            }
        }

        System.runAs(certInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++postScheduleCountInst1;
                }
            }
        }

        System.runAs(anInstructor) {
            for (List<Opportunity> courses : [SELECT Id FROM Opportunity]) {
                for (Opportunity course : courses) {
                    ++postScheduleCountInst2;
                }
            }
        }

        System.assertEquals(0, errorCount);
        System.assertEquals(1, successCount);
        System.assertEquals(-1, postScheduleCountInst1 - preScheduleCountInst1);
        System.assertEquals(+1, postScheduleCountInst2 - preScheduleCountInst2);

    }


}

