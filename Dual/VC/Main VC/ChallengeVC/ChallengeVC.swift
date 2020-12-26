//
//  ChallengeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/27/20.
//

import UIKit
import Firebase


enum challengeControl {
    case pending
    case active
    case expire
}

class ChallengeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ControlChallenge = challengeControl.pending
    var type: String!
    var userid: String!

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
                self.height1Constant.constant = self.view.frame.height * (50/647)
                completed()
                return
            }
            
                if snap?.isEmpty == true {
                    
                    self.pendingTableView.isHidden = true
                    self.height1Constant.constant = self.view.frame.height * (50/647)
                    completed()
                    
                } else {
                    
                    
                    self.pendingTableView.isHidden = false
                    
                    if maxItem == 1 {
                        
                        self.height1Constant.constant = self.view.frame.height * (120/647)
                        
                    } else {
                        
                        let count = snap?.count
                        
                        if count == 1 {
                            
                            self.height1Constant.constant = self.view.frame.height * (120/647)
                            
                        }
                        else if count == 2 {
                            
                            self.height1Constant.constant = self.view.frame.height * (150/647)
                            
                            
                        } else {
                            
                            self.height1Constant.constant = self.view.frame.height * (200/647)
                            
                        }
                        
                        
                    }
                    
                    
                    for item in snap!.documents {
                        
                        
                        let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                        self.pendingList.append(dict)
                        
                        
                        
                        
                    }
                    
                    
                    self.ControlChallenge = challengeControl.pending
                    self.pendingTableView.reloadData()
                    self.firstLoad = true
                    completed()
                
                
                }
        
            
          
        }
        
        
    }
    
    
    func findExistAndRemove(item: ChallengeModel, completed: @escaping DownloadComplete)  {
        
        var count = 0
        var done = false
       
        
        for i in pendingList {
            
            if i.sender_ID == item.sender_ID, i.category == item.category, i.messages == item.messages, i.created_timeStamp == item.created_timeStamp {
                
                pendingList.remove(at: count)
                
                if self.pendingList.count == 1 {
                    
                    self.height1Constant.constant = self.view.frame.height * (120/647)
                }
                else if self.pendingList.count == 2 {
                    
                    self.height1Constant.constant = self.view.frame.height * (150/647)
                    
                    
                } else {
                    
                    self.pendingTableView.isHidden =  true
                    self.height1Constant.constant = self.view.frame.height * (50/647)
                    
                }
                
                done = true
                self.ControlChallenge = challengeControl.pending
                self.pendingTableView.reloadData()
                completed()
                break
                
            }
            
            count += 1
            
        }
        
        if done == false {
            
            count = 0
            
            for i in activeList {
                
                if i.sender_ID == item.sender_ID, i.category == item.category, i.messages == item.messages, i.created_timeStamp == item.created_timeStamp {
                    
                    activeList.remove(at: count)
                    
                    if self.activeList.count == 1 {
                        
                        self.height2Constant.constant = self.view.frame.height * (120/647)
                    }
                    else if self.activeList.count == 2 {
                        
                        self.height2Constant.constant = self.view.frame.height * (150/647)
                        
                        
                    } else {
                        
                        self.ActiveTableView.isHidden =  true
                        self.height2Constant.constant = self.view.frame.height * (50/647)
                        
                    }
                    
                    done = true
                    self.ControlChallenge = challengeControl.active
                    self.ActiveTableView.reloadData()
                    completed()
                    break
                    
                }
                
                count += 1
                
            }
            
        }
        
        
        
        if done == false {
            
            count = 0
            
            for i in expireList {
                
                if i.sender_ID == item.sender_ID, i.category == item.category, i.messages == item.messages, i.created_timeStamp == item.created_timeStamp {
                    
                    expireList.remove(at: count)
                    
                    if self.expireList.count == 1 {
                        
                        self.height3Constant.constant = self.view.frame.height * (120/647)
                    }
                    else if self.expireList.count == 2 {
                        
                        self.height3Constant.constant = self.view.frame.height * (150/647)
                        
                        
                    } else {
                        
                        self.expireTableView.isHidden =  true
                        self.height3Constant.constant = self.view.frame.height * (50/647)
                        
                    }
                    
                    done = true
                    self.ControlChallenge = challengeControl.expire
                    self.expireTableView.reloadData()
                    completed()
                    break
                    
                }
                
                count += 1
                
            }
            
        }
        
        if done == false {
            
            completed()
            
        }
           
        
    }
    
    
    func loadActiveChallenges(maxItem: Int, completed: @escaping DownloadComplete) {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Active").whereField("started_timeStamp", isGreaterThan: myNSDate).limit(to: maxItem).getDocuments { (snap, err) in
       
            if err != nil {
                
                self.ActiveTableView.isHidden = true
                self.height2Constant.constant = self.view.frame.height * (50/647)
                completed()
                return
            }
            
            if snap?.isEmpty == true {
                
                self.ActiveTableView.isHidden = true
                self.height2Constant.constant = self.view.frame.height * (50/647)
                completed()
                
            } else {
                
                self.ActiveTableView.isHidden = false
                
                
                if maxItem == 1 {
                    
                    self.height2Constant.constant = self.view.frame.height * (120/647)
                    
                } else {
                    
                    let count = snap?.count
                    
                    if count == 1 {
                        
                        self.height2Constant.constant = self.view.frame.height * (120/647)
                    }
                    else if count == 2 {
                        
                        self.height2Constant.constant = self.view.frame.height * (150/647)
                        
                        
                    } else {
                        
                        self.height2Constant.constant = self.view.frame.height * (200/647)
                        
                    }
                    
                    
                }
                
                
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.activeList.append(dict)
                    
                    
                    
                    
                }
                
                self.ControlChallenge = challengeControl.active
                self.ActiveTableView.reloadData()
                completed()
                
                
            }
            
        
        }
        
        
    }
    
    
    func loadExpireChallenges(maxItem: Int, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Expired").order(by: "updated_timeStamp", descending: true).limit(to: maxItem).getDocuments { (snap, err) in
       
            if err != nil {
                
                self.expireTableView.isHidden = true
                self.height3Constant.constant = self.view.frame.height * (50/647)
                completed()
                return
            }
            
            if snap?.isEmpty == true {
                
                self.expireTableView.isHidden = true
                self.height3Constant.constant = self.view.frame.height * (50/647)
                completed()
                
            } else {
            
                self.expireTableView.isHidden = false
                
                if maxItem == 1 {
                    
                    self.height3Constant.constant = self.view.frame.height * (120/647)
                    
                } else {
                    
                    let count = snap?.count
                    
                    if count == 1 {
                        
                        self.height3Constant.constant = self.view.frame.height * (120/647)
                    }
                    else if count == 2 {
                        
                        self.height3Constant.constant = self.view.frame.height * (150/647)
                        
                        
                    } else {
                        
                        self.height3Constant.constant = self.view.frame.height * (200/647)
                        
                    }
                    
                    
                }
                
                
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.expireList.append(dict)
           
                    
                }
                
                self.ControlChallenge = challengeControl.expire
                self.expireTableView.reloadData()
                completed()
               
                
            }
            
        
        }
        
        
    }
    
    func loadOverallChallenge() {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { [self] (snap, err) in
            
            var start = 0
            snap!.documentChanges.forEach { diff in
                
                if firstLoad == true {
                    
                    let item = ChallengeModel(postKey: diff.document.documentID, Challenge_model: diff.document.data())
                    
                    if (diff.type == .added) {
                                
                        self.processItem(diff: diff, item: item)
                        
                    } else if (diff.type == .modified) {
                        
                        findExistAndRemove(item: item) {
                            
                            self.processItem(diff: diff, item: item)
                            
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
            
            if pendingList.count == maxItem {
                
                pendingList.remove(at: maxItem - 1)
                
            }
            
            pendingList.insert(item, at: 0)
            
            
            
            if pendingList.count == 1 {
                
                self.height1Constant.constant = self.view.frame.height * (120/647)
            }
            else if pendingList.count == 2 {
                
                self.height1Constant.constant = self.view.frame.height * (150/647)
                
            } else {
                
                self.height1Constant.constant = self.view.frame.height * (200/647)
                
            }
            
            
            self.ControlChallenge = challengeControl.pending
            self.pendingTableView.isHidden = false
            pendingTableView.reloadData()
            
        } else if diff.document.data()["challenge_status"] as! String == "Active" {
            
            
            if activeList.count == maxItem {
                
                activeList.remove(at: maxItem - 1)
                
            }
            
            activeList.insert(item, at: 0)
            
            if activeList.count == 1 {
                
                self.height2Constant.constant = self.view.frame.height * (120/647)
            }
            else if activeList.count == 2 {
                
                self.height2Constant.constant = self.view.frame.height * (150/647)
                
            } else {
                
                self.height2Constant.constant = self.view.frame.height * (200/647)
                
            }
            
            self.ControlChallenge = challengeControl.active
            self.ActiveTableView.isHidden = false
            ActiveTableView.reloadData()
            
            
            
        } else if diff.document.data()["challenge_status"] as! String == "Expired" {
            
            
            if expireList.count == maxItem {
                
                expireList.remove(at: maxItem - 1)
                
            }
            
            expireList.insert(item, at: 0)
            
            if expireList.count == 1 {
                
                self.height3Constant.constant = self.view.frame.height * (120/647)
            }
            else if expireList.count == 2 {
                
                self.height3Constant.constant = self.view.frame.height * (150/647)
                
                
            } else {
                
                self.height3Constant.constant = self.view.frame.height * (200/647)
                
            }
            
            
            self.ControlChallenge = challengeControl.expire
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
        
        switch self.ControlChallenge {
            
        case .pending:
           
            if tableView == self.pendingTableView {
                
                let item = pendingList[indexPath.row]
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "PendingTableViewCell") as? PendingTableViewCell {
                    
                    cell.configureCell(item)
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
                    
                    
                    cell.configureCell(item)
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
                    
                    cell.configureCell(item)
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
                self.userid = pendingList[indexPath.row].sender_ID
            case .active:
                self.userid = activeList[indexPath.row].sender_ID
            case .expire:
                self.userid = expireList[indexPath.row].sender_ID
        }
        
        
        self.performSegue(withIdentifier: "moveToUserProfileVC1", sender: nil)
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70.0
        
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
