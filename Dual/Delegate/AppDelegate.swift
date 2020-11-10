//
//  AppDelegate.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/21/20.
//

import UIKit
import Firebase
import PixelSDK
import Alamofire
import FBSDKCoreKit
import GoogleSignIn
import TwitterKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let baseURLString: String = "https://desolate-woodland-21996.herokuapp.com/"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        FirebaseApp.configure()
        PixelSDK.setup("test")
        PixelSDK.shared.maxVideoDuration = 60
        
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            print("The app is launching for the first time. Setting UserDefaults...")
            
            do {
                try Auth.auth().signOut()
            } catch {
                
            }
            
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
            
            // Run code here for the first launch
            
        } else {
            print("The app has been launched before. Loading UserDefaults...")
            // Run code here for every other launch but the first
        }
        
        ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
               )
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: twApiKey, consumerSecret: twSecretKey)
           
        
        return true
    }
    
    func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if login_type == "Facebook" {
            
           return ApplicationDelegate.shared.application (
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            
        } else if login_type == "Google" {
            
            return GIDSignIn.sharedInstance().handle(url)
            
        } else {
            
            
            return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
            
        }

            

    }
    
   

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
        
    }
    

    override init() {
        super.init()
        
        // Main API client configuration
        MainAPIClient.shared.baseURLString = baseURLString
        
    }


}

