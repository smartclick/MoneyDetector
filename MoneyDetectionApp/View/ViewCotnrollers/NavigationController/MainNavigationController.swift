//
//  MainNavigationController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

//MARK:- View Lifecycle
class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .black
        navigationBar.isTranslucent = false
        
        view.backgroundColor = .white
    }

}
