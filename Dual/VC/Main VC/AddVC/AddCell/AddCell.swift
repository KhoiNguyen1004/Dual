//
//  AddCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/7/20.
//

import UIKit
import AlamofireImage
import Alamofire

class AddCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var name: UILabel!
    
    
    var info: AddModel!
    
    
    func configureCell(_ Information: AddModel) {
        self.info = Information
        
        
        
        self.name.text = info.name
        
        if let url = info.url {
            
            imageStorage.async.object(forKey: url) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.imageView.image = image
                        
                        //try? imageStorage.setObject(image, forKey: url)
                        
                    }
                    
                } else {
                    
                    
                 AF.request(self.info.url).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):
                            self.imageView.image = value
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
