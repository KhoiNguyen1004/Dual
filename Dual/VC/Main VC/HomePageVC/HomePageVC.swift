//
//  HomePageVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/6/20.
//

import UIKit
import Firebase


class HomePageVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabBar.barTintColor = .black
        tabBar.isTranslucent = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    
        
        check_condition()
        
        
    }
    
    func check_condition() {
        
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
            print(uid)
                 
        } else {
                 
                 
            try! Auth.auth().signOut()
            self.performSegue(withIdentifier: "moveToInterestedVC", sender: nil)
                
      
        }
        
    
        
    }
    

}
