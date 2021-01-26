//
//  SettingVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/2/20.
//

import UIKit
import Firebase
import SafariServices

class SettingVC: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    var feature = ["Edit profile", "Account activity", "Report", "Term of Service", "About us", "Logout"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        tableView.reloadData()
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feature.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = feature[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell {
            
            if indexPath.row != 0 {
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.black
                cell.addSubview(line)
                
            }
            
           cell.configureCell(item)
            
            return cell
            
        } else {
            
            return SettingCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = feature[indexPath.row]
        
        if item == "Edit profile" {
            
            self.performSegue(withIdentifier: "moveToEditProfileVC", sender: nil)
            
        } else if item == "Account activity" {
            
            
            
            
            
        } else if item == "Report" {
            
            
            
            
        }  else if item == "Term of Service" {
            
            openTermOfService()
            
            
        } else if item == "About us" {
            
            openAboutUs()
            
            
        } else if item == "Logout" {
            
           
            try? Auth.auth().signOut()
            Auth.auth().signInAnonymously() { [self] (authResult, error) in
               
                if error != nil {
                    showErrorAlert("Oops!", msg: error!.localizedDescription)
                } else {
                    
                    
                    self.performSegue(withIdentifier: "moveToMainVC6", sender: nil)
                    
                }
            
            }
        
        }
        
    }
    
    func openTermOfService() {
        
        guard let urls = URL(string: "http://dual.so") else {
            return //be safe
        }
        
        let vc = SFSafariViewController(url: urls)
        
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func openAboutUs() {
        
        guard let urls = URL(string: "http://dual.so") else {
            return //be safe
        }
        
        let vc = SFSafariViewController(url: urls)
        
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
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
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
   
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
