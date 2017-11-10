@isTest
private class testLoanController {

    @isTest
    static void testSearchByNameWithOneName(){
        testDataCreation();
        loanController lc = new loanController();
        User libr = getLibrarian();
        User stud = getStudent();
        lc.name = stud.LastName;
        
        test.startTest();
        System.runAs(libr){
            lc.searchByName();  
        }
        Test.stopTest();
        
        integer listSize = lc.lstStudentsByName.size();
        System.assert(listSize>0, 'The list size is not greater than 0');
        System.assertEquals(false, lc.showError, 'showError should be false');
        System.assert(lc.showStudents, 'showStudents should be true');
    }
    
    @isTest
    static void testSearchByNameWithNoName(){
        testDataCreation();
        loanController lc = new loanController();
        User libr = getLibrarian();
        lc.name = '';
        
        test.startTest();
        System.runAs(libr){
            lc.searchByName();
        }
        Test.stopTest();
        
        integer listSize = lc.lstStudentsByName.size();
        System.assert(listSize>0, 'The list size is not greater than 0');
        System.assertEquals(false, lc.showError, 'showError should be false');
        System.assert(lc.showStudents, 'showStudents should be true');
    }

    @isTest
    static void testSearchByWithWrongName(){
        testDataCreation();
        loanController lc = new loanController();
        User libr = getLibrarian();
        lc.name = 'noExistinName';

        test.startTest();
        System.runAs(libr){
            lc.searchByName();
        }
        Test.stopTest();
        
        integer listSize = lc.lstStudentsByName.size();
        System.assertEquals(0, listSize, 'The list should be 0');
        System.assertEquals('There are no students with that name', lc.errorMessage, 'The error message should be displayed');
        System.assert(lc.showError, 'showError should be true');
        System.assertEquals(0, listSize, 'The list size is not greater than 0');
        System.assertEquals(false, lc.showStudents, 'showStudents should be false');
    }

    @isTest
    static void testReturnToSearch(){
        testDataCreation();
        loanController lc = new loanController();
        User libr = getLibrarian();
        
        Test.startTest();
        System.runAs(libr){
            lc.returnToSearch();
        }
        Test.stopTest();
        System.assertEquals(true, lc.showStudentsSection, 'ShowStudentsSections should be true');
        System.assertEquals(false, lc.showLoansSection, 'ShowLoansSection should be false');
    }
    
    @isTest
    static void testSelectStudentWithoutLoansOverdue(){
        testDataCreation();
        loanController lc = new loanController();
        User libr = getLibrarian();
        User stud = getStudent();
        lc.studentId = stud.Id;
        String testFullName = stud.FirstName +' '+ stud.LastName;
        
        Test.startTest();
        System.runAs(libr){
            lc.selectStudent();
        }
        Test.stopTest();
        
        System.assertEquals(false, lc.showStudentsSection, 'showStudentsSection should be false');
        System.assert(lc.showLoansSection, 'showStudentsSection should be true');
        System.assertEquals(stud, lc.userSelected, 'Wrong user selected');
        System.assertEquals(testFullName, lc.fullName, 'FullName should match with testFullName');        
        System.assert(lc.showSearchCopyCode, 'showSearchCopyCode should be true');
        System.assertEquals(false, lc.showLoanOverdue, 'showLoanOverdue should be false');
    }    
    
    @isTest
    static void testSelectStudentWithLoansOverdue(){
        testDataCreation();
        loanController lc = new loanController();
        User libr = getLibrarian();
        User stud = getStudent();
        lc.studentId = stud.Id;
        String testFullName = stud.FirstName +' '+ stud.LastName;
        
        Book__c book = [Select Id From Book__c Where Title__c = 'test2'];
        Book_Copy__c CopyLoanTest1 = [Select Copy_Code__c from Book_Copy__c Where Book_Copy__c = :book.Id Limit 1];
        
        Loan__c loanTest1 = new Loan__c(
            Loan_Date__c = Date.today() - 3,
            Return_Date__c = Date.today() - 1,
            Copy_Loan__c = CopyLoanTest1.Id,
            Student__c = stud.Id
        );
        insert loanTest1;
        
        Test.startTest();
        System.runAs(libr){
            lc.selectStudent();
        }
        Test.stopTest();
        
        System.assertEquals(false, lc.showStudentsSection, 'showStudentsSection should be false');
        System.assert(lc.showLoansSection, 'showStudentsSection should be true');
        System.assertEquals(stud, lc.userSelected, 'Wrong user selected');
        System.assertEquals(testFullName, lc.fullName, 'FullName should match with testFullName');        
        System.assertEquals(false, lc.showSearchCopyCode, 'showSearchCopyCode should be false');
        System.assert(lc.showLoanOverdue, 'showLoanOverdue should be true');
    }      
    
    @isTest
    static void testResturnLoan(){

        testDataCreation();
        User libr = getLibrarian();
        User stud = getStudent();
        loanController lc = new loanController();
        lc.studentId = stud.Id;
        Book__c book = [Select Id From Book__c Where Title__c = 'test1'];
        Book_Copy__c bookCopy = [Select Copy_Code__c, Available__c from Book_Copy__c Where Book_Copy__c = :book.Id Limit 1];
        Loan__c loan = [Select Id, Returned__c From Loan__c Where Copy_Loan__r.Id = :bookCopy.Id Limit 1];
        lc.loanToReturn = loan.id;
        
        Test.startTest();
        System.runAs(libr){
            lc.returnLoan();        
        }
        Test.stopTest();    
        
        //system.assertEquals(Date.today(), loan.Returned__c, 'The copy should be available');
        system.assertEquals(true, lc.showMessageSection, 'showMessageSection should be true');
        system.assertEquals('The loan was succesfully returned', lc.notificationNessage, 'Both messages should match');
    }
    
