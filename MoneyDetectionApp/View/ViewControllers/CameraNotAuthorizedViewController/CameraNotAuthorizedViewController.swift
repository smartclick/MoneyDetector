//
//  CameraNotAuthorizedViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/24/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

// MARK: - Properties and Super class methods
class CameraNotAuthorizedViewController: BaseImagePickerViewController {

    @IBOutlet weak var chooseFromGalleryButton: UIButton!

    override public func imageSelected(image: UIImage) {
        let camVC = CameraViewController()
        camVC.selectedImage = image
        self.navigationController?.pushViewController(camVC, animated: true)
    }
}

// MARK: - View Lifecycle
extension CameraNotAuthorizedViewController {
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
}

// MARK: - Actions
extension CameraNotAuthorizedViewController {
    @objc
    func appResignActive(notification: NSNotification) {
        updateUI()
        if isCameryAccessAccepted() {
            Assembler.configureRoot()
        }
    }

    @IBAction func allowAccessButtonAction(_ sender: Any) {
        checkCameraPermission { [weak self] (isSuccess) in
            guard let self = self else {
                return
            }
            if isSuccess {
                Assembler.configureRoot()
            } else {
                self.showAlertToEnablePermission(title: Messages.cameraAlertTitle)
            }
        }
    }

    @IBAction func chooseFromGalleryButtonAction(_ sender: Any) {
        checkGalleryPermission { [weak self] (isSuccess) in
            guard let self = self else {
                return
            }
            if isSuccess {
                self.updateUI()
                self.presentImagePicker()
            } else {
                self.showAlertToEnablePermission(title: Messages.galleryAlertTitle)
            }
        }
    }
}

// MARK: - Private methods
extension CameraNotAuthorizedViewController {
    private func updateUI() {
        let title = isGalleryAccessAccepted() ?
            Messages.authorizedGalleryButtonTitle :
            Messages.unauthorizedGalleryButtonTitle
        chooseFromGalleryButton.setTitle(title, for: .normal)
    }
}
