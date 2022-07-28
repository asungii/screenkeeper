import UIKit
import FirebaseDatabase
import Foundation

class ParentViewController: UIViewController {

    let defaults = UserDefaults.standard
    let database = Database.database().reference()
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    private var childTime: Int = -1
    private var childUsername: String = "noname"
    
    private var timer = Timer()
    
    let username = UserDefaults.standard.string(forKey: "username") ?? "noname"
            
    private let timerDisplay: UILabel = {
        let timerDisplay = UILabel()
        timerDisplay.backgroundColor = .white
        timerDisplay.textColor = .systemBlue
        timerDisplay.text = "0"
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
                
        print(username)
        
        let center = view.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2*CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.orange.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 20
        trackLayer.lineCap = .round
        trackLayer.fillColor = UIColor.clear.cgColor
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue
        view.addSubview(timerDisplay)
        view.addSubview(addTimeField)
        view.addSubview(addTimeButton)
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
    }
    
    func triggerTimerRingAnimation(_ duration: Double) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = CFTimeInterval(duration) * 1.25 // i have no idea why this doesn't work right but it just needs to be *1.25 idk
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "basic")
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        timerDisplay.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        addTimeField.frame = CGRect(x: width/2 - 150, y: timerDisplay.frame.origin.y + timerDisplay.frame.size.height + 10, width: 183, height: 50)
        addTimeButton.frame = CGRect(x: width/2 - 150 + 193, y: timerDisplay.frame.origin.y + timerDisplay.frame.size.height + 10, width: 107, height: 50)
        
        trackLayer.bounds = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        trackLayer.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        shapeLayer.bounds = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        shapeLayer.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)

    }

    override func viewDidAppear(_ animated: Bool) {
        
        var endTime = -1.0
        
        database.child("users/\(username)/device0/time_end").observe(.value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            var timerDuration = 0
            
            endTime = snapshot.value as? Double ?? -1.0
            
            let endTimeDate = strongSelf.doubleToDate(endTime)
            let timeInterval = endTimeDate.timeIntervalSinceNow
            
            if endTimeDate < Date() {
                timerDuration = 0
            }
            
            strongSelf.triggerTimerRingAnimation(endTime - Date().timeIntervalSince1970)
            
            let childName = strongSelf.childUsername.dropLast(6)
            
            let content = UNMutableNotificationContent()
            content.title = "\(childName)'s screen time has expired!"
            content.body = "Tap here to check \(childName)'s status."
            
            strongSelf.queueNotification(content: content, triggerDate: endTimeDate)
            
        })
        // timer outside here, somehow get timeEnd variable out here
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            self.updateTimer(endTime)
            
            // issue is, timeEnd is static-- it doesn't change even when it changes in firebase.
        })
    }
    
    @objc private func timerAction() {
    }
    
    func updateTimer(_ endTime: Double) {
        let endTimeDate = doubleToDate(endTime)
        let timeInterval = endTimeDate.timeIntervalSinceNow
        
        if endTimeDate < Date() {
            timerDisplay.text = "0"
            return
        }
        
        let formatter = DateComponentsFormatter()
        
        timerDisplay.text = formatter.string(from: timeInterval)
    }
    
    @objc private func addTimeButtonTapped() {
                
        self.database.child("users/\(self.username)/device0/time_end").observeSingleEvent(of: .value, with: { snapshot in
            
            var oldEndTime = snapshot.value as? Double ?? -1.0
            
            // handling if time <= 0
            if oldEndTime < self.dateToDouble(Date()) {
                oldEndTime = self.dateToDouble(Date())
            }
            
            // finding end time
            let endTime = oldEndTime + (Double(self.addTimeField.text ?? "0") ?? 0.0)
                            
            // setting end time
            self.database.child("users/\(self.username)/device0/time_end").setValue(endTime)
            
            self.updateTimer(endTime)
            print("timer : \((endTime - Date().timeIntervalSince1970))")
        })
    }
    
    func queueNotification(content: UNNotificationContent, triggerDate: Date) {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.hour, .minute, .second], from: triggerDate as Date)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
               print("error when adding notification request")
           }
        }
    }
    
    func dateToDouble(_ date: Date) -> Double {
        return date.timeIntervalSince1970
    }
    
    func doubleToDate(_ double: Double) -> Date {
        return Date(timeIntervalSince1970: double)
    }

}
