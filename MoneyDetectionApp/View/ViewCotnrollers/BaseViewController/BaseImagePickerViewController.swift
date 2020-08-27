//
//  BaseViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/11/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

//MARK:- Properties
class BaseImagePickerViewController: UIViewController {
    var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        return imagePicker
    }()
    
    public func imageSelected(image: UIImage) {
        
    }
}

//MARK:- Public methods
extension BaseImagePickerViewController{
    public func presentImagePicker(sourceType: UIImagePickerController.SourceType = .photoLibrary) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(withMessage: Messages.galleryNotAvailable)
        }
    }

}

extension BaseImagePickerViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true, completion: {
            guard selectedImage != nil else {
                return
            }
            self.imageSelected(image: selectedImage!)            
        })
    }
}
