//
//  UtilityMethods.swift
//  Money Detection App
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

struct UIUtilityMethods {
    static func initializeWindow(withRootViewController rootViewController: UIViewController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        return window
    }
}
