//
//  InterestedVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/3/20.
//

import UIKit
import Cache
import Alamofire
import AlamofireImage
import Firebase
import SwiftPublicIP

class InterestedVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var itemList = [InterestedModel]()
    var selectedList = [InterestedModel]()
    var caseLoad = 0
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.allowsMultipleSelection = true
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
        
        
        loadGame()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemList.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = itemList[indexPath.row]
        
    
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestedCell", for: indexPath) as? InterestedCell {
            
            cell.layer.cornerRadius = 20
            cell.configureCell(item)
           
            
            return cell
            
        } else {
            
            return InterestedCell()
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        
        if indexPath.row % 2 == 0 {
            
            let randomInt = Int.random(in: 0..<4)
            
            if randomInt == 0 {
                caseLoad = 0
                return CGSize(width: (view.frame.width - 70 ) / 2 , height: 47)
            } else if randomInt == 1 {
                caseLoad = 1
                return CGSize(width: (view.frame.width - 90 ) / 2 , height: 47)
            } else if randomInt == 2 {
                caseLoad = 2
                return CGSize(width: (view.frame.width - 110 ) / 2 , height: 47)
            } else {
                caseLoad = 3
                return CGSize(width: (view.frame.width - 120 ) / 2 , height: 47)
            }
            
        } else {
            
            if caseLoad == 2 || caseLoad == 3 {
                
                let randomInt = Int.random(in: 0..<2)
                
                if randomInt == 0 {
                    caseLoad = 0
                    return CGSize(width: (view.frame.width - 70) / 2 , height: 47)
                } else if randomInt == 1 {
                    caseLoad = 1
                    return CGSize(width: (view.frame.width - 90 ) / 2 , height: 47)
                } else {
                    
                    caseLoad = 0
                    return CGSize(width: (view.frame.width - 70 ) / 2 , height: 47)
                    
                }
                
                
            } else {
                
                let randomInt = Int.random(in: 2..<4)
                
                if randomInt == 2 {
                    caseLoad = 2
                    return CGSize(width: (view.frame.width - 110 ) / 2 , height: 47)
                } else if randomInt == 3 {
                    caseLoad = 3
                    return CGSize(width: (view.frame.width - 120 ) / 2 , height: 47)
                } else {
                    
                    caseLoad = 2
                    return CGSize(width: (view.frame.width - 110 ) / 2 , height: 47)
                    
                }
                
                
                
            }
            
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 27
    }
    
    
    func loadGame() {
        
        DataService.instance.mainFireStoreRef.collection("Support_game").order(by: "name", descending: true).getDocuments { (snap, err) in
   
            if err != nil {
                
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
            }
        
            for item in snap!.documents {
                
            
                let i = item.data()
                
                let item  = InterestedModel(postKey: item.documentID, Game_model: i)
                
                if i["name"] as? String != "Others" {
                    
                    
                    
                    self.itemList.insert(item, at: 0)
                    
                } else {
                    
                    self.itemList.append(item)
                    
                }
                
                
 
                self.collectionView.reloadData()
                
                
            }
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? InterestedCell
        let selectColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
        if cell?.isSelected == true {
            
            cell?.contentView.backgroundColor = selectColor
            cell?.name.textColor = UIColor.white
            
            let img = UIImage(named: "wtick")
            
            cell?.imageView.image = img
                
        }
        
        let item = itemList[indexPath.row]
        selectedList.append(item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? InterestedCell
        cell?.contentView.backgroundColor = UIColor.white
        cell?.name.textColor = UIColor.black
        
        let item = itemList[indexPath.row]
        
     
        
        imageStorage.async.object(forKey: item.url) { result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    
                    
                    cell?.imageView.image = image
                    
                    //try? imageStorage.setObject(image, forKey: url)
                    
                }
                
            } else {
                
                
                AF.request(item.url).responseImage { response in
                    
                    
                    switch response.result {
                    case let .success(value):
                        cell?.imageView.image = value
                        try? imageStorage.setObject(value, forKey: item.url)
                    case let .failure(error):
                        print(error)
                    }
                    
                    
                    
                }
                
            }
            
        }
        
        
        var count = 0
        for x in selectedList {
 
            if let name = item.name {
                
                if x.name == name {
                    
                    selectedList.remove(at: count)
                    
                }
                
            }
            
            count += 1
            
        }
        
    }

    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }


    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if selectedList.isEmpty == true {
            
            self.showErrorAlert("Ops !", msg: "Please pick one of your favorite, so we can deliver more precise content!")
            
        } else {
            
            swiftLoader()
            
            Auth.auth().signInAnonymously() { [self] (authResult, error) in
               
                if error != nil {
                    self.showErrorAlert("Ops!", msg: error!.localizedDescription)
                } else {
                    
                    let uid = authResult?.user.uid
                    var list = [String]()
                    
                    for i in self.selectedList {
                        list.append(i.name)
                    }
                    
                    let dict = ["uid": uid!, "interested_list": list, "timeStamp": FieldValue.serverTimestamp()] as [String : Any]
                    
                    
                    let data = ["USER_ID": uid!, "LIKES_VALUE": 0, "VIEWS_VALUE": 0, "SUBSCRIBE_VALUE": 0, "CATEGORY_VALUE": list] as [String : Any]
                    
                    let db = DataService.instance.mainFireStoreRef.collection("interested_list")
                    var ref: DocumentReference? = nil
                    ref = db.addDocument(data: dict) { err in
                        
                        if let err = err {
                            
                            self.showErrorAlert("Opss !", msg: err.localizedDescription)
                            
                        } else {
                            
                            let sessionId = ref!.documentID
                            fileComplete(data: data, sessionId: sessionId)
                            
    
                        }
  
                }
                
            }
                
            }
            
        }
        
        
        
    }
    
    func fileComplete(data: [String : Any], sessionId: String) {
        
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let string = string {
            
                getIPInformation(IP: string, data: data, sessionId: sessionId)
               
            }
        }
        
    }
    
    func getIPInformation(IP: String, data: [String : Any], sessionId: String) {
        
        let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(IP)
        
        AF.request(urls, method: .get)
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                case .success(let json):
                    
                    if let dict = json as? Dictionary<String, Any> {
                        
                        if let status = dict["status"] as? String, status == "success" {
                            
                            if let country = dict["country"] as? String {
                                
                                var newData = data
                                newData.updateValue(country, forKey: "REGION_VALUE")
                                self.callUsersPersonlize(data: newData, sessionId: sessionId)
                            }
                            
                        } else {
                            
                            self.callUsersPersonlize(data: data, sessionId: sessionId)
                            
                        }
                        
                        
                    }
                    
                case .failure( _):
                    
                    
                    self.callUsersPersonlize(data: data, sessionId: sessionId)
                    
                    
                    
                }
                
            }
      
     
        
    }
    
    func callUsersPersonlize(data: [String : Any], sessionId: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("aws-personalize-send-users")
        
      
        AF.request(urls!, method: .post, parameters: [
            
            "USER_ID": data["USER_ID"]!,
            "SUBSCRIBE_VALUE": 0,
            "REGION_VALUE": data["REGION_VALUE"]!

        ])
        .validate(statusCode: 200..<500)
        .responseJSON { responseJSON in
            
            SwiftLoader.hide()
            self.performSegue(withIdentifier: "moveToMainVC", sender: nil)
            
        }
        
        
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
    
    
        
}


