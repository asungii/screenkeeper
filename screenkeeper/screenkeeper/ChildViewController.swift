import UIKit
import FirebaseDatabase

class ChildViewController: UIViewController {

    let defaults = UserDefaults.standard
    let database = Database.database().reference()
    
    var timer = Timer()
        
    private let timerDisplay: UILabel = {
        let timerDisplay = UILabel()
        timerDisplay.backgroundColor = .white
        timerDisplay.textColor = .systemRed
        timerDisplay.text = "0"
        timerDisplay.textAlignment = .center
        return timerDisplay
    }()
    
    private let checkButton: UIButton = {
        let checkButton = UIButton()
        checkButton.backgroundColor = .white
        checkButton.setTitleColor(.systemRed, for: .normal)
        checkButton.setTitleColor(.systemMint, for: .highlighted)
        checkButton.setTitle("test", for: .normal)
        checkButton.addTarget(self, action: #selector(checkButtonClicked), for: .touchUpInside)
        return checkButton
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemRed
        view.addSubview(timerDisplay)
        view.addSubview(checkButton)
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        timerDisplay.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        checkButton.frame = CGRect(x: width/2 - 150, y: timerDisplay.frame.origin.y + timerDisplay.frame.size.height + 10, width: 300, height: 50)
    }

    override func viewDidAppear(_ animated: Bool) {
        let username = defaults.string(forKey: "username") ?? "noname"
        
        print(username)
        
        database.child("child_users/\(username)/time").observe(.value, with: { [self] snapshot in
            
            let time = snapshot.value as? Int ?? -1

            print(time)
            print("time changed")
            
            self.updateTimer(time)
        })
    }
    
    @objc private func checkButtonClicked() {
        
        print("checkButtonClicked tapped")
        
    }
    
    @objc private func timerAction() {
    }
    
    func updateTimer(_ newTime: Int) {
        timerDisplay.text = String(newTime)
    }
}
