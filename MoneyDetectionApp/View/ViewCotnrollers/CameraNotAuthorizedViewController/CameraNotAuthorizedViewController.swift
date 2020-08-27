//
//  CameraNotAuthorizedViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/24/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

class CameraNotAuthorizedViewController: BaseImagePickerViewController {

    @IBOutlet weak var chooseFromGalleryButton: UIButton!

    override public func imageSelected(image: UIImage) {
        let camVC = CameraViewController()
        camVC.selectedImage = image
        self.navigationController?.pushViewController(camVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        navigationController?.navigationBar.isHidden = false
    }

    @objc
    func appResignActive(notification: NSNotification) {
        updateUI()
        checkCameraPermission { (isSuccess) in
            if isSuccess {
                Assembler.configureRoot()
            }
        }
    }

    @IBAction func allowAccessButtonAction(_ sender: Any) {
        checkCameraPermission { (isSuccess) in
            if isSuccess {
                Assembler.configureRoot()
            } else {
                self.showAlertToEnablePermission(title: "Camera")
            }
        }
    }

    @IBAction func chooseFromGalleryButtonAction(_ sender: Any) {
        if !isGalleryAccessAccepted() {
            showAlertToEnablePermission(title: "Gallery")
        } else {
            presentImagePicker()
        }
    }

    private func updateUI() {
        let title = isGalleryAccessAccepted() ?
            UIConstants.authorizedGalleryButtonTitle :
            UIConstants.unauthorizedGalleryButtonTitle
        chooseFromGalleryButton.setTitle(title, for: .normal)
    }
}
