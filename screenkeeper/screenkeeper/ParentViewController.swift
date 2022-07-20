import UIKit
import FirebaseDatabase
import Foundation

class ParentViewController: UIViewController {

    let defaults = UserDefaults.standard
    let database = Database.database().reference()
    
    private var childTime: Int = -1
    private var childUsername: String = "noname"
    
    let username = UserDefaults.standard.string(forKey: "username") ?? "noname"
            
    private let timerDisplay: UILabel = {
        let timerDisplay = UILabel()
        timerDisplay.backgroundColor = .white
        timerDisplay.textColor = .systemBlue
        timerDisplay.text = "-1"
        timerDisplay.textAlignment = .center
        return timerDisplay
    }()
    
    private let addTimeField: UITextField = {
        let addTimeField = UITextField()
        addTimeField.placeholder = "Time to Add"
        addTimeField.backgroundColor = .white
        addTimeField.autocapitalizationType = .none
        addTimeField.autocorrectionType = .no
        addTimeField.leftViewMode = .always
        addTimeField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return addTimeField
    }()
    
    private let addTimeButton: UIButton = {
        let addTimeButton = UIButton()
        addTimeButton.backgroundColor = .white
        addTimeButton.setTitleColor(.systemBlue, for: .normal)
        addTimeButton.setTitleColor(.systemMint, for: .highlighted)
        addTimeButton.setTitle("Add Time", for: .normal)
        addTimeButton.addTarget(self, action: #selector(addTimeButtonTapped), for: .touchUpInside)
        return addTimeButton
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // somehow moving this to the viewdidload worked?? for fixing the first click "noname" shit
        database.child("parent_users/\(username)/device0").observeSingleEvent(of: .value, with: { snapshot in
            /*self.defaults.set(snapshot.value as? String ?? "noname", forKey: "childUsername")
            print(self.defaults.string(forKey: "childUsername"))
             */
            
            self.childUsername = snapshot.value as? String ?? "noname"
        })
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue
        view.addSubview(timerDisplay)
        view.addSubview(addTimeField)
        view.addSubview(addTimeButton)
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        timerDisplay.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        addTimeField.frame = CGRect(x: width/2 - 150, y: timerDisplay.frame.origin.y + timerDisplay.frame.size.height + 10, width: 183, height: 50)
        addTimeButton.frame = CGRect(x: width/2 - 150 + 193, y: timerDisplay.frame.origin.y + timerDisplay.frame.size.height + 10, width: 107, height: 50)
    }

    override func viewDidAppear(_ animated: Bool) {
        
        database.child("parent_users/\(username)/device0").observeSingleEvent(of: .value, with: { snapshot in
            /*self.defaults.set(snapshot.value as? String ?? "noname", forKey: "childUsername")
            print(self.defaults.string(forKey: "childUsername"))
             */
            
            self.childUsername = snapshot.value as? String ?? "noname"
        
            var timeEnd = -1.0
            
            self.database.child("child_users/\(self.childUsername)/time_end").observe(.value, with: { [weak self] snapshot in
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
        })
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

    
    @objc private func addTimeButtonTapped() {
        
        database.child("parent_users/\(username)/device0").observeSingleEvent(of: .value, with: { snapshot in
            /*self.defaults.set(snapshot.value as? String ?? "noname", forKey: "childUsername")
            print(self.defaults.string(forKey: "childUsername"))
             */
            
            self.childUsername = snapshot.value as? String ?? "noname"
        
            // for some reason, childUsername is "" when outside this closure
            
            self.database.child("child_users/\(self.childUsername)/time_end").observeSingleEvent(of: .value, with: { snapshot in
                
                var oldEndTimer = snapshot.value as? Double ?? -1.0
                print(snapshot.value)
                print(Date())
                
                if oldEndTimer < self.dateToDouble(Date()) {
                    print("if statement true")
                    oldEndTimer = self.dateToDouble(Date())
                }
                
                print(oldEndTimer)
                
                // THIS HAD TO GO INSIDE!!! THINGS OUTSIDE THE CLOSURE RUN TOGETHER, FIRST!!!
                              
                let startTimer = oldEndTimer
                
                let endTimer = oldEndTimer + (Double(self.addTimeField.text ?? "0") ?? 0.0)
                                
                self.database.child("child_users/\(self.childUsername)/time_end").setValue(endTimer)
                
                // the new endTimerDate is becoming the amount of time from ten added to the oldTimerDate
                
            })
        })
    }
    
    func dateToDouble(_ date: Date) -> Double {
        return date.timeIntervalSince1970
    }
    
    func doubleToDate(_ double: Double) -> Date {
        return Date(timeIntervalSince1970: double)
    }

}
