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
import AsyncDisplayKit


class ProfileVC: UIViewController, UINavigationControllerDelegate, DTCollectionViewManageable, UICollectionViewDelegateFlowLayout {
    
    
    // challenge history
    
    
    @IBOutlet weak var rate2: UILabel!
    @IBOutlet weak var rate1: UILabel!
    @IBOutlet weak var emptyMessage: UILabel!
    
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    
    @IBOutlet weak var category1: UILabel!
    @IBOutlet weak var logo1: borderAvatarView!
    @IBOutlet weak var date1: UILabel!
    @IBOutlet weak var name1: UILabel!
    @IBOutlet weak var star1: UILabel!
    
    
    @IBOutlet weak var category2: UILabel!
    @IBOutlet weak var logo2: borderAvatarView!
    @IBOutlet weak var date2: UILabel!
    @IBOutlet weak var name2: UILabel!
    @IBOutlet weak var star2: UILabel!
    
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    var SelectedUserName = ""
    var SelectedAvatarUrl = ""
    var selectedItem: HighlightsModel!
    
    
    @IBOutlet weak var avatarImg: borderAvatarView!
    @IBOutlet weak var profileImgBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var expectedTargetContentOffset: CGPoint = .zero
    
    var Highlight_list = [HighlightsModel]()
    var challenge_list = [ChallengeModel]()
    var firstLoad = true
    var firstChallenge = true
    var firstLoadProfile = true
    
