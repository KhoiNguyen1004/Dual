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
import SwiftPublicIP

class HighlightVC: UIViewController {
    
    
    @IBOutlet weak var isComment: UISwitch!
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var FriendsBtn: UIButton!
    @IBOutlet weak var OnlyMeBtn: UIButton!
    @IBOutlet weak var soundText: UILabel!
    @IBOutlet weak var highlightTitle: UITextField!
    @IBOutlet weak var checkImg: UIImageView!
    @IBOutlet weak var HighlightName: UILabel!
    @IBOutlet weak var HighlightImg: UIImageView!
    @IBOutlet weak var creatorLink: UITextField!
    
    //
    var selectedVideo: SessionVideo!
    var exportedURL: URL!
    var mode: String!
    var music: String!
    var isAllowComment: Bool!
    var Htitle: String!
    var StreamLink: String!
    var ratio: CGFloat!
    var item: AddModel!
    var animatedLabel: MarqueeLabel!
    var region: String!
    
    var playbackID = ["iTrAhcnYhFWOf3Gl6T01CsMpnBcBp01nXuTrirEYGpEk00", "0001k3PQ3JUnXay5fXEk9qqMdht2OO5wpZhG01FLU1G4cA", "KPPRb751xBDdJi21cX01lbd1fsedu901KAQX3RKIQdP8M", "KPPRb751xBDdJi21cX01lbd1fsedu901KAQX3RKIQdP8M", "Mx4WtrpOCJxw893awZgLZgDuKJ4HlRMiDBGmwGUEmZE", "xWo00JxS1Z4J26AUHRrBVQ4R6WBBQG8IOtmW7seY1u9U", "NpDROSj37C9nxo5GZS8rq86nZqQDga3IJ4Sno0101902Nw", "pxPdG94auSVCFSe62PLo74mUbC6jxJCHERNKfSPaeu4", "VVFZ3EYmNRlTCv0002iNBHNjWHW8eiLub0201AYSCrCzWaw", "Y36siveM02UxdKsVbrgTIJwvtBbwvP9DEBLf8jdmYYTo", "0001ugBIsT01ZpJmcKLwJztImtW5HBhRJZuO1UmB5YGT2o", "KPPRb751xBDdJi21cX01lbd1fsedu901KAQX3RKIQdP8M", "Mx4WtrpOCJxw893awZgLZgDuKJ4HlRMiDBGmwGUEmZE", "iTrAhcnYhFWOf3Gl6T01CsMpnBcBp01nXuTrirEYGpEk00", "0001k3PQ3JUnXay5fXEk9qqMdht2OO5wpZhG01FLU1G4cA"]
    
    var assetID = ["8QAxu6WAHicXFzLzR9u2HnANDBMAWsjJAL2N902F6K00M", "I01UCtORWXxqxyc02elRTV3wHoy00PxS2PnjVMzTqD74O4", "9uI7h01TPREEse00k8KqRLQEVTzD00TZMocDeSRT9U8NpE", "rlEZVpv00Q01vyvy1pW202bgdP02YiErZ02e01tiMlj5PGyQ8", "2szFt02ED00MFbtrPC3T802T01owM6cMxQwWitRlPCrg01ok", "oiheYU3T6bkWOj42Dqc3MX400uhmTZHSgyqIZFeCDr8s", "DyfqbhcApW2qwgWJhgsJpHQbUaeFAXKd4WWGUUMkvPA", "bWg5Ij9RlBpyQCRB00xTTcR0228Q4YSn5qZ02RfjU2f00Ao", "sLby7u4dENV6Pf5Bm6iZCSdr8rTqSAODkcS3rQR5jHg", "VSvBoyEwxBU6t2m02rsPmIqWJHUt68kjBlQ01gwsqnTc4", "9uI7h01TPREEse00k8KqRLQEVTzD00TZMocDeSRT9U8NpE", "rlEZVpv00Q01vyvy1pW202bgdP02YiErZ02e01tiMlj5PGyQ8", "8QAxu6WAHicXFzLzR9u2HnANDBMAWsjJAL2N902F6K00M", "I01UCtORWXxqxyc02elRTV3wHoy00PxS2PnjVMzTqD74O4"]
    
    var userUID = ["dP6ZLayQy5dN59Wkjd4jjF0h7BV2", "BeSO6rdwi5eLWoWzqCkx4MqsHNr2", "E3wt6vvY47SKiDHksauxKP2INVq2", "TjfFhKhxgNVcrngYjy9NweB5Ejw2", "ohz1pUuIsqdFkedSu6IhSwnw30I3", "Sd0Nex639OOAhuBoPVvw2eQwhnq2", "VuVdRPpm81gWYOeOCObpmFvuID63", "h7UOtTCva5SppfmrUQLOE0Ivugo1", "uvINdlCvkVeSCNxoGeqpcNtScnc2", "r1HDUHn24td8q3ywjPFjzojqUTn2"]

