//
//  CommentNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/5/21.
//

import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase




fileprivate let FontSize: CGFloat = 12
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10


class CommentNode: ASCellNode {
    
    var post: CommentModel
    
    var userNameNode: ASTextNode!
    var CmtNode: ASTextNode!
    var imageView: ASImageNode!
    var AvatarNode: ASNetworkImageNode!
    var textNode: ASTextNode!
    var replyBtnNode: ASButtonNode!
    var InfoNode: ASDisplayNode!
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    var reply : ((ASCellNode) -> Void)?
    
    var like : ((ASCellNode) -> Void)?
    
    init(with post: CommentModel) {
        
        self.post = post
        self.userNameNode = ASTextNode()
        self.CmtNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.replyBtnNode = ASButtonNode()
        self.InfoNode = ASDisplayNode()
        self.imageView = ASImageNode()
        self.textNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor(red: 43, green: 43, blue: 43)
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        
        
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        CmtNode.isLayerBacked = true
        
   
        if self.post.reply_to != "" {
            
            DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: self.post.reply_to!).getDocuments {  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    for item in snapshot.documents {
                        
                        let paragraphStyles = NSMutableParagraphStyle()
                        paragraphStyles.alignment = .left
                    
                        if let username = item.data()["username"] as? String {
                            
                        
                           let username = "@\(username)"
                            
                           
                            if self.post.timeStamp != nil {
                                
                                
                                let date = self.post.timeStamp.dateValue()
                                
                                let usernameAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                                
                                let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                                let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                                
                                
                                let user = NSMutableAttributedString(string: "\(username): ", attributes: usernameAttributes)
                                
                                let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
                                let time = NSAttributedString(string: " \(timeAgoSinceDate(date, numericDates: true))", attributes: timeAttributes)
                                user.append(text)
                                user.append(time)
                                
                                self.CmtNode.attributedText = user
                                
                            } else {
                                
                                let usernameAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                                
                                
                                let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                                let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                                
                                
                                let user = NSMutableAttributedString(string: "\(username): ", attributes: usernameAttributes)
                                
                                let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
                                let time = NSAttributedString(string: " Just now", attributes: timeAttributes)
                                user.append(text)
                                user.append(time)
                                
                                self.CmtNode.attributedText = user
                                
                            }
                            
                            
                            
                        }
                        
                    }
                
            }
            
            
        } else {
            
            
            if self.post.timeStamp != nil {
                
                
                let date = self.post.timeStamp.dateValue()
                
                
                let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                
                let text = NSMutableAttributedString(string: self.post.text, attributes: textAttributes)
                let time = NSAttributedString(string: " \(timeAgoSinceDate(date, numericDates: true))", attributes: timeAttributes)
                text.append(time)
                
                CmtNode.attributedText = text
                
            } else {
                
                
                let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                
                let text = NSMutableAttributedString(string: self.post.text, attributes: textAttributes)
                let time = NSAttributedString(string: " Just now", attributes: timeAttributes)
                text.append(time)
                
                CmtNode.attributedText = text
                
            }
            
        }
        
    
        
        InfoNode.backgroundColor = UIColor.clear
        
