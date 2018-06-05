import UIKit
import GoogleSignIn
import GoogleAPIClientForREST


class ViewController: UIViewController {
    private lazy var viewModel: MealListViewModel = {
        return MealListViewModel()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Изменить имя",
                                                            style: .plain, target: self,
                                                            action: #selector(changeName))
        setupGoogleApi()
        setupViews()
        setupViewModel()
        
        viewModel.initialSign()
    }
    
    
    private let mealsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(MealCell.self, forCellWithReuseIdentifier: MealCell.cellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    
    private func setupViews() {
        view.addSubview(mealsCollectionView)
        
        mealsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        mealsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        mealsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mealsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mealsCollectionView.backgroundColor = UIColor.white
        mealsCollectionView.delegate = self
        mealsCollectionView.dataSource = self
    }
    
    
    private func setupViewModel() {
        viewModel.inputNameAlert = { title, message in
            DispatchQueue.main.async {
                self.inputNameAlert(title: title, message: message)
            }
        }
        
        viewModel.showAlert = { title, message, completion in
            DispatchQueue.main.async {
                self.showAlert(title: title, message: message, completion: completion)
            }
        }
        
        viewModel.reloadTable = {
            DispatchQueue.main.async {
                self.mealsCollectionView.reloadData()
            }
        }
        
        viewModel.setBarTitle = { title in
            DispatchQueue.main.async {
                self.navigationItem.title = title
            }
        }
    }
    
    
    @objc private func changeName() {
        inputNameAlert()
    }
}


extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    private func setupGoogleApi() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = viewModel.scopes
    }
    
    //this method is called by default on authorization
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        viewModel.googleSign(user: user, error: error)
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MealCell.cellIdentifier, for: indexPath)
            as? MealCell else {
            fatalError()
        }
        
        let cellVM = viewModel.getMealCellViewModel(at: indexPath.row)
        cell.mealCategory = cellVM.category
        cell.mealName = cellVM.mealName
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfMeals
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 150)
    }
}


extension ViewController {
    private func showAlert(title : String, message: String, completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: completion)
    }
    
    
    private func inputNameAlert(title: String = "Imput your name", message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.defaultInitilization(hint: "Your name")
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.defaultInitilization(hint: "Your second name")
        })
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action in
            let firstName = alert.textFields?[0].text ?? ""
            let secondName = alert.textFields?[1].text ?? ""
            let name = firstName + " " + secondName
            UserDefaults.standard.set(name, forKey: "name")
            
            self.viewModel.requestMeal(name: name)
        }
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
}

