import UIKit

class UserClassificationViewController: UIViewController {
    
    private let parentButton: UIButton = {
        let parentButton = UIButton()
        parentButton.backgroundColor = .white
        parentButton.setTitle("I am a Parent", for: .normal)
        parentButton.setTitleColor(.black, for: .normal)
        
        parentButton.setTitleColor(.systemBlue, for: .highlighted)
        parentButton.addTarget(self, action: #selector(parentButtonClicked), for: .touchUpInside)
        return parentButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue
        view.addSubview(parentButton)
        parentButton.frame = CGRect(x: width/2 - 150, y: height/2 - 150, width: 300, height: 100)
    }
    
    @objc func parentButtonClicked(sender: UIButton!) {
        /*
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "ParentViewController") as! ParentViewController
        self.navigationController?.pushViewController(newVC, animated: true)
        */
        
        let newVC = ParentViewController()
        show(newVC, sender: self)
        
        print("parent button clicked")
    }
}

