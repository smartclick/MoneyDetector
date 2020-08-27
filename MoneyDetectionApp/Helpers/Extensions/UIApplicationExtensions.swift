//
//  UIApplicationExtensions.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/25/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

extension UIApplication {
    static var loaderView: UIActivityIndicatorView!

    static func showLoader() {
        DispatchQueue.main.async {
            let window: UIWindow? = UtilityMethods.getKeyWindow()
            if window == nil {
                return
            }
            if nil == UIApplication.loaderView {
                UIApplication.loaderView = UIActivityIndicatorView(frame: window!.bounds)
                if #available(iOS 13.0, *) {
                    UIApplication.loaderView.style = .large
                } else {
                    UIApplication.loaderView.style = .whiteLarge
                }
                UIApplication.loaderView.color = .white
                UIApplication.loaderView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            }
            if loaderView.superview != nil {
                UIApplication.loaderView.removeFromSuperview()
            }
            window!.addSubview(UIApplication.loaderView)
            UIApplication.loaderView.autopinToSuperviewEdges()
            UIApplication.loaderView.startAnimating()
        }
    }
    
    static func hideLoader() {
        DispatchQueue.main.async {
            if UIApplication.loaderView != nil {
                UIApplication.loaderView.stopAnimating()
                UIApplication.loaderView.removeFromSuperview()
            }
        }
    }
}
