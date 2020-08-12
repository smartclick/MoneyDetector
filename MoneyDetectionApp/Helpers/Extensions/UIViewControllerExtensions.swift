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
import MoneyDetector

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
        showAlert(withMessage: "\(title) \(Messages.permission)") {
            if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        }        
    }
    
    func showAlert(withMessage message: String, okAction:(() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle:UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: Messages.alertButtonTitle, style: UIAlertAction.Style.default)
        { action -> Void in
            okAction?()
        })
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    func shareImageAndText(image: UIImage, text: String) {
        let shareAll: [Any] = [text , image]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showErrorAlertt(error: MDNetworkError) {
        var message = error.localizedDescription
        switch error {
        case .apiError(let errorMessage):
            message = errorMessage
        default:
            break
        }
        showAlert(withMessage: message)
        
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
