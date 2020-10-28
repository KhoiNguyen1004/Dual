//
//  HighlightVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/7/20.
//

import UIKit
import Alamofire
import AlamofireImage
import MarqueeLabel
import PixelSDK
import PhotosUI
import Firebase

class HighlightVC: UIViewController {
    
    
    @IBOutlet weak var isComment: UISwitch!
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var FriendsBtn: UIButton!
    @IBOutlet weak var OnlyMeBtn: UIButton!
    
    @IBOutlet weak var soundText: MarqueeLabel!
    @IBOutlet weak var highlightTitle: UITextField!
    var item: AddModel!
    

    @IBOutlet weak var checkImg: UIImageView!
    @IBOutlet weak var HighlightName: UILabel!
    @IBOutlet weak var HighlightImg: UIImageView!
    
    @IBOutlet weak var creatorLink: UITextField!
    
    var selectedVideo: SessionVideo!
    var exportedURL: URL!
    var mode: String!
    var music: String!
    var isAllowComment: Bool!
    var Htitle: String!
    var StreamLink: String!
    var ratio: CGFloat!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        if item.url2 != "" {
            
            HighlightName.text = item.name
            
            imageStorage.async.object(forKey: item.url2) { [self] result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                
                        self.HighlightImg.image = image
                        
      
                    }
                    
                } else {
                    
                    
                    AF.request(self.item.url2).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):
                            HighlightImg.image = value
                            try? imageStorage.setObject(value, forKey: self.item.url2)
                        case let .failure(error):
                            print(error)
                        }
                         
                    }
                    
                }
                
            }
            
            
        } else {
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        highlightTitle.borderStyle = .none
        creatorLink.borderStyle = .none
        
        
        // sound text
        
        soundText.type = .continuous
        soundText.speed = .rate(80)
        soundText.fadeLength = 10.0
        soundText.leadingBuffer = 30.0
        soundText.trailingBuffer = 20.0
        soundText.animationDelay = 0.0
        soundText.textAlignment = .center
        soundText.text = "Original sound - Kai1004pro                                   "
        
        
        
        
        
        
        // default setting
        music = "Original sound"
        isAllowComment = true
        isComment.setOn(true, animated: false)
        
        

        loadLastMode()
        loadLastLink()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if soundText.isPaused == true {
            
            soundText.unpauseLabel()
            
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        soundText.pauseLabel()
        
    }
    
    func loadLastLink() {
        
        
        DataService.instance.mainRealTimeDataBaseRef.child("Last_link").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { [self] (snapData) in
            
            
            if snapData.exists() {
                
                if let dict = snapData.value as? Dictionary<String, Any> {
                    
                    if let SavedLink = dict["stream_link"] as? String {
                        
                        if SavedLink != "nil" {
                            
                            creatorLink.text = SavedLink
                            
                        }
                        
                    }
                
                
            }
            
            
        }
            
        })
        
        
    }
    
    func loadLastMode() {
        
        
        DataService.instance.mainRealTimeDataBaseRef.child("Last_mode").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { [self] (snapData) in
            
            
            if snapData.exists() {
                
                if let dict = snapData.value as? Dictionary<String, Any> {
                    
                    if let SavedMode = dict["mode"] as? String {
                        
                       
                        
                        if SavedMode == "Public" {
                            
                            self.mode = SavedMode
                            
                            publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
                            FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                            OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                            
                        } else if SavedMode == "Friends" {
                            
                            self.mode = SavedMode
                            
                            FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
                            publicBtn.setImage(UIImage(named: "public"), for: .normal)
                            OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                            
                        } else if SavedMode == "Only me" {
                            
                            self.mode = SavedMode
                            
                            OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
                            FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                            publicBtn.setImage(UIImage(named: "public"), for: .normal)
                            
                        } else {
                            
                            self.mode = "Public"
                            
                            // defaults mode
                            
                            publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
                            FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                            OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                            
                        }
                        
                    }
                    
                }
                
            } else {
                
                
                self.mode = "Public"
                
                // defaults mode
                
                publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
                FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                
            }
            
        })
        
        
        
    }
    

 
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func isCommentBtnPressed(_ sender: Any) {
        
        if isAllowComment == true {
            
            
            isAllowComment =  false
            isComment.setOn(false, animated: true)
            
            print("Allow comment: \(String(describing: self.isAllowComment))")
            
            
        } else {
            
            isAllowComment = true
            isComment.setOn(true, animated: true)
            
            print("Allow comment: \(String(describing: self.isAllowComment))")
            
        }
        
        
    }
    // mode choose
    
    @IBAction func PublicBtnPressed(_ sender: Any) {
        
        publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
        
        mode = "Public"
    }
    
    
    @IBAction func FriendsBtnPressed(_ sender: Any) {
        
        FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
        
        mode = "Friends"
        
    }
    
    @IBAction func OnlyMeBtnPressed(_ sender: Any) {
        
        OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        
        mode = "Only me"
        
        
    }
    
    // dismiss keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        self.view.endEditing(true)
    }
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
        
        
        PixelSDK.shared.primaryFilters = PixelSDK.defaultInstaFilters + PixelSDK.defaultVisualEffectFilters
        
        
        let container = ContainerController(modes: [.library, .video])
        container.editControllerDelegate = self
        
        // Include only videos from the users photo library
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        // Include only videos from the users drafts
        container.libraryController.draftMediaTypes = [.video]
        
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
       
        
        
    }
 
    
    func exportVideo(video: SessionVideo, completed: @escaping DownloadComplete) {
        
        
        VideoExporter.shared.export(video: video, progress: { progress in
            print("Export progress: \(progress)")
        }, completion: { [self] error in
            if let error = error {
                SwiftLoader.hide()
                self.showErrorAlert("Ops!", msg: "Unable to export video: \(error)")
                return
            }
            
            self.exportedURL = video.exportedVideoURL
            ratio = video.renderSize.width / video.renderSize.height
           
            completed()

    
        })
        
    }
    
    
    
    
    // upload video to firebase
    
    
    func uploadVideo(url: URL) {
        
        
        
        let data = try! Data(contentsOf: url)
        let metaData = StorageMetadata()
        let vidUID = UUID().uuidString
        metaData.contentType = "video/mp4"
        let uploadUrl = DataService.instance.mainStorageRef.child(item.name).child(vidUID)
        
        let uploadTask = uploadUrl.putData(data , metadata: metaData) { (metaData, err) in
            
            
            
            if err != nil {

                print(err?.localizedDescription as Any)
                return
            }
            
            
            
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            print("Uploading progress: \(percentComplete)")
        }
        
        
        uploadTask.observe(.success) { snapshot in
          // Upload completed successfully
            
            uploadUrl.downloadURL(completion: { [self] (url, err) in
                 
                 
                 guard let Url = url?.absoluteString else { return }
                 
                 let downUrl = Url as String
                 let downloadUrl = downUrl as NSString
                 let downloadedUrl = downloadUrl as String
                 
                 
                 // put in firestore here
                
                
                 
                let higlightVideo = ["category": self.item.name as Any, "url": downloadedUrl as Any, "status": "Pending" as Any, "userUID": Auth.auth().currentUser!.uid as Any, "post_time": FieldValue.serverTimestamp() , "mode": self.mode as Any, "music": self.music as Any, "Mux_processed": false, "Mux_playbackID": "nil", "Allow_comment": self.isAllowComment!, "highlight_title": self.Htitle!, "stream_link": self.StreamLink!,"ratio": self.ratio!]
                
                
                // update last mode
                DataService.instance.mainRealTimeDataBaseRef.child("Last_mode").child(Auth.auth().currentUser!.uid).setValue(["mode": self.mode as Any])
                
                DataService.instance.mainRealTimeDataBaseRef.child("Last_link").child(Auth.auth().currentUser!.uid).setValue(["stream_link": self.StreamLink as Any])
                
               
                 
                let db = DataService.instance.mainFireStoreRef.collection("Highlights")
                 
                print("Writing to database")
                
                let id = db.addDocument(data: higlightVideo)
                
                print("Finished writting")
                
                print("Send data to backend for mux processing!")
                
                DataService.instance.mainRealTimeDataBaseRef.child("Mux-Processing").child(id.documentID).setValue(["url": downloadedUrl])
                
                print("Sent")
                
                
             })
            
        }
        
        
    }
    
    
    
    
    @IBAction func postBtnPressed(_ sender: Any) {
        

        if selectedVideo != nil {
            
            if creatorLink.text != "" {
                
                
                if verifyUrl(urlString: creatorLink.text) != true {
                    
                    creatorLink.text = ""
                    self.showErrorAlert("Oops!", msg: "Seem like it's not a valid url, please correct yours")
                    return
                    
                }
             
            }
            
            swiftLoader()
            
            
            if let title = highlightTitle.text, title != "" {
                
                Htitle = title
            } else {
                
                Htitle = "nil"
                
            }
            
            if let link = creatorLink.text, link != "" {
                
                StreamLink = link
                
            } else {
                
                StreamLink = "nil"
            }
            
            
            print("Start exporting")
            exportVideo(video: selectedVideo){
                // add watermark
                DispatchQueue.main.async {
                    self.selectedVideo = nil
                    let img = UIImage(named: "Icon awesome-photo-video")
                    self.checkImg.image = img
                    SwiftLoader.hide()
                }
                

                print("Start uploading")
                
                Dispatch.background {
                    
                    print("Run on background thread")
                    self.uploadVideo(url: self.exportedURL)
                    
                    
                }
                
            }
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please upload or record your highlight")
            
        }
        

}
    
    
    // func show error alert
    
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
  
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }

    
}

extension HighlightVC: EditControllerDelegate {
    
    
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        // Called after the EditController's view did load.
        
        print("Did load here")
    }
    
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Called when the Next button in the EditController is pressed.
        // Use this time to either dismiss the UINavigationController, or push a new controller on.
        
        
        if let video = session.video {
            
            selectedVideo = video
            let img = UIImage(named: "wtick")
            checkImg.image = img
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
}

