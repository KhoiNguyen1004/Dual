//
//  ChallengeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/27/20.
//

import UIKit
import Firebase

class ChallengeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser?.isAnonymous == true {
            
            print("Login anonymously")
            
            let Lview = LoginView()
            Lview.frame = self.view.layer.bounds
            Lview.SignUpBtn.addTarget(self, action: #selector(ChallengeVC.SignUpBtnPressed), for: .touchUpInside)
            self.view.addSubview(Lview)
            
            return
             
        }
        
        
    }
    
    @objc func SignUpBtnPressed() {
        
        self.performSegue(withIdentifier: "moveToLoginVC3", sender: nil)
        
    }



}
