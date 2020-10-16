//
//  ProfileVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/14/20.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit
import AVFoundation
import CoreLocation
import Alamofire
import DTCollectionViewManager

class ProfileVC: UIViewController, UINavigationControllerDelegate, DTCollectionViewManageable, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var avatarImg: borderAvatarView!
    @IBOutlet weak var profileImgBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var expectedTargetContentOffset: CGPoint = .zero
    
    var Highlight_list = [HighlightsModel]()
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        
        manager.register(HighlightsCollectionCell.self) { [weak self] mapping in
            
            mapping.sizeForCell { cell, model in
                self?.itemSize(for: self?.collectionView.bounds.size.width ?? .zero) ?? .zero
            }
            
            
            
            
        }
        

        
        loadVideo()
        
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { [weak self] context in
            self?.expectedTargetContentOffset = self?.collectionView.contentOffset ?? .zero
            self?.updateLayout(size: size, animated: true)
        } completion: { _ in }
    }
    
    
    
 
    @IBAction func ImgBtnPressed(_ sender: Any) {
        
        
        let sheet = UIAlertController(title: "Upload your photo", message: "", preferredStyle: .actionSheet)
        
        
        let camera = UIAlertAction(title: "Take a new photo", style: .default) { (alert) in
            
            self.camera()
            
        }
        
        let album = UIAlertAction(title: "Upload from album", style: .default) { (alert) in
            
            self.album()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        
        sheet.addAction(camera)
        sheet.addAction(album)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
        
    }
    
    func album() {
        
        self.getMediaFrom(kUTTypeImage as String)
        
        
    }
    
    func camera() {
        
        
        
        self.getMediaCamera(kUTTypeImage as String)
        
    }
    
    // get media
    
    func getMediaFrom(_ type: String) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func getMediaCamera(_ type: String) {
        
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String] //UIImagePickerController.availableMediaTypes(for: .camera)!
        mediaPicker.sourceType = .camera
        self.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    func getImage(image: UIImage) {
        
        profileImgBtn.setTitle("", for: .normal)
        avatarImg.image = image
       

    }
    
    
    func loadVideo() {
        
        let db = DataService.instance.mainFireStoreRef
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("Highlights").whereField("userUID", isEqualTo: uid!).order(by: "post_time", descending: true).limit(to: 50)
            .addSnapshotListener { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
            
                
                if firstLoad == true {
                    
                    for item in snapshot.documents {
                        
                        
                        print("First load")
                        
                        let dict = HighlightsModel(postKey: item.documentID, Highlight_model: item.data())
                        self.Highlight_list.append(dict)
                        
                        manager.memoryStorage.setItems(self.Highlight_list)
                        
                    }
                    
                    firstLoad =  false
                    
                }
                
          
                snapshot.documentChanges.forEach { diff in

                    if (diff.type == .modified) {
                       
                        if diff.document.data()["status"] as! String == "Ready" {
                            
                            
                            print("New ready: \(diff.document.data())")
                            
                            let item = HighlightsModel(postKey: diff.document.documentID, Highlight_model: diff.document.data())
                            self.Highlight_list.insert(item, at: 0)
                            manager.memoryStorage.removeAllItems()
                            manager.memoryStorage.setItems(self.Highlight_list)
                            // add new item processing goes here
                            
                        } else {
                            
                    
                            
                        }
                    } else if (diff.type == .removed) {
                        
                        print("New removed: \(diff.document.data())")
                        
                        // delete processing goes here
                    }
                  
                }
            }
        
   
    }
    
    // layouyt
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0);
    }
    

}

extension ProfileVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            getImage(image: editedImage)
        } else if let originalImage =
            info[.originalImage] as? UIImage {
            getImage(image: originalImage)
        }
        
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func itemSize(for width: CGFloat) -> CGSize {
        
        return CGSize(width: (width - 1)/3, height: 170)
    
    }
    
    private func updateLayout(size: CGSize, animated: Bool) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = itemSize(for: size.width)
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }
    
}
