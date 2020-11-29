//
//  ChallengesView.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/19/20.
//

import UIKit

class ChallengesView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var maxCharLbl: UILabel!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var messages: UITextField!
    @IBOutlet weak var toLbl: UILabel!
    let kCONTENT_XIB_NAME = "ChallengesView"
     
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
