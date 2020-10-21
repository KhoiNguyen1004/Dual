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
    
    
    var selectedItem: HighlightsModel!
    
    @IBOutlet weak var imgTest: UIImageView!
    
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
        
        
        let sheet = UIAlertController(title: "Upload your profile photo", message: "", preferredStyle: .actionSheet)
        
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        manager.didSelect(HighlightsCollectionCell.self) { cell, model, indexPath in
            
            
            // React to selection
            
            self.selectedItem = model
            self.performSegue(withIdentifier: "MoveToEditVideoVC", sender: nil)
            
            
        }
        
    }
    
    // prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MoveToEditVideoVC"{
            if let destination = segue.destination as? EditVideoVC
            {
                
                destination.selectedItem = self.selectedItem
               
                
            }
        }
        
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
                        
                        
                        if item.data()["status"] as! String == "Ready" {
                            
                           
                            let dict = HighlightsModel(postKey: item.documentID, Highlight_model: item.data())
                            self.Highlight_list.append(dict)
                            
                            manager.memoryStorage.setItems(self.Highlight_list)
                            
                        }
                        
                    }
                    
                    firstLoad =  false
                    
                }
                
          
                snapshot.documentChanges.forEach { diff in

                    if (diff.type == .modified) {
                       
                        if diff.document.data()["status"] as! String == "Ready" {
                               
                            let item = HighlightsModel(postKey: diff.document.documentID, Highlight_model: diff.document.data())
                            
                            let isIn = findDataInList(item: item)
                            
                            if isIn == false {
                                
                                self.Highlight_list.insert(item, at: 0)
                                
                            } else {
                                
                                let index = findDataIndex(item: item)
                                self.Highlight_list.remove(at: index)
                                self.Highlight_list.insert(item, at: index)
                                
                                
                            }
                            
                            
                            manager.memoryStorage.setItems(self.Highlight_list)
                            // add new item processing goes here
                            
                        }
                        
                    } else if (diff.type == .removed) {
                        
                       
                        let item = HighlightsModel(postKey: diff.document.documentID, Highlight_model: diff.document.data())
                        
                        let index = findDataIndex(item: item)
                        self.Highlight_list.remove(at: index)
                        manager.memoryStorage.setItems(self.Highlight_list)
                        
                        // delete processing goes here
                    }
                  
                }
            }
        
   
    }
    
    func findDataInList(item: HighlightsModel) -> Bool {
        
        for i in Highlight_list {
            
            if i.Mux_playbackID == item.Mux_playbackID, i.Mux_assetID == item.Mux_assetID, i.url == item.url {
                
                return true
                
            }
            
           
            
        }
        
        return false
        
    }
    
    func findDataIndex(item: HighlightsModel) -> Int {
        
        var count = 0
        
        for i in Highlight_list {
            
            if i.Mux_playbackID == item.Mux_playbackID, i.Mux_assetID == item.Mux_assetID, i.url == item.url {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
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
