//
//  AddVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/7/20.
//

import UIKit
import Cache
import Alamofire
import AlamofireImage
import Firebase

class AddVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var itemList = [AddModel]()
    var selectedItem: AddModel!
    var SelectedIndex: IndexPath!
    
    var firstLoad = true
    var caseLoad = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.allowsSelection = true
                 
            self.collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
            
            

        loadAddGame()
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemList.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = itemList[indexPath.row]
        
    
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath) as? AddCell {
            
            cell.layer.cornerRadius = 20
            
            if item.status == true {
                cell.shadowView.backgroundColor = UIColor.clear
            } else {
                cell.shadowView.backgroundColor = UIColor.black
            }
            
            
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? AddCell
        
        if itemList.isEmpty != true {
            
            let item = itemList[indexPath.row]
            
            if item.status != true {
                
                self.showErrorAlert("Oops!", msg: "This category is temporarily disabled, please try again later.")
                
                return
                
            }
            
            if selectedItem != nil {
                
                if item.name == selectedItem.name, item.url == selectedItem.url {
                    
                    cell?.contentView.backgroundColor = UIColor.white
                    cell?.name.textColor = UIColor.black
                    
                    let item = itemList[indexPath.row]
                    
                    imageStorage.async.object(forKey: selectedItem.url) { result in
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
                    
                    selectedItem = nil
                    
                } else {
                    
                    let DeselectedCell = collectionView.cellForItem(at: SelectedIndex as IndexPath) as? AddCell
                    
                    DeselectedCell?.contentView.backgroundColor = UIColor.white
                    DeselectedCell?.name.textColor = UIColor.black
                    
                    let item = itemList[indexPath.row]
                    
                    imageStorage.async.object(forKey: selectedItem.url) { result in
                        if case .value(let image) = result {
                            
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                
                                
                                DeselectedCell?.imageView.image = image
                                             
                            }
                            
                        } else {
                            
                            
                            AF.request(item.url).responseImage { response in
                                
                                
                                switch response.result {
                                case let .success(value):
                                    DeselectedCell?.imageView.image = value
                                    try? imageStorage.setObject(value, forKey: item.url)
                                case let .failure(error):
                                    print(error)
                                }
                                 
                            }
                            
                        }
                        
                    }
                    
                    
                    let selectColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
                    if cell?.isSelected == true {
                        
                        cell?.contentView.backgroundColor = selectColor
                        cell?.name.textColor = UIColor.white
                        
                        let img = UIImage(named: "wtick")
                        
                        cell?.imageView.image = img
                        selectedItem = item
                        SelectedIndex = indexPath
                        
                            
                    }

                    
                    
                }
                
            } else {
                
                let selectColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
                if cell?.isSelected == true {
                    
                    cell?.contentView.backgroundColor = selectColor
                    cell?.name.textColor = UIColor.white
                    
                    let img = UIImage(named: "wtick")
                    
                    cell?.imageView.image = img
                    selectedItem = item
                    SelectedIndex = indexPath
                        
                }
                
            }
            
            
            // check whether disable continue button
            if selectedItem == nil {
                
                continueBtn.isHidden = true
                
            } else {
                
                continueBtn.isHidden = false
            }
          
            
        }
        
        
        
        
       
        
    }
    

    
    func loadAddGame() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Support_game").order(by: "name", descending: true)
            .addSnapshotListener { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if firstLoad == true {
                    
                    for item in snapshot.documents {
                        
                        let i = item.data()
                        let item = AddModel(postKey: item.documentID, Game_model: i)
                        
                        if i["name"] as? String != "Others" {
                         
                            
                            self.itemList.insert(item, at: 0)
                            
                        } else {
                            
                            self.itemList.append(item)
                            
                        }
                        
                        self.collectionView.reloadData()
                        
                        
                    }
                    
                    firstLoad =  false
                    
                }
                
          
                snapshot.documentChanges.forEach { diff in
                    
                    
                    let item = AddModel(postKey: diff.document.documentID, Game_model: diff.document.data())

                    if (diff.type == .modified) {
        
                        let isIn = findDataInList(item: item)
                        
                        if isIn == false {
                            
                            self.itemList.insert(item, at: 0)
                            
                        } else {
                            
                            let index = findDataIndex(item: item)
                            self.itemList.remove(at: index)
                            self.itemList.insert(item, at: index)
                            
                            
                        }
                        
                        
                        self.collectionView.reloadData()
                        
                    } else if (diff.type == .removed) {
                        
                      
                        
                        let index = findDataIndex(item: item)
                        self.itemList.remove(at: index)
                        self.collectionView.reloadData()
                        
                        // delete processing goes here
                        
                        
                    } else if (diff.type == .added) {
                        
                      
                        let isIn = findDataInList(item: item)
                        
                        if isIn == false {
                            
                            self.itemList.insert(item, at: 0)
                            self.collectionView.reloadData()
                            
                        }
                        
                        
                    }
                }
            }
        
    }
    
    func findDataInList(item: AddModel) -> Bool {
        
        for i in itemList {
            
            if i.name == item.name {
                
                return true
                
            }
            
           
            
        }
        
        return false
        
    }
    
    func findDataIndex(item: AddModel) -> Int {
        
        var count = 0
        
        for i in itemList {
            
            if i.name == item.name {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func ContinueBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToCreateHighlightVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "moveToCreateHighlightVC"{
            if let destination = segue.destination as? HighlightVC
            {
                
                destination.item = self.selectedItem
               
                
            }
        }
        
        
    }
    


}
