import UIKit
import FirebaseDatabase
import Foundation

class ParentViewController: UIViewController {

    let defaults = UserDefaults.standard
    let database = Database.database().reference()
    
    private var childTime: Int = -1
    private var childUsername: String = "noname"
    
    let username = UserDefaults.standard.string(forKey: "username") ?? "noname"
    
    var timer = Timer()
        
    private let timerDisplay: UILabel = {
        let timerDisplay = UILabel()
        timerDisplay.backgroundColor = .white
        timerDisplay.textColor = .systemBlue
        timerDisplay.text = "0"
        timerDisplay.textAlignment = .center
        return timerDisplay
    }()
    
    private let addTimeButton: UIButton = {
        let addTimeButton = UIButton()
        addTimeButton.backgroundColor = .white
        addTimeButton.setTitleColor(.systemBlue, for: .normal)
        addTimeButton.setTitleColor(.systemMint, for: .highlighted)
        addTimeButton.setTitle("add time, 10 secs", for: .normal)
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
        view.addSubview(addTimeButton)
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        timerDisplay.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        addTimeButton.frame = CGRect(x: width/2 - 150, y: timerDisplay.frame.origin.y + timerDisplay.frame.size.height + 10, width: 300, height: 50)
    }

    override func viewDidAppear(_ animated: Bool) {
        
        database.child("parent_users/\(username)/device0").observeSingleEvent(of: .value, with: { snapshot in
            /*self.defaults.set(snapshot.value as? String ?? "noname", forKey: "childUsername")
            print(self.defaults.string(forKey: "childUsername"))
             */
            
            self.childUsername = snapshot.value as? String ?? "noname"
        
            self.database.child("child_users/\(self.childUsername)/time_end").observe(.value, with: { [weak self] snapshot in
                guard let strongSelf = self else {
                    return
                }
                
                let time = snapshot.value as? Int ?? -1

                print(time)
                print("time changed")
                
                strongSelf.updateTimer(time)
            })
        })
    }
    
    @objc private func timerAction() {
    }
    
    func updateTimer(_ newTime: Int) {
        timerDisplay.text = String(newTime)
    }

    
    @objc private func addTimeButtonTapped() {
        
        database.child("parent_users/\(username)/device0").observeSingleEvent(of: .value, with: { snapshot in
            /*self.defaults.set(snapshot.value as? String ?? "noname", forKey: "childUsername")
            print(self.defaults.string(forKey: "childUsername"))
             */
            
            self.childUsername = snapshot.value as? String ?? "noname"
            
            print(self.childUsername)
            print(self.childTime)
            // for some reason, childUsername is "" when outside this closure
            
            self.database.child("child_users/\(self.childUsername)/time_end").observeSingleEvent(of: .value, with: { snapshot in
                print("child_users/\(self.childUsername)/time_end")
                print(snapshot.value)
                self.oldchildEndTime = snapshot.value as? Int ?? -1
                
                // THIS HAD TO GO INSIDE!!! THINGS OUTSIDE THE CLOSURE RUN TOGETHER, FIRST!!!
                              
                let startTimerDate = Date()
                
                let endTimerDate = startTimerDate.addingTimeInterval(10)
                
                self.database.child("child_users/\(self.childUsername)/time_end").setValue(endTimerDate)
                
            })
        })
    }

}
