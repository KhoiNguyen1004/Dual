//
//  ViewAllChallengeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/24/20.
//

import UIKit
import Firebase
import MGSwipeTableCell
import SwiftPublicIP
import Alamofire

class ViewAllChallengeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var challengeList = [ChallengeModel]()
    var type: String!
    var userid: String!
    var challengeid: String!
    var rate_index = 0
    var viewUID: String!
    
    
    
    private var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        if viewUID != nil {
            
          
            if type == "Pending" {
                loadPendingChallenges(uid: viewUID)
            } else if type == "Active" {
                loadActiveChallenge(uid: viewUID)
            } else{
                loadExpireChallenge(uid: viewUID)
            }
            
            
        }
  
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = pullControl
        } else {
            tableView.addSubview(pullControl)
        }
    
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.challengeList.removeAll()
        
        if viewUID != nil {
            
          
            if type == "Pending" {
                loadPendingChallenges(uid: viewUID)
            } else if type == "Active" {
                loadActiveChallenge(uid: viewUID)
            } else{
                loadExpireChallenge(uid: viewUID)
            }
            
            
        }
              
    }
    
    
    func loadPendingChallenges(uid: String) {
        
     let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
  
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: uid).whereField("challenge_status", isEqualTo: "Pending").whereField("created_timeStamp", isGreaterThan: myNSDate).limit(to: 50).getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                
                return
            }
            
                if snap?.isEmpty == true {
                    
                    if self.pullControl.isRefreshing == true {
                        self.pullControl.endRefreshing()
                    }
                    
                    return
                    
                } else {
                      
                    for item in snap!.documents {
                        
                        let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                        self.challengeList.append(dict)
           
                    }
                    
                    if self.pullControl.isRefreshing == true {
                        self.pullControl.endRefreshing()
                    }
      
                    self.tableView.reloadData()
       
                }
      
        }
     
    }
    
    func loadActiveChallenge(uid: String) {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("uid_list", arrayContains: uid).whereField("challenge_status", isEqualTo: "Active").whereField("started_timeStamp", isGreaterThan: myNSDate).limit(to: 50).getDocuments { (snap, err) in
       
            if err != nil {
                
                print(err!.localizedDescription)
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                
                
                return
            }
            
            if snap?.isEmpty == true {
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                return
                
            } else {
                    
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.challengeList.append(dict)
                                
                }
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
 
                self.tableView.reloadData()
               
            }
            
        
        }
        
        
    }
    
    
    func loadExpireChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("uid_list", arrayContains: uid).whereField("challenge_status", isEqualTo: "Expired").order(by: "updated_timeStamp", descending: true).limit(to: 50).getDocuments { (snap, err) in
       
            if err != nil {
                
                print(err!.localizedDescription)
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                return
            }
            
            if snap?.isEmpty == true {
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                return
                
            } else {
            
        
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.challengeList.append(dict)
           
                    
                }
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                
                self.tableView.reloadData()
              
            }
            
        
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if challengeList.isEmpty != true {
            
            tableView.restore()
            return 1
            
        } else {
            
            if type == "Pending" {
                tableView.setEmptyMessage("Can't find any pending challenge, let's get some !!!")
            } else if type == "Active" {
                tableView.setEmptyMessage("Can't find any active challenge, let's get some !!!")
            } else {
                tableView.setEmptyMessage("Can't find any expire challenge, let's get some !!!")
            }
            
            return 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return challengeList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 25    //if you want round edges
        maskLayer.backgroundColor = UIColor.red.cgColor
        
        let item = challengeList[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AllChallengeCell") as? AllChallengeCell {
            
            cell.configureCell(item)
            cell.delegate = self
            
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
            cell.layer.mask = maskLayer
            
            return cell
            
        } else {
            
            return AllChallengeCell()
        }
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        
        return true
        
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        
        let padding = 25
        swipeSettings.expandLastButtonBySafeAreaInsets = true
        swipeSettings.transition = .border
        
        if let item_index = self.tableView.indexPath(for: cell)?.row {
            
            let item = self.challengeList[item_index]
            
            if item.challenge_status == "Pending" {
                
                
                if direction == MGSwipeDirection.rightToLeft {
                    expansionSettings.fillOnTrigger = false;
                    expansionSettings.threshold = 1.1
                          
                    
                    let declineImg = resizeImage(image: UIImage(named: "decline")!, targetSize: CGSize(width: 20.0, height: 20.0))
                    let acceptImg = resizeImage(image: UIImage(named: "accept")!, targetSize: CGSize(width: 25.0, height: 25.0))
                    
                    let accept = MGSwipeButton(title: "", icon: acceptImg, backgroundColor: UIColor.clear, padding: padding,  callback: { (cell) -> Bool in
                        
                        
                        self.AcceptAtIndexPath(self.tableView.indexPath(for: cell)!)

                        return false; //don't autohide to improve delete animation
                        
                        
                    });
                    
                    
                    
                    let decline = MGSwipeButton(title: "", icon: declineImg, backgroundColor: UIColor.clear, padding: padding, callback: { (cell) -> Bool in
                        
                        
                        
                        self.RejectAtIndexPath(self.tableView.indexPath(for: cell)!)
                        
                        return false; //autohide
                        
                    });
                    
                    return [decline, accept]
                    
                } else {
                    
                    return nil
                    
                }
                
            } else if item.challenge_status == "Active" {
                
                
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
                        
                      
                        
                        self.CloseAtIndexPath(self.tableView.indexPath(for: cell)!)
                        
                        return false; //autohide
                        
                    });
                    
                    return [Message, Call, Close]
                    
                } else {
                    
                    return nil
                    
                }
                
                
            } else if item.challenge_status == "Expired" {
                
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
                        
                        
                        let uid_lis = challengeList[self.tableView.indexPath(for: cell)!.row].uid_list
                        rate_index = self.tableView.indexPath(for: cell)!.row
                    
                        for item in uid_lis! {
                            
                            if item != Auth.auth().currentUser?.uid {
                                
                                
                                userid = item
                                challengeid = challengeList[self.tableView.indexPath(for: cell)!.row]._challenge_id
                                self.present(rateViewController, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                        
                        
                        
                        return false; //autohide
                        
                    });
                    
                    if challengeList[self.tableView.indexPath(for: cell)!.row]._shouldShowRate == nil {
                        
                        return nil
                        
                    } else {
                        
                        
                        if challengeList[self.tableView.indexPath(for: cell)!.row]._shouldShowRate ==  true {
                            
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
            
            
        } else {
            
            return nil
                    
        }
        
    }
    
    func AcceptAtIndexPath(_ path: IndexPath) {
           
        let item = challengeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Active", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    return
                }
                
                
                self.challengeList.remove(at: path.row)
                self.tableView.deleteRows(at: [IndexPath(row: path.row, section: 0)], with: .automatic)
                
            }
            
        }
  
    }
    
    
    func RejectAtIndexPath(_ path: IndexPath) {
           
        let item = challengeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Rejected", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    return
                }
                
                self.challengeList.remove(at: path.row)
                self.tableView.deleteRows(at: [IndexPath(row: path.row, section: 0)], with: .automatic)
                
            }
            
        }
        
        
        
    }
    
    
    func CloseAtIndexPath(_ path: IndexPath) {
           
        let item = challengeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Expired", "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    return
                }
                
                self.challengeList.remove(at: path.row)
                self.tableView.deleteRows(at: [IndexPath(row: path.row, section: 0)], with: .automatic)
                
            }
            
        }
        
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        for item_uid in challengeList[indexPath.row].uid_list {
            
            if item_uid != Auth.auth().currentUser?.uid {
         
                userid = item_uid
                
            }
    
        }
       
        self.performSegue(withIdentifier: "moveToUserProfileVC2", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToUserProfileVC2"
        {
            if let destination = segue.destination as? UserProfileVC
            {
                
                destination.isFeed = false
                destination.uid = self.userid
                  
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70.0
        
    }
    
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
      
    
    
}


extension ViewAllChallengeVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension ViewAllChallengeVC: CWRateKitViewControllerDelegate {

    func didChange(rate: Int) {
        print("Current rate is \(rate)")
    }

    func didSubmit(rate: Int) {
        
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
                                        
                                       
                                        let item = challengeList[rate_index]
                                        item._shouldShowRate = false
                                        self.tableView.reloadRows(at: [IndexPath(row: rate_index, section: 0)], with: .automatic)
                                        
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
    
    func didDismiss() {
        print("Dismiss the rate view")
    }
    
   
    
}

