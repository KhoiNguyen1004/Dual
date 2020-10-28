//
//  PlayView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/25/20.
//

import UIKit

class PlayView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playImg: UIImageView!
    
    let kCONTENT_XIB_NAME = "PlayView"
     
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
