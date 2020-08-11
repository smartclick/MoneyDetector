//
//  UIViewControllerExtensions.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import AVKit
import Photos

extension UIViewController {
    func checkCameraPermission(completion: @escaping ((Bool) -> ())) {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
        case .notDetermined:
            proceedWithCameraAccess(completion: completion)
        default:
            DispatchQueue.main.async {
                completion(false)
                self.showAlertToEnablePermission(title: "Camera")
            }
        }
    }
    
    func pushDetectResultsViewController(withImage image: UIImage) {
        let resultVC = DetectResultsViewController(withImage: image)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func proceedWithCameraAccess(completion: @escaping ((Bool) -> ())) {
        // handler in .requestAccess is needed to process user's answer to our request
        AVCaptureDevice.requestAccess(for: .video) { success in
            if success { // if request is granted (success is true)
                DispatchQueue.main.async {
                    completion(true)
                }
            } else { // if request is denied (success is false)
                // Show the alert with animation
                DispatchQueue.main.async {
                    // Create Alert
                    completion(false)
                    self.showAlertToEnablePermission(title: "Camera")
                }
            }
        }
    }
    
    func checkGalleryPermission(completion: @escaping ((Bool) -> ())) {
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    completion(true)
                }
            default:
                DispatchQueue.main.async {
                    completion(false)
                    self.showAlertToEnablePermission(title: "Gallery")
                }
            }
        })
    }        
    
    func showAlertToEnablePermission(title: String) {
        // Create Alert
        let alert = UIAlertController(title: title, message: "\(title) access is absolutely necessary to use this app", preferredStyle: .alert)
        
        // Add "OK" Button to alert, pressing it will bring you to the settings app
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))        
        self.present(alert, animated: true)
    }
}

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
