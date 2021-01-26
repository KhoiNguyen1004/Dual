//
//  CommentVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/1/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit

class CommentVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    var sum = [Int]()
    var total = 0
    var isTitle = false
    @IBOutlet weak var totalCmtCount: UILabel!
    var isFeed = false
    @IBOutlet weak var bView: UIView!
    var isBack = false
    var currentItem: HighlightsModel!
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    var reply_to_uid: String!
    

    var CmtQuery: Query!
    var prev_id: String!
    
    var root_id: String!
    var index: Int!
    
    @IBOutlet weak var tView: UIView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var textConstraint: NSLayoutConstraint!
    @IBOutlet weak var cmtTxtView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var placeholderLabel : UILabel!
    var CommentList = [CommentModel]()
    var tableNode: ASTableNode!
    
    private var pullControl = UIRefreshControl()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        self.tableNode = ASTableNode(style: .plain)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        cmtTxtView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add comment..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (cmtTxtView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        cmtTxtView.addSubview(placeholderLabel)
        
        placeholderLabel.frame = CGRect(x: 5, y: (cmtTxtView.font?.pointSize)! / 2 - 5, width: 200, height: 30)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.isHidden = !cmtTxtView.text.isEmpty
        
        cmtTxtView.returnKeyType = .send
        
        checkIfHighlightTitleIsAComment()
        
        tView.addSubview(tableNode.view)
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 20
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        setupLongPressGesture()
        calculateToTalCmt()
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
   
    }
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        self.CommentList.removeAll()
        lastDocumentSnapshot = nil
        query = nil
        
        
        
        calculateToTalCmt()
        checkIfHighlightTitleIsAComment()
        

    
    }
    
    
    func checkIfHighlightTitleIsAComment() {

        if currentItem.highlight_title != "nil" {
            
            isTitle = true
            
            DataService.init().mainFireStoreRef.collection("Comments").whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("Comment_uid", isEqualTo: currentItem.userUID!).whereField("text", isEqualTo: currentItem.highlight_title!).whereField("timeStamp", isEqualTo: currentItem.post_time!).whereField("is_title", isEqualTo: true).getDocuments { [self]  querySnapshot, error in
                
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.isEmpty == true {
                    
                    
                    let db = DataService.instance.mainFireStoreRef.collection("Comments")
                    let device = UIDevice().type.rawValue
                    var ref: DocumentReference!
                    
                    let data = ["Comment_uid": currentItem.userUID!, "timeStamp": currentItem.post_time!, "text": currentItem.highlight_title!, "cmt_status": "valid", "isReply": false, "Mux_playbackID": currentItem.Mux_playbackID!, "root_id": "nil", "has_reply": false, "Update_timestamp": currentItem.post_time!, "is_title": true, "Device": device] as [String : Any]
                    
                           
                    ref = db.addDocument(data: data) { (errors) in
                        
                        if errors != nil {
                            
                            self.wireDelegates(item: nil)
                            print(errors!.localizedDescription)
                            return
                            
                        }
                        
                        let item = CommentModel(postKey: ref.documentID, Comment_model: data)
                        
                        self.wireDelegates(item: item)
                        
                    }
                    
                    
                } else {
                    
                    
                    for items in querySnapshot!.documents {
                        
                        let item = CommentModel(postKey: items.documentID, Comment_model: items.data())
                        self.wireDelegates(item: item)
                        break
                        
                    }
                    
                    
                }
                    
            }
            
          
            
            
        } else {
            
            isTitle = false
            self.wireDelegates(item: nil)
            
            
        }
        
        
    }
    
    
    
        
    
    
    func calculateToTalCmt() {
        
        if let Mux_playbackID = currentItem.Mux_playbackID {
            
            DataService.init().mainFireStoreRef.collection("Comments").whereField("Mux_playbackID", isEqualTo: Mux_playbackID).whereField("cmt_status", isEqualTo: "valid").whereField("is_title", isEqualTo: false).getDocuments { [self]  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                if snapshot.isEmpty == true {
                    totalCmtCount.text = "No Comment"
                } else {
                    
                    
                    totalCmtCount.text = "\(snapshot.count) Comments"
                    
                    
                }
                
            }
              
        }
            
    }
    
    func wireDelegates(item: CommentModel!) {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        if currentItem.highlight_title != "nil", isTitle == true {
            
            print(CommentList.count)
            self.CommentList.insert(item, at: 0)
            print(CommentList.count)
            self.tableNode.reloadData()
            //self.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            isTitle = false
            
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        //self.tableNode.frame = self.tView.bounds
        self.tableNode.frame = CGRect(x: 0, y: 0, width: self.tView.frame.width, height: self.tView.frame.height - 50)
        
    }
    
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
        
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
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
       
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            
            sendCommentBtn()
            textView.text = ""
            placeholderLabel.isHidden = !textView.text.isEmpty
            textView.resignFirstResponder()
            
            
            return false
        }
        
        return true
    }
    
    func sendCommentBtn() {
        
        if let text = cmtTxtView.text, text != "" {
            
            SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                if let error = error {
                    
                    print(error.localizedDescription)
                    self.showErrorAlert("Oops !", msg: "Can't verify your information to send challenge, please try again.")
                    
                } else if let string = string {
                    
                    DispatchQueue.main.async() { [self] in
                        
            
                        let device = UIDevice().type.rawValue
                        
                        var data = [String:Any]()
                        
                        let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(string)
                        
                        if root_id != nil {
                            
                            data = ["Comment_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "text": text, "cmt_status": "valid", "isReply": true, "Mux_playbackID": currentItem.Mux_playbackID!, "root_id": root_id!, "has_reply": false, "Update_timestamp": FieldValue.serverTimestamp(), "reply_to": reply_to_uid!, "is_title": false] as [String : Any]
                            
                            
                            
                            
                        } else {
                            
                            data = ["Comment_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "text": text, "cmt_status": "valid", "isReply": false, "Mux_playbackID": currentItem.Mux_playbackID!, "root_id": "nil", "has_reply": false, "Update_timestamp": FieldValue.serverTimestamp(), "is_title": false] as [String : Any]
                            
                        }
                        
                        
                        let db = DataService.instance.mainFireStoreRef.collection("Comments")
                        AF.request(urls, method: .get)
                            .validate(statusCode: 200..<500)
                            .responseJSON { responseJSON in
                                
                                switch responseJSON.result {
                                    
                                case .success(let json):
                                    
                                    if let dict = json as? Dictionary<String, Any> {
                                        
                                        var ref: DocumentReference!
                  
                                        if let status = dict["status"] as? String, status == "success" {
                                            
                                            data.merge(dict: dict)
                                                   
                                            ref = db.addDocument(data: data) { (errors) in
                                                
                                                if errors != nil {
                                                    
                                                    self.showErrorAlert("Oops !", msg: errors!.localizedDescription)
                                                    return
                                                    
                                                }
                                                
                                                
                                                
                                                if root_id != nil {
                                                    DataService.instance.mainFireStoreRef.collection("Comments").document(root_id).updateData(["has_reply": true, "Update_timestamp": FieldValue.serverTimestamp()])
                                                } else {
                                                    
                                                    print("Not a reply")
                                                    
                                                }
                                           
                                                var start = 0
                                                let item = CommentModel(postKey: ref.documentID, Comment_model: data)
                         
                                                
                                                
                                                if index != nil {
                                                    start = index + 1
                                                    self.CommentList.insert(item, at: index + 1)
                                                    self.tableNode.insertRows(at: [IndexPath(row: index + 1, section: 0)], with: .none)
                                                    tableNode.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                                                    
                                                } else {
                                                    
                                                    
                                                    if currentItem.highlight_title != "nil" {
                                                        
                                                        start = 1
                                                        self.CommentList.insert(item, at: 1)
                                                        self.tableNode.insertRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                                                        tableNode.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
                                                        
                                                    } else {
                                                        
                                                        start = 0
                                                        self.CommentList.insert(item, at: 0)
                                                        self.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                                                        tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                                                        
                                                    }
                                                    
                                                    
                                                }
                                                
                                         
                                                
                                                var updatePath: [IndexPath] = []
                                                
                                                for row in start ... CommentList.count - 1 {
                                                    let path = IndexPath(row: row, section: 0)
                                                    updatePath.append(path)
                                                }
                                                
                                                
                                                self.tableNode.reloadRows(at: updatePath, with: .automatic)
 
 
                                            
                                                showNote(text: "Comment sent!")
                                                calculateToTalCmt()
                                                
                                                root_id = nil
                                                reply_to_uid = nil
                                                index = nil
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                case .failure(let err):
                                    
                                    print(err.localizedDescription)
                                    self.showErrorAlert("Oops !", msg: "Can't verify your information to send comment, please try again.")
                                    
                                }
                                
                            }
                        
                        // update layout
                        
                        
                    }
                    
                }
                
            }
            
            
        }
        
    }
     
    func checkduplicateLoading(post: CommentModel) -> Bool {
        
        
        for item in CommentList {
            
            if post.Comment_id == item.Comment_id {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isFeed == true {
            
            should_Play = true
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            isFeed = false
            
        }
        
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                bottomConstraint.constant = -keyboardHeight
                viewHeight.constant = 50
                textConstraint.constant = 8
                bView.isHidden = false
               
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    
        
    @objc func handleKeyboardHide(notification: Notification) {
        
        bottomConstraint.constant = 0
        viewHeight.constant = 80
        textConstraint.constant = 30
        bView.isHidden = true
        
        if cmtTxtView.text.isEmpty == true {
            placeholderLabel.text = "Add comment"
            
        }
        
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        
    }
    
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    
}
extension CommentVC: ASTableDelegate {


    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 50);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
        
       

    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        self.retrieveNextPageWithCompletion { (newPosts) in
            
            self.insertNewRowsInTableNode(newPosts: newPosts)
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
      
            context.completeBatchFetching(true)
            
            
        }
        
    }
    
    func loadReplied(item: CommentModel, indexex: Int, root_index: Int) {
        
        if let item_id = item.Comment_id {
            
            
            let db = DataService.instance.mainFireStoreRef
            //whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!)
         
            if item.lastCmtSnapshot == nil {
                
              
                CmtQuery = db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("is_title", isEqualTo: false).whereField("cmt_status", isEqualTo: "valid").whereField("root_id", isEqualTo: item_id).order(by: "timeStamp", descending: false).limit(to: 5)
                
                
            } else {
                
                CmtQuery = db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("is_title", isEqualTo: false).whereField("cmt_status", isEqualTo: "valid").whereField("root_id", isEqualTo: item_id).order(by: "timeStamp", descending: false).limit(to: 5).start(afterDocument: item.lastCmtSnapshot)
            }
       
            CmtQuery.getDocuments {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                guard snapshot.count > 0 else {
                    return
                }
                
                
                var actualPost = [QueryDocumentSnapshot]()
                
                for item in snapshot.documents {
                    
                    let check = CommentModel(postKey: item.documentID, Comment_model: item.data())
                    
                    
                    if self.checkduplicateLoading(post: check) == false {
                                        
                        actualPost.append(item)
                        
                    }
                    
                    
                }
                
                if actualPost.isEmpty != true {
                    
                    
                    let section = 0
                    var indexPaths: [IndexPath] = []

                    var last = 0
                    var start = indexex + 1
                    
                    
                    
                    for row in start...actualPost.count + start - 1 {
                        
                        let path = IndexPath(row: row, section: section)
                        indexPaths.append(path)
                        
                        last = row
                        
                    }
                    
                    
                    
                    for item in actualPost {
                        
                        var updatedItem = item.data()
                        
                        if item == actualPost.last {
                            
                            
                            updatedItem.updateValue(true, forKey: "has_reply")
                            
                        }
                        
                        
                        let items = CommentModel(postKey: item.documentID, Comment_model: updatedItem)
         
                        self.CommentList.insert(items, at: start)
                        
                        
                        if item == snapshot.documents.last {
                            
                            self.CommentList[start].lastCmtSnapshot = actualPost.last
                            
                        }
                        
                        start += 1
                        
                    }
                    
                    self.tableNode.insertRows(at: indexPaths,with: .none)
                    
                    self.CommentList[root_index].lastCmtSnapshot = actualPost.last
                    
                    
                    var updatePath: [IndexPath] = []
                    
                    for row in indexex + 1 ... self.CommentList.count - 1 {
                        let path = IndexPath(row: row, section: 0)
                        updatePath.append(path)
                    }
                    
                    
                    self.tableNode.reloadRows(at: updatePath, with: .automatic)
                    
                    
                    self.tableNode.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
                    
                    
                    

                    
                    
                }
            
                
                
               
                
                
            }
            
            
        }
        
        
    }
    
}


extension CommentVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    
        return self.CommentList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let post = self.CommentList[indexPath.row]
           
        return {
            let node = CommentNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.reply = { (nodes) in
                
                
                
                if self.prev_id != nil {
                    
                    if self.prev_id != self.CommentList[indexPath.row].Comment_id {
                        
                        self.CmtQuery = nil
                        self.prev_id = self.CommentList[indexPath.row].Comment_id
                        
                    }
                    
                    
                } else {
                    
                    self.prev_id = self.CommentList[indexPath.row].Comment_id
                    
                }
                
  
                if post.root_id != "nil", post.has_reply == true {
                    
                    let newIndex = self.findIndexForRootCmt(post: post)
                    let newPost = self.CommentList[newIndex]
                    
                    
                    
                    
                    let newDict = ["Comment_uid": post.Comment_uid!, "timeStamp": post.timeStamp!, "text": post.text!, "cmt_status": "valid", "isReply": true, "Mux_playbackID": post.Mux_playbackID!, "root_id": post.root_id!, "has_reply": false, "Update_timestamp": post.Update_timestamp!, "reply_to": post.reply_to!, "is_title": false] as [String : Any]
                
                    let elem = CommentModel(postKey: post.Comment_id, Comment_model: newDict)
                    self.CommentList[indexPath.row] = elem
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                    
                    self.loadReplied(item: newPost, indexex: indexPath.row, root_index: newIndex)
                    
                    
                } else {
                    
                    
                    
                    let newDict = ["Comment_uid": post.Comment_uid!, "timeStamp": post.timeStamp!, "text": post.text!, "cmt_status": "valid", "isReply": false, "Mux_playbackID": post.Mux_playbackID!, "root_id": "nil", "has_reply": false, "Update_timestamp": post.Update_timestamp!, "reply_to": post.reply_to!, "is_title": false] as [String : Any]
                
                    let elem = CommentModel(postKey: post.Comment_id, Comment_model: newDict)
                    self.CommentList[indexPath.row] = elem
                    
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                    
                    self.loadReplied(item: post, indexex: indexPath.row, root_index: indexPath.row)
                    
                }
                
                
                
                
            }
            
            return node
        }
        
    }
    
    func findIndexForRootCmt(post: CommentModel) -> Int {
        
        index = 0
        
        
        for item in CommentList {
            
            
            if item.Comment_id == post.root_id
            {
                return index
                
            } else {
                
                index += 1
            }
            
        }
        
        return index
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        
        //guard let cell = node as? PostNode else { return }
        
       
    
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
    
        
        // guard let cell = node as? PostNode else { return }
        
       
        
    }
    
    func getuserName(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { [self]  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item.data()["username"] as? String {
                        
                    
                        placeholderLabel.text = "Reply to @\(username)"
                        
                        
                    }
                    
                }
            
        }
        
        
    }
 
        
}

extension CommentVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([QueryDocumentSnapshot]) -> Void) {
        
