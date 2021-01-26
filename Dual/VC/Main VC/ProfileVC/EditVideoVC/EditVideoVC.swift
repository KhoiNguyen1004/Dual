//
//  EditVideoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/18/20.
//

import UIKit
import AVFoundation
import MarqueeLabel
import Alamofire
import AsyncDisplayKit
import Firebase
import SwiftPublicIP


class EditVideoVC: UIViewController {
    
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var avatarUrl: borderAvatarView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var InfoView: UIStackView!
    @IBOutlet weak var streamLink: MarqueeLabel!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var gameLogo: borderAvatarView!
    @IBOutlet weak var soundLbl: MarqueeLabel!
    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var commentCountLbl: UILabel!
    
    var region: String!
    var target = ""
    var value = 1
    //
    var selectedItem: HighlightsModel!
    var animatedLabel: MarqueeLabel!
    var videoNode = ASVideoNode()
    var SelectedUserName: String!
    var SelectedAvatarUrl: String!
    
    @IBOutlet weak var videoHeight: NSLayoutConstraint!
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        // animation text
        
        if selectedItem.stream_link != "nil" {
            
            
            streamLink.text = ""
            animatedLabel = MarqueeLabel.init(frame: streamLink.layer.bounds, rate: 60.0, fadeLength: 10.0)
            animatedLabel.type = .continuous
            animatedLabel.leadingBuffer = 20.0
            animatedLabel.trailingBuffer = 10.0
            animatedLabel.animationDelay = 0.0
            animatedLabel.textAlignment = .center
            animatedLabel.font = UIFont.systemFont(ofSize: 13)
            
            
            if let text = selectedItem.stream_link {
                animatedLabel.text = "\(text)                      "
            }
            
            
           
            streamLink.addSubview(animatedLabel)
        
            //
            
            soundLbl.text = "Original sound"
            soundLbl.textAlignment = .right
            
            
        } else {

            soundLbl.text = ""
            animatedLabel = MarqueeLabel.init(frame: CGRect(x: soundLbl.layer.bounds.minX, y: soundLbl.layer.bounds.minY, width: soundLbl.layer.bounds.width, height: 16.0), rate: 60.0, fadeLength: 10.0)
            animatedLabel.type = .continuous
            animatedLabel.leadingBuffer = 20.0
            animatedLabel.trailingBuffer = 10.0
            animatedLabel.animationDelay = 0.0
            animatedLabel.textAlignment = .center
            animatedLabel.font = UIFont.systemFont(ofSize: 13)
            
            
            if let username = SelectedUserName {
                animatedLabel.text = "Original sound - \(username)                      "
            } else {
                animatedLabel.text = "Original sound                               "
            }
           
           
            soundLbl.addSubview(animatedLabel)
            
            //
            
            streamLink.text = ""
            
            
        }
        
        
        if SelectedAvatarUrl != "", let url =  SelectedAvatarUrl {
            
            let imageNode = ASNetworkImageNode()
            imageNode.contentMode = .scaleAspectFit
            imageNode.shouldRenderProgressImages = true
            imageNode.url = URL.init(string: url)
            imageNode.frame = self.avatarUrl.layer.bounds
            self.avatarUrl.image = nil
            
            
            self.avatarUrl.addSubnode(imageNode)
            
            
        }
        
        if let name = SelectedUserName {
            usernameLbl.text = "@\(name)"
        }
        
       
        gameName.text = selectedItem.category
       
        let date = selectedItem.post_time.dateValue()
        timeStamp.text = timeAgoSinceDate(date, numericDates: true)
      
        
        
        loadLogo(category: selectedItem.category)
        loadTitleOrCmt()
        self.likeInteraction()
        self.CommentInteraction()
  
