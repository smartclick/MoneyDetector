//
//  MainViewController.swift
//  Money Detection App
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

//MARK:- Properties
class MainViewController: UIViewController {    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!        
}

//MARK:- View lifecycle
extension MainViewController {    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
}

//MARK:- Private methods
extension MainViewController {
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = sourceType
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(withMessage: Messages.galleryNotAvailable)
        }
    }
    
    private func pushCameraViewController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraVC = CameraViewController()
            navigationController?.pushViewController(cameraVC, animated: true)
        } else {
            showAlert(withMessage: Messages.cameraNotAvailable)
        }
    }        
}

//MARK:- IBActions
extension MainViewController {
    @IBAction func cameraButtonAction(_ sender: Any) {
        checkCameraPermission { (isSuccess) in
            self.pushCameraViewController()
        }
    }
    
    @IBAction func galleryButtonAction(_ sender: Any) {
        checkGalleryPermission { (isSuccess) in
            self.presentImagePicker(sourceType: .photoLibrary)
        }
    }
}

// MARK:- UIImagePickerControllerDelegate methods
extension MainViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true, completion: {
            guard selectedImage != nil,let resizedImage = UIUtilityMethods.resizeImage(image: selectedImage!, newSize: CGFloat(Constants.serverExpectedSize)) else {
                return
            }
            self.pushDetectResultsViewController(withImage: resizedImage)
        })
    }
}
