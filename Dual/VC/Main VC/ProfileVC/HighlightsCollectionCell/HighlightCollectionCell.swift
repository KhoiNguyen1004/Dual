//
//  HighlightCollectionCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/15/20.
//

import UIKit
import DTCollectionViewManager
import Alamofire
import AsyncDisplayKit

class HighlightsCollectionCell: UICollectionViewCell, ModelTransfer {
    
    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var modeView: UIImageView!
    @IBOutlet weak var ViewCount: UILabel!
    var imageNode = ASNetworkImageNode()
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
       
    }
    
    func update(with model: HighlightsModel) {
        
        
        // Fill cell with actual data
          
        
        let playbackID = model.Mux_playbackID
        
        let mode = model.mode
        
        if mode == "Public" {
            
            modeView.image = UIImage(named: "public")
        
        } else if mode == "Friends" {
            
            modeView.image = UIImage(named: "friends")
            
        } else if mode == "Only me" {
            
            modeView.image = UIImage(named: "profile")
            
        }
        
     
        let url = "https://image.mux.com/\(playbackID!)/animated.gif?start=0&end=2&fit_mode=pad"
        
    
        imageNode.contentMode = .scaleAspectFill
        imageNode.shouldRenderProgressImages = true
        imageNode.animatedImagePaused = false
        imageNode.url = URL.init(string: url)
        imageNode.frame = self.thumbnailView.layer.bounds
        
        
        
        self.thumbnailView.addSubnode(imageNode)
        
        
    }
    

    
    
}
