//
//  NormalLoginVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/26/20.
//

import UIKit
import Firebase
import Alamofire

class NormalLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    
    var phoneBook = [PhoneBookModel]()

    var finalPhone: String?
    var finalCode: String?
    
    
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    var usernameBorder = CALayer()
    var phoneBtnBorder = CALayer()
    var Pview = PhoneView()
    var Uview = userNameView()
    var dayPicker = UIPickerView()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        

        phoneBtn.setTitleColor(UIColor.white, for: .normal)
        usernameBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
       
        
        loadPhoneBook()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        phoneBtnBorder = phoneBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0)
        usernameBorder = usernameBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0)
        phoneBtn.layer.addSublayer(phoneBtnBorder)
        
        
        setUpPhoneView()
    }
    
    
    func setUpPhoneView() {
        
        Pview.frame = self.ContentView.layer.bounds
        self.ContentView.addSubview(Pview)
        
        Pview.areaCodeBtn.attributedPlaceholder = NSAttributedString(string: "Code",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Pview.PhoneNumberLbl.attributedPlaceholder = NSAttributedString(string: "Phone number",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        // btn
        
        Pview.areaCodeBtn.addTarget(self, action: #selector(NormalLoginVC.openPhoneBookBtnPressed), for: .editingDidBegin)
        Pview.GetCodeBtn.addTarget(self, action: #selector(NormalLoginVC.getCodeBtnPressed), for: .touchUpInside)
        
        Pview.PhoneNumberLbl.delegate = self
        Pview.PhoneNumberLbl.keyboardType = .numberPad
        Pview.PhoneNumberLbl.becomeFirstResponder()
        
        
    }
    
    @objc func getCodeBtnPressed() {
        
        if let phone = Pview.PhoneNumberLbl.text, phone != "", phone.count >= 7, let code = Pview.areaCodeBtn.text, code != "" {
                
            sendPhoneVerfication(phone: phone, countryCode: code)
            
        }
       
        
    }
    
    @objc func openPhoneBookBtnPressed() {
        
        createDayPicker()
        
    }
    
    func setUpUsernameView() {
        
        Uview.frame = CGRect(x: self.ContentView.layer.bounds.minX , y: self.ContentView.layer.bounds.minY + 15, width: self.ContentView.layer.bounds.width, height: self.ContentView.layer.bounds.height)
        
        self.ContentView.addSubview(Uview)
       
        Uview.usernameLbl.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        Uview.passwordLbl.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Uview.NextBtn.addTarget(self, action: #selector(NormalLoginVC.userNameBtnPressed), for: .touchUpInside)
        
        
        Uview.usernameLbl.delegate = self
        Uview.usernameLbl.keyboardType = .default
        
        Uview.passwordLbl.delegate = self
        Uview.passwordLbl.keyboardType = .default
        Uview.passwordLbl.isHidden = false
        
        
        Uview.usernameLbl.becomeFirstResponder()
        
        
    }
    
    @objc func userNameBtnPressed() {
        
        if let username = Uview.usernameLbl.text, username != "", let pwd = Uview.passwordLbl.text, pwd != "", pwd.count >= 5 {
            
            
            swiftLoader()
            
            DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: username).getDocuments { (snap, err) in
                
                if err != nil {
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                    return
                }
                
                if snap?.isEmpty == true {
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: "It seems like your username isn't signed up yet, let's continue using phone number to create your account.")
                    return
                }
                
                for item in snap!.documents {
           
                    let i = item.data()
                    
                    if let encryptedKey = i["encryptedKey"] as? String {
                        
                        let encryptedRandomEmail = "\(encryptedKey)@credential-dual.so"
                        
                        Auth.auth().signIn(withEmail: encryptedRandomEmail, password: pwd) { (result, error) in
                            
                            if error != nil {
                                
                                SwiftLoader.hide()
                                self.showErrorAlert("Opss !", msg: error!.localizedDescription)
                                return
                                
                            }
                            
                            SwiftLoader.hide()
                            self.performSegue(withIdentifier: "moveToMainVC5", sender: nil)
                            
                        }
                        
                        
                    }
                    
                }
                
                
            }
            
            
        }
        
    }
   
    
    @IBAction func phoneBtnPressed(_ sender: Any) {
        
        
        Uview.removeFromSuperview()
        setUpPhoneView()
        
        usernameBorder.removeFromSuperlayer()
        phoneBtn.layer.addSublayer(phoneBtnBorder)
        phoneBtn.setTitleColor(UIColor.white, for: .normal)
        usernameBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    
    @IBAction func usernameBtnPressed(_ sender: Any) {
        
        
        Pview.removeFromSuperview()
        setUpUsernameView()

        phoneBtnBorder.removeFromSuperlayer()
        usernameBtn.layer.addSublayer(usernameBorder)
        phoneBtn.setTitleColor(UIColor.lightGray, for: .normal)
        usernameBtn.setTitleColor(UIColor.white, for: .normal)
        
    }
    
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func loadPhoneBook() {
        
        DataService.instance.mainFireStoreRef.collection("Global phone book").order(by: "country", descending: false).getDocuments { [self] (snap, err) in
   
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
        
            for item in snap!.documents {
                
            
                let i = item.data()
                
                let item  = PhoneBookModel(postKey: item.documentID, phone_model: i)
                
                self.phoneBook.append(item)
                
                
            }
            
            self.dayPicker.delegate = self
            
        }
        
        
        
    }
    
    func createDayPicker() {

        Pview.areaCodeBtn.inputView = dayPicker

    }
    
    func sendPhoneVerfication(phone: String, countryCode: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("start")
        
        swiftLoader()
        
        AF.request(urls!, method: .post, parameters: [
            
            "phone": phone,
            "countryCode": countryCode,
            "via": "sms"
            
        ])
        .validate(statusCode: 200..<500)
        .responseJSON { responseJSON in
            
            switch responseJSON.result {
                
            case .success( _):
                SwiftLoader.hide()
                self.finalPhone = phone
                self.finalCode = countryCode
                self.performSegue(withIdentifier: "moveToPhoneVeriVC", sender: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops !", msg: error.localizedDescription)
                
            }
            
        }
    }
    
    // prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToPhoneVeriVC"{
            if let destination = segue.destination as? PhoneVerficationVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
               
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

extension NormalLoginVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return phoneBook.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = UIColor.darkGray
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
        }
        if let code = phoneBook[row].code, let country = phoneBook[row].country {
            pickerLabel?.text = "\(country)            +\(code)"
        } else {
            pickerLabel?.text = "Error loading"
        }
     
        pickerLabel?.textColor = UIColor.white

        return pickerLabel!
    }
    
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        
        if let code = phoneBook[row].code {
            
            Pview.areaCodeBtn.text = "+\(code)"
            
        }
    
        
    }
    
}
