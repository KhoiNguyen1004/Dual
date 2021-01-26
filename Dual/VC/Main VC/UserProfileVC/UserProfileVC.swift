//
//  UserProfileVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/24/20.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit
import AVFoundation
import CoreLocation
import Alamofire
import DTCollectionViewManager
import AsyncDisplayKit

class UserProfileVC: UIViewController, DTCollectionViewManageable, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var rate2: UILabel!
    @IBOutlet weak var rate1: UILabel!
    @IBOutlet weak var emptyMessage: UILabel!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    
    @IBOutlet weak var category1: UILabel!
    @IBOutlet weak var logo1: borderAvatarView!
    @IBOutlet weak var date1: UILabel!
    @IBOutlet weak var name1: UILabel!
    @IBOutlet weak var star1: UILabel!
    
    
    @IBOutlet weak var category2: UILabel!
    @IBOutlet weak var logo2: borderAvatarView!
    @IBOutlet weak var date2: UILabel!
    @IBOutlet weak var name2: UILabel!
    @IBOutlet weak var star2: UILabel!
    
    var isFeed = false
    var isBack = false
    var uid: String!
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var avatarImg: borderAvatarView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var keyList = [String]()
    
    
    private var expectedTargetContentOffset: CGPoint = .zero
    
    var Highlight_list = [HighlightsModel]()
    var challenge_list = [ChallengeModel]()
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if uid != nil {
            
            manager.register(userHighlightsCollectionCell.self) { [weak self] mapping in
                
                mapping.sizeForCell { cell, model in
                    self?.itemSize(for: self?.collectionView.bounds.size.width ?? .zero) ?? .zero
                }
                          
            }
            
            loadVideo(uid: uid)
            loadProfile(uid: uid)
            
            
            
            pullControl.tintColor = UIColor.systemOrange
            pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
            if #available(iOS 10.0, *) {
                collectionView.refreshControl = pullControl
            } else {
                collectionView.addSubview(pullControl)
            }
            
            
        } else {
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBack == true {
            
            if isFeed == true {
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                isFeed = false
                should_Play = true
            }
            
        }
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        isBack = true
        
    }
    
    @objc private func refreshListData(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.Highlight_list.removeAll()
        loadVideo(uid: uid)
              
    }
    
    func loadChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef

        db.collection("Challenges").whereField("isPending", isEqualTo: false).whereField("uid_list", arrayContains: uid).order(by: "updated_timeStamp", descending: true).limit(to: 2)
            
            .getDocuments { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.isEmpty == true {
                    
                    
                    emptyMessage.isHidden = false
                    view1.isHidden = true
                    view2.isHidden = true
                    
                } else {
                    
                    emptyMessage.isHidden = true
                    
                    
                    for item in snapshot.documents {
                        
                        let elem = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                        challenge_list.append(elem)
                        
                    }
                    
                    if challenge_list.count >= 2 {
                        
                        view1.isHidden = false
                        view2.isHidden = false
                        
                    } else {
                        
                        view1.isHidden = false
                        view2.isHidden = true
                        
                    }
                    
                    loadChallengeInfo()
                    
                }
                
               
                
                
        }
           
    }
    
    
    
    func loadChallengeInfo() {
        
        var count = 0
        
        
        
        for item in challenge_list {
            
            let uid = getuserUID(list: item.uid_list!, uid: self.uid)
            
            if uid != "" {
                
                
                let date = item.updated_timeStamp.dateValue()
                
                
                if count == 0 {
                    
                    
                    date1.text = formatDate(date: date)
                    category1.text = item.category
                    getLogo(category: item.category, image: logo1)
                    loadInfo(uid: uid, user: name1)
                    getstar(uid: uid, rate: rate1)
                    
                } else if count == 1 {
                    
                    date2.text = formatDate(date: date)
                    category2.text = item.category
                    getLogo(category: item.category, image: logo2)
                    loadInfo(uid: uid, user: name2)
                    getstar(uid: uid, rate: rate2)
                }
   
                
            }
            
            
            count+=1
            
            
        }
        
        
    }
    
    
    func loadInfo(uid: String, user: UILabel) {
        
       
        DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                
                    if let username = item.data()["username"] as? String {
                        
                        //
                        user.text = "Vs @\(username)"

   
                    }
                
            }
            
        }
       
    }
    
    func getLogo(category: String, image: UIImageView) {
        
        
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("name", isEqualTo: category).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
                
                if let url = item.data()["url2"] as? String {
                    
                   
                    let imageNode = ASNetworkImageNode()

                    
                    imageNode.contentMode = .scaleAspectFill
                    imageNode.shouldRenderProgressImages = true
                    imageNode.animatedImagePaused = false
                    imageNode.url = URL.init(string: url)
                    imageNode.frame = image.layer.bounds
                    
  
                    image.addSubnode(imageNode)
                    
                    
                }
                
                
            }
            
            
        }
        
    }
    
    func getstar(uid: String, rate: UILabel) {
        
        DataService.instance.mainFireStoreRef.collection("Challenge_rate").whereField("to_uid", isEqualTo: uid).limit(to: 100).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            
            if snapshot.isEmpty != true {
                
                
                var rate_lis = [Int]()
                
                for item in snapshot.documents {
                    
                    
                    
                    if let current_rate = item.data()["rate_value"] as? Int {
                        
                        rate_lis.append(current_rate)
                        
                    }
                    
                    
                    
                    
                }
                
            
                let average = calculateMedian(array: rate_lis)
                rate.text = String(format:"%.1f", average)
                
            }
            
    
        }
        
        
        
        
    }
    
    
    func formatDate(date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
       
        return dateFormatter.string(from: date)
        
    }
    
    func getuserUID(list: [String], uid: String) -> String {
        
        
        
        for item in list {
            
            if item != uid {
                
                return item
            }
            
            
        }
        
        return ""
        
        
    }
    
    func loadProfile(uid: String) {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                

                for item in snapshot.documents {

                    self.assignProfile (item: item.data())
                    
                }
                
          
                
        }
        
    }
    
    func assignProfile(item: [String: Any]) {
        
        if let username = item["username"] as? String, let name = item["name"] as? String, let avatarUrl = item["avatarUrl"] as? String  {
            
           
            nameLbl.text = name
            usernameLbl.text = "@\(username)"
            emptyMessage.text = "@\(username) doesn't have any challenge"
            
            let imageNode = ASNetworkImageNode()
            imageNode.contentMode = .scaleAspectFit
            imageNode.shouldRenderProgressImages = true
            imageNode.url = URL.init(string: avatarUrl)
            imageNode.frame = self.avatarImg.layer.bounds
            self.avatarImg.image = nil
            
            self.avatarImg.addSubnode(imageNode)
            
            
            loadChallenge(uid: uid)
            
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { [weak self] context in
            self?.expectedTargetContentOffset = self?.collectionView.contentOffset ?? .zero
            self?.updateLayout(size: size, animated: true)
        } completion: { _ in }
    }
    
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        manager.didSelect(userHighlightsCollectionCell.self) { [self] cell, model, indexPath in
            
            // React to selection
            
            loadKeyList(key: model.highlight_id)

        }
        
    }
    
    func loadKeyList(key: String) {
        
        
        keyList.removeAll()
        var shouldstart = false
        
        for item in Highlight_list {
            
            if item.highlight_id == key {
                keyList.append(key)
                shouldstart = true
            }
            
            if item.highlight_id != key, shouldstart == true {
                keyList.append(item.highlight_id)
            }
            
        }
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo2")), object: nil)
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "removeAllobserve")), object: nil)
        
        isReObserved = true
        isBack = false
        self.performSegue(withIdentifier: "moveToUserHighlightVC", sender: nil)
        
    }
    
    
    // prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToUserHighlightVC"{
            if let destination = segue.destination as? UserHighlightFeedVC
            {
                
                destination.item_id_list = self.keyList
                
               
                
            }
        } else if segue.identifier == "moveToViewAllChallenge3"{
            if let destination = segue.destination as? ViewAllChallengeVC
            {
                
                destination.viewUID = uid
                
            }
        }
        
    }
    
    func loadVideo(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        
        db.collection("Highlights").whereField("userUID", isEqualTo: uid).order(by: "post_time", descending: true).limit(to: 50)
            .getDocuments { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.isEmpty == true {
                    
                    print("No video")
                    return
                    
                }
                
                for item in snapshot.documents {
                    
                    
                    if item.data()["h_status"] as! String == "Ready", item.data()["mode"] as! String != "Only me" {
                        
                       
                        let dict = HighlightsModel(postKey: item.documentID, Highlight_model: item.data())
                        self.Highlight_list.append(dict)
                        
                        manager.memoryStorage.setItems(self.Highlight_list)
                        
                    }
                    
                }
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }      
            }
        
   
    }
    
    // layouyt
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0);
    }
    
    private func itemSize(for width: CGFloat) -> CGSize {
 
        return CGSize(width: (width - 0)/2, height: 150)
    
    }
    
    private func updateLayout(size: CGSize, animated: Bool) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = itemSize(for: size.width)
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }
    

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func AllChallengeBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToViewAllChallenge3", sender: nil)
        
    }
}
