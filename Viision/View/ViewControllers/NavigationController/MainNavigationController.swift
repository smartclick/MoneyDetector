//
//  MainNavigationController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

// MARK: - View Lifecycle
class MainNavigationController: UINavigationController {

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return appPreferedStatusBarStyle
    }
    
    var appPreferedStatusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]

        changeNavColorToOpacity()

    }
    
    func changeNavColorToWhite() {
        navigationBar.isTranslucent = false
        view.backgroundColor = .clear

        navigationBar.barTintColor = .white
        navigationBar.tintColor = .black
    }
    
    func changeNavColorToOpacity() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        view.backgroundColor = .clear

        navigationBar.barTintColor = .clear
        navigationBar.tintColor = .white
    }
    
}
