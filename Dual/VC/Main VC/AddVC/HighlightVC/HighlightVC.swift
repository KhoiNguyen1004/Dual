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
import MediaWatermark


class HighlightVC: UIViewController {
    
    
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var FriendsBtn: UIButton!
    @IBOutlet weak var OnlyMeBtn: UIButton!
    
    @IBOutlet weak var soundText: MarqueeLabel!
    @IBOutlet weak var highlightTitle: UITextField!
    var item: AddModel!

    @IBOutlet weak var HighlightName: UILabel!
    @IBOutlet weak var HighlightImg: UIImageView!
    
    @IBOutlet weak var creatorLink: UITextField!
    
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
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if soundText.isPaused == true {
            
            soundText.restartLabel()
            
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        soundText.pauseLabel()
    }
    

 
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // mode choose
    
    @IBAction func PublicBtnPressed(_ sender: Any) {
        
        publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
    }
    
    
    @IBAction func FriendsBtnPressed(_ sender: Any) {
        
        FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
    }
    
    @IBAction func OnlyMeBtnPressed(_ sender: Any) {
        
        OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        
        
    }
    
    // dismiss keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        self.view.endEditing(true)
    }
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
        
        
        let sheet = UIAlertController(title: "Hello Kai1004pro!", message: "Please choose which type to upload your highlight!", preferredStyle: .alert)
        
        
        let new = UIAlertAction(title: "New record", style: .default) { (alert) in
            
            let container = ContainerController(mode: .video)
            container.editControllerDelegate = self
            
            let nav = UINavigationController(rootViewController: container)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
            
        }
        
        let library = UIAlertAction(title: "Video library", style: .default) { (alert) in
            
            
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
        
        
        
        sheet.addAction(new)
        sheet.addAction(library)
        present(sheet, animated: true, completion: nil)
       
        
        
    }
    
    func addWatermark(image: UIImage, name: String, url: URL) {
        
        if let item = MediaItem(url: url) {
            let logoImage = UIImage(named: "logo")
                    
            let firstElement = MediaElement(image: logoImage!)
            firstElement.frame = CGRect(x: 0, y: 0, width: logoImage!.size.width, height: logoImage!.size.height)
                    
            let testStr = "Attributed Text"
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35) ]
            let attrStr = NSAttributedString(string: testStr, attributes: attributes)
                    
            let secondElement = MediaElement(text: attrStr)
            secondElement.frame = CGRect(x: 300, y: 300, width: logoImage!.size.width, height: logoImage!.size.height)
                    
            item.add(elements: [firstElement, secondElement])
                    
            let mediaProcessor = MediaProcessor()
            mediaProcessor.processElements(item: item) { (result, error) in
                
                print(result.processedUrl!)
                
            }
        }
        
        
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
            
            VideoExporter.shared.export(video: video, progress: { progress in
                print("Export progress: \(progress)")
            }, completion: { error in
                if let error = error {
                    print("Unable to export video: \(error)")
                    return
                }

                print("Finished video export at URL: \(video.exportedVideoURL)")
            })
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
   
    
    
    
    
}

