//
//  FinalInfoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/28/20.
//

import UIKit

class FinalInfoVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    
    var finalPhone: String?
    var finalCode: String?
    var finalName: String?
    var finalBirthday: String?
   
    var isNameValid = false
    var fView = usernamePwdView()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupView()
        
    }
    
    func setupView() {
        
        fView.frame = CGRect(x: self.contentView.layer.bounds.minX + 16, y: self.contentView.layer.bounds.minY, width: self.contentView.layer.bounds.width - 32, height: self.contentView.layer.bounds.height)
        
        fView.usernameLbl.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        fView.pwdLbl.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        self.fView.userNameCheck.image = nil
        fView.usernameLbl.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.contentView.addSubview(fView)
        
        fView.usernameLbl.delegate = self
        fView.usernameLbl.keyboardType = .default
        fView.usernameLbl.becomeFirstResponder()
        
        
    }
    
    func checkAvailableName(name: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: name).getDocuments { (snap, err) in
   
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
        
            if snap?.isEmpty == true {
                
                self.isNameValid = true
                self.fView.userNameCheck.image = UIImage(named: "wtick")
                
            } else {
                
                self.isNameValid = false
                self.fView.userNameCheck.image = UIImage(named: "no")
                
            }
            
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        
        if let username = fView.usernameLbl.text, username != "" {
            
            checkAvailableName(name: username)
            
        } else {
            
            self.isNameValid = false
            self.fView.userNameCheck.image = nil
            
        }
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
