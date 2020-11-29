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
    
    var isFeed = false
    var uid: String!
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var avatarImg: borderAvatarView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    private var expectedTargetContentOffset: CGPoint = .zero
    
    var Highlight_list = [HighlightsModel]()
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
        
        if isFeed == true {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            isFeed = false
        }

        
    }
    
    @objc private func refreshListData(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.Highlight_list.removeAll()
        loadVideo(uid: uid)
              
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
            let imageNode = ASNetworkImageNode()
            imageNode.contentMode = .scaleAspectFit
            imageNode.shouldRenderProgressImages = true
            imageNode.url = URL.init(string: avatarUrl)
            imageNode.frame = self.avatarImg.layer.bounds
            self.avatarImg.image = nil
            
            self.avatarImg.addSubnode(imageNode)
            
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
    
        manager.didSelect(userHighlightsCollectionCell.self) { cell, model, indexPath in
            
            // React to selection
            
            //self.selectedItem = model
            self.performSegue(withIdentifier: "moveToUserHighlightVC", sender: nil)
            
        }
        
    }
    
    // prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /*
        if segue.identifier == "moveToUserHighlightVC"{
            if let destination = segue.destination as? EditVideoVC
            {
                
                //destination.selectedItem = self.selectedItem
                //destination.SelectedUserName = self.SelectedUserName
                //destination.SelectedAvatarUrl = self.SelectedAvatarUrl
               
                
            }
        }
        */
    }
    
    
    func loadVideo(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        
        db.collection("Highlights").whereField("userUID", isEqualTo: uid).order(by: "post_time", descending: true).limit(to: 50)
            .getDocuments { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                    
                    
                    if item.data()["status"] as! String == "Ready" {
                        
                       
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
    

    
}
