//
//  LoginVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/26/20.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class LoginVC: UIViewController, ZSWTappableLabelTapDelegate {

    @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    enum LinkType: String {
        case Privacy = "Privacy"
        case TermsOfUse = "TOU"
        case CodeOfProduct = "COP"
        
        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/Web-Privacy-Policy.pdf")!
            case .TermsOfUse:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/Website-Terms-of-Use.pdf")!
            case .CodeOfProduct:
                return Foundation.URL(string: "http://campusconnectonline.com/wp-content/uploads/2017/07/User-Code-of-Conduct.pdf")!
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        termOfUseLbl.tapDelegate = self
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [NSAttributedString.Key: AnyObject]()
            }
            
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.black,
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                LoginVC.URLAttributeName: type.URL
            ]
        })
       
        let string = NSLocalizedString("By using any of these login options above, you agree to our <link type='TOU'>Terms of use</link>, <link type='Privacy'>Privacy Policy</link> and <link type='COP'>User Code of Conduct</link>.", comment: "")
        
        termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
    }
    
    //
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[LoginVC.URLAttributeName] as? URL else {
            return
        }
        
        if #available(iOS 9, *) {
            show(SFSafariViewController(url: URL), sender: self)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // handle login
    
    @IBAction func PhoneUsernameBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "MoveToNormalLoginVC", sender: nil)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
