//
//  DetailView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/24/20.
//

import UIKit
import MarqueeLabel
class DetailView: UIView {
    
   @IBOutlet weak var InfoView: UIStackView!
   @IBOutlet var contentView: UIView!
   @IBOutlet weak var username: UILabel!
   @IBOutlet weak var streamLink: UILabel!
   @IBOutlet weak var gameName: UILabel!
   @IBOutlet weak var timeStamp: UILabel!
   @IBOutlet weak var gameLogo: borderAvatarView!
   @IBOutlet weak var soundLbl: UILabel!
  
   let kCONTENT_XIB_NAME = "DetailView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }

  

}
