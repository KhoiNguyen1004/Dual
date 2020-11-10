//
//  EditVideoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/18/20.
//

import UIKit
import AVFoundation
import MarqueeLabel
import Alamofire
import AsyncDisplayKit
import MUXSDKStats
import Firebase


class EditVideoVC: UIViewController {
    
    @IBOutlet weak var avatarUrl: borderAvatarView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var InfoView: UIStackView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var streamLink: MarqueeLabel!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var gameLogo: borderAvatarView!
    @IBOutlet weak var soundLbl: MarqueeLabel!
    @IBOutlet weak var videoPlayer: UIView!
    
    //
    var selectedItem: HighlightsModel!
    var animatedLabel: MarqueeLabel!
    var videoNode = ASVideoNode()
    var SelectedUserName: String!
    var SelectedAvatarUrl: String!
    
    @IBOutlet weak var videoHeight: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        // animation text
        
        if selectedItem.stream_link != "nil" {
            
            
            streamLink.text = ""
            animatedLabel = MarqueeLabel.init(frame: streamLink.layer.bounds, rate: 60.0, fadeLength: 10.0)
            animatedLabel.type = .continuous
            animatedLabel.leadingBuffer = 20.0
            animatedLabel.trailingBuffer = 10.0
            animatedLabel.animationDelay = 0.0
            animatedLabel.textAlignment = .center
            animatedLabel.font = UIFont.systemFont(ofSize: 13)
            
            
            if let text = selectedItem.stream_link {
                animatedLabel.text = "\(text)                      "
            }
            
            
           
            streamLink.addSubview(animatedLabel)
        
            //
            
            soundLbl.text = "Original sound"
            soundLbl.textAlignment = .right
            
            
        } else {

            soundLbl.text = ""
            animatedLabel = MarqueeLabel.init(frame: CGRect(x: soundLbl.layer.bounds.minX, y: soundLbl.layer.bounds.minY, width: soundLbl.layer.bounds.width, height: 16.0), rate: 60.0, fadeLength: 10.0)
            animatedLabel.type = .continuous
            animatedLabel.leadingBuffer = 20.0
            animatedLabel.trailingBuffer = 10.0
            animatedLabel.animationDelay = 0.0
            animatedLabel.textAlignment = .center
            animatedLabel.font = UIFont.systemFont(ofSize: 13)
            
            
            if let username = SelectedUserName {
                animatedLabel.text = "Original sound - \(username)                      "
            } else {
                animatedLabel.text = "Original sound                               "
            }
           
           
            soundLbl.addSubview(animatedLabel)
            
            //
            
            streamLink.text = ""
            
            
        }
        
        
        if SelectedAvatarUrl != "", let url =  SelectedAvatarUrl {
            
            let imageNode = ASNetworkImageNode()
            imageNode.contentMode = .scaleAspectFit
            imageNode.shouldRenderProgressImages = true
            imageNode.url = URL.init(string: url)
            imageNode.frame = self.avatarUrl.layer.bounds
            self.avatarUrl.image = nil
            
            
            self.avatarUrl.addSubnode(imageNode)
            
            
        }
        
        
        usernameLbl.text = SelectedUserName
        gameName.text = selectedItem.category
       
        let date = selectedItem.post_time.dateValue()
        timeStamp.text = timeAgoSinceDate(date, numericDates: true)
      
        
        
        loadLogo(category: selectedItem.category)
        
  
        
    }
    
    
    @objc func loadUrl() {
        
        if let link = selectedItem.stream_link, link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }

            if UIApplication.shared.canOpenURL(requestUrl) {
                 UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            }
            
        } else {
            
            print("Empty link")
            
        }
        
    }
    
    func loadLogo(category: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("name", isEqualTo: category).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
                
                if let url = item.data()["url2"] as? String {
                    
                    imageStorage.async.object(forKey: url) { result in
                        if case .value(let image) = result {
                            
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                
                                
                                self.gameLogo.image = image
                                
                                //try? imageStorage.setObject(image, forKey: url)
                                
                            }
                            
                        } else {
                            
                            
                         AF.request(url).responseImage { response in
                                
                                
                                switch response.result {
                                case let .success(value):
                                    self.gameLogo.image = value
                                    try? imageStorage.setObject(value, forKey: url)
                                case let .failure(error):
                                    print(error)
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
                
            }
            
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        NotificationCenter.default.removeObserver(self)
        
        self.videoNode.pause()
        
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let id = selectedItem.Mux_playbackID {
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            
            let url = "https://stream.mux.com/\(id).m3u8"

            let asset = AVAsset(url: URL(string: url)!)
     
            videoNode.frame = videoPlayer.layer.bounds
            
            videoPlayer.addSubnode(videoNode)
            
            if selectedItem.ratio <= 1.0 {
                
                videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                
            } else {
                
                videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                
            }
            
            
            videoNode.shouldAutoplay = false
            videoNode.shouldAutorepeat = true
           
            videoNode.asset = asset
    
            videoNode.play()
            
            
        }
        
        
        let linkBtn = ASButtonNode()
        linkBtn.backgroundColor = UIColor.clear
        linkBtn.frame = CGRect(x: InfoView.layer.bounds.minX, y: InfoView.layer.bounds.maxY - 16, width: 170, height: 20)
        linkBtn.addTarget(self, action: #selector(loadUrl), forControlEvents: .touchUpInside)
        
        InfoView.addSubnode(linkBtn)
        
        
    }
  
    
    @objc func appMovedToBackground() {
        
        if videoNode.isPlaying() == true {
            
            print("pause")
            videoNode.pause()
            
            // process notification
            NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToactive), name: UIApplication.didBecomeActiveNotification, object: nil)
            
        }
        
        
    }
    
    @objc func appMovedToactive() {
        
        if videoNode.isPlaying() == false {
            
            print("resume")
            
            videoNode.play()
            
            // process notification
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            
            
        }

        
    }
    
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        
        videoControl()
        
    }
    
    func videoControl() {
        
        
        if videoNode.isPlaying() == true {
            
            UIView.transition(with: playBtn, duration: 0.5, options: .transitionFlipFromRight, animations: { [self] in
                playBtn.setImage(UIImage(named: "play"), for: .normal)
                        }, completion: nil)
        
        
            videoNode.pause()
            
        } else {
            
            
            
            UIView.transition(with: playBtn, duration: 0.5, options: .transitionFlipFromLeft, animations: { [self] in
                playBtn.setImage(nil, for: .normal)
                        }, completion: nil)
            
            videoNode.play()
            
        }
        
        
    }
    
    
    @IBAction func videoSettingBtnPressed(_ sender: Any) {
        
        if videoNode.isPlaying() == true {
            
            videoNode.pause()
            NotificationCenter.default.addObserver(self, selector: #selector(EditVideoVC.resumeAfterEdit), name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            
        }
        
        self.performSegue(withIdentifier: "moveToVideoSettingVC", sender: nil)
        
    }
    
    
    @IBAction func videoSettingBtn1Pressed(_ sender: Any) {
        
        if videoNode.isPlaying() == true {
            
            videoNode.pause()
            NotificationCenter.default.addObserver(self, selector: #selector(EditVideoVC.resumeAfterEdit), name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            
        }
        
        self.performSegue(withIdentifier: "moveToVideoSettingVC", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToVideoSettingVC"{
            if let destination = segue.destination as? VideoSettingVC
            {
                
                destination.selectedItem = self.selectedItem
               
                
            }
        }
        
        
    }
    
    
    
    @objc func resumeAfterEdit() {
        
        
        videoNode.play()
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        
        
    }
    
}