        let db = DataService.instance.mainFireStoreRef
        //whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!)
     
        if lastDocumentSnapshot == nil {
            
          
            query = db.collection("Comments").whereField("isReply", isEqualTo: false).whereField("is_title", isEqualTo: false).whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").order(by: "Update_timestamp", descending: true).limit(to: 20)
            
            
        } else {
            
            query = db.collection("Comments").whereField("isReply", isEqualTo: false).whereField("is_title", isEqualTo: false).whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").order(by: "Update_timestamp", descending: true).start(afterDocument: lastDocumentSnapshot)
        }
        
        query.getDocuments { [self] (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                print("Successfully retrieved \(snap!.count) Comments.")
                let items = snap?.documents
                self.lastDocumentSnapshot = snap!.documents.last
                DispatchQueue.main.async {
                    block(items!)
                }
                
            } else {
                
                let items = snap?.documents
                DispatchQueue.main.async {
                    block(items!)
                }
              
                
            }
            
            
        }
        
    }
    
    func insertNewRowsInTableNode(newPosts: [QueryDocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        let section = 0
        
        var actualPost = [QueryDocumentSnapshot]()
        
        
        for item in newPosts {
            
            let inputItem = CommentModel(postKey: item.documentID, Comment_model: item.data())
            
            if checkduplicateLoading(post: inputItem) != true {
                
                actualPost.append(item)
                
            }
            
        }
        
        guard actualPost.count > 0 else {
            return
        }
  
        var items = [CommentModel]()
        var indexPaths: [IndexPath] = []
        let total = self.CommentList.count + actualPost.count
        
        for row in self.CommentList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in actualPost {
            
            let item = CommentModel(postKey: i.documentID, Comment_model: i.data())
            items.append(item)
          
        }
        
    
        self.CommentList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
        
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        cmtTxtView.becomeFirstResponder()
        
        if let uid = CommentList[indexPath.row].Comment_uid {
            getuserName(uid: uid)
        } else{
            placeholderLabel.text = "Reply to @Undefined"
        }
        
        if CommentList[indexPath.row].isReply == false {
            root_id = CommentList[indexPath.row].Comment_id
            index = indexPath.row
        } else {
            root_id = CommentList[indexPath.row].root_id
            index = findIndexForRootCmt(post: CommentList[indexPath.row])
        }
        
        
        reply_to_uid =  CommentList[indexPath.row].Comment_uid
        
        
        tableNode.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: true)
 
    }
    
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5 // 0.5 second press
        longPressGesture.delegate = self
        self.tableNode.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableNode.view)
            if let indexPath = self.tableNode.indexPathForRow(at: touchPoint) {
                
                
                let uid = Auth.auth().currentUser?.uid
                
                tableNode.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: true)
                
                let sheet = UIAlertController(title: "Comment action", message: "", preferredStyle: .actionSheet)
                
                
                let report = UIAlertAction(title: "Report", style: .default) { (alert) in
                    
                    
                    
                }
                
                let delete = UIAlertAction(title: "Delete", style: .destructive) { [self] (alert) in
                    
                    let item = CommentList[indexPath.row]
                    removeComment(items: item, indexPath: indexPath.row)
                    
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                    
                }
                
                if uid == CommentList[indexPath.row].Comment_uid {
                    
                    
                    sheet.addAction(report)
                    sheet.addAction(delete)
                    sheet.addAction(cancel)
                    
                } else {
                    
                    sheet.addAction(report)
                    sheet.addAction(cancel)
                    
                    
                }

                
                self.present(sheet, animated: true, completion: nil)
                
            }
        }
    }
    
    
    func removeComment(items: CommentModel, indexPath: Int) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Comments")
        
        if items.Comment_id != "nil" {
            
            db.document(items.Comment_id).updateData(["cmt_status": "deleted", "Update_timestamp": FieldValue.serverTimestamp()]) { (err) in
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    self.CommentList.remove(at: indexPath)
                    self.tableNode.deleteRows(at: [IndexPath(item: indexPath, section: 0)], with: .automatic)
                    
                    if items.root_id == "nil" {
                        
                        self.RemoveIndexOfChildComment(from: items, start: indexPath)
                        
                    }
                    
                    
                    showNote(text: "Comment deleted!")
                    DataService.instance.mainRealTimeDataBaseRef.child("Cmt-Deleting").child(items.Comment_id).setValue(["id": items.Comment_id])
                    self.calculateToTalCmt()
                    
                }
            }
            
        } else {
            
            self.showErrorAlert("Ops !", msg: "Unable to remove this comment right now, please try again.")
            
            
        }
        
 

    }
    
    
    func RemoveIndexOfChildComment(from: CommentModel, start: Int) {
        
        
        var indexPaths: [IndexPath] = []
    
        var indexex = 0
        //var count = 1
        if let root_id = from.Comment_id {
            
            
            for item in CommentList {
                
                if item.root_id == root_id {
                    
                    let indexPath = IndexPath(row: indexex, section: 0)
                    indexPaths.append(indexPath)
                    self.CommentList.remove(at: start)
 
                }
                
                
                indexex += 1
                
            }
         
        }
        
        self.tableNode.deleteRows(at: indexPaths, with: .automatic)
        
        
    }
    
    
}