        replyBtnNode.backgroundColor = UIColor.clear
        CmtNode.backgroundColor = UIColor.clear
        userNameNode.backgroundColor = UIColor.clear
        
        
       
        
       
        
        
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 5, y: 2, width: 20, height: 20)
    
        
    
        textNode.isLayerBacked = true
    
        textNode.backgroundColor = UIColor.clear
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
                                                     
        textNode.frame = CGRect(x: 0, y: 30, width: 30, height: 20)
       
        
        let button = ASButtonNode()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 60)
        button.backgroundColor = UIColor.clear
        
        
        InfoNode.addSubnode(imageView)
        InfoNode.addSubnode(textNode)
        InfoNode.addSubnode(button)
   
        button.addTarget(self, action: #selector(CommentNode.LikedBtnPressed), forControlEvents: .touchUpInside)
        replyBtnNode.addTarget(self, action: #selector(CommentNode.repliedBtnPressed), forControlEvents: .touchUpInside)
        
        
        loadInfo(uid: self.post.Comment_uid)
        loadCmtCount(id: self.post.Comment_id)
        checkLikeCmt(id: self.post.Comment_id)
        
        
       //
        
        
        automaticallyManagesSubnodes = true
        
        
        
        
    }
    
    
    @objc func LikedBtnPressed(sender: AnyObject!) {
  
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments_Like").whereField("cmt_id", isEqualTo: self.post.Comment_id!).whereField("like_uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments {  querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
               
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                for item in snapshot.documents {
                    
                    self.unlikePerform(id: item.documentID)
                    
                }
                
            } else {
                
                
                let imgView = UIImageView()
                imgView.image = UIImage(named: "heart-fill")
                imgView.frame.size = CGSize(width: 70, height: 70)
                imgView.center = self.view.center
                self.view.addSubview(imgView)
                
                let degree = arc4random_uniform(200) + 1;
                
                
                imgView.transform = CGAffineTransform(rotationAngle: CGFloat(degree))
                
                UIView.animate(withDuration: 1) {
                    
                    imgView.alpha = 0
                    
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    if imgView.alpha == 0 {
                        
                        imgView.removeFromSuperview()
                        
                    }
                    
                }
 
                
                self.imageView.image = UIImage(named: "heart-fill")
                self.likePerform()
                
                
            }
            
            
        }
        
    }
    
    func unlikePerform(id: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Comments_Like")
              
        db.document(id).delete { (err) in
            
            if err != nil {
                print(err!.localizedDescription)
            }
            
            self.checkLikeCmt(id: id)
            
        }
        
        
        
    }
    
    func likePerform() {
        
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
            if let error = error {
                
                print(error.localizedDescription)
                
            } else if let string = string {
                
                DispatchQueue.main.async() { [self] in
                    
                    let device = UIDevice().type.rawValue
                    
                    var data = [String:Any]()
                    
                    let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(string)
                    
                    data = ["like_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "cmt_status": "valid", "Mux_playbackID": self.post.Mux_playbackID!, "Update_timestamp": FieldValue.serverTimestamp(), "cmt_id": self.post.Comment_id!] as [String : Any]
        
                    let db = DataService.instance.mainFireStoreRef.collection("Comments_Like")
                    AF.request(urls, method: .get)
                        .validate(statusCode: 200..<500)
                        .responseJSON { responseJSON in
                            
                            switch responseJSON.result {
                                
                            case .success(let json):
                                
                                if let dict = json as? Dictionary<String, Any> {
                                    
                                    if let status = dict["status"] as? String, status == "success" {
                                        
                                        data.merge(dict: dict)
                                               
                                        db.addDocument(data: data) { (errors) in
                                            
                                            if errors != nil {
                                                
                                                print(errors!.localizedDescription)
                                                return
                                                
                                            }
                                            
                                            checkLikeCmt(id: self.post.Comment_id)
                                            
                                            
                                        }
                                    }
                                }
                                
                            case .failure(let err):
                                print("Error: can't like \(err.localizedDescription)")
                            }
                            
                        }
                    
                }
                    
                }
                
            }
        
    }
 
    
    func checkLikeCmt(id: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments_Like").whereField("cmt_id", isEqualTo: id).getDocuments {  querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
               
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                      
                db.collection("Comments_Like").whereField("cmt_id", isEqualTo: id).whereField("like_uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments {  querySnapshot, error in
                    
                    guard let snapshots = querySnapshot else {
                       
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if snapshots.isEmpty != true {
                        
                        self.imageView.image = UIImage(named: "heart-fill")
                        
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        
                        let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                        let like = NSMutableAttributedString(string: "\(snapshot.count.formatUsingAbbrevation())", attributes: LikeAttributes)
                        self.textNode.attributedText = like
                        
                        
                    } else {
                        
                        
                        self.imageView.image = UIImage(named: "Icon ionic-ios-heart-empty")
                        
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        
                        let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                        let like = NSMutableAttributedString(string: "\(snapshot.count.formatUsingAbbrevation())", attributes: LikeAttributes)
                        self.textNode.attributedText = like
                        
                        
                    }
                    
                    UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                        self.view.layoutIfNeeded()
                    }, completion: { (completed) in
                        
                    })
                    
                    
                }
                
                
            } else {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                let like = NSMutableAttributedString(string: "", attributes: LikeAttributes)
                self.textNode.attributedText = like
                
                self.imageView.image = UIImage(named: "Icon ionic-ios-heart-empty")
                
                
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
                })
                
                
            }
            
            
        }
        
        
    }
    
    

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        InfoNode.style.preferredSize = CGSize(width: 30.0, height: 60.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        if self.post.has_reply == true {
            headerSubStack.children = [userNameNode, CmtNode, replyBtnNode]
        } else {
            headerSubStack.children = [userNameNode, CmtNode]
        }
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack, InfoNode]
        
        if self.post.isReply == true {
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 40, bottom: 16, right: 20), child: headerStack)
            
        } else {
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
            
        }
        
       
        
    }
    
    func loadCmtCount(id: String) {
        
        
        if self.post.has_reply == true, self.post.root_id != "nil" {
      
            if self.post.lastCmtSnapshot != nil{
                
                let db = DataService.instance.mainFireStoreRef
                
                db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("root_id", isEqualTo: self.post.root_id!).whereField("cmt_status", isEqualTo: "valid").order(by: "timeStamp", descending: false).start(afterDocument: self.post.lastCmtSnapshot).getDocuments {  querySnapshot, error in
                    
                    guard let snapshot = querySnapshot else {
                       
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if snapshot.isEmpty != true {
                        
                        self.replyBtnNode.setTitle("Show more (\(snapshot.count))", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.lightGray, for: .normal)
                        self.replyBtnNode.contentHorizontalAlignment = .left
                        
                        
                    }
                    
                    
                }
                
                
            }
            
            
        } else {
            
            
            DataService.init().mainFireStoreRef.collection("Comments").whereField("root_id", isEqualTo: id).whereField("cmt_status", isEqualTo: "valid").getDocuments { [self]  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                
                
                if snapshot.isEmpty != true {
                    
                    replyBtnNode.setTitle("Replied (\(snapshot.count))", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.lightGray, for: .normal)
                    replyBtnNode.contentHorizontalAlignment = .left
                    
                    
                }
                
            }
            
            
        }
        
        
        
    }
    
    func loadInfo(uid: String ) {
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { [self]  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item.data()["username"] as? String {
                        
                    
                        userNameNode.attributedText = NSAttributedString(string: "@\(username)", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                        
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            AvatarNode.url = URL(string: avatarUrl)
                            
                        }
                        
                        
                    }
                    
                }
           
        }
        
    }
    
    @objc func repliedBtnPressed(sender: AnyObject!) {
  
        reply?(self)
  
    }
    
    
}
