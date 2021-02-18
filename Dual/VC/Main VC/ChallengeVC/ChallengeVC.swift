//
//  ChallengeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/27/20.
//

import UIKit
import Firebase
import MGSwipeTableCell
import SwiftPublicIP
import Alamofire

enum challengeControl {
    case pending
    case active
    case expire
}

class ChallengeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {

    var ControlChallenge = challengeControl.pending
    var type: String!
    var userid: String!
    var challengeid: String!
    var shouldProcess = true
    var rate_index = 0

    @IBOutlet weak var height1Constant: NSLayoutConstraint!
    @IBOutlet weak var height2Constant: NSLayoutConstraint!
    @IBOutlet weak var height3Constant: NSLayoutConstraint!
    
    @IBOutlet weak var pendingTableView: UITableView!
    @IBOutlet weak var ActiveTableView: UITableView!
    @IBOutlet weak var expireTableView: UITableView!
    
    var maxItem = 0
    
    var pendingList = [ChallengeModel]()
    var activeList = [ChallengeModel]()
    var expireList = [ChallengeModel]()
    
  
    var firstLoad = false
    
    
    private var pullControl1 = UIRefreshControl()
    private var pullControl2 = UIRefreshControl()
    private var pullControl3 = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser?.isAnonymous == true {
            
            print("Login anonymously")
            
            let Lview = LoginView()
            Lview.frame = self.view.layer.bounds
            Lview.SignUpBtn.addTarget(self, action: #selector(ChallengeVC.SignUpBtnPressed), for: .touchUpInside)
            self.view.addSubview(Lview)
            
            return
             
        }
        
        height2Constant.constant = self.view.frame.height * (50/647)
        height3Constant.constant = self.view.frame.height * (50/647)
        
        
        if self.view.frame.height * (150/647) >= 180 {
            
            maxItem = 3
            
        } else if self.view.frame.height * (150/647) >= 150, self.view.frame.height * (150/647) < 180 {
            
            maxItem = 2
            
        } else {
            
            maxItem = 1
            
        }
        
        pendingTableView.delegate = self
        pendingTableView.dataSource = self
        
        ActiveTableView.delegate = self
        ActiveTableView.dataSource = self
        
        expireTableView.delegate = self
        expireTableView.dataSource = self
        
    
        
        loadPendingChallenges(maxItem: maxItem) {
            
            self.loadActiveChallenges(maxItem: self.maxItem) {
                
                self.loadExpireChallenges(maxItem: self.maxItem) {
                    
                   self.loadOverallChallenge()
                    
                }
                
            }
            
        }
        
        // setup pull control for each tableView
        
        //1
        pullControl1.tintColor = UIColor.systemOrange
        pullControl1.addTarget(self, action: #selector(refreshListData1(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            pendingTableView.refreshControl = pullControl1
        } else {
            pendingTableView.addSubview(pullControl1)
        }
        
        //2
        
        
        pullControl2.tintColor = UIColor.systemOrange
        pullControl2.addTarget(self, action: #selector(refreshListData2(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            ActiveTableView.refreshControl = pullControl2
        } else {
            ActiveTableView.addSubview(pullControl2)
        }
        
        //3
        
        
        pullControl3.tintColor = UIColor.systemOrange
        pullControl3.addTarget(self, action: #selector(refreshListData3(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            expireTableView.refreshControl = pullControl3
        } else {
            expireTableView.addSubview(pullControl3)
        }
        
        
    }
    
    
    @objc private func refreshListData1(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.pendingList.removeAll()
        loadPendingChallenges(maxItem: maxItem) {
        
            print("Finish reload for pending list")
                              
        }
              
    }
    
    @objc private func refreshListData2(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.activeList.removeAll()
        
        loadActiveChallenges(maxItem: maxItem) {
        
            print("Finish reload for active list")
                              
        }
              
    }
    
