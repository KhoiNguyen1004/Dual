//
//  MessageVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 2/4/21.
//

import UIKit

class MessageVC: UIViewController {
    
    
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var friendBtn: UIButton!
    
    
    var challengeBorder = CALayer()
    var friendBorder = CALayer()
    
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Messages"
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = add
        
        
        
        //
        
        challengeBtn.setTitleColor(UIColor.white, for: .normal)
        friendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        challengeBorder = challengeBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0)
        friendBorder = friendBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0)
        
        
        challengeBtn.layer.addSublayer(challengeBorder)
        
        
        
    }
    
    
    @objc func addTapped() {
        
        print("Tapped")
        
    }
    
    @IBAction func challengeBtnPressed(_ sender: Any) {
        
        
        friendBorder.removeFromSuperlayer()
        challengeBtn.layer.addSublayer(challengeBorder)
        challengeBtn.setTitleColor(UIColor.white, for: .normal)
        friendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    @IBAction func friendBtnPressed(_ sender: Any) {
        
        
        challengeBorder.removeFromSuperlayer()
        friendBtn.layer.addSublayer(friendBorder)
        challengeBtn.setTitleColor(UIColor.lightGray, for: .normal)
        friendBtn.setTitleColor(UIColor.white, for: .normal)
        
    }
    
}