    @isTest 
    static void testNewLoanWithCopyCodeNull(){
        testDataCreation();
        User libr = getLibrarian();
        loanController lc = new loanController();
        lc.copyCode = '';
        
        Test.startTest();
        System.runAs(libr){
            lc.newLoan();
        }
        Test.stopTest(); 
        
        system.assertEquals(true, lc.showMessageSection, 'showMessageSection should be true');
        system.assertEquals('In order to make a new loan, you need to enter a copy code first.', lc.notificationNessage, 'The message should match');
    }
    
    @isTest 
    static void testNewLoanWithCopyNotAvailable(){
        testDataCreation();
        User libr = getLibrarian();
        Book__c book = [Select Id From Book__c Where Title__c = 'test1'];
        Book_Copy__c bookCopy = [Select Copy_Code__c from Book_Copy__c Where Book_Copy__c = :book.Id Limit 1];
        loanController lc = new loanController();
        lc.copyCode = bookCopy.Copy_Code__c;
        
        Test.startTest();
        System.runAs(libr){
            lc.newLoan();
        }
        Test.stopTest(); 
        
        system.assertEquals(true, lc.showMessageSection, 'showMessageSection should be true');
        system.assertEquals('The copy is not available.', lc.notificationNessage, 'The message should match');
    }
    
    @isTest 
    static void testNewLoanWithCopyCode(){
        testDataCreation();
        User libr = getLibrarian();
        User stud = getStudent();
        Book__c book = [Select Id From Book__c Where Title__c = 'test2'];
        Book_Copy__c bookCopy = [Select Copy_Code__c from Book_Copy__c Where Book_Copy__c = :book.Id Limit 1];
        loanController lc = new loanController();
        lc.copyCode = bookCopy.Copy_Code__c;
        lc.userSelected = stud;
        
        Test.startTest();
        System.runAs(libr){
            lc.newLoan();
        }
        Test.stopTest(); 
        
        system.assertEquals(true, lc.showMessageSection, 'showMessageSection should be true');
        system.assertEquals('New loan created succesfully.', lc.notificationNessage, 'The message should match');
    }
    
    @isTest 
    static void testNewLoanWithError(){
        testDataCreation();
        User libr = getLibrarian();
        loanController lc = new loanController();
        lc.copyCode = '123456789';
        lc.userSelected = libr;
        
        Test.startTest();
        System.runAs(libr){
            lc.newLoan();
        }
        Test.stopTest(); 
        
        system.assertEquals(true, lc.showMessageSection, 'showMessageSection should be true');
        system.assertEquals('There are not copys with that copy code.', lc.notificationNessage, 'The message should match');
    }

    @testSetup
    static void testUserCreation(){
        Profile ProfileLibr  = [Select Id, Name From Profile Where Name='Librarian' Limit 1];
        userRole RoleLibr = [Select Id, Name From userRole Where Name='Librarian' Limit 1];
        
        Profile ProfileStud  = [Select Id, Name From Profile Where Name='Student' Limit 1];
        userRole RoleStud = [Select Id, Name From userRole Where Name='Student' Limit 1];
                        
        User studentTest1 = new User(
            FirstName = 'Test',
            LastName = 'librarian',
            alias = 'libr',
            email = 'denise@oktana.io',
            username = 'librarian@Assignment1salesforce.com',
            CommunityNickname = 'libr',
            ProfileID  = ProfileLibr.id,
            UserRoleId = RoleLibr.id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert studentTest1;
        
        User studentTest2 = new User(
            FirstName = 'test',
            LastName = 'student',
            alias = 'stud',
            email = 'denise@oktana.io',
            username = 'student@Assignment1salesforce.com',
            CommunityNickname = 'stud',
            ProfileID  = ProfileStud.Id,
            UserRoleId = RoleStud.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert studentTest2;
    }
    
    static void testDataCreation(){
        user student = getStudent();
        system.debug(student);
        user librarian = getLibrarian();
        
        Book__c bookTest1 = new Book__c(
            Author__c = 'test1',
            Title__c = 'test1',
            ISBN__c = 09876541,
            Publisher__c = 'test1',
            Description__c = 'test1'
        );
        insert bookTest1;
        
        Book__c bookTest2 = new Book__c(
            Author__c = 'test2',
            Title__c = 'test2',
            ISBN__c = 098765431,
            Publisher__c = 'test2',
            Description__c = 'test2'
        );
        insert bookTest2;
        
        Book_Copy__c bookCopyTest1 = new Book_Copy__c (
            Book_Copy__c = bookTest1.id
        );
        insert bookCopyTest1;
        
        Book_Copy__c bookCopyTest2 = new Book_Copy__c (
            Book_Copy__c = bookTest1.id
        );
        insert bookCopyTest2;
        
        Book_Copy__c bookCopyTest3 = new Book_Copy__c (
            Book_Copy__c = bookTest2.id
        );
        insert bookCopyTest3;
       
        Book_Copy__c CopyLoanTest1 = [Select Copy_Code__c, Available__c from Book_Copy__c LIMIT 1];
        
        Loan__c loanTest1 = new Loan__c(
            Loan_Date__c = Date.today(),
            Return_Date__c = Date.today() + 3,
            Copy_Loan__c = CopyLoanTest1.Id,
            Student__c = student.Id
        );
        insert loanTest1;
    }
    
    static User getLibrarian(){
        User u = [Select Email From User Where username = 'librarian@Assignment1salesforce.com' LIMIT 1];
        return u;
    }
    
    static User getStudent(){
        User u = [Select FirstName, LastName, Email From User Where username = 'student@Assignment1salesforce.com' LIMIT 1];
        return u;
    }
}