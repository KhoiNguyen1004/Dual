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

class ProfileVC: UIViewController, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var avatarImg: borderAvatarView!
    @IBOutlet weak var profileImgBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadVideo()
        
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
        
        db.collection("Highlights").whereField("userUID", isEqualTo: uid!).order(by: "post_time", descending: true).whereField("status", isEqualTo: "Ready").limit(to: 50)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                    print(item.data())
                }
                
                
                snapshot.documentChanges.forEach { diff in

                    if (diff.type == .modified) {
                       
                        if diff.document.data()["status"] as! String == "Ready" {
                            
                            
                            print("New ready: \(diff.document.data())")
                            
                            // add new item processing goes here
                            
                        } else {
                            
                            //print("Pending: \(diff.document.data())")
                            
                        }
                    } else if (diff.type == .removed) {
                        
                        print("New removed: \(diff.document.data())")
                        
                        // delete processing goes here
                    }
                  
                }
            }
        
   
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
    

    
}
