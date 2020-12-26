//
//  ViewAllChallengeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/24/20.
//

import UIKit
import Firebase

class ViewAllChallengeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var challengeList = [ChallengeModel]()
    var type: String!
    var userid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        if type == "Pending" {
            loadPendingChallenges()
        } else if type == "Active" {
            loadActiveChallenge()
        } else{
            loadExpireChallenge()
        }
  
        
    }
    
    
    func loadPendingChallenges() {
        
     let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
  
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Pending").whereField("created_timeStamp", isGreaterThan: myNSDate).limit(to: 50).getDocuments { (snap, err) in
       
            if err != nil {
                return
            }
            
                if snap?.isEmpty == true {
                    
                    return
                    
                } else {
                      
                    for item in snap!.documents {
                        
                        let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                        self.challengeList.append(dict)
           
                    }
      
                    self.tableView.reloadData()
       
                }
      
        }
     
    }
    
    func loadActiveChallenge() {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Active").whereField("started_timeStamp", isGreaterThan: myNSDate).limit(to: 50).getDocuments { (snap, err) in
       
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                
                return
                
            } else {
                    
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.challengeList.append(dict)
                                
                }
 
                self.tableView.reloadData()
               
            }
            
        
        }
        
        
    }
    
    
    func loadExpireChallenge() {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Expired").order(by: "updated_timeStamp", descending: true).limit(to: 50).getDocuments { (snap, err) in
       
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                
                return
                
            } else {
            
        
                for item in snap!.documents {
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                    self.challengeList.append(dict)
           
                    
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
                tableView.setEmptyMessage("You don't have any pending challenge, let's get some !!!")
            } else if type == "Active" {
                tableView.setEmptyMessage("You don't have any active challenge, let's get some !!!")
            } else {
                tableView.setEmptyMessage("You don't have any expire challenge, let's get some !!!")
            }
            
            return 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return challengeList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = challengeList[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AllChallengeCell") as? AllChallengeCell {
            
            cell.configureCell(item)
            return cell
            
        } else {
            
            return AllChallengeCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        userid = challengeList[indexPath.row].sender_ID
        
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
