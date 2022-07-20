import UIKit
import FirebaseDatabase

class ChildViewController: UIViewController {

    let defaults = UserDefaults.standard
    let database = Database.database().reference()
    
    let childUsername = UserDefaults.standard.string(forKey: "username") ?? "noname"
    
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
                
        var timeEnd = -1.0
        
        self.database.child("child_users/\(childUsername)/time_end").observe(.value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            timeEnd = snapshot.value as? Double ?? -1.0

        })
        // timer outside here, somehow get timeEnd variable out here
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            self.updateTimer(timeEnd)
            // issue is, timeEnd is static-- it doesn't change even when it changes in firebase.
        })
    }
    
    @objc private func checkButtonClicked() {
        
        print("checkButtonClicked tapped")
        
    }
    
    @objc private func timerAction() {
    }
    
    func updateTimer(_ timeEnd: Double) {
        let timeEndDate = doubleToDate(timeEnd)
        let timeInterval = timeEndDate.timeIntervalSinceNow
        
        if timeEndDate < Date() {
            timerDisplay.text = "0"
            return
        }
        
        timerDisplay.text = String(Int(round(timeInterval)))
    }
    
    func dateToDouble(_ date: Date) -> Double {
        return date.timeIntervalSince1970
    }
    
    func doubleToDate(_ double: Double) -> Date {
        return Date(timeIntervalSince1970: double)
    }
    
}
