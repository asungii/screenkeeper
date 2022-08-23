import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

class ChildSetupViewController: UIViewController {
    
    let database = Database.database().reference()
    let defaults = UserDefaults.standard
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Enter parent code here"
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
    
    private let parentEmailField: UITextField = {
        let parentEmailField = UITextField()
        parentEmailField.placeholder = "Parent Email"
        parentEmailField.backgroundColor = .white
        parentEmailField.autocapitalizationType = .none
        parentEmailField.autocorrectionType = .no
        parentEmailField.leftViewMode = .always
        parentEmailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return parentEmailField
    }()
    
    private let parentCodeField: UITextField = {
        let parentCodeField = UITextField()
        parentCodeField.placeholder = "Parent Code"
        parentCodeField.backgroundColor = .white
        parentCodeField.autocapitalizationType = .none
        parentCodeField.autocorrectionType = .no
        parentCodeField.leftViewMode = .always
        parentCodeField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return parentCodeField
    }()
    
    private let continueButton: UIButton = {
        let continueButton = UIButton()
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .systemOrange
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return continueButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        view.addSubview(label)
        view.addSubview(nameField)
        view.addSubview(parentEmailField)
        view.addSubview(parentCodeField)
        view.addSubview(continueButton)
    
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        
        label.frame = CGRect(x: 20, y: 100, width: width - 40, height: 40)
        nameField.frame = CGRect(x: 20, y: label.frame.origin.y + label.frame.size.height + 10, width: width - 40, height: 40)

        parentEmailField.frame = CGRect(x: 20, y: nameField.frame.origin.y + nameField.frame.size.height + 10, width: width - 40, height: 40)
        parentCodeField.frame = CGRect(x: 20, y: parentEmailField.frame.origin.y + parentEmailField.frame.size.height + 10, width: width - 40, height: 40)
        continueButton.frame = CGRect(x: 20, y: parentCodeField.frame.origin.y + parentCodeField.frame.size.height + 10, width: width - 40, height: 40)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        nameField.becomeFirstResponder()
    }
    
    @objc private func continueButtonTapped() {
        // check firebase for link code
        // add UUID to parent associated with link code
        guard let parentCode = parentCodeField.text, !parentCode.isEmpty, let parentEmail = parentEmailField.text, !parentEmail.isEmpty, let enteredName = nameField.text, !enteredName.isEmpty else {
            print("parent code field empty")
            return
        }
        
        let parentUsername = createSafeEmail(email: parentEmail)
        let childUsername = enteredName + createCode()
        
        defaults.set(childUsername, forKey: "childUsername")
        defaults.set(enteredName, forKey: "name")
        defaults.set(parentUsername, forKey: "parentUsername")
        
        database.child("users/\(parentUsername)").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            let value = snapshot.value as? NSDictionary
            let addcode = value?["addcode"] as? String ?? ""
            
            guard addcode == parentCode else {
                print("addcode incorrect")
                return
            }
                        
            strongSelf.database.child("users/\(parentUsername)").observeSingleEvent(of: .value, with: { snapshot in
                let count = snapshot.childrenCount - 5 // THIS IS NUMBER OF NONDEVICE ITEMS IN PARENT USER
                let token = FirebaseMessaging.Messaging.messaging().fcmToken

                strongSelf.database.child("users/\(parentUsername)/device\(count)/username").setValue(childUsername)
                strongSelf.database.child("users/\(parentUsername)/device\(count)/name").setValue(enteredName)
                strongSelf.database.child("users/\(parentUsername)/device\(count)/time_end").setValue(0)
                strongSelf.database.child("users/\(parentUsername)/device\(count)/time_over").setValue(false)
                strongSelf.database.child("users/\(parentUsername)/device\(count)/fcmToken").setValue(token)
            })
                        
            print("device connection successful")
            
            strongSelf.defaults.set(true, forKey: "complete")
            
            strongSelf.nameField.resignFirstResponder()
            strongSelf.parentEmailField.resignFirstResponder()
            strongSelf.parentCodeField.resignFirstResponder()
            
            let vc = ChildViewController()
            vc.modalPresentationStyle = .fullScreen
            strongSelf.present(vc, animated: true)
            
        })
         
    }
    
    func createSafeEmail(email: String) -> String {
        let index = email.firstIndex(of: "@") ?? email.endIndex
        let truncatedEmail = email[..<index]
        let safeEmail = truncatedEmail.replacingOccurrences(of: ".", with: "_")
        return String(safeEmail.lowercased())
    }
    
    func createCode() -> String {
        let baseIntA = Int(arc4random() % 65535)
        let str = String(format: "%06X", baseIntA)
        return String("\(str)")
    }
    
}
