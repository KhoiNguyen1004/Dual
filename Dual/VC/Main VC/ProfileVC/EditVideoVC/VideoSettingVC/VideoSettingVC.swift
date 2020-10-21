//
//  VideoSettingVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/18/20.
//

import UIKit
import Photos
import Alamofire

class VideoSettingVC: UIViewController {
    
    var selectedItem: HighlightsModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func vidInformationBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToVidInformationVC", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToVidInformationVC"{
            if let destination = segue.destination as? VideoInformationVC
            {
                
                destination.selectedItem = self.selectedItem
               
                
            }
        }
        
    }
    
    @IBAction func downloadVideoBtnPressed(_ sender: Any) {
        
        if let id = selectedItem.Mux_playbackID {
            
            let url = "https://stream.mux.com/\(id)/high.mp4"
           
            downloadVideo(url: url, id: id)
            
        }
        
        
    }
    
    @IBAction func shareVideoLinkBtnPressed(_ sender: Any) {
        
        let items: [Any] = ["Check out my highlights", URL(string: "https://www.dual.so")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
        
    }
    
    @IBAction func DeleteVideoBtnPressed(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Are you sure to delete this video !", message: "If you confirm to delete, this video will be removed permanently and this action can't be undo.", preferredStyle: UIAlertController.Style.actionSheet)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { [self] action in

            
            if let id = selectedItem.highlight_id, let playback_id = selectedItem.Mux_assetID {
                
                DispatchQueue.main.async {
                    swiftLoader(progress: "Deleting")
                }
              
                let db = DataService.instance.mainFireStoreRef.collection("Highlights")
                    
                db.document(id).delete() { err in
                    
                   
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                    }
                    
                    if let err = err {
                            print("Error removing document: \(err)")
                    } else {
                            print("Document successfully removed!")
                        
                    
                        
                        print("Send data to backend for mux deleting!")
                        
                        DataService.instance.mainRealTimeDataBaseRef.child("Mux-Deleting").child(id).setValue(["id": playback_id])
                        
                        print("Sent")
                        
                        DispatchQueue.main.async {
                           
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            
                        }
                        
                       
                            
                    }
                }
                
                
            }
            
                
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func downloadVideo(url: String, id: String){

        AF.request(url).downloadProgress(closure : { (progress) in
       
            self.swiftLoader(progress: "\(String(format:"%.2f", Float(progress.fractionCompleted) * 100))%")
            
        }).responseData{ (response) in
            
            switch response.result {
            
            case let .success(value):
                
                
                let data = value
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent("\(id).mp4")
                do {
                    try data.write(to: videoURL)
                } catch {
                    print("Something went wrong!")
                }
          
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { saved, error in
                    
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                    }
                    
                    if (error != nil) {
                        
                        
                        DispatchQueue.main.async {
                            print("Error: \(error!.localizedDescription)")
                            self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                        }
                        
                    } else {
                        
                        
                        DispatchQueue.main.async {
                            
                        
                            print("Done")
                            
                            let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
     
                        
                    }
                }
                
            case let .failure(error):
                print(error)
                
        }
           
           
        }
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader(progress: String) {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: progress, animated: true)
        
 
    }
    
}
