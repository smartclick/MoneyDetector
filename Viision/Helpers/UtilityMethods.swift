//
//  UtilityMethods.swift
//  Money Detection App
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import MoneyDetector

struct UIUtilityMethods {
    static func initializeWindow(withRootViewController rootViewController: UIViewController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        return window
    }

    static func resizeImage(image: UIImage, newSize: CGFloat) -> UIImage? {
        var newWidth = newSize
        var newHeight = newSize
        if image.size.width > image.size.height {
            let scale = newWidth / image.size.width
            newHeight = image.size.height * scale
        } else {
            let scale = newHeight / image.size.height
            newWidth = image.size.width * scale
        }
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

struct UtilityMethods {
    static func getMessage(error: MDNetworkError) -> String {
        var message = Messages.somethingWrong
        switch error {
        case .apiError(let errorMessage):
            message = errorMessage
        case .domainError:
            message = Messages.checkInternetConnection
        default:
            break
        }
        return message
    }

    static func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }

    static func getColor(confidence: Double) -> UIColor {
        switch confidence {
        case 0..<33:
            return UIConstants.correctnessRedColor
        case 33..<79:
            return UIConstants.correctnessOrangeColor
        default:
            return UIConstants.correctnessGreenColor
        }
    }

    static func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return Array(UIApplication.shared.connectedScenes)
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