    var count = 0
    
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
        
        
        // default setting
        music = "Original sound"
        isAllowComment = true
        isComment.setOn(true, animated: false)
        
        
        
        loadProfile()
        loadLastMode()
        loadLastLink()
        //UploadSample()
        
    }
    
    func UploadSample() {
        
        if count <= 100 {
            
            let time = FieldValue.serverTimestamp()
            
            let Dict = ["url": "https://firebasestorage.googleapis.com/v0/b/dual-71608.appspot.com/o/LOL%2F620FF6C4-5D8B-4D2D-A841-A5890511F5EC?alt=media&token=5608c437-a77e-4302-80ac-6a18c4a07f83", "ratio": 1.0, "status": "Ready", "userUID": userUID.randomElement()!, "org": "Comcast Cable Communications, LLC", "stream_link": "nil", "as": "AS7922 Comcast Cable Communications, LLC", "highlight_title": "nil", "countryCode": "US", "mode": "Friends", "region": "NH", "query": "50.204.100.194", "regionName": "New Hampshire", "city": "Durham", "category": "LOL", "Allow_comment": true, "timezone": "America/New_York", "country": "United States", "lon": -70.91970000000001, "zip": 03824, "Mux_processed": true, "lat": 43.1174, "music": "Original sound", "post_time": time, "isp": "Comcast Cable Communications, LLC", "Device": "iPhone 11 Pro Max", "Mux_playbackID": playbackID.randomElement()!, "Mux_assetID": assetID.randomElement()!, "AWS": false] as [String : Any]
            
            let db = DataService.instance.mainFireStoreRef.collection("Highlights")
            
            db.addDocument(data: Dict) { (err) in
                if err != nil {
                    
                    print(err!.localizedDescription)
                    
                }
                
                
                print("Uploaded to database \(self.count)")
                self.count += 1
                self.UploadSample()
                
            }
            
           
        }
        
  
        
    }
    
  
    
    func loadProfile() {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).addSnapshotListener { [self] querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    for item in snapshot.documents {
                    
                        if let username = item.data()["username"] as? String {
                        
                            soundText.text = ""
                            animatedLabel = MarqueeLabel.init(frame: CGRect(x: soundText.layer.bounds.minX, y: soundText.layer.bounds.minY + 10, width: soundText.layer.bounds.width, height: 16.0), rate: 60.0, fadeLength: 10.0)
                            animatedLabel.type = .continuous
                            animatedLabel.leadingBuffer = 20.0
                            animatedLabel.trailingBuffer = 10.0
                            animatedLabel.animationDelay = 0.0
                            animatedLabel.textAlignment = .center
                            animatedLabel.font = UIFont.systemFont(ofSize: 13)
                            animatedLabel.text = "Original sound - \(username)                                            "
                            soundText.addSubview(animatedLabel)
                            break

                    }
      
                }
                
            }
            
        }
        
  
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
                 let device = UIDevice().type.rawValue
                 
                 // put in firestore here
                      
                var higlightVideo = ["category": self.item.name as Any, "url": downloadedUrl as Any, "status": "Pending" as Any, "userUID": Auth.auth().currentUser!.uid as Any, "post_time": FieldValue.serverTimestamp() , "mode": self.mode as Any, "music": self.music as Any, "Mux_processed": false, "Mux_playbackID": "nil", "Allow_comment": self.isAllowComment!, "highlight_title": self.Htitle!, "stream_link": self.StreamLink!,"ratio": self.ratio!, "Device": device, "AWS": false]
                
                //
                
                SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let string = string {
                          
                        let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(string)
                          
                        AF.request(urls, method: .get)
                            .validate(statusCode: 200..<500)
                            .responseJSON { responseJSON in
                                
                                switch responseJSON.result {
                                    
                                case .success(let json):
                                    
                                    if let dict = json as? Dictionary<String, Any> {
                                        
                                        if let status = dict["status"] as? String, status == "success" {
                                            
                                            higlightVideo.merge(dict: dict)
                                            region = dict["country"] as? String
                                            // update last mode
                                            self.writeToDb(higlightVideo: higlightVideo, downloadedUrl: downloadedUrl)
                                            // update last mode
                                            
                                        }
                                    }
                                    
                                case .failure(let error):
              
                                    print(error.localizedDescription)
                                   
                                    
      
                                }
                                
                            }

                    }
                }
                            
             })
            
        }
        
        
    }
    
    func writeToDb(higlightVideo: [String: Any], downloadedUrl: String) {
        
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

