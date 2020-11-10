//
//  FinalInfoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/28/20.
//

import UIKit
import Firebase
import SwiftPublicIP
import Alamofire

class FinalInfoVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    
    
    var avatarUrl: String?
    var finalPhone: String?
    var finalCode: String?
    var finalName: String?
    var finalBirthday: String?
    var Create_mode: String?
    var keyId: String?
    
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
        fView.nextBtn.addTarget(self, action: #selector(FinalInfoVC.NextBtnPressed), for: .touchUpInside)
       
        
        self.contentView.addSubview(fView)
        
        fView.usernameLbl.delegate = self
        fView.usernameLbl.keyboardType = .default
        fView.usernameLbl.becomeFirstResponder()
        
        
    }
    
    func checkAvailableName(name: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: name).getDocuments { (snap, err) in
   
            if err != nil {
                
                print(err!.localizedDescription)
                self.isNameValid = false
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
            
            
            if username != "" {
                
                checkAvailableName(name: username)
                
            } else {
                
                self.isNameValid = false
                self.fView.userNameCheck.image = nil
                
            }
            
            
            
        }
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        

    }
    
    
    @objc func NextBtnPressed() {
        
        if let username = fView.usernameLbl.text, username != "", isNameValid == true, let pwd = fView.pwdLbl.text, pwd != "", pwd.count >= 5 {
            
            var encryptedRandomEmail = ""
            var finalID = ""
            
            if let id = Auth.auth().currentUser?.uid {
                
                swiftLoader()
                
                let randomInt = Int.random(in: 0..<3)
                
                if randomInt == 0 {
                    
                    finalID = "RuiDUALCTOLOGINDEFAULT\(id)S100497SUN"
                    
                } else if randomInt == 1 {
                    
                    finalID = "ShAnnaDUALCTOLOGINDEFAULT\(id)S100497Julati"
                    
                } else  {
                    
                    finalID = "KhoiDUALLOGINCEODEFAULT\(id)S100497Nguyen"
                    
                }
                
                if avatarUrl == nil {
                    avatarUrl = "nil"
                }
     
                encryptedRandomEmail = "\(finalID)@credential-dual.so"
                
                let authCredential =  EmailAuthProvider.credential(withEmail: encryptedRandomEmail, password: pwd)
               
                Auth.auth().currentUser?.link(with: authCredential, completion: { (result, err) in
                    
                    if err != nil {
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops !", msg: err!.localizedDescription)
                        return
                    }

                    let device = UIDevice().type.rawValue
                 
                    var userInfomation = ["phone": self.finalPhone as Any, "code": self.finalCode as Any, "name": self.finalName as Any, "birthday": self.finalBirthday as Any, "create_time": FieldValue.serverTimestamp(), "username": username, "avatarUrl": self.avatarUrl as Any, "Email": "nil", "account_verified": false, "userUID": Auth.auth().currentUser!.uid, "email_verified": false, "encryptedKey": finalID, "Create_mode": self.Create_mode as Any, "Device": device]
                    
                    if let mode = self.Create_mode, let lKey = self.keyId {
                        
                        let loginKey = lKey
                        userInfomation.updateValue(loginKey, forKey: "\(mode)_id")
                        
                    }
                    
                    let user_sensitive_information = ["password": pwd, "secret_key": finalID, "create_time": FieldValue.serverTimestamp()] as [String : Any]
         
                    print("Writing user information to database")
                      
                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let string = string {
                            
                            
                            let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(string)
                            
                            
                            AF.request(urls, method: .get)
                                .validate(statusCode: 200..<500)
                                .responseJSON { responseJSON in
                                    
                                    switch responseJSON.result {
                                        
                                    case .success(let json):
                                        
                                        if let dict = json as? Dictionary<String, Any> {
                                            
                                            if let status = dict["status"] as? String, status == "success" {
                                                
                                                userInfomation.merge(dict: dict)
                                                self.writeToDb(userInfomation: userInfomation, user_sensitive_information: user_sensitive_information)
                                                
                                            } else {
                                                
                                                print("Fail to get IP")
                                                self.writeToDb(userInfomation: userInfomation, user_sensitive_information: user_sensitive_information)
                                                
                                            }
                                            
                                            
                                        }
                                        
                                    case .failure(let error):
                                        
                                        
                                        print(error.localizedDescription)
                                        self.writeToDb(userInfomation: userInfomation, user_sensitive_information: user_sensitive_information)
                                        
                                        
                                    }
                                    
                                }
                           
                        }
                    }
                             
                })
                         
            }
                
            
        } else {
            
            showErrorAlert("Oops !", msg: "There is something wrong with your provided information, please try again")
            
            
        }
        
        
    }
    
    
    func writeToDb(userInfomation: [String: Any], user_sensitive_information: [String:Any]) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Users")
        
        db.addDocument(data: userInfomation) { (error) in
            
            
            if error != nil {
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops !", msg: error!.localizedDescription)
                return
                
            }
            
            DataService.instance.mainFireStoreRef.collection("Pwd_users").addDocument(data: user_sensitive_information)
            SwiftLoader.hide()
            print("Finished writting")
            self.performSegue(withIdentifier: "moveToMainVC2", sender: nil)
            
        }
        
        
    }
    
}
