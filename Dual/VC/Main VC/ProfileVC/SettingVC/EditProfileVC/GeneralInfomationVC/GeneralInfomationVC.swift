//
//  GeneralInfomationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/3/20.
//

import UIKit
import Firebase

class GeneralInfomationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var usernameLbl: UITextField!
    @IBOutlet weak var birthdayLbl: UITextField!
    @IBOutlet weak var usernameCheckImg: UIImageView!
    var isValid = false
    
    
    var datePicker = UIDatePicker()
    var updateID = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameLbl.delegate = self
        isValid = false
        loadProfile()
        
        usernameLbl.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }

    func loadProfile() {
        
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    for item in snapshot.documents {
                        
                        self.updateID = item.documentID
                    
                        if let username = item.data()["username"] as? String, let name = item.data()["name"] as? String {
                            
                            self.nameLbl.attributedPlaceholder = NSAttributedString(string: name,
                                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                            
                            self.usernameLbl.attributedPlaceholder = NSAttributedString(string: username,
                                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                            
                        }
                        
                        
                        if let birthday = item.data()["birthday"] as? String, birthday != "nil" {
                            
                            self.birthdayLbl.attributedPlaceholder = NSAttributedString(string: birthday,
                                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                            
                            
                        } else {
                            
                            
                            self.birthdayLbl.attributedPlaceholder = NSAttributedString(string: "Birthday (not set)",
                                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                            
                        }
                        
                    }
                
            }
            
        }
        
        
        
        
    }
    
    
    
    @IBAction func BirthdayBtnPressed(_ sender: Any) {
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -8, to: Date())
        birthdayLbl.inputView = datePicker
        datePicker.addTarget(self, action: #selector(DetailInfoVC.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "MM-dd-yyyy"
        birthdayLbl.text = dateFormatter.string(from: sender.date)

    }
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        
        if nameLbl.text != "" || usernameLbl.text != "" || birthdayLbl.text != "" {
            
            print("Updating")
            
            var updateData = [String: Any]()
            
            
            if usernameLbl.text != "", isValid == true {
                
                if isValid == true {
                    
                    updateData.updateValue(usernameLbl.text as Any, forKey: "username")
                    self.usernameLbl.attributedPlaceholder = NSAttributedString(string: usernameLbl.text!,
                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                    
                } else {
                    
                    showErrorAlert("Oops !", msg: "This username is not available")
                    return
                    
                }
                
               
                
            } 
            
            if nameLbl.text != "" {
                
                updateData.updateValue(nameLbl.text as Any, forKey: "name")
                self.nameLbl.attributedPlaceholder = NSAttributedString(string: nameLbl.text!,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                
            }
            
            
            if birthdayLbl.text != "" {
                
                updateData.updateValue(birthdayLbl.text as Any, forKey: "birthday")
                self.birthdayLbl.attributedPlaceholder = NSAttributedString(string: birthdayLbl.text!,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                
            }
            
            let db = DataService.instance.mainFireStoreRef.collection("Users")
            db.document(self.updateID).updateData(updateData) { (err) in
                
                if err != nil {
                    
                    self.showErrorAlert("Oops !", msg: err!.localizedDescription)
                    return
                }
                
                
                self.nameLbl.text = ""
                self.usernameLbl.text = ""
                self.birthdayLbl.text = ""
                self.isValid = false
                
                
                let alertController = UIAlertController(title: "Your information has been saved!", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            
        } else {
            
            showErrorAlert("Oops !", msg: "Can't find any change.")
            
            
        }
        
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        
        if let username = usernameLbl.text {
            
            if username != "" {
                
                checkAvailableName(name: username)
                
            } else {
                
                self.isValid = false
                self.usernameCheckImg.image = nil
            }
            
            
            
        }
        
    }
    
    func checkAvailableName(name: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: name).getDocuments { (snap, err) in
   
            if err != nil {
                
                print(err!.localizedDescription)
                self.isValid = false
                return
            }
        
            if snap?.isEmpty == true {
                
                self.isValid = true
                self.usernameCheckImg.image = UIImage(named: "wtick")
                
            } else {
                
                self.isValid = false
                self.usernameCheckImg.image = UIImage(named: "no")
                
            }
            
        }
        
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
    
}
