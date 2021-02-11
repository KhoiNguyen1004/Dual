//
//  UserHighlightFeedVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 12/26/20.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Firebase
import SwiftPublicIP
import Alamofire
import SwiftyJSON

class UserHighlightFeedVC: UIViewController, UIAdaptivePresentationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var bView: UIView!
    
   
    var currentIndex = 0
    var challengeItem: HighlightsModel!
    var challengeName = ""
    var userid = ""
  
    var firstLoad = true
    var previousIndex = 0
    var tableNode: ASTableNode!
    var posts = [HighlightsModel]()
    var item_id_list = [String]()
    var index = 0
    
    var backgroundView = UIView()
    var CView = ChallengesView()
    var keyboard = false
    var myCategoryOrdersTuple: [(key: String, value: Float)]? = nil
    var viewsCategoryOrdersTuple: [(key: String, value: Float)]? = nil
 
    var isFeed = false
   
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        ismained = false
        
        bView.addSubview(tableNode.view)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 2
        
   
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
        keyboard = true
    }
        
    @objc func handleKeyboardHide(notification: Notification) {
        
        keyboard = false
        
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        should_Play = false
        alreadyShow = false
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "removeAllobserve")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "CheckIfPauseVideo")), object: nil)
        
        
        
        should_Play = true
        alreadyShow = true
        
        
    
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = bView.bounds
        
    }
    
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.isPagingEnabled = true
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
        
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Dismiss")
    }

    // functions
    
    
    func shareVideo(item: HighlightsModel) {
        
        if let id = item.highlight_id, id != "" {
            
            let items: [Any] = ["Check out this highlight", URL(string: "https://www.dual.so/\(id)")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                
            }
           
           present(ac, animated: true, completion: nil)
           NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
        
        }
    
        
    }
    
    func challenge(item: HighlightsModel) {
        
        if let uid = Auth.auth().currentUser?.uid, Auth.auth().currentUser?.isAnonymous != true, uid != item.userUID {
            
        
         DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: item.userUID!).getDocuments { [self] querySnapshot, error in
            
                guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                }
                
                
                if snapshot.isEmpty != true {
                    
                    for items in snapshot.documents {
                        
                        if let username = items.data()["username"] as? String {
                                
                                challengeName = username
                                
                                
                        } else {
                            
                            challengeName = "Undefined"
                            
                        }
                            
                    }
                    
                    self.userid = item.userUID
                    
                    self.backgroundView.frame = self.view.frame
                    backgroundView.backgroundColor = UIColor.black
                    backgroundView.alpha = 0.6
                    self.view.addSubview(backgroundView)
                    
                    
                    
                    CView.frame = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height * (250/813), width: self.view.frame.size.width * (365/414), height: self.view.frame.size.height * (157/813))
                    self.view.addSubview(CView)
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
                    CView.messages.becomeFirstResponder()
                    CView.center.x = view.center.x
                    challengeItem = item
                    CView.messages.delegate = self
                    
                    CView.toLbl.text = "To @\(challengeName)"
                    CView.messages.attributedPlaceholder = NSAttributedString(string: "Send a message to @\(challengeName)",
                                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
                    CView.messages.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                    CView.send.addTarget(self, action:  #selector(FeedVC.ChallengeBtnPressed), for: .touchUpInside)
                    
                } else {
                    
                    self.showErrorAlert("Oops !", msg: "You can't send challenge to this user.")
                    return
                    
                }
            
            }
           
        } else {
            
            self.showErrorAlert("Oops !", msg: "You should be a signed user to challenge or you can't challenge yourself.")
            
        }
     
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == CView.messages, CView.messages.text != "" {
            
            CView.maxCharLbl.text = "Max 35 chars - \(CView.messages.text!.count)"
            
        } else {
            
            CView.maxCharLbl.text = "Max 35 chars"
            
        }
        
    }
    
    func checkPendingChallenge(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
       
        db.whereField("sender_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("receiver_ID", isEqualTo: receiver_ID).whereField("challenge_status", isEqualTo: "Pending").getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops !", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                
                completed()
                
            } else {
                
                self.showErrorAlert("Oops !", msg: "You have sent to @\(self.challengeName) a challenge before, please wait for the user's acceptance or until the expiration time.")
                return
                
            }
            
        
        }
        

        
    }
    
    func checkActiveChallenge(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("sender_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("receiver_ID", isEqualTo: receiver_ID).whereField("challenge_status", isEqualTo: "Active").getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops !", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                completed()
                
            } else {
                
                self.showErrorAlert("Oops !", msg: "Your and @\(self.challengeName)'s challenge is active, you can't send another the expiration time.")
                return
                
            }
            
            
            
        }
        
    }
    
    @objc func ChallengeBtnPressed() {
        
        if challengeItem != nil {
            
            checkPendingChallenge(receiver_ID: challengeItem.userUID) {
                
                self.checkActiveChallenge(receiver_ID: self.challengeItem.userUID) {
                    
                    if self.CView.messages.text != "" {
                        
                        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                            if let error = error {
                                
                                print(error.localizedDescription)
                                self.showErrorAlert("Oops !", msg: "Can't verify your information to send challenge, please try again.")
                                
                            } else if let string = string {
                                
                                DispatchQueue.main.async() { [self] in
                                    
                        
                                    let device = UIDevice().type.rawValue
                                    let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(string)
                                    var data = ["receiver_ID": challengeItem.userUID!, "sender_ID": Auth.auth().currentUser!.uid, "category": challengeItem.category!, "created_timeStamp": FieldValue.serverTimestamp(), "started_timeStamp": FieldValue.serverTimestamp(), "Device": device, "messages": self.CView.messages.text!, "challenge_status": "Pending"] as [String : Any]
                                    
                                    let db = DataService.instance.mainFireStoreRef.collection("Challenges")
                                    
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
                                                                
                                                                self.showErrorAlert("Oops !", msg: errors!.localizedDescription)
                                                                return
                                                                
                                                            }
                                                            
                                                            CView.messages.text = ""
                                                            backgroundView.removeFromSuperview()
                                                            CView.removeFromSuperview()
                                                            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                                                            
                                                            showNote(text: "Cool! You have succesfully sent a challenge to @\(challengeName)")
                                                            
                                                            
                                                        }
                      
                                                    }
                                                    
                                                }
                                                
                                            case .failure(let err):
                                                
                                                print(err.localizedDescription)
                                                self.showErrorAlert("Oops !", msg: "Can't verify your information to send challenge, please try again.")
                                               
                                                
                                            }
                                            
                                        }
                                    
                                }
                                
             
                            }
                        }
                                  
                        
                        
                    } else {
                        
                        self.showErrorAlert("Oops !!!", msg: "Please enter your challenge messages.")
                        
                    }
                    
                }
                
            }
            
            
            
      
            
        } else {
            
            backgroundView.removeFromSuperview()
            CView.removeFromSuperview()
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            
            self.showErrorAlert("Oops !!!", msg: "Can't send challeng now, please try again")
            
            
        }
        
       
       
        
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
    
    func openLink(item: HighlightsModel) {
        
        if let link = item.stream_link, link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }

            if UIApplication.shared.canOpenURL(requestUrl) {
                 UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            }
            
        } else {
            
            print("Empty link")
            
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.CView)
            
            if CView.bounds.contains(currentPoint) {
              
            } else {
                
                if keyboard == true {
                    
                    self.view.endEditing(true)
                    
                    
                } else {
                    
                    backgroundView.removeFromSuperview()
                    CView.removeFromSuperview()
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                    
                }
               
            }
            
        }
        
        
    }
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

