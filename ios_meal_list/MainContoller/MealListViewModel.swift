import UIKit
import GoogleSignIn
import GoogleAPIClientForREST


class MealListViewModel: NSObject {
    let service = GTLRSheetsService()
    let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    
    private var user = User()
    private var cellsViewModel = [MealCellViewModel]()
    
    var showAlert: ((String, String, (() -> ())?) -> ())!
    var inputNameAlert: ((String, String) -> ())!
    var reloadTable: (() -> ())!
    var setBarTitle: ((String) -> ())!
    
    var numberOfMeals: Int {
        return user.meals.count
    }
    
    
    func getMealCellViewModel(at index: Int) -> MealCellViewModel {
        return cellsViewModel[index]
    }

    
    func initialSign() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
        } else {
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    
    func googleSign(user: GIDGoogleUser!, error: Error?) {
        if let error = error {
            showAlert("Authentication Error", error.localizedDescription, nil)
            service.authorizer = nil
        } else {
            service.authorizer = user.authentication.fetcherAuthorizer()
            
            if let name = UserDefaults.standard.string(forKey: "name") {
                requestMeal(name: name)
            } else {
                inputNameAlert("Input your name", "")
            }
        }
    }
    
    
    func requestMeal(name: String) {
        user.username = name
        
        let (date, currentDay) = getDayOfWeek()
        
        if date == 1 || date == 7 {
            showAlert("Chill", "Today is \(currentDay). You have no meals.", nil)
            return
        }
        
        let sheetId = "1X3IXPpOI0GUz2FoT7AzxB4KDuz7KNoPswkDhsDn0l0M"
        let range = "\(currentDay)!A1:M34"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: sheetId, range: range)
        
        service.executeQuery(query, delegate: self,
                             didFinish: #selector(parseMeal(ticket:finishedWithObject:error:)))
    }
    
    
    
    @objc private func parseMeal(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        if let error = error {
            showAlert("Error getting data", error.localizedDescription, nil)
            return
        }
        
        guard let rows = result.values, !rows.isEmpty else {
            showAlert("No data", "Empty data", nil)
            return
        }
        
        //get names of all meals and categories
        let (mealNames, mealCategories) = parseMealNamesAndCategories(mealsRow: rows[1],
                                                                      categoriesRow: rows[0])
        
        guard let usernameRow = findUserNameRow(rows: rows), usernameRow.count > 0 else {
            inputNameAlert("Error", "No such name in the table. Pick another one")
            return
        }
        
        let orderedMeals = parseOrderedMeals(usernameRow: usernameRow,
                                             mealNames: mealNames, mealCategories: mealCategories)
        
        user.meals = orderedMeals
        setBarTitle("\(getDayOfWeek().1),  \(user.username)")
        reloadTable()
    }
    
    
    private func parseMealNamesAndCategories(mealsRow: [Any], categoriesRow: [Any]) -> ([String], [String]){
        var mealNames = [String]()
        var mealCategories = [String]()
        var previousMealCategory = ""
        
        for i in 1..<mealsRow.count {
            if let mealName = mealsRow[i] as? String {
                mealNames.append(mealName)
                
                if i < categoriesRow.count, let mealCategory = categoriesRow[i] as? String, mealCategory != "" {
                    mealCategories.append(mealCategory)
                    previousMealCategory = mealCategory
                } else {
                    mealCategories.append(previousMealCategory)
                }
            }
        }
        
        return (mealNames, mealCategories)
    }
    
    
    private func findUserNameRow(rows: [[Any]]) -> [Any]? {
        var usernameRow: [Any]?
        
        for i in 2..<rows.count {
            if let name = rows[i][0] as? String, name == user.username {
                usernameRow = rows[i]
                break
            }
        }
        
        return usernameRow
    }
    
    
    private func parseOrderedMeals(usernameRow: [Any], mealNames: [String], mealCategories: [String]) -> [Meal] {
        var orderedMeals = [Meal]()
        cellsViewModel.removeAll(keepingCapacity: true)
        
        for i in 1..<usernameRow.count {
            if let mealIndex = usernameRow[i] as? String, mealIndex != "" {
                let meal = Meal(category: mealCategories[i - 1],
                                mealName: mealNames[i-1])
                orderedMeals.append(meal)
                
                let cellViewModel = MealCellViewModel(category: meal.category, mealName: meal.mealName)
                cellsViewModel.append(cellViewModel)
            }
        }
        
        return orderedMeals
    }
    
    
    //that's ugly
    private func getDayOfWeek() -> (Int, String) {
        var weekDayName: String
        
        switch Date().dayNumberOfWeek() {
        case 1:
            weekDayName = "Воскресенье"
            break;
        case 2:
            weekDayName = "Понедельник"
            break;
        case 3:
            weekDayName = "Вторник"
            break;
        case 4:
            weekDayName = "Среда"
            break;
        case 5:
            weekDayName = "Четверг"
            break;
        case 6:
            weekDayName = "Пятница"
            break;
        case 7:
            weekDayName = "Суббота"
            break;
        default:
            fatalError()
        }
        
        return (Date().dayNumberOfWeek() ?? 2, weekDayName)
    }
}
