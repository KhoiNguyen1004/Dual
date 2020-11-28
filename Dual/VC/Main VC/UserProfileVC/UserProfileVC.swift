//
//  UserProfileVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/24/20.
//

import UIKit

class UserProfileVC: UIViewController {
    
    var isFeed: Bool!
    var uid: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if uid != nil {
            
            loadUserProfile(uid: uid)
            
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isFeed == true {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        }

        
    }
    
    func loadUserProfile(uid: String) {
        
        
    }
    

    
}
