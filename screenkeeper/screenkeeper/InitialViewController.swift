import FirebaseAuth
import UIKit

class InitialViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    private let childButton: UIButton = {
        let childButton = UIButton()
        childButton.setTitle("I am a Child", for: .normal)
        childButton.backgroundColor = .systemOrange
        childButton.setTitleColor(.white, for: .normal)
        childButton.addTarget(self, action: #selector(childButtonTapped), for: .touchUpInside)
        return childButton
    }()
    
    private let parentButton: UIButton = {
        let parentButton = UIButton()
        parentButton.setTitle("I am a Parent", for: .normal)
        parentButton.backgroundColor = .systemOrange
        parentButton.setTitleColor(.white, for: .normal)
        parentButton.addTarget(self, action: #selector(parentButtonTapped), for: .touchUpInside)
        return parentButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.addSubview(childButton)
        view.addSubview(parentButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        
        childButton.frame = CGRect(x: 20, y: 100, width: width - 40, height: 40)
        parentButton.frame = CGRect(x: 20, y: childButton.frame.origin.y + childButton.frame.size.height + 10, width: width - 40, height: 40)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkSkipInitialHandler()
    }
    
    @objc private func childButtonTapped() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "isParent")
        print("defaults set: isParent - false")
        
        let vc = ChildSetupViewController()
        present(vc, animated: true)
    }
    
    @objc private func parentButtonTapped() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "isParent")
        print("defaults set: isParent - true")
        
        let vc = LoginViewController()
        present(vc, animated: true)
    }
    
    func checkSkipInitialHandler() {
        // check userdefaults if user fully initialized
        // put user in appropriate home screen. if child, put home screen. if parent, check if currentUser != nil and then put in
        if defaults.bool(forKey: "complete") {
            print("initalvc skipped")
            if (defaults.bool(forKey: "isParent")) {
                if FirebaseAuth.Auth.auth().currentUser != nil {
                    let vc = ParentViewController()
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: false)
                } else {
                    let vc = LoginViewController()
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: false)
                }
            } else {
                let vc = ChildViewController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: false)
            }
        } else {
        }
    }
    
}
