//
//  AppDelegate.swift
//  Money Detection App
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {} else {
            window = UIUtilityMethods.initializeWindow(withRootViewController: Assembler.getRootController())
        }
        if UserDefaults.standard.object(forKey: Constants.outlineKey) == nil {
            UserDefaults.standard.setValue(true, forKey: Constants.outlineKey)
        }
        return true
    }
}

// MARK: UISceneSession Lifecycle
@available(iOS 13.0, *)
extension AppDelegate {

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
