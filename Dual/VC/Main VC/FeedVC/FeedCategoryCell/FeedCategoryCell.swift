//
//  FeedCategoryCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/22/20.
//

import UIKit
import Alamofire

class FeedCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var CategoryImg: UIImageView!
    @IBOutlet weak var Fylbl: UILabel!
    
    var info: CategoryModel!
    
    func configureCell(_ Information: CategoryModel) {
        self.info = Information
      
        if let url = info.url, url != "" {
            
            self.Fylbl.text = ""
            
            imageStorage.async.object(forKey: url) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.CategoryImg.image = image
                        
                        //try? imageStorage.setObject(image, forKey: url)
                        
                    }
                    
                } else {
                    
                 AF.request(self.info.url).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):
                            self.CategoryImg.image = value
                            try? imageStorage.setObject(value, forKey: url)
                        case let .failure(error):
                            print(error)
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            
         
        } else {
            
            
            self.Fylbl.text = "For you"
            self.CategoryImg.image = nil
            
            
        }
        
        
        
        
    }
    
}
