//
//  HighlightCollectionCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/15/20.
//

import UIKit
import DTCollectionViewManager
import Alamofire


class HighlightsCollectionCell: UICollectionViewCell, ModelTransfer {
    
    @IBOutlet weak var thumbnail: UIImageView!
    //@IBOutlet weak var modeView: UIImageView!
    //@IBOutlet weak var ViewImg: UIImageView!
    //@IBOutlet weak var ViewCount: UILabel!
    
    
    func update(with model: HighlightsModel) {
        
            // Fill your cell with actual data
        let playbackID = model.Mux_playbackID
        let url = "https://image.mux.com/\(playbackID!)/thumbnail.png?width=314&height=178&fit_mode=pad"
        
       
        
        imageStorage.async.object(forKey: url) { result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    
                    
                    
                    DispatchQueue.main.async {
                        self.thumbnail.image = image
                    }
                    
                }
                
            } else {
                
                
             AF.request(url).responseImage { response in
                    
                    
                    switch response.result {
                    case let .success(value):
                        
                        DispatchQueue.main.async {
                            self.thumbnail.image = value
                        }
                      
                        try? imageStorage.setObject(value, forKey: url)
                        
                    case let .failure(error):
                        
                        print(error)
                        
                    }
         
                }
                
            }
            
        }
        
        
    }
    

    
    
    
}
