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
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var streamLink: UILabel!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var gameLogo: borderAvatarView!
    @IBOutlet weak var soundLbl: MarqueeLabel!
    @IBOutlet weak var videoPlayer: UIView!
    var selectedItem: HighlightsModel!
 
    var videoNode = ASVideoNode()
    
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // sound text
        
        soundLbl.type = .continuous
        soundLbl.speed = .rate(60)
        soundLbl.fadeLength = 10.0
        soundLbl.leadingBuffer = 30.0
        soundLbl.trailingBuffer = 20.0
        soundLbl.animationDelay = 0.0
        soundLbl.textAlignment = .center
        soundLbl.text = "Original sound - Kai1004pro                                   "
        
        
        gameName.text = selectedItem.category
        
        if selectedItem.stream_link != "nil" {
            
            streamLink.text = selectedItem.stream_link
            
        } else {
            
            streamLink.text = ""
            
        }
        
        let date = selectedItem.post_time.dateValue()
        timeStamp.text = timeAgoSinceDate(date, numericDates: true)
      
        
        
        loadLogo(category: selectedItem.category)
        
  
        
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
            
            videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            videoNode.shouldAutoplay = false
            videoNode.shouldAutorepeat = true
           
            videoNode.asset = asset
    
            videoNode.play()
            
            
        }
        
        
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
