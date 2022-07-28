import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class RegisterViewController: UIViewController {

    let database = Database.database().reference()
    let defaults = UserDefaults.standard
        
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let nameField: UITextField = {
        let nameField = UITextField()
        nameField.placeholder = "Your Name"
        nameField.backgroundColor = .white
        nameField.autocapitalizationType = .none
        nameField.autocorrectionType = .no
        nameField.leftViewMode = .always
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return nameField
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

    private let registerButton: UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle("Continue", for: .normal)
        registerButton.backgroundColor = .systemOrange
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return registerButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue
        view.addSubview(label)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passField)
        view.addSubview(registerButton)
        
        // IMPLEMENT FEATURE: send user to home screen based on account type if currentUser != nil
    }

    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        label.frame = CGRect(x: 0, y: 100, width: width, height: 80)
        
        nameField.frame = CGRect(x: 20, y: label.frame.origin.y + label.frame.size.height + 10, width: width - 40, height: 40)
        
        emailField.frame = CGRect(x: 20, y: nameField.frame.origin.y + nameField.frame.size.height + 10, width: width - 40, height: 40)
        
        passField.frame = CGRect(x: 20, y: emailField.frame.origin.y + emailField.frame.size.height + 10, width: width - 40, height: 40)
        
        registerButton.frame = CGRect(x: 20, y: passField.frame.origin.y + passField.frame.size.height + 10, width: width - 40, height: 30)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameField.becomeFirstResponder()
    }
    
    func createAddCode() -> String {
        let baseIntA = Int(arc4random() % 65535)
        let str = String(format: "%06X", baseIntA)
        return String(str)
    }
    
    func createSafeEmail(email: String) -> String {
        let index = email.firstIndex(of: "@") ?? email.endIndex
        let truncatedEmail = email[..<index]
        let safeEmail = truncatedEmail.replacingOccurrences(of: ".", with: "_")
        return String(safeEmail.lowercased())
    }
    
    @objc private func registerButtonTapped() {
        
        guard let enteredName = nameField.text, !enteredName.isEmpty, let email = emailField.text, !email.isEmpty, let password = passField.text, !password.isEmpty else {
            print("missing field data")
            return
        }
                
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            guard error == nil else {
                print("user creation failed")
                return
            }
            
            let newCode = self.createAddCode()
            
            let token = FirebaseMessaging.Messaging.messaging().fcmToken
            
            let newUser: [String: Any] = [
                "email": email,
                "addcode": newCode,
                "name": enteredName,
                "fcmToken": token
            ]
            
            let username = self.createSafeEmail(email: email)
            
            self.database.child("users/\(username)").setValue(newUser)

            self.defaults.set(username, forKey: "username")
            self.defaults.set(enteredName, forKey: "name")
            
            print("user \(username) created")
            
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
                guard error == nil else {
                    print("new user sign in failed")
                    return
                }
            })
            
            self.defaults.set(true, forKey: "complete")
            
            self.emailField.resignFirstResponder()
            self.passField.resignFirstResponder()
            
            let vc = ParentViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        })
    }

}

