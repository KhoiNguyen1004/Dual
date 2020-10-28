//
//  PostNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/23/20.
//

import UIKit
import AsyncDisplayKit
import MarqueeLabel

class PostNode: ASCellNode {
    
    var post: HighlightsModel
    var gradientNode: GradientNode
    var backgroundImageNode: ASNetworkImageNode
    var videoNode: ASVideoNode
    var animatedLabel: MarqueeLabel!
    
    var PlayViews: PlayView!
    var DetailViews: DetailView!
    
 
    
    // btn
    
    var shareBtn : ((ASCellNode) -> Void)?
    var challengeBtn : ((ASCellNode) -> Void)?
    var linkBtn : ((ASCellNode) -> Void)?
    
    
    init(with post: HighlightsModel) {
        
        self.post = post
        self.backgroundImageNode = ASNetworkImageNode()
        self.videoNode = ASVideoNode()
        self.gradientNode = GradientNode()
        
        super.init()
        
        self.backgroundImageNode.url = self.getThumbnailURL(post: post)
        self.backgroundImageNode.contentMode = .scaleAspectFill
        
        self.gradientNode.isLayerBacked = true
        self.gradientNode.isOpaque = false

        self.videoNode.url = self.getThumbnailURL(post: post)
        self.videoNode.shouldAutoplay = true
        self.videoNode.shouldAutorepeat = true
        
        if post.ratio <= 1.0 {
            
            self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            
        } else {
            
            self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
            
        }
    
        self.backgroundColor = UIColor.black
                
        DispatchQueue.main.async() { [self] in
            DetailViews = DetailView()
            self.videoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
            
            
            
            self.view.addSubview(DetailViews)
            
            
            DetailViews.translatesAutoresizingMaskIntoConstraints = false
            DetailViews.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            DetailViews.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            DetailViews.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            DetailViews.heightAnchor.constraint(equalToConstant: 210).isActive = true
            
            //
            self.gameInfoSetting(post: post, Dview: DetailViews)
            
            self.videoNode.view.translatesAutoresizingMaskIntoConstraints = false
            self.videoNode.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
            self.videoNode.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            self.videoNode.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            self.videoNode.view.bottomAnchor.constraint(equalTo: DetailViews.topAnchor, constant: 0).isActive = true
           
     
            self.gradientNode.frame = self.videoNode.frame
            
            
            // add playview
            PlayViews = PlayView()
            self.view.addSubview(PlayViews)
           
            
            PlayViews.translatesAutoresizingMaskIntoConstraints = false
            PlayViews.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
            PlayViews.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            PlayViews.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            PlayViews.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -210).isActive = true
            
            // add inside button

            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(SingleTapped))
            singleTap.numberOfTapsRequired = 1
            PlayViews.addGestureRecognizer(singleTap)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(DoubleTapped))
            doubleTap.numberOfTapsRequired = 2
            PlayViews.addGestureRecognizer(doubleTap)
            
            
            singleTap.require(toFail: doubleTap)
            
            // detailView btn
            
            
        }
           
        self.addSubnode(backgroundImageNode)
        self.addSubnode(videoNode)
        self.addSubnode(self.gradientNode)
        

        // update layout
       
        DispatchQueue.main.async() { [self] in
            
            
            
            
            let challengeViews = ChallengeView()
            self.view.addSubview(challengeViews)
            challengeViews.contentView.backgroundColor = UIColor.clear
            
            
            challengeViews.translatesAutoresizingMaskIntoConstraints = false
            challengeViews.heightAnchor.constraint(equalToConstant: 130).isActive = true
            challengeViews.widthAnchor.constraint(equalToConstant: 70).isActive = true
            challengeViews.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            challengeViews.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -210).isActive = true
            
            
            // add button closure need view controller hierachy
            
            let shareBtn = ASButtonNode()
            shareBtn.backgroundColor = UIColor.clear
            shareBtn.frame = challengeViews.shareBtn.frame
            
            shareBtn.addTarget(self, action: #selector(PostNode.shareBtnPressed), forControlEvents: .touchUpInside)
            
            challengeViews.addSubnode(shareBtn)
            
            
            let ChallengeBtn = ASButtonNode()
            ChallengeBtn.backgroundColor = UIColor.clear
            ChallengeBtn.frame = challengeViews.challengeBtn.frame
            
            ChallengeBtn.addTarget(self, action: #selector(PostNode.challengeBtnPressed), forControlEvents: .touchUpInside)
            
            challengeViews.addSubnode(ChallengeBtn)
            
            
            let linkBtn = ASButtonNode()
            linkBtn.backgroundColor = UIColor.clear
            linkBtn.frame = CGRect(x: DetailViews.InfoView.frame.minX, y: DetailViews.InfoView.frame.maxY - 16, width: 170, height: 20)
            
            linkBtn.addTarget(self, action: #selector(PostNode.streamLinkBtnPressed), forControlEvents: .touchUpInside)
            
            DetailViews.addSubnode(linkBtn)
                  
        }

       
    }
    

    
    @objc func SingleTapped() {
        
        
        if videoNode.isPlaying() == true {
            
            videoNode.pause()
            
            
            UIView.transition(with: PlayViews.playImg, duration: 0.5, options: .transitionFlipFromRight, animations: { [self] in
                PlayViews.playImg.image = UIImage(named: "play")
                    }, completion: nil)
          
            
        } else {
            videoNode.play()
            
            UIView.transition(with: PlayViews.playImg, duration: 0.5, options: .transitionFlipFromRight, animations: { [self] in
                PlayViews.playImg.image = nil
                    }, completion: nil)
        }
 
        
        
    }
    
    
    @objc func DoubleTapped() {
        // do something here
        
        print("Like handle")
        
    }
    
    
   
    @objc func resumeVideo() {
        
        
        if videoNode.isPlaying() == false {
            
            videoNode.play()
            
        }
        
        NotificationCenter.default.removeObserver(self, name:(NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostNode.pauseVideo), name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
       
    }
    
    @objc func pauseVideo() {
        
        
        if videoNode.isPlaying() == true {
            

            videoNode.pause()
            
        }
        
        NotificationCenter.default.removeObserver(self, name:(NSNotification.Name(rawValue: "pauseVideo")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostNode.resumeVideo), name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        
    }
    
    func removeAllobserve() {
        
        print("Remove all expired observes")
        NotificationCenter.default.removeObserver(self)
           
    }
    
    func startObserve() {
        
        
        print("Start new observing")
        NotificationCenter.default.addObserver(self, selector: #selector(PostNode.pauseVideo), name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToactive), name: UIApplication.didBecomeActiveNotification, object: nil)
      
    }
    
    @objc func appMovedToBackground() {
        
        if videoNode.isPlaying() == true {
            
            print("Move to background pause")
            
            videoNode.pause()
            
            // process notification
        
        }
        
        
    }
    
    @objc func appMovedToactive() {
        
        if videoNode.isPlaying() == false {
            
            print("resume active")
            if should_Play == true {
                videoNode.play()
            }
       
            
        }

        
    }
    
    @objc func shareBtnPressed(sender: AnyObject!) {
  
        shareBtn?(self)
  
        
    }
    
    @objc func challengeBtnPressed(sender: AnyObject!) {
  
        challengeBtn?(self)
  
        
    }

    @objc func streamLinkBtnPressed(sender: AnyObject!) {
  
        linkBtn?(self)
  
    
    }
    
    
   
    
    func gameInfoSetting(post: HighlightsModel, Dview: DetailView) {
        
        
        if post.stream_link != "nil" {
            
            
            Dview.streamLink.text = ""
            animatedLabel = MarqueeLabel.init(frame: Dview.streamLink.layer.bounds, rate: 60.0, fadeLength: 10.0)
            animatedLabel.type = .continuous
            animatedLabel.leadingBuffer = 20.0
            animatedLabel.trailingBuffer = 10.0
            animatedLabel.animationDelay = 0.0
            animatedLabel.textAlignment = .center
            animatedLabel.font = UIFont.systemFont(ofSize: 13)
            
            
            if let text = post.stream_link {
                animatedLabel.text = "\(text)                      "
            }
            
            
           
            Dview.streamLink.addSubview(animatedLabel)
        
            //
            
            Dview.soundLbl.text = "Original sound"
            Dview.soundLbl.textAlignment = .right
            
            
        } else {

            Dview.soundLbl.text = ""
            animatedLabel = MarqueeLabel.init(frame: Dview.soundLbl.layer.bounds, rate: 60.0, fadeLength: 10.0)
            animatedLabel.type = .continuous
            animatedLabel.leadingBuffer = 20.0
            animatedLabel.trailingBuffer = 10.0
            animatedLabel.animationDelay = 0.0
            animatedLabel.textAlignment = .center
            animatedLabel.font = UIFont.systemFont(ofSize: 13)
            
            animatedLabel.text = "Original sound - kai1004pro                      "
           
            Dview.soundLbl.addSubview(animatedLabel)
            
            //
            
            Dview.streamLink.text = ""
            
            
        }
        
        
        Dview.gameName.text = post.category
        
        
        let date = post.post_time.dateValue()
        Dview.timeStamp.text = timeAgoSinceDate(date, numericDates: true)

        getLogo(category: post.category, Dview: Dview)
    }
    
    func getLogo(category: String, Dview: DetailView) {
        
        if Dview.gameLogo != nil {
            
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
                        imageNode.frame = Dview.gameLogo.layer.bounds
                        
      
                        Dview.gameLogo.addSubnode(imageNode)
                        
                        
                    }
                    
                    
                }
                
                
            }
            
        } 
        
    }
    
    func getThumbnailURL(post: HighlightsModel) -> URL? {
        
        if let id = post.Mux_playbackID, id != "nil" {
            
            let urlString = "https://image.mux.com/\(id)/thumbnail.png?width=378&height=200&smart_crop=true"
            return URL(string: urlString)
            
        } else {
            
            return nil
            
        }
        
    }
    
    func getVideoURL(post: HighlightsModel) -> URL? {
        
        if let id = post.Mux_playbackID, id != "nil" {
            
            let urlString = "https://stream.mux.com/\(id).m3u8"
            return URL(string: urlString)
            
        } else {
            
            return nil
            
        }
        
       
    }
    
    func mute() {
        self.videoNode.muted = true
    }
    
    func unmute() {
        self.videoNode.muted = false
    }
    
}