extension UserHighlightFeedVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.size.width;
        let min = CGSize(width: width, height: self.bView.layer.frame.height);
        let max = CGSize(width: width, height: self.bView.layer.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        
        return true
        
    }
    
    
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
       
   
        if item_id_list.isEmpty != true, index < item_id_list.count {
  
            self.retrieveNextPageWithCompletion { (newPosts) in
                
                
                self.insertNewRowsInTableNode(newPosts: newPosts)
                
                context.completeBatchFetching(true)
                
                
            }
            
        }
        
 
    }
    
   
}

extension UserHighlightFeedVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    
        return self.posts.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let post = self.posts[indexPath.row]
           
        return {
            let node = PostNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.shareBtn = { (node) in
                
                self.shareVideo(item: post)
                  
            }
            
            node.challengeBtn = { (node) in
                
                self.challenge(item: post)
                
            }
            
            
            node.linkBtn = { (node) in
                
                self.openLink(item: post)
                
            }
                
            return node
        }
        
   
            
    }
    

    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        
        guard let cell = node as? PostNode else { return }
        
        currentIndex = cell.indexPath!.row
        
        if cell.animatedLabel != nil {
            
            cell.animatedLabel.restartLabel()
            
        }
        
        
        cell.startObserve()
    
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
    
        
        guard let cell = node as? PostNode else { return }
        
        if cell.PlayViews != nil {
            cell.PlayViews.playImg.image = nil
        }
        
        
        cell.removeAllobserve()
        
    }
    
}

extension UserHighlightFeedVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
 
        let db = DataService.instance.mainFireStoreRef
        if item_id_list.isEmpty == true || item_id_list.count > index {
                 
        print("Load index: \(index), item: \(item_id_list[index]), itemCount: \(item_id_list.count)")
                 
        db.collection("Highlights").document(item_id_list[index]).getDocument { (snap, err) in
     
            if err != nil {
                         
                print(err!.localizedDescription)
                return
            }
                     
                self.index += 1
                     
                DispatchQueue.main.async {
                         block([snap!])
                }
                    
            
            }
             
             
        }
        
       
    
    }
    
    
    
    func insertNewRowsInTableNode(newPosts: [DocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + newPosts.count
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newPosts {
            
            let item = HighlightsModel(postKey: i.documentID, Highlight_model: i.data()!)
            items.append(item)
          
        }
        
    
        self.posts.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
        
    }
    
    
}

