//
//  Assembler.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/24/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import AVKit

class Assembler {
    static func configureRoot() {
        changeRootWithAnimation(window: getMainWindow(), viewController: getRootController())
    }

    static func getRootController() -> MainNavigationController {
        var mainNavigationController: MainNavigationController!
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            mainNavigationController = MainNavigationController(rootViewController: CameraViewController())
        case .notDetermined:
            mainNavigationController = MainNavigationController(rootViewController: GrantAccessViewController())
        default:
            mainNavigationController = MainNavigationController(rootViewController: CameraNotAuthorizedViewController())
        }
        return mainNavigationController
    }

    static func changeRootWithAnimation(window: UIWindow?, viewController: UIViewController) {
        guard let window = window else { return }
        // Set the new rootViewController of the window.
        // Calling "UIView.transition" below will animate the swap.
        window.rootViewController = viewController

        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .transitionCrossDissolve

        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.5

        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: {_ in
            // maybe do something on completion here
        })
    }

    static func configureOnAccessDenied() {
        DispatchQueue.main.async {
            let root = CameraNotAuthorizedViewController()
            changeRootWithAnimation(window: getMainWindow(),
                                    viewController: MainNavigationController(rootViewController: root))
        }
    }

    static func getMainWindow() -> UIWindow? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            window = sceneDelegate?.window
        } else {
            let appDel = UIApplication.shared.delegate as? AppDelegate
            window = appDel?.window
        }
        return window
    }

}