    private var pullControl = UIRefreshControl()
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser?.isAnonymous == true {
            
            print("Login anonymously")
            
            let Lview = LoginView()
            Lview.frame = self.view.layer.bounds
            Lview.SignUpBtn.addTarget(self, action: #selector(ProfileVC.SignUpBtnPressed), for: .touchUpInside)
            self.view.addSubview(Lview)
            
            return
             
        }
        
        manager.register(HighlightsCollectionCell.self) { [weak self] mapping in
            
            mapping.sizeForCell { cell, model in
                self?.itemSize(for: self?.collectionView.bounds.size.width ?? .zero) ?? .zero
            }
                      
        }
     
        loadVideo()
        loadProfile()
        loadChallenge()
        
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = pullControl
        } else {
            collectionView.addSubview(pullControl)
        }
        
        
    }
    
    
    func loadChallenge() {
        
        let db = DataService.instance.mainFireStoreRef
        let uid = Auth.auth().currentUser?.uid
           
        db.collection("Challenges").whereField("isPending", isEqualTo: false).whereField("uid_list", arrayContains: uid!).order(by: "updated_timeStamp", descending: true).limit(to: 2)
            
            .addSnapshotListener { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if firstChallenge == true {
                    
                    if snapshot.isEmpty == true {
                        
                        
                        view1.isHidden = true
                        view2.isHidden = true
                        emptyMessage.text = "You don't have any challenge, let's get some!"
                        emptyMessage.isHidden = false
                        
                        
                    } else {
                        
                        emptyMessage.isHidden = true
                        
                        for item in snapshot.documents {
                            
                            let elem = ChallengeModel(postKey: item.documentID, Challenge_model: item.data())
                            challenge_list.append(elem)
                            
                        }
                        
                        if challenge_list.count >= 2 {
                            
                            view1.isHidden = false
                            view2.isHidden = false
                            
                        } else {
                            
                            view1.isHidden = false
                            view2.isHidden = true
                            
                        }
                        
                        loadChallengeInfo()
                        
                    }
                    
                    firstChallenge = false
                    
                    
                    
                }

                snapshot.documentChanges.forEach { diff in
                    
                    let item = ChallengeModel(postKey: diff.document.documentID, Challenge_model: diff.document.data())

                    if (diff.type == .modified) {
                       
                        if diff.document.data()["isPending"] as! Bool == false {
                               
                            let isIn = findDataInChallengeList(item: item)
                            
                            if isIn == false {
                                
                                emptyMessage.isHidden = true
                                
                                
                                if challenge_list.count >= 2 {
                                    
                                    challenge_list.remove(at: 0)
                                    challenge_list.append(item)
                                    
                                } else {
                                    
                                    challenge_list.append(item)
                                    
                                }
                                
                                
                                if challenge_list.count >= 2 {
                                    
                                    view1.isHidden = false
                                    view2.isHidden = false
                                    
                                } else {
                                    
                                    view1.isHidden = false
                                    view2.isHidden = true
                                    
                                }
                                
                        }
                            
                        loadChallengeInfo()
             
                    }
                        
                }
                  
            }
        }
           
    }
    
    
    
    func loadChallengeInfo() {
        
        var count = 0
        
        for item in challenge_list {
            
            let uid = getuserUID(list: item.uid_list!)
            
            if uid != "" {
            
                let date = item.updated_timeStamp.dateValue()
                
                
                if count == 0 {
                    
                    
                    date1.text = formatDate(date: date)
                    category1.text = item.category
                    getLogo(category: item.category, image: logo1)
                    loadInfo(uid: uid, user: name1)
                    getstar(uid: uid, rate: rate1)
                    
                } else if count == 1 {
                    
                    date2.text = formatDate(date: date)
                    category2.text = item.category
                    getLogo(category: item.category, image: logo2)
                    loadInfo(uid: uid, user: name2)
                    getstar(uid: uid, rate: rate2)
                    
                }
   
                
            }
            
            
            count+=1
            
            
        }
        
        
    }
    
    
    func getstar(uid: String, rate: UILabel) {
        
        DataService.instance.mainFireStoreRef.collection("Challenge_rate").whereField("to_uid", isEqualTo: uid).limit(to: 100).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            
            if snapshot.isEmpty != true {
                
                
                var rate_lis = [Int]()
                
                for item in snapshot.documents {
                    
                    
                    
                    if let current_rate = item.data()["rate_value"] as? Int {
                        
                        rate_lis.append(current_rate)
                        
                    }
                    
                    
                    
                    
                }
                
            
                let average = calculateMedian(array: rate_lis)
                rate.text = String(format:"%.1f", average)
                
            }
            
    
        }
        
        
        
        
    }
    
    
    func loadInfo(uid: String, user: UILabel) {
        
       
        DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                
                    if let username = item.data()["username"] as? String {
                        
                        //
                        user.text = "Vs @\(username)"

   
                    }
                
            }
            
        }
       
        
    }
    
    func getLogo(category: String, image: UIImageView) {
        
        
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("name", isEqualTo: category).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
                
                if let url = item.data()["url2"] as? String {
                    
                   
                    let imageNode = ASNetworkImageNode()

                    
                    imageNode.contentMode = .scaleAspectFill
                    imageNode.shouldRenderProgressImages = true
                    imageNode.animatedImagePaused = false
                    imageNode.url = URL.init(string: url)
                    imageNode.frame = image.layer.bounds
                    
  
                    image.addSubnode(imageNode)
                    
                    
                }
                
                
            }
            
            
        }
        
    }
    
    func formatDate(date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
       
        return dateFormatter.string(from: date)
        
    }
    
    func getuserUID(list: [String]) -> String {
        
        let uid = Auth.auth().currentUser?.uid
        
        for item in list {
            
            if item != uid {
                
                return item
            }
            
            
        }
        
        return ""
        
        
    }
    
    func findDataInChallengeList(item: ChallengeModel) -> Bool {
        
        for i in challenge_list {
            
            if i.messages == item.messages, i.created_timeStamp == item.created_timeStamp {
                
                return true
                
            }
        }
        
        return false
        
    }
    
    @objc private func refreshListData(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.Highlight_list.removeAll()
        self.firstLoad = true
        loadVideo()
              
    }
    
    func loadProfile() {
        
        
        let db = DataService.instance.mainFireStoreRef
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("Users").whereField("userUID", isEqualTo: uid!).addSnapshotListener { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                

                if firstLoadProfile == true {
                    
                    
                    
                    for item in snapshot.documents {
                        
                        
                        
                        self.assignProfile (item: item.data())
                        
                    }
                    
                    firstLoadProfile =  false
                    
                }
                
          
                snapshot.documentChanges.forEach { diff in
                    

                    if (diff.type == .modified) {
                       
                        self.assignProfile (item: diff.document.data())
                        
                    }
                  
                }
            }
        
    }
    
    func assignProfile(item: [String: Any]) {
        
        if let username = item["username"] as? String, let name = item["name"] as? String, let avatarUrl = item["avatarUrl"] as? String  {
            
           
            self.SelectedUserName = username
            self.SelectedAvatarUrl = avatarUrl
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
    
    @objc func SignUpBtnPressed() {
        
        self.performSegue(withIdentifier: "moveToLoginVC2", sender: nil)
      
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
  
        uploadImg(image: image)

    }
    
    func uploadImg(image: UIImage) {

        swiftLoader()
        
        self.swiftLoader()
        let metaData = StorageMetadata()
        let imageUID = UUID().uuidString
        metaData.contentType = "image/jpeg"
        var imgData = Data()
        imgData = image.jpegData(compressionQuality: 1.0)!
         
        DataService.instance.AvatarStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
            
            if err != nil {
                
                SwiftLoader.hide()
                self.showErrorAlert("Oopss !!!", msg: "Error while saving your image, please try again")
                print(err?.localizedDescription as Any)
                
            } else {
                
                DataService.instance.AvatarStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
               
                    guard let Url = url?.absoluteString else { return }
                    
                    let downUrl = Url as String
                    let downloadUrl = downUrl as NSString
                    let downloadedUrl = downloadUrl as String
                    
                    
                    DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: Auth.auth().currentUser?.uid as Any).getDocuments { (snap, err) in
                    
                    
                        if err != nil {
                        
                            self.showErrorAlert("Opss !", msg: err.debugDescription)
      
                        } else {
                            if snap?.isEmpty != true {
                                
                                for dict in (snap?.documents)! {
                                    
                                    let id = dict.documentID
                                    DataService.instance.mainFireStoreRef.collection("Users").document(id).updateData(["avatarUrl": downloadedUrl])
                                    SwiftLoader.hide()
                                    break
                                                      
                                    
                                }
                                
                            } else {
                                
                                self.showErrorAlert("Opss !", msg: "Can't find user")
                                
                            }
                        }
                        
                    }
                    
                })
                      
                
            }
            
            
        }
        
              
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
                destination.SelectedUserName = self.SelectedUserName
                destination.SelectedAvatarUrl = self.SelectedAvatarUrl
               
                
            }
        } else if segue.identifier == "moveToViewAllChallenge2"{
            if let destination = segue.destination as? ViewAllChallengeVC
            {
                
                destination.viewUID = Auth.auth().currentUser?.uid
                
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
                        
                        
                        if let status = item.data()["h_status"] as? String, status == "Ready" {
                            
                           
                            let dict = HighlightsModel(postKey: item.documentID, Highlight_model: item.data())
                            self.Highlight_list.append(dict)
                            
                            manager.memoryStorage.setItems(self.Highlight_list)
                            
                        }
                        
                    }
                    
                    if self.pullControl.isRefreshing == true {
                        self.pullControl.endRefreshing()
                    }
                    
                    firstLoad =  false
                    
                }
                
          
                snapshot.documentChanges.forEach { diff in
                    
                    let item = HighlightsModel(postKey: diff.document.documentID, Highlight_model: diff.document.data())

                    if (diff.type == .modified) {
                       
                        if let status = diff.document.data()["h_status"] as? String, status == "Ready" {
                               
                            
                            
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
                            
                        } else if let status = diff.document.data()["h_status"] as? String, status == "Deleted" {
                            
                            let index = findDataIndex(item: item)
                            self.Highlight_list.remove(at: index)
                            manager.memoryStorage.setItems(self.Highlight_list)
                            
                        }
                        
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
    
    
    @IBAction func settingBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToSettingVC", sender: nil)
       
    }
    
    @IBAction func setting1BtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToSettingVC", sender: nil)
        
    }
     
    
    @IBAction func AllChallengeBtnPressed(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "moveToViewAllChallenge2", sender: nil)
        
        
    }
    
    
    @IBAction func moveToFollowList(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToFollowListVC", sender: nil)
        
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
 
        return CGSize(width: (width - 0)/2 - 2, height: 150)
    
    }
    
    private func updateLayout(size: CGSize, animated: Bool) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = itemSize(for: size.width)
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }
    
    
    
    
}
