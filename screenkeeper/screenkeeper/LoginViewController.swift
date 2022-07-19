import FirebaseDatabase
import FirebaseAuth
import UIKit

class LoginViewController: UIViewController {
    
    let database = Database.database().reference()
    let defaults = UserDefaults.standard
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Log In"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let emailField: UITextField = {
        let emailField = UITextField()
        emailField.placeholder = "Email Address"
        emailField.backgroundColor = .white
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.leftViewMode = .always
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return emailField
    }()
    
    private let passField: UITextField = {
        let passField = UITextField()
        passField.placeholder = "Password"
        passField.backgroundColor = .white
        passField.autocapitalizationType = .none
        passField.autocorrectionType = .no
        passField.isSecureTextEntry = true
        passField.leftViewMode = .always
        passField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return passField
    }()
    
    private let loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Continue", for: .normal)
        loginButton.backgroundColor = .systemOrange
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return loginButton
    }()
    
    private let createAccountButton: UIButton = {
        let createAccountButton = UIButton()
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.backgroundColor = .systemOrange
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
        return createAccountButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue
        view.addSubview(label)
        view.addSubview(emailField)
        view.addSubview(passField)
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
        
        // IMPLEMENT FEATURE: send user to home screen based on account type if currentUser != nil
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        
        label.frame = CGRect(x: 0, y: 100, width: width, height: 80)
        
        emailField.frame = CGRect(x: 20, y: label.frame.origin.y + label.frame.size.height + 10, width: width - 40, height: 40)
        
        passField.frame = CGRect(x: 20, y: emailField.frame.origin.y + emailField.frame.size.height + 10, width: width - 40, height: 40)
        
        loginButton.frame = CGRect(x: 20, y: passField.frame.origin.y + passField.frame.size.height + 10, width: width - 40, height: 30)
        
        createAccountButton.frame = CGRect(x: 20, y: loginButton.frame.origin.y + loginButton.frame.size.height + 10, width: width - 40, height: 30)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailField.becomeFirstResponder()
    }
    
    func createAddCode() -> String {
        let baseIntA = Int(arc4random() % 65535)
        let str = String(format: "%06X", baseIntA)
        return String("\(str)")
    }
    
    func createSafeEmail(email: String) -> String {
        let index = email.firstIndex(of: "@") ?? email.endIndex
        let safeEmail = email[..<index]
        return String(safeEmail.lowercased())
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailField.text, !email.isEmpty, let password = passField.text, !password.isEmpty else {
            print("missing field data")
            return
        }
        
        // get auth instance
        // try sign in
        // if fail, create account
        // create account
        
        // check sign in on app launch
        // allow user to sign out with button
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                // login failed!
                // prompt acc creation
                let alert = UIAlertController(title: "User not found", message: "The username or password was incorrect.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {_ in
                }))
                strongSelf.present(alert, animated: true)
                return
            }
            
            print("user signed in")
            
            let username = strongSelf.createSafeEmail(email: email)
            
            strongSelf.defaults.set(username, forKey: "username")
            strongSelf.database.child("parent_users/\(username)/name").observeSingleEvent(of: .value, with: { snapshot in
                let name = snapshot.value as? String ?? "noname"
                
                strongSelf.defaults.set(name, forKey: "name")
            })
            
            strongSelf.defaults.set(true, forKey: "complete")
            
            strongSelf.emailField.resignFirstResponder()
            strongSelf.passField.resignFirstResponder()
            
            let vc = ParentViewController()
            vc.modalPresentationStyle = .fullScreen
            strongSelf.present(vc, animated: true)
        })
        
    }
    
    @objc private func createAccountButtonTapped() {
        showCreateAccount()
    }
    
    func showCreateAccount() {
        print("show create account")
        let vc = RegisterViewController()
        present(vc, animated: true)
    }

}
