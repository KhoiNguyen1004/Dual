//
//  PostNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/23/20.
//

import UIKit
import AsyncDisplayKit

class PostNode: ASCellNode {
    
    var post: HighlightsModel
    var backgroundImageNode: ASNetworkImageNode
    var videoNode: ASVideoNode
    
 
    init(with post: HighlightsModel) {
        self.post = post
        self.backgroundImageNode = ASNetworkImageNode()
        self.videoNode = ASVideoNode()
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        self.backgroundImageNode.url = self.getThumbnailURL(post: post)
        self.backgroundImageNode.contentMode = .scaleAspectFill
        
        
        
        self.videoNode.url = self.getThumbnailURL(post: post)
        self.videoNode.shouldAutoplay = true
        self.videoNode.shouldAutorepeat = true
        self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue;
        
    
        self.backgroundColor = UIColor.black
    
        DispatchQueue.main.async() {
            self.videoNode.asset = AVAsset(url: self.getVideoURL(post: post)!)
            
        
            self.videoNode.view.translatesAutoresizingMaskIntoConstraints = false
            self.videoNode.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
            self.videoNode.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            self.videoNode.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            self.videoNode.view.heightAnchor.constraint(equalToConstant: 320).isActive = true
            
    
        }
         
        self.addSubnode(backgroundImageNode)
        self.addSubnode(videoNode)
       
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
