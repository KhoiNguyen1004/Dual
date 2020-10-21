//
//  VideoInformationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/18/20.
//

import UIKit

class VideoInformationVC: UIViewController {

    @IBOutlet weak var titleLbl: UITextField!
    @IBOutlet weak var creatorLinkLbl: UITextField!
    @IBOutlet weak var isComment: UISwitch!
    
    
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var FriendsBtn: UIButton!
    @IBOutlet weak var OnlyMeBtn: UIButton!
    
    
    var mode: String!
    var comment_allow: Bool!
    var selectedItem: HighlightsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        titleLbl.borderStyle = .none
        creatorLinkLbl.borderStyle = .none
        
        
        
        if selectedItem.highlight_title != "nil" {
            
            titleLbl.placeholder = selectedItem.highlight_title
            
        }
        
        
        if selectedItem.stream_link != "nil" {
            
            creatorLinkLbl.placeholder = selectedItem.stream_link
            
        }
        
        
        if selectedItem.Allow_comment == true {
            
            isComment.setOn(true, animated: true)
            
        } else{
            
            isComment.setOn(false, animated: true)
            
        }
        
        
        if selectedItem.mode == "Public" {
            
            publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
            FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
            OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
            
            
        } else if selectedItem.mode == "Friends" {
            
            FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
            publicBtn.setImage(UIImage(named: "public"), for: .normal)
            OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
            
            
        } else if selectedItem.mode == "Only me" {
            
            OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
            FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
            publicBtn.setImage(UIImage(named: "public"), for: .normal)
                   
        }
        
        
        
    }
    
    @IBAction func isCommentBtnPressed(_ sender: Any) {
        
        if comment_allow == true {
            
            
            comment_allow =  false
            isComment.setOn(false, animated: true)
            
            
            
            
        } else if comment_allow == false {
            
            comment_allow = true
            isComment.setOn(true, animated: true)
            
           
            
        } else {
            
            
            if selectedItem.Allow_comment == true {
                
                comment_allow =  false
                isComment.setOn(false, animated: true)
                
                
            } else {
                
                
                comment_allow = true
                isComment.setOn(true, animated: true)
                
                
            }
            
            
        }
        
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        
        
        if titleLbl.text != "" || creatorLinkLbl.text != "" || mode != nil || comment_allow != nil {
            
            print("Updating")
            
            var updateData = [String: Any]()
            
            if titleLbl.text != "" {
                
                updateData.updateValue(titleLbl.text!, forKey: "highlight_title")
                
            }
            
            if creatorLinkLbl.text != "" {
                
                updateData.updateValue(creatorLinkLbl.text!, forKey: "stream_link")
                
            }
            
            if self.mode != nil {
                
                updateData.updateValue(self.mode!, forKey: "mode")
                
            }
            
            if self.comment_allow != nil {

                updateData.updateValue(self.comment_allow!, forKey: "Allow_comment")
                
            }
            
            let db = DataService.instance.mainFireStoreRef.collection("Highlights")
            db.document(selectedItem.highlight_id).updateData(updateData)
            
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
            
            
        } else {
            
            print("Nothing changes")
            
        }
        
        
        
    }
    
    
    // mode choose
    
    @IBAction func PublicBtnPressed(_ sender: Any) {
        
        publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
        
        mode = "Public"
    }
    
    
    @IBAction func FriendsBtnPressed(_ sender: Any) {
        
        FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
        
        mode = "Friends"
        
    }
    
    @IBAction func OnlyMeBtnPressed(_ sender: Any) {
        
        OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        
        mode = "Only me"
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    
    }
    
}
