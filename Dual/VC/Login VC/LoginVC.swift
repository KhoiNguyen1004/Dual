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
import FBSDKLoginKit
import FBSDKCoreKit
import AlamofireImage
import Alamofire
import FirebaseStorage
import Firebase
import GoogleSignIn
import TwitterKit



class LoginVC: UIViewController, ZSWTappableLabelTapDelegate, LoginButtonDelegate, GIDSignInDelegate {
    
    
    
    
    @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    var finalPhone: String?
    var finalCode: String?
    var finalName: String?
    var finalBirthday: String?
    var Create_mode: String?
    var keyId: String?
    var avatarUrl: String?
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    var fbButton = FBLoginButton()
    
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
        
        
        setupFBBtn()
        setupGGBtn()
        
    }
    
    
    
    
    func setupFBBtn() {
        
        
       
        fbButton.center = facebookBtn.center
        fbButton.delegate = self
        fbButton.isHidden = true
        fbButton.permissions = ["public_profile"]
        facebookBtn.addSubview(fbButton)
        
    }
    
    func setupGGBtn() {
        
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
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
    
    @IBAction func fbBtnPressed(_ sender: Any) {
        
        
        login_type = "Facebook"
        fbButton.sendActions(for: .touchUpInside)

        
    }
    
    @IBAction func GgBtnPressed(_ sender: Any) {
        
        login_type = "Google"
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        getDataFromFacebook()
        
    
    }
    
    func getDataFromFacebook() {
      
        swiftLoader()
        
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email,age_range,gender, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil){
                if let fbDetails = result as? Dictionary<String, Any> {
               
                    if let id = fbDetails["id"] {
                        self.checkForAlreadyAccount(field: "Facebook_id", id: "fb\(id)", dict: fbDetails)
                    }
                    
                }
                
            } else {
                
                // error
                SwiftLoader.hide()
                print(error!.localizedDescription)
                
            }
        
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        
       
        print("Facebook logged out")
        
    }
    

    func checkForAlreadyAccount(field: String,id: String, dict: Dictionary<String, Any>) {
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField(field, isEqualTo: id).getDocuments { (snap, err) in
            
            if err != nil {
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
            }
            
            self.keyId = id
                   
            
            if snap?.isEmpty == true {
                
                
                print(field, id)
                
                print("Process new login")
                
                if login_type == "Facebook" {
                    self.processNewFBLogin(dict: dict)
                } else if login_type == "Google" {
                    self.processNewGGLogin(dict: dict)
                } else if login_type == "Twitter"{
                    self.processNewTwLogin(dict: dict)
                }
                
            } else {
                
                print("Process already login")
                
                for item in snap!.documents {
           
                    let i = item.data()
                    
                    if let encryptedKey = i["encryptedKey"] as? String {
                        
                        self.performNormalLogin(key: encryptedKey)
                        
                        
                    }
                    
                }
                
                
            }
            
        }
        
        
    }
    
    func performNormalLogin(key: String) {
        
        DataService.instance.mainFireStoreRef.collection("Pwd_users").whereField("secret_key", isEqualTo: key).getDocuments { (snap, err) in
            
            if err != nil {
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
       
                let i = item.data()
                
                if let pwd = i["password"] as? String {
                    
                   let encryptedRandomEmail = "\(key)@credential-dual.so"
                    
                    Auth.auth().signIn(withEmail: encryptedRandomEmail, password: pwd) { (result, error) in
                        
                        if error != nil {
                            
                            SwiftLoader.hide()
                            self.showErrorAlert("Opss !", msg: error!.localizedDescription)
                            return
                            
                        }
                        SwiftLoader.hide()
                        self.performSegue(withIdentifier: "moveToMainVC5", sender: nil)
                        
                    }
                    
                    
                }
                
            }
            
            
            
            
        }
        
        
    }
    
    func processNewTwLogin(dict: Dictionary<String, Any>) {
        
        if let name = dict["fullName"] as? String {
            finalName = name
        } else {
            finalName = "Defaults"
        }
        
        
        if let url = dict["img_url"] as? String {
            
            self.downloadImgAndPerformSegue(url: url)
            
        }
        
    }
    
    func processNewGGLogin(dict: Dictionary<String, Any>) {
        
        if let name = dict["fullName"] as? String {
            finalName = name
        } else {
            finalName = "Defaults"
        }
        
        if let tokenAccess = dict["tokenAccess"] as? String {
            
            let Url_Base = "https://www.googleapis.com/oauth2/v3/userinfo?access_token="
            let _UrlProfile = "\(Url_Base)\(tokenAccess)"
            AF.request(_UrlProfile).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let result = response.value as? [String: Any] {
                        
                        if  let photoUrl = result["picture"] as? String {
                            
                            self.downloadImgAndPerformSegue(url: photoUrl)
                            
                            
                        }
                    }
                        
                case .failure:
                    self.showErrorAlert("Oops!", msg: "CRACC: Can't get information from Google")
                    return
                        
                    }
                }
                
            }
            
    
    
    }
        
    
    func downloadImgAndPerformSegue(url: String) {
        
        AF.request(url).responseImage { response in
               
               
               switch response.result {
               case let .success(value):
                    let metaData = StorageMetadata()
                   
                    let imageUID = UUID().uuidString
                    metaData.contentType = "image/jpeg"
                    var imgData = Data()
                    imgData = value.jpegData(compressionQuality: 1.0)!
                    
                    DataService.instance.AvatarStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
                        
                        if err != nil {
                            print(err?.localizedDescription as Any)
                            return
                        }
                        
                        DataService.instance.AvatarStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
                            
                            guard let Url = url?.absoluteString else { return }
                            
                            let downUrl = Url as String
                            let downloadUrl = downUrl as NSString
                            let downloadedUrl = downloadUrl as String
                            
                            self.avatarUrl = downloadedUrl
                            self.performMovingTransaction()
                            
                        })
                        
                    }
                    
               case let .failure(error):
                    print(error.localizedDescription)
                    self.avatarUrl = "nil"
                    self.performMovingTransaction()
               }
               
               
               
           }
        
    }
   
        
        
    
    
    func processNewFBLogin(dict: Dictionary<String, Any>) {
        
        
        if let name = dict["name"] as? String {
           finalName = name
        } else {
            finalName = "Defaults"
        }
        
        if let picture = dict["picture"] as? Dictionary<String, Any> {
            
            if let data = picture["data"] as? Dictionary<String, Any> {
                
                if let url = data["url"] as? String {
                    
                    AF.request(url).responseImage { response in
                           
                           
                           switch response.result {
                           case let .success(value):
                                let metaData = StorageMetadata()
                               
                                let imageUID = UUID().uuidString
                                metaData.contentType = "image/jpeg"
                                var imgData = Data()
                                imgData = value.jpegData(compressionQuality: 1.0)!
                                
                                DataService.instance.AvatarStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
                                    
                                    if err != nil {
                                        print(err?.localizedDescription as Any)
                                        return
                                    }
                                    
                                    DataService.instance.AvatarStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
                                        
                                        guard let Url = url?.absoluteString else { return }
                                        
                                        let downUrl = Url as String
                                        let downloadUrl = downUrl as NSString
                                        let downloadedUrl = downloadUrl as String
                                        
                                        self.avatarUrl = downloadedUrl
                                        self.performMovingTransaction()
                                        
                                    })
                                    
                                }
                                
                           case let .failure(error):
                                print(error.localizedDescription)
                                self.avatarUrl = "nil"
                                self.performMovingTransaction()
                           }
                           
                           
                           
                       }
                    
                }
            }
            
        }
        
        
        
    }
    
    func performMovingTransaction() {
        
        finalPhone = "nil"
        finalCode = "nil"
        finalBirthday = "nil"
        Create_mode = login_type
        
        SwiftLoader.hide()
        self.performSegue(withIdentifier: "MoveToFinalInfo2", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MoveToFinalInfo2"{
            if let destination = segue.destination as? FinalInfoVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
                destination.finalName = self.finalName
                destination.finalBirthday = self.finalBirthday
                destination.Create_mode = self.Create_mode
                destination.avatarUrl = self.avatarUrl
                destination.keyId = self.keyId
                
            }
        }
        
    }
    
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
         
        
    }
    
    // google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        return
      }
        
     
      // Perform any operations on signed in user here.
      let userId = user.userID                  // For client-side use only!
      let fullName = user.profile.name
      let tokenAccess = user.authentication.accessToken
      let tokenID = user.authentication.idToken
     
      // ...
        
      
        
      if let id = userId, fullName != nil, tokenAccess != nil, tokenID != nil  {
            
        let dict = ["fullName": fullName as Any, "tokenAccess": tokenAccess as Any, "tokenID": tokenID as Any] as Dictionary<String, Any>
        checkForAlreadyAccount(field: "Google_id", id: "gg\(id)", dict: dict)
            
      } else {
        
        
        self.showErrorAlert("Oops !!!", msg: "Can't gather your information")
        
      }
        
   
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func twitterBtnPressed(_ sender: Any) {
        
        login_type = "Twitter"
        
        TWTRTwitter.sharedInstance().logIn { (session, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            
            self.swiftLoader()
   
            let client = TWTRAPIClient()
            client.loadUser(withID: session!.userID, completion: { [self] (user, error) in
                
                if let url = user?.profileImageURL, let name = user?.name {
                    
                    let dict = ["fullName": name as Any, "img_url": url] as Dictionary<String, Any>
                    
                        checkForAlreadyAccount(field: "Twitter_id", id: "tw\(session!.userID)", dict: dict)
                    
                        
                    }
                    
                })
                
                
               
            
        }
    }
    
}

