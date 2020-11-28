//
//  HomePageVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/6/20.
//

import UIKit
import Firebase
import Alamofire

class HomePageVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabBar.barTintColor = .black
        tabBar.isTranslucent = false
        
        //try? Auth.auth().signOut()
        self.delegate = self

    }
 
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         
        check_condition()

    }
   
   
    
    func check_condition() {
        
        
        if let uid = Auth.auth().currentUser?.uid, uid != "" {
        
          
                 
        } else {
                 
                 
            try! Auth.auth().signOut()
            self.performSegue(withIdentifier: "moveToInterestedVC", sender: nil)
                
      
        }
        
    
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0, alreadyShow == true{
            
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
            
        }
        
    }

}
