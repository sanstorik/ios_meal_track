import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

//https://docs.google.com/spreadsheets/d/1XuwNQ8gYQelkVFhlgLlvz5014dT-RWh-PDUBOG9f5FI/edit#gid=0

class ViewController: UIViewController {
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    private let service = GTLRSheetsService()
    
    
    private let signInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupGoogleApi()
        setupViews()
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    
    private func setupViews() {
        
    }
    
    
    private func showMeal() {
        
    }
}


extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    private func setupGoogleApi() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            
            requestMeal()
        }
    }
    
    
    private func requestMeal() {
        let sheetId = "1XuwNQ8gYQelkVFhlgLlvz5014dT-RWh-PDUBOG9f5FI"
        let range = "A3:M34"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: sheetId, range: range)
        
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayMeal(ticket:finishedWithObject:error:)))
    }
    
    
    @objc private func displayMeal(ticket: GTLRServiceTicket,
                             finishedWithObject result : GTLRSheets_ValueRange,
                             error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error getting data", message: error.localizedDescription)
            return
        }
        
        guard let rows = result.values, !rows.isEmpty else {
            showAlert(title: "No data", message: "Emtpy data")
            return
        }
        
        for row in rows {
            print("\(row[0])")
        }
    }
}


extension ViewController {
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

