//
//  BaseViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/11/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

//MARK:- Properties
class BaseViewController: UIViewController {
    lazy var activityIndicatorView : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .whiteLarge
        }
        activityIndicator.color = .white
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
}

//MARK:- View Lifecycle
extension BaseViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController {
            navigationController.view.addSubview(activityIndicatorView)
        } else {
            view.addSubview(activityIndicatorView)
        }
        activityIndicatorView.autopinToSuperviewEdges()
    }

}