    @objc private func refreshListData3(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.expireList.removeAll()
        
        loadExpireChallenges(maxItem: maxItem) {
        
            print("Finish reload for expire list")
                              
        }
              
    }
    
    
    @objc func SignUpBtnPressed() {
        
        self.performSegue(withIdentifier: "moveToLoginVC3", sender: nil)
        
    }
    
    
    func loadPendingChallenges(maxItem: Int, completed: @escaping DownloadComplete) {
        
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Pending").whereField("created_timeStamp", isGreaterThan: myNSDate).limit(to: maxItem).getDocuments { (snap, err) in
       
            if err != nil {
                self.pendingTableView.isHidden = true
                self.height1Constant.constant = self.view.frame.height * (60/647)
                
                if self.pullControl1.isRefreshing == true {
                    self.pullControl1.endRefreshing()
                }
                
                
                completed()
                return
            }
            
                if snap?.isEmpty == true {
                    
                    self.pendingTableView.isHidden = true
                    self.height1Constant.constant = self.view.frame.height * (60/647)
                    completed()
                    
                } else {
                    
                    
                    self.pendingTableView.isHidden = false
                    
                    if maxItem == 1 {
                        
                        self.height1Constant.constant = self.view.frame.height * (130/647)
                        
                    } else {
                        
                        let count = snap?.count
                        
                        if count == 1 {
                            
                            self.height1Constant.constant = self.view.frame.height * (130/647)
                            
                        }
                        else if count == 2 {
                            
                            self.height1Constant.constant = self.view.frame.height * (160/647)
                            
                            
                        } else {
                            
                            self.height1Constant.constant = self.view.frame.height * (230/647)
                            
                        }
                        
                        
                    }
                    
                    
                    for item in snap!.documents {
                        
                        
                        let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                        self.pendingList.append(dict)
                        
                   
                    }
                    
                    
                    if self.pullControl1.isRefreshing == true {
                        self.pullControl1.endRefreshing()
                    }
                    
                    
                    
                    self.ControlChallenge = challengeControl.pending
                    self.pendingTableView.reloadData()
                    
                   
                    completed()
                
                
                }
        
            
          
        }
        
        
    }
    
    
    func findExistAndRemove(item: ChallengeModel, completed: @escaping DownloadComplete)  {
        
        var count = 0
        var done = false
       
        if pendingList.isEmpty != true {
            
            for i in pendingList {
                
                if i.sender_ID == item.sender_ID, i.category == item.category, i.messages == item.messages, i.created_timeStamp == item.created_timeStamp {
                    
                    if i.challenge_status != item.challenge_status {
                        
                        pendingList.remove(at: count)
                        //self.pendingTableView.deleteRows(at: [IndexPath(row: count, section: 0)], with: .automatic)
                        
                        if self.pendingList.count == 1 {
                            
                            self.height1Constant.constant = self.view.frame.height * (130/647)
                        }
                        else if self.pendingList.count == 2 {
                            
                            self.height1Constant.constant = self.view.frame.height * (160/647)
                            
                            
                        } else {
                            
                            self.pendingTableView.isHidden =  true
                            self.height1Constant.constant = self.view.frame.height * (60/647)
                            
                        }
                        
                        shouldProcess = true
                        break
                        
                    } else {
                        
                        
                        shouldProcess = false
                        
                    }
                    
                    
                    
                }
                
                count += 1
                
            }
            
            
            done = true
            self.ControlChallenge = challengeControl.pending
            self.pendingTableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                
                completed()
                
            }
            
            
        }
        
        
        
        if activeList.isEmpty != true {
            
            if done == false {
                
                count = 0
                
                for i in activeList {
                    
                    if i.sender_ID == item.sender_ID, i.category == item.category, i.messages == item.messages, i.created_timeStamp == item.created_timeStamp {
                        
                        
                        if i.challenge_status != item.challenge_status {
                            
                            activeList.remove(at: count)
                            //self.ActiveTableView.deleteRows(at: [IndexPath(row: count, section: 0)], with: .automatic)
                            
                            if self.activeList.count == 1 {
                                
                                self.height2Constant.constant = self.view.frame.height * (130/647)
                            }
                            else if self.activeList.count == 2 {
                                
                                self.height2Constant.constant = self.view.frame.height * (160/647)
                                
                                
                            } else {
                                
                                self.ActiveTableView.isHidden =  true
                                self.height2Constant.constant = self.view.frame.height * (60/647)
                                
                            }
                            
                            shouldProcess = true
                            break
                            
                        } else {
                            
                            shouldProcess = false
                            
                        }
                        
                        
                        
                    }
                    
                    count += 1
                    
                }
                
            }
            
            done = true
            self.ControlChallenge = challengeControl.active
            self.ActiveTableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                
                completed()
                
            }
            
        }
        
        
        if expireList.isEmpty != true {
            
            if done == false {
                
                count = 0
                
                for i in expireList {
                    
                    if i.sender_ID == item.sender_ID, i.category == item.category, i.messages == item.messages, i.created_timeStamp == item.created_timeStamp {
                        
                        
                        if i.challenge_status != item.challenge_status {
                            
                            
                            expireList.remove(at: count)
                            //self.expireTableView.deleteRows(at: [IndexPath(row: count, section: 0)], with: .automatic)
                            
                            if self.expireList.count == 1 {
                                
                                self.height3Constant.constant = self.view.frame.height * (130/647)
                            }
                            else if self.expireList.count == 2 {
                                
                                self.height3Constant.constant = self.view.frame.height * (160/647)
                                
                                
                            } else {
                                
                                self.expireTableView.isHidden =  true
                                self.height3Constant.constant = self.view.frame.height * (60/647)
                                
                            }
                            
                            shouldProcess = true
                            break
                            
                        } else {
                            
                            
                            shouldProcess = false
                            
                            
                        }
                       
                        
                        
                    }
                    
                    count += 1
                    
                }
                
                done = true
                print(expireList.count)
                self.ControlChallenge = challengeControl.expire
                self.expireTableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    
                    completed()
                    
                }
                
            }
                
        }
        
        
        if done == false {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                completed()
                
            }
            
        }
        
        
           
        
    }
    
    
    func loadActiveChallenges(maxItem: Int, completed: @escaping DownloadComplete) {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        let uid = Auth.auth().currentUser?.uid
        
        db.whereField("uid_list", arrayContains: uid!).whereField("challenge_status", isEqualTo: "Active").whereField("started_timeStamp", isGreaterThan: myNSDate).limit(to: maxItem).getDocuments { [self] (snap, err) in
       
            if err != nil {
                
                self.ActiveTableView.isHidden = true
                self.height2Constant.constant = self.view.frame.height * (60/647)
                if self.pullControl2.isRefreshing == true {
                    self.pullControl2.endRefreshing()
                }
                completed()
                return
            }
            
            if snap?.isEmpty == true {
                
                self.ActiveTableView.isHidden = true
                self.height2Constant.constant = self.view.frame.height * (60/647)
                completed()
                
            } else {
                
                self.ActiveTableView.isHidden = false
                
                
                if maxItem == 1 {
                    
                    self.height2Constant.constant = self.view.frame.height * (130/647)
                    
                } else {
                    
                    let count = snap?.count
                    
                    if count == 1 {
                        
                        self.height2Constant.constant = self.view.frame.height * (130/647)
                    }
                    else if count == 2 {
                        
                        self.height2Constant.constant = self.view.frame.height * (160/647)
                        
                        
                    } else {
                        
                        self.height2Constant.constant = self.view.frame.height * (230/647)
                        
                    }
                    
                    
                }
                
                
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.activeList.append(dict)
       
                }
                
                self.ControlChallenge = challengeControl.active
               
                self.ActiveTableView.reloadData()
                
                if self.pullControl2.isRefreshing == true {
                    self.pullControl2.endRefreshing()
                }
                
                completed()
                
                
            }
            
        
        }
        
        
    }
    
    
    func loadExpireChallenges(maxItem: Int, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        let uid = Auth.auth().currentUser?.uid
        
        db.whereField("uid_list", arrayContains: uid!).whereField("challenge_status", isEqualTo: "Expired").order(by: "updated_timeStamp", descending: true).limit(to: maxItem).getDocuments { (snap, err) in
       
            if err != nil {
                
                self.expireTableView.isHidden = true
                self.height3Constant.constant = self.view.frame.height * (60/647)
                
                if self.pullControl3.isRefreshing == true {
                    self.pullControl3.endRefreshing()
                }
                
                completed()
                return
            }
            
            if snap?.isEmpty == true {
                
                self.expireTableView.isHidden = true
                self.height3Constant.constant = self.view.frame.height * (60/647)
                completed()
                
            } else {
            
                self.expireTableView.isHidden = false
                
                if maxItem == 1 {
                    
                    self.height3Constant.constant = self.view.frame.height * (130/647)
                    
                } else {
                    
                    let count = snap?.count
                    
                    if count == 1 {
                        
                        self.height3Constant.constant = self.view.frame.height * (130/647)
                    }
                    else if count == 2 {
                        
                        self.height3Constant.constant = self.view.frame.height * (160/647)
                        
                        
                    } else {
                        
                        self.height3Constant.constant = self.view.frame.height * (230/647)
                        
                    }
                    
                    
                }
                
                
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.expireList.append(dict)
           
                    
                }
                
                self.ControlChallenge = challengeControl.expire
                self.expireTableView.reloadData()
                
                
                if self.pullControl3.isRefreshing == true {
                    self.pullControl3.endRefreshing()
                }
                
                completed()
               
                
            }
            
        
        }
        
        
    }
    
    func loadOverallChallenge() {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        let uid = Auth.auth().currentUser?.uid
            
            
        db.whereField("uid_list", arrayContains: uid!).addSnapshotListener { [self] (snap, err) in
            
            var start = 0
            snap!.documentChanges.forEach { diff in
                
                if firstLoad == true {
                    
                    let item = ChallengeModel(postKey: diff.document.documentID, Challenge_model: diff.document.data())
                    
                    if (diff.type == .added) {
                        
                        
                        if item.challenge_status == "Pending" {
                            
                            if diff.document.data()["receiver_ID"] as? String == uid {
                                  
                                if shouldProcess == true {
                                    
                                    
                                    self.processItem(diff: diff, item: item)
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            if shouldProcess == true {
                                
                                self.processItem(diff: diff, item: item)
                                
                            }
                        }
                                
                        
                        
                    } else if (diff.type == .modified) {
                        
                        if item.challenge_status == "Pending" {
                            
                            if diff.document.data()["receiver_ID"] as? String == uid {
                                  
                                findExistAndRemove(item: item) {
                                    
                                    if shouldProcess == true {
                                        
                                        
                                        self.processItem(diff: diff, item: item)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            findExistAndRemove(item: item) {
                                
                                if shouldProcess == true {
                                    
                                    
                                    self.processItem(diff: diff, item: item)
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                } else {
                    
                    if snap?.isEmpty == true {
                        
                        firstLoad = true
                        print("start observing challenge")
                        
                    } else {
                        
                        if start == snap!.count - 1 {
                            
                            firstLoad = true
                            print("start observing challenge")
                            
                        }
                        
                        start+=1
                        
                    }
                    
                   
                    
                }
                
            }
            
        }
        
        
    }
    
    func processItem(diff: DocumentChange, item: ChallengeModel) {
        
        if diff.document.data()["challenge_status"] as! String == "Pending" {
            
            
            self.ControlChallenge = challengeControl.pending
            if pendingList.count == maxItem {
                
                pendingList.remove(at: maxItem - 1)
                self.pendingTableView.deleteRows(at: [IndexPath(row: maxItem - 1, section: 0)], with: .automatic)
                
            }
            
            pendingList.insert(item, at: 0)
            
            
            
            
            if pendingList.count == 1 {
                
                self.height1Constant.constant = self.view.frame.height * (130/647)
            }
            else if pendingList.count == 2 {
                
                self.height1Constant.constant = self.view.frame.height * (160/647)
                
            } else {
                
                self.height1Constant.constant = self.view.frame.height * (230/647)
                
            }
            
            
            self.ControlChallenge = challengeControl.pending
            self.pendingTableView.isHidden = false
            pendingTableView.reloadData()
            
        } else if diff.document.data()["challenge_status"] as! String == "Active" {
            
            
            self.ControlChallenge = challengeControl.active
            
            if activeList.count == maxItem {
                
                activeList.remove(at: maxItem - 1)
                self.ActiveTableView.deleteRows(at: [IndexPath(row: maxItem - 1, section: 0)], with: .automatic)
                
            }
            
            activeList.insert(item, at: 0)
           
            
            if activeList.count == 1 {
                
                self.height2Constant.constant = self.view.frame.height * (130/647)
            }
            else if activeList.count == 2 {
                
                self.height2Constant.constant = self.view.frame.height * (160/647)
                
            } else {
                
                self.height2Constant.constant = self.view.frame.height * (230/647)
                
            }
            
           
            self.ActiveTableView.isHidden = false
            ActiveTableView.reloadData()
            
            
            
        } else if diff.document.data()["challenge_status"] as! String == "Expired" {
            
            
            
            self.ControlChallenge = challengeControl.expire
            
            if expireList.count == maxItem {
                
                expireList.remove(at: maxItem - 1)
                self.expireTableView.deleteRows(at: [IndexPath(row: maxItem - 1, section: 0)], with: .automatic)
            }
            
            expireList.insert(item, at: 0)
            
            
            if expireList.count == 1 {
                
                self.height3Constant.constant = self.view.frame.height * (130/647)
            }
            else if expireList.count == 2 {
                
                self.height3Constant.constant = self.view.frame.height * (160/647)
                
                
            } else {
                
                self.height3Constant.constant = self.view.frame.height * (230/647)
                
            }
            
            
            
            self.expireTableView.isHidden = false
            expireTableView.reloadData()
            

        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch self.ControlChallenge {
            
        case .pending:
            return pendingList.count
        case .active:
            return activeList.count
            
        case .expire:
            return expireList.count
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 25    //if you want round edges
        maskLayer.backgroundColor = UIColor.red.cgColor
        
        switch self.ControlChallenge {
            
        case .pending:
           
            if tableView == self.pendingTableView {
                
                let item = pendingList[indexPath.row]
            
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "PendingTableViewCell") as? PendingTableViewCell {
                    
                    
                    cell.delegate = self
                    cell.configureCell(item)
    
                    maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
                    cell.layer.mask = maskLayer
                    
                    return cell
                    
                } else {
                    
                    return PendingTableViewCell()
                }
                
            } else {
                
                return PendingTableViewCell()
                
            }
            
            
        case .active:
            
            if tableView == self.ActiveTableView {
               
                let item = activeList[indexPath.row]
                if let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveTableViewCell") as? ActiveTableViewCell {
                    
                    cell.delegate = self
                    cell.configureCell(item)
                    
                    
                    maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
                    cell.layer.mask = maskLayer
                    
                    return cell
                    
                } else {
                    
                    return ActiveTableViewCell()
                }
                
            } else {
                
                return ActiveTableViewCell()
                
            }
            
        case .expire:
            
            if tableView == self.expireTableView {
               
                let item = expireList[indexPath.row]
                if let cell = tableView.dequeueReusableCell(withIdentifier: "ExpireTableViewCell") as? ExpireTableViewCell {
                    
                    
                    cell.delegate = self
                    cell.configureCell(item)
                    
                    maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
                    cell.layer.mask = maskLayer
                    
                    return cell
                    
                } else {
                    
                    return ExpireTableViewCell()
                }
                
            } else {
                
                return ExpireTableViewCell()
                
            }
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch self.ControlChallenge {
        
            case .pending:
      
                for item_uid in self.pendingList[indexPath.row].uid_list {
                    
                    if item_uid != Auth.auth().currentUser?.uid {
                        
                        self.userid = item_uid
                   
                    }
           
                }

            case .active:
                
                for item_uid in self.activeList[indexPath.row].uid_list {
                    
                    if item_uid != Auth.auth().currentUser?.uid {
                        
                        self.userid = item_uid
                   
                    }
           
                }
                
            case .expire:
                
                for item_uid in self.expireList[indexPath.row].uid_list {
                    
                    if item_uid != Auth.auth().currentUser?.uid {
                        
                        self.userid = item_uid
                   
                    }
           
                }
        }
        
        
        self.performSegue(withIdentifier: "moveToUserProfileVC1", sender: nil)
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75.0
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        
        return true
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        var type = ""
        let padding = 25
        swipeSettings.expandLastButtonBySafeAreaInsets = true
        swipeSettings.transition = .border
        
        
        if self.pendingTableView.indexPath(for: cell)?.row != nil {
            
            type = "Pending"
            
        } else if self.ActiveTableView.indexPath(for: cell)?.row != nil {
            
            type = "Active"
            
        } else if self.expireTableView.indexPath(for: cell)?.row != nil {
            
            type = "Expired"
            
        }
        
       
        if type == "Pending" {
            
          
            if direction == MGSwipeDirection.rightToLeft {
                expansionSettings.fillOnTrigger = false;
                expansionSettings.threshold = 1.1
                     
                let declineImg = resizeImage(image: UIImage(named: "decline")!, targetSize: CGSize(width: 20.0, height: 20.0))
                let acceptImg = resizeImage(image: UIImage(named: "accept")!, targetSize: CGSize(width: 25.0, height: 25.0))
                
                let accept = MGSwipeButton(title: "", icon: acceptImg, backgroundColor: UIColor.clear, padding: padding,  callback: { (cell) -> Bool in
                    
                    
                    self.AcceptAtIndexPath(self.pendingTableView.indexPath(for: cell)!)

                    return false; //don't autohide to improve delete animation
                    
                    
                });
                
                
                
                let decline = MGSwipeButton(title: "", icon: declineImg, backgroundColor: UIColor.clear, padding: padding, callback: { (cell) -> Bool in
                    
                    
                    
                    self.RejectAtIndexPath(self.pendingTableView.indexPath(for: cell)!)
                    
                    return false; //autohide
                    
                });
                
                return [decline, accept]
                
            } else {
                
                return nil
                
            }
            
        } else if type == "Active" {
            
            
            let callImg = resizeImage(image: UIImage(named: "call")!, targetSize: CGSize(width: 25.0, height: 25.0))
            let messImg = resizeImage(image: UIImage(named: "mess")!, targetSize: CGSize(width: 25.0, height: 25.0))
            let closeImg = resizeImage(image: UIImage(named: "closed")!, targetSize: CGSize(width: 25.0, height: 25.0))
            
               
            
            if direction == MGSwipeDirection.rightToLeft {
                expansionSettings.fillOnTrigger = false;
                expansionSettings.threshold = 2.0
                      
                let Call = MGSwipeButton(title: "", icon: callImg, backgroundColor: UIColor.clear, padding: padding,  callback: { (cell) -> Bool in
                    
                    
                    
                    
                    //self.deleteAtIndexPath(self.tableView.indexPath(for: cell)!, stripe_id: self.stripeIDs)
                    
                    return false; //don't autohide to improve delete animation
                    
                    
                });
                
                
                
                let Message = MGSwipeButton(title: "", icon: messImg, backgroundColor: UIColor.clear, padding: padding, callback: { (cell) -> Bool in
                    
                  
                    //self.defaultAtIndexPath(self.tableView.indexPath(for: cell)!, stripe_id: self.stripeIDs)
                    
                    return false; //autohide
                    
                });
                
                let Close = MGSwipeButton(title: "", icon: closeImg, backgroundColor: UIColor.clear, padding: padding, callback: { (cell) -> Bool in
                    
                  
                    
                    
                    self.CloseAtIndexPath(self.ActiveTableView.indexPath(for: cell)!)

                    
                    return false; //autohide
                    
                });
                
                return [Message, Call, Close]
                
            } else {
                
                return nil
                
            }
            
            
        } else if type == "Expired" {
            
            
            let starImg = resizeImage(image: UIImage(named: "star")!, targetSize: CGSize(width: 25.0, height: 25.0))
            let reportImg = resizeImage(image: UIImage(named: "reports")!, targetSize: CGSize(width: 25.0, height: 25.0))
            
        
            if direction == MGSwipeDirection.rightToLeft {
                expansionSettings.fillOnTrigger = false;
                expansionSettings.threshold = 1.1
                
                let report = MGSwipeButton(title: "", icon: reportImg, backgroundColor: UIColor.clear, padding: padding,  callback: { (cell) -> Bool in
                    
                    
                    let slideVC =  reportView()
                    
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = self
    
                    self.present(slideVC, animated: true, completion: nil)
                    
                    //self.deleteAtIndexPath(self.tableView.indexPath(for: cell)!, stripe_id: self.stripeIDs)
                    
                    return false; //don't autohide to improve delete animation
                    
                    
                });
                
                
                
                let rate = MGSwipeButton(title: "", icon: starImg, backgroundColor: UIColor.clear, padding: padding, callback: { [self] (cell) -> Bool in
                    
                  
                    let rateViewController = CWRateKitViewController()
                    rateViewController.delegate = self
                    rateViewController.modalPresentationStyle = .formSheet
                    rateViewController.overlayOpacity = 0.8
                    rateViewController.animationDuration = 0.1
                    
                    rateViewController.confirmRateEnabled = true
                    rateViewController.showCloseButton = true
                    
                    rateViewController.showHeaderImage = true
                    rateViewController.headerImage = UIImage(named: "initial_smile")
                    rateViewController.headerImageSize = CGSize(width: 52.0, height: 52.0)
                    rateViewController.headerImageIsStatic = false
                    
                    rateViewController.cornerRadius = 16.0
                    rateViewController.showShadow = true
                    rateViewController.animationType = .bounce
                    
                    rateViewController.selectedMarkImage = UIImage(named: "star_selected.png")
                    rateViewController.unselectedMarkImage = UIImage(named: "star_unselected.png")
                    rateViewController.sizeMarkImage = CGSize(width: 30.0, height: 30.0)
                    
                    
                    rateViewController.hapticMoments = [.willChange, .willSubmit]
                    
                    rateViewController.headerImages = [
                        UIImage(named: "smile_1"),
                        UIImage(named: "smile_2"),
                        UIImage(named: "smile_3"),
                        UIImage(named: "smile_4"),
                        UIImage(named: "smile_5")
                    ]
                    
                    rateViewController.submitTextColor = .orange
                    rateViewController.submitText = "Send rate"
                    
                    
                    let uid_lis = expireList[self.expireTableView.indexPath(for: cell)!.row].uid_list
                    rate_index = self.expireTableView.indexPath(for: cell)!.row
                
                    for item in uid_lis! {
                        
                        if item != Auth.auth().currentUser?.uid {
                            
                            
                            userid = item
                            challengeid = expireList[self.expireTableView.indexPath(for: cell)!.row]._challenge_id
                            self.present(rateViewController, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                    
                    
                    
                    return false; //autohide
                    
                });
                
                if expireList[self.expireTableView.indexPath(for: cell)!.row]._shouldShowRate == nil {
                    
                    return nil
                    
                } else {
                    
                    
                    if expireList[self.expireTableView.indexPath(for: cell)!.row]._shouldShowRate ==  true {
                        
                        return [report, rate]
                        
                    } else {
                        
                        return [report]
                        
                    }
                    
                }
                
                
                
                
                
                
            } else {
                
                return nil
                
            }
            
            
        } else {
            
            
            return nil
        }
        
        
    }
    
    func AcceptAtIndexPath(_ path: IndexPath) {
           
        let item = pendingList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Active", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    return
                }
                
                
                
                
            }
            
        }
        
        
        
    }
    
    
    func RejectAtIndexPath(_ path: IndexPath) {
           
        let item = pendingList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Rejected", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                }
                
                
                
            }
            
        }
        
        
        
    }
    
    
    func CloseAtIndexPath(_ path: IndexPath) {
           
        
        
        let item = activeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Expired", "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                }
                
                
                
            }
            
        }
   
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func viewAllPendingBtnPressed(_ sender: Any) {
        
        type = "Pending"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    
    @IBAction func viewAllActiveBtnPressed(_ sender: Any) {
        
        type = "Active"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    @IBAction func ViewAllExpireBtnPressed(_ sender: Any) {
        
        type = "Expired"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MoveToViewAllVC"{
            if let destination = segue.destination as? ViewAllChallengeVC
            {
                
                destination.type = self.type
                destination.viewUID = Auth.auth().currentUser?.uid
                
            }
        } else if segue.identifier == "moveToUserProfileVC1"
        {
            if let destination = segue.destination as? UserProfileVC
            {
                
                destination.isFeed = false
                destination.uid = self.userid
                  
            }
        }
        
    }
    
}

extension ChallengeVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension ChallengeVC: CWRateKitViewControllerDelegate {

    func didChange(rate: Int) {
        print("Current rate is \(rate)")
    }

    func didSubmit(rate: Int) {
        
        if rate != 0 {
            
            submitRateToData(rate: rate)
            
        }
        
    }
    
    func didDismiss() {
        print("Dismiss the rate view")
    }
    
    
    func submitRateToData(rate: Int) {
        
        print("Submit with rate \(rate)")
        
        
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
            if let error = error {
                
                print(error.localizedDescription)
                self.showErrorAlert("Oops !", msg: "Can't verify your information to send challenge, please try again.")
                
            } else if let string = string {
                
                DispatchQueue.main.async() { [self] in
                    
                    let device = UIDevice().type.rawValue
                    
                    var data = [String:Any]()
                    
                    let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(string)
                    
                    data = ["from_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "rate_status": "valid", "challenge_id": challengeid!, "to_uid": userid!, "rate_value": rate] as [String : Any]
                        
                        
                   let db = DataService.instance.mainFireStoreRef.collection("Challenge_rate")
                    
                    AF.request(urls, method: .get)
                        .validate(statusCode: 200..<500)
                        .responseJSON { responseJSON in
                            
                            switch responseJSON.result {
                                
                            case .success(let json):
                                
                                if let dict = json as? Dictionary<String, Any> {
                                    
                                    data.merge(dict: dict)
                                    
                                    db.addDocument(data: data) { (errors) in
                                        
                                        if errors != nil {
                                                                        
                                            print(errors!.localizedDescription)
                                            return
                                            
                                        }
                                        let item = expireList[rate_index]
                                        item._shouldShowRate = false
                                        self.expireTableView.reloadRows(at: [IndexPath(row: rate_index, section: 0)], with: .automatic)
                                        
                                    }
                                    
                                    
                                }
                                
                            case .failure(let err):
                                
                                print(err.localizedDescription)
                                self.showErrorAlert("Oops !", msg: "Can't verify your information to send comment, please try again.")
                                
                            }
                            
                        }
                    
                
                    
                    
                }
                
            }
            
        }
        
    
        
    }
    
   
}
