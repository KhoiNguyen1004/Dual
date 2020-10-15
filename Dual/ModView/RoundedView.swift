//
//  windowInfo.swift
//  Campus Connect
//
//  Created by Khoi Nguyen on 3/29/18.
//  Copyright © 2018 Campus Connect LLC. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
       
        
        layer.cornerRadius = 25
        clipsToBounds = true
        
        
        
    }

}

extension UIView {

    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue

            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }


    func addShadow(shadowColor: CGColor = UIColor.orange.cgColor,
               shadowOffset: CGSize = CGSize(width: 3.0, height: 4.0),
               shadowOpacity: Float = 0.7,
               shadowRadius: CGFloat = 4.5) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

