import UIKit
import FirebaseDatabase

class ChildViewController: UIViewController {

    let defaults = UserDefaults.standard
    let database = Database.database().reference()
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    let childUsername = UserDefaults.standard.string(forKey: "childUsername") ?? "noname"
    let parentUsername = UserDefaults.standard.string(forKey: "parentUsername") ?? "noname"
    
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
        view.backgroundColor = .systemRed
        view.addSubview(timerDisplay)
        view.addSubview(checkButton)
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
        checkButton.frame = CGRect(x: width/2 - 150, y: timerDisplay.frame.origin.y + timerDisplay.frame.size.height + 10, width: 300, height: 50)
        trackLayer.bounds = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        trackLayer.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        shapeLayer.bounds = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
        shapeLayer.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 300)
    }

    override func viewDidAppear(_ animated: Bool) {
                
        var endTime = -1.0
        
        database.child("users/\(parentUsername)/device0/time_end").observe(.value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            endTime = snapshot.value as? Double ?? -1.0
            
            let endTimeDate = strongSelf.doubleToDate(endTime)
            
            strongSelf.triggerTimerRingAnimation(endTime - Date().timeIntervalSince1970)
        })
        // timer outside here, somehow get timeEnd variable out here
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            self.updateTimer(endTime)
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
            self.database.child("users/\(self.parentUsername)/device0/time_over").setValue(true)
            return
        }
        
        let formatter = DateComponentsFormatter()
        
        timerDisplay.text = formatter.string(from: timeInterval)
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
