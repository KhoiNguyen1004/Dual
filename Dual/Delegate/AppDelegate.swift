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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let baseURLString: String = "https://desolate-woodland-21996.herokuapp.com/"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        FirebaseApp.configure()
        PixelSDK.setup(pixel_key)
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
        
        
        
        return true
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

