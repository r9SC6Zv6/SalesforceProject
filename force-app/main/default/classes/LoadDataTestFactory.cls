public with sharing class LoadDataTestFactory {

    public static List<Course__c> loadCourses() {
        return Test.loadData(Course__c.sObjectType, 'TestCourses');
    }

    public static List<Certification__c> loadCertifications() {
        return Test.loadData(Certification__c.sObjectType, 'TestCertifications');
    }

    public static List<Account> loadAccounts() {
        return Test.loadData(Account.sObjectType, 'TestAccounts');
    }

    public static List<User> createUsers() {
        Id instructorProfileId = [SELECT Id FROM Profile WHERE Name = 'Instructor' LIMIT 1].Id;

        List<User> users = new List<User>();

        User instructor1 = new User(Username='mholmes@300321em.example.com',
                                            FirstName='Minnie', LastName='Holmes',
                                            email='mholmes@example.com',
                                            alias='mholmes',
                                            CommunityNickname='mholmes',
                                            TimeZoneSidKey='America/Los_Angeles',
                                            LocaleSidKey='en_US', 
                                            EmailEncodingKey='UTF-8',
                                            ProfileId=instructorProfileId, 
                                            LanguageLocaleKey='en_US'
                                           );
        users.add(instructor1);
        User instructor2 = new User(Username='nsanchez@300321em.example.com',
                                            FirstName='Minnie', LastName='Sanchez',
                                            email='nsanchez@example.com',
                                            alias='nsanchez',
                                            CommunityNickname='nsanchez',
                                            TimeZoneSidKey='America/Los_Angeles',
                                            LocaleSidKey='en_US', 
                                            EmailEncodingKey='UTF-8',
                                            ProfileId=instructorProfileId, 
                                            LanguageLocaleKey='en_US'
                                           );
        users.add(instructor2);

        return users;
    }
}