        videoNode.isUserInteractionEnabled = false
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(videoControl))
        singleTap.numberOfTapsRequired = 1
        videoPlayer.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(DoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        videoPlayer.addGestureRecognizer(doubleTap)
        
        
        singleTap.require(toFail: doubleTap)
        
        
    }
    
    
    @objc func DoubleTapped() {
        // do something here
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.instance.mainFireStoreRef.collection("Likes").whereField("Mux_playbackID", isEqualTo: selectedItem.Mux_playbackID!).whereField("LikerID", isEqualTo: uid).getDocuments { querySnapshot, error in
                
                guard querySnapshot != nil else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                     
                
                self.target = "Like"
          
                if querySnapshot?.isEmpty == true {
                    
                    
                    let imgView = UIImageView()
                    imgView.image = UIImage(named: "heart-fill")
                    imgView.frame.size = CGSize(width: 70, height: 70)
                    imgView.center = self.videoPlayer.center
                    
                    let degree = arc4random_uniform(200) + 1;
                    
                    
                    imgView.transform = CGAffineTransform(rotationAngle: CGFloat(degree))
                    
                    
                    self.videoPlayer.addSubview(imgView)
                    
                    UIView.animate(withDuration: 1.5) {
                        imgView.alpha = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        
                        if imgView.alpha == 0 {
                            
                            imgView.removeFromSuperview()
                            
                        }
                        
                    }
                    
                    
                    print("new like")
                    self.value = 1
                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let string = string {
                            
                            generateLikeIP(IP: string)
                           
                        }
                        
                    }
                    
                } else {
                    
                    print("remove like")
                   
                    for item in querySnapshot!.documents {
                        
                        let id = item.documentID
                        DataService.instance.mainFireStoreRef.collection("Likes").document(id).delete()
                        
                        print("Like delete")
                        
                        break
                        
                        
                    }
                    
                    
                    self.value = -1
                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let string = string {
                            
                            generateLikeIP(IP: string)
                           
                        }
                        
                    }
                    
                
                }
            }
            
        }
        
    }
    
    
    func generateLikeIP(IP: String) {
        
        let device = UIDevice().type.rawValue
        let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(IP)
        var data = ["Mux_playbackID": selectedItem.Mux_playbackID!, "LikerID": Auth.auth().currentUser!.uid, "ownerUID": selectedItem.userUID!, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "category": selectedItem.category!] as [String : Any]
        let db = DataService.instance.mainFireStoreRef.collection("Likes")
        var ref: DocumentReference? = nil
        target = "Like"
        
        
        AF.request(urls, method: .get)
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                case .success(let json):
                    
                    if let dict = json as? Dictionary<String, Any> {
                        
  
                        if let status = dict["status"] as? String, status == "success" {
                            
                            data.merge(dict: dict)
                            self.region = dict["country"] as? String
                            var id = ""
                            if self.value != -1 {
                                ref = db.addDocument(data: data)
                                id = ref!.documentID
                            } else{
                                id = self.randomString(length: 8)
                            }
                            
           
                            self.sendToItemsPersonalize(data: data, id: id)
                           
                        }
                        
                    }
                    
                case .failure(_ ): break
                    
                    
                   
                    
                }
                
            }
        
        }
    
    
    func sendToItemsPersonalize(data: [String: Any], id: String) {
        
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("aws-personalize-send-events")
        let timeStamp = Int(Date().timeIntervalSince1970)
       
        if target == "Like" {
            
            if let uid = Auth.auth().currentUser?.uid {
                
                
                likeInteraction()
                
                AF.request(urls!, method: .post, parameters: [

                    "USER_ID": uid,
                    "ITEM_ID": self.selectedItem.highlight_id!,
                    "EVENT_VALUE": value,
                    "EVENT_TYPE": "Like",
                    "TIMESTAMP": timeStamp,
                    "EVENTID": id,
                    "REGION_ID": self.region!,
                    "impression": impressionList

                ])
                .validate(statusCode: 200..<500)
                .responseJSON { responseJSON in
                
            }
                
            }

        }
  
    }
    
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func loadTitleOrCmt() {
        
        if self.selectedItem.highlight_title != "nil"{
            
            let paragraphStyles = NSMutableParagraphStyle()
            paragraphStyles.alignment = .left
            
            let usernameAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyles]
            let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
            let user = NSMutableAttributedString(string: "Author: ", attributes: usernameAttributes)
            
            let text = NSAttributedString(string: self.selectedItem.highlight_title, attributes: textAttributes)
            user.append(text)
        
            
            titleLbl.attributedText = user
            
        } else {
            
            
            loadLastestCmt()
            
            
            
        }
        
        
    }
    
    func loadLastestCmt() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").whereField("isReply", isEqualTo: false).whereField("Mux_playbackID", isEqualTo: self.selectedItem.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").whereField("is_title", isEqualTo: false).order(by: "Update_timestamp", descending: true).limit(to: 1).getDocuments { [self] (snap, err) in
            
            if err != nil {
                
                titleLbl.text = "What do you think?"
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                for items in snap!.documents {
                    
                    let item = CommentModel(postKey: items.documentID, Comment_model: items.data())
                    
                    getUserCmtInfo(cmt_item: item)
                }
                
            } else {
                
                titleLbl.text = "What do you think?"
                
            }
            
        }
        
        
    }
    
    func getUserCmtInfo(cmt_item: CommentModel) {
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: cmt_item.Comment_uid!).getDocuments {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item.data()["username"] as? String {
                        
                    
                       let username = "@\(username)"
                        
                       
                        if cmt_item.timeStamp != nil {
                            
                            let date = cmt_item.timeStamp.dateValue()
                            
                            let usernameAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                            
                            let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                            let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                            
                            
                            let user = NSMutableAttributedString(string: "\(username): ", attributes: usernameAttributes)
                            
                            let text = NSAttributedString(string: cmt_item.text, attributes: textAttributes)
                            let time = NSAttributedString(string: " \(timeAgoSinceDate(date, numericDates: true))", attributes: timeAttributes)
                            user.append(text)
                            user.append(time)
                            
                            self.titleLbl.attributedText = user
                            
                            
                        } else {
                            
                            
                            let usernameAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                            
                            
                            let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                            let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
                            
                            
                            let user = NSMutableAttributedString(string: "\(username): ", attributes: usernameAttributes)
                            
                            let text = NSAttributedString(string: cmt_item.text, attributes: textAttributes)
                            let time = NSAttributedString(string: " Just now", attributes: timeAttributes)
                            user.append(text)
                            user.append(time)
                            
                            self.titleLbl.attributedText = user
                            
                            
                        }
                        
                        
                    }
                    
                }
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func likeInteraction() {
        
        DataService.instance.mainFireStoreRef.collection("Likes").whereField("Mux_playbackID", isEqualTo: selectedItem.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                self.likeImg.image = UIImage(named: "Icon ionic-ios-heart-empty")
                self.likeCountLbl.text = "Likes"
                
            } else {
                
                if let count = querySnapshot?.count {
                    
                    //LikerID
                    
                    self.likeCountLbl.text = "\(count.formatUsingAbbrevation()) Likes"
                    self.checkifUserLike()
                    
                }
                
            }
                
            
        }
        
    
    }
    func checkifUserLike() {
        
        DataService.instance.mainFireStoreRef.collection("Likes").whereField("Mux_playbackID", isEqualTo: selectedItem.Mux_playbackID!).whereField("LikerID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                self.likeImg.image = UIImage(named: "Icon ionic-ios-heart-empty")
                
                
            } else {
                
                self.likeImg.image = UIImage(named: "heart-fill")
                
                
            }
            
            
            
        }
        
        
    }
    
    func CommentInteraction() {
        
        DataService.instance.mainFireStoreRef.collection("Comments").whereField("Mux_playbackID", isEqualTo: selectedItem.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").whereField("is_title", isEqualTo: false).getDocuments{ querySnapshot, error in
            
            
           
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                self.commentCountLbl.text = "Comments"
                
            } else {
                
                if let count = querySnapshot?.count {
                    
            
                    self.commentCountLbl.text = "\(count.formatUsingAbbrevation()) Comments"
                    
                }
                
            }
         
        }
        
    }
    
    
    @objc func loadUrl() {
        
        if let link = selectedItem.stream_link, link != ""
        {
        
            guard let requestUrl = URL(string: link) else {
                self.showErrorAlert("Oops!", msg: "This link seems not legit, we cannot open for safety reason.")
                return
            }

            if UIApplication.shared.canOpenURL(requestUrl) {
                 UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            }
            
        } else {
            
            print("Empty link")
            
        }
        
    }
    
    func loadLogo(category: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("name", isEqualTo: category).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
                
                if let url = item.data()["url2"] as? String {
                    
                    imageStorage.async.object(forKey: url) { result in
                        if case .value(let image) = result {
                            
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                
                                
                                self.gameLogo.image = image
                                
                                //try? imageStorage.setObject(image, forKey: url)
                                
                            }
                            
                        } else {
                            
                            
                         AF.request(url).responseImage { response in
                                
                                
                                switch response.result {
                                case let .success(value):
                                    self.gameLogo.image = value
                                    try? imageStorage.setObject(value, forKey: url)
                                case let .failure(error):
                                    print(error)
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
                
            }
            
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        NotificationCenter.default.removeObserver(self)
        
        self.videoNode.pause()
        
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let id = selectedItem.Mux_playbackID {
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            
            let url = "https://stream.mux.com/\(id).m3u8"

            let asset = AVAsset(url: URL(string: url)!)
     
            videoNode.frame = videoPlayer.layer.bounds
            
            videoPlayer.addSubnode(videoNode)
            
            if selectedItem.ratio < 1.0 {
                
                videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                
            } else {
                
                videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                
            }
            
            
            videoNode.shouldAutoplay = false
            videoNode.shouldAutorepeat = true
           
            videoNode.asset = asset
    
            videoNode.play()
            
            
        }
        
        
        let linkBtn = ASButtonNode()
        linkBtn.backgroundColor = UIColor.clear
        linkBtn.frame = CGRect(x: InfoView.layer.bounds.minX, y: InfoView.layer.bounds.maxY - 16, width: 170, height: 20)
        linkBtn.addTarget(self, action: #selector(loadUrl), forControlEvents: .touchUpInside)
        
        InfoView.addSubnode(linkBtn)
        
        
    }
  
    
    @objc func appMovedToBackground() {
        
        if videoNode.isPlaying() == true {
            
            print("pause")
            videoNode.pause()
            
            // process notification
            NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToactive), name: UIApplication.didBecomeActiveNotification, object: nil)
            
        }
        
        
    }
    
    @objc func appMovedToactive() {
        
        if videoNode.isPlaying() == false {
            
            print("resume")
            
            videoNode.play()
            
            // process notification
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            
            
        }

        
    }
    
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
 
    
    @objc func videoControl() {
        
        
        if videoNode.isPlaying() == true {
              
            videoNode.pause()
            
            UIView.transition(with: playImg, duration: 0.5, options: .transitionFlipFromRight, animations: { [self] in
                playImg.image = UIImage(named: "play")
                    }, completion: nil)
            
            
        } else {
            
       
            videoNode.play()
            
            UIView.transition(with: playImg, duration: 0.5, options: .transitionFlipFromRight, animations: { [self] in
                playImg.image = nil
                    }, completion: nil)
            
        }
        
        
    }
    
    
    @IBAction func videoSettingBtnPressed(_ sender: Any) {
        
        if videoNode.isPlaying() == true {
            
            videoNode.pause()
            NotificationCenter.default.addObserver(self, selector: #selector(EditVideoVC.resumeAfterEdit), name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            
        }
        
        self.performSegue(withIdentifier: "moveToVideoSettingVC", sender: nil)
        
    }
    
    
    @IBAction func videoSettingBtn1Pressed(_ sender: Any) {
        
        if videoNode.isPlaying() == true {
            
            videoNode.pause()
            NotificationCenter.default.addObserver(self, selector: #selector(EditVideoVC.resumeAfterEdit), name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            
        }
        
        self.performSegue(withIdentifier: "moveToVideoSettingVC", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToVideoSettingVC"{
            if let destination = segue.destination as? VideoSettingVC
            {
                
                destination.selectedItem = self.selectedItem
               
                
            }
        }
        
        
    }
    
    
    
    @objc func resumeAfterEdit() {
        
        
        videoNode.play()
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        
        
    }
    
    @IBAction func cmtBtnPressed(_ sender: Any) {
        
        
        DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_assetID", isEqualTo: selectedItem.Mux_assetID!).whereField("Mux_playbackID", isEqualTo: selectedItem.Mux_playbackID!).whereField("h_status", isEqualTo: "Ready").whereField("Allow_comment", isEqualTo: true).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                self.showErrorAlert("Oops !", msg: "Can't open the comment for this highlight right now.")
                return
            }
            
            if snap?.isEmpty == true {
                
                self.showErrorAlert("Oops !", msg: "The comment for this highlight is disabled")
                return
                
            } else {
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
                
                //let memeDetailVC = MemeDetailVC.init(meme: Meme())
                let slideVC = CommentVC()
                
                slideVC.modalPresentationStyle = .custom
                slideVC.transitioningDelegate = self
                slideVC.currentItem = self.selectedItem
                should_Play = false
                self.present(slideVC, animated: true, completion: nil)
                          
                
            }
            
        }
        
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension EditVideoVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
