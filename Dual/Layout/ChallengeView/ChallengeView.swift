//
//  ChallengeView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/24/20.
//

import UIKit

class ChallengeView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var shareBtn: UIImageView!
    @IBOutlet weak var challengeBtn: UIImageView!
    
    let kCONTENT_XIB_NAME = "ChallengeView"
     
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
