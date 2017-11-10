public class loanController {
    
    public List<Loan__c> lstActiveLoans {get; set;}
    public List<User> lstStudentsByName {get; set;}
    
    public User userSelected{get;set;}

    public boolean showLoanOverdue {get;set;}
    public boolean showSearchCopyCode {get;set;}
    public boolean showStudentsSection {get; set;}
    public boolean showLoansSection {get; set;}
    public boolean showMessageSection {get; set;}
    public boolean showStudents {get;set;}
    public boolean showError {get;set;}
    
    public String name{get;set;}
    public String studentId{get;set;}
    public String copyCode{get; set;}
    public string loanToReturn {get;set;}
    public string fullName{get;set;}
    public string errorMessage{get; set;}
    public String notificationNessage{get;set;}
    
    public loanController(){
        lstActiveLoans = new List<Loan__c>();
    	lstStudentsByName = new List<User>();
        showStudents = false;
        showError = false;
        showLoanOverdue = false;
        showStudentsSection = true;
        showMessageSection = false;
    }    
    
    public void searchByName(){
        
        if(name != ''){
        	lstStudentsByName = [select FirstName, LastName from User where LastName = :name AND userRole.Name = 'Student'];
        }else{
            lstStudentsByName = [select FirstName, LastName, Email from User where userRole.Name = 'Student'];
        } 
        
        RenderSec();
    }
    
	public PageReference RenderSec(){
        if(lstStudentsByName.size() > 0){
            showError = false;
            showStudents = true;
        }
        else{
			errorMessage = 'There are no students with that name';
            showStudents = false;
            showError = true;
        }
        return null ;
    }
    
    public void returnToSearch(){
        showStudentsSection = true;
        showLoansSection = false ;
    }
    
    public void selectStudent(){

        showStudentsSection = false;
        showLoansSection = true;
        
        userSelected = [select FirstName, LastName, Email from User where Id = :studentId];
        fullName = userSelected.FirstName + ' ' +  userSelected.LastName;
        studentLoans();
        
    }

    public void studentLoans (){
        showSearchCopyCode = true;
        
        lstActiveLoans = [select Copy_Loan__r.Book_Copy__r.Title__c, Return_Date__c, Copy_Loan__r.Copy_Code__c from Loan__c where Returned__c = null AND Student__r.Id = :studentId];
      	for(Loan__c l: lstActiveLoans){
            if(l.Return_Date__c < Date.today()){
                showSearchCopyCode = false;
            	showLoanOverdue = true;
                break;
            }
        }
    }
    
    public void returnLoan(){
        string msg ='';
        try{
            Loan__c loan = [select Returned__c from Loan__c where id = :loanToReturn];
            loan.Returned__c = Date.today();
            update loan;
            
            msg = 'The loan was succesfully returned';
            
            userSelected = [select FirstName, LastName, Email from User where Id = :studentId];
			studentLoans();
            
        }catch(DmlException ex){
        	msg= 'There was an error processing the operation';  
        }
        
        RenderMessage(msg);
    }
    
    public void newLoan(){
        
        boolean validation = true;
        String msg = '';
        Book_Copy__c bookCopy;
        
        if(copyCode == ''){
            validation = false;
            msg = 'In order to make a new loan, you need to enter a copy code first.';
        }

        try{
            if(validation){
            	bookCopy = [select Copy_Code__c, bookTitle__c, Available__c from Book_Copy__c where Copy_Code__c = :copyCode LIMIT 1];
                            
            	if(bookCopy.Available__c){  
                    Loan__c createNewLoan = new Loan__c(
                        Loan_Date__c = Date.today(),
                        Return_Date__c = Date.today() + 3,
                        Copy_Loan__c = bookCopy.Id,
                        Student__c = userSelected.Id
                    );
                    insert createNewLoan;
                    studentLoans();
                    msg = 'New loan created succesfully.';
                }else{
                    validation = false;
                	msg = 'The copy is not available.';
                }
            }
            
        }catch(QueryException ex){
            msg = 'There are not copys with that copy code.';    
        }

        RenderMessage(msg);
    }
    
    public PageReference RenderMessage(String msg){
        if(msg != ''){
            showMessageSection = true;
            notificationNessage = msg;
        }
        return null ;
    }
    
}