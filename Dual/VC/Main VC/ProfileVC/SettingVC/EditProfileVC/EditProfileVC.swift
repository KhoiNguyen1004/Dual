//
//  EditProfileVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/3/20.
//

import UIKit

class EditProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var feature = ["General information", "Email address", "Phone number", "Password"]
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell") as? EditProfileCell {
            
            if indexPath.row != 0 {
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.black
                cell.addSubview(line)
                
            }
            
           cell.configureCell(item)
            
            return cell
            
        } else {
            
            return EditProfileCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = feature[indexPath.row]
        
        if item == "General information" {
            
            self.performSegue(withIdentifier: "moveToGeneralInfomationVC", sender: nil)
            
        } else if item == "Email address" {
            
            self.performSegue(withIdentifier: "moveToChangeEmailVC", sender: nil)
            
        } else if item == "Phone number" {
            
            self.performSegue(withIdentifier: "moveToChangePhoneVC", sender: nil)
            
            
        } else if item == "Password" {
            
            self.performSegue(withIdentifier: "moveToChangePwdVC", sender: nil)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
}
