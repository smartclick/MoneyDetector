//
//  CameraViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

//MARK:- CameraViewControllerDelegate Definitation
protocol CameraViewControllerDelegate {
    func didSelectImage(cameraViewController: CameraViewController, image :UIImage)
    func didCancel(cameraViewController: CameraViewController)
}

//MARK:- Properties
class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var photoOutput : AVCapturePhotoOutput!
    var takePicture = false
    
    var delegate: CameraViewControllerDelegate?
    
    private lazy var sessionQueue = DispatchQueue(label: Constants.sessionQueueName)
    
    var selectedImage: UIImage?
    
    var isCameraView: Bool {
        return selectedImage == nil
    }
    
    var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        return imagePicker
    }()
    
    @IBOutlet weak var imageButtonsContainerView: UIView!
    @IBOutlet weak var cameraButtonsContainerView: UIView!
    @IBOutlet weak var cameraContainerView: PreviewView!
    @IBOutlet weak var previewImageView: UIImageView!    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var tapToFocusLabel: UILabel!
}

//MARK:- View Lifecycle
extension CameraViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraContainerView.session = captureSession
        if isCameraView {
            setupCaptureSession()
        }
        imageButtonsContainerView.addBlurEffect()
        cameraButtonsContainerView.addBlurEffect()
        configureGalleryButton()
        updateUI(showCamera: isCameraView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        if isCameraView {
            startSession()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isCameraView {
            stopSession()
        }
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isCameraView {
            updateUI(showCamera: true)
        }
    }
}

//MARK:- IBActions
extension CameraViewController {
    @IBAction func cameraButtonAction(_ sender: Any) {
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        if isCameraView {
            setDefaultFocusAndExposure()
            updateUI(showCamera: true)
            startSession()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func galleryButtonAction(_ sender: Any) {
        if isGalleryAccessAccepted(),UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlertToEnablePermission(title: "Gallery")
        }
    }
    
    @IBAction func detectButtonAction(_ sender: Any) {
        guard let image = previewImageView.image,let resizedImage = UIUtilityMethods.resizeImage(image: image, newSize: CGFloat(Constants.serverExpectedSize)) else {
            return
        }
        pushDetectResultsViewController(withImage: resizedImage)
    }
    
    @IBAction func linkButtonAction(_ sender: Any) {
        presentLinkViewController()
    }
        
}

//MARK:- Camera Related Private Methods
extension CameraViewController {
    private func updateUI(showCamera: Bool) {
        cameraButtonsContainerView.isHidden = !showCamera
        tapToFocusLabel.isHidden = !showCamera
        imageButtonsContainerView.isHidden = showCamera
        previewImageView.isHidden = showCamera
        if selectedImage != nil {
            previewImageView.image = selectedImage
        }
    }
    
    private func presentLinkViewController() {
        let linkVC = LinkViewController()
        linkVC.modalPresentationStyle = .overFullScreen
        linkVC.modalTransitionStyle = .crossDissolve
        linkVC.delegate = self
        navigationController?.present(linkVC, animated: true)
    }
    
    private func setupCaptureSession(){
        sessionQueue.async {
            //start configuration
            self.captureSession.beginConfiguration()
            
            //session specific configuration
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            //setup inputs
            self.setupInputs()
            
            DispatchQueue.main.async {
                //setup preview layer
                self.setupPreviewLayer()
            }
            
            //setup output
            self.setupOutput()
            
            //commit configuration
            self.captureSession.commitConfiguration()
        }
    }
    
    private func setupInputs(){
        //get back camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        if(device.isFocusModeSupported(.continuousAutoFocus)) {
            try! device.lockForConfiguration()
            device.isSubjectAreaChangeMonitoringEnabled = true
            device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.unlockForConfiguration()
        }
        //now we need to create an input objects from our devices
        guard let bInput = try? AVCaptureDeviceInput(device: device) else {
            fatalError("could not create input device from back camera")
        }
        
        if !captureSession.canAddInput(bInput) {
            fatalError("could not add back camera input to capture session")
        }
        //connect back camera input to session
        captureSession.addInput(bInput)
    }
    
    private func setupOutput(){
        photoOutput = AVCapturePhotoOutput()
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            fatalError("could not add video output")
        }
        
        photoOutput.connections.first?.videoOrientation = .portrait
    }
    
    private func startSession() {
        cameraContainerView.isHidden = false
        sessionQueue.async {
            self.configureObservers()
            self.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        cameraContainerView.isHidden = true
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                self.removeObservers()
            }
        }
    }
    
    private func setupPreviewLayer(){
//        cameraContainerView.videoPreviewLayer.frame = cameraContainerView.layer.bounds
        cameraContainerView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setDefaultFocusAndExposure),
                                               name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                               object: nil)
    }
    
    private func configureGalleryButton() {
        let imgManager = PHImageManager.default()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        if let last = fetchResult.lastObject {
            imgManager.requestImage(for: last, targetSize: galleryButton.frame.size, contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, _) in
                self.galleryButton.setImage(image, for: .normal)
            })
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setDefaultFocusAndExposure() {
        if let device = AVCaptureDevice.default(for:AVMediaType.video) {
            do {
                try device.lockForConfiguration()
                device.isSubjectAreaChangeMonitoringEnabled = true
                device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
                
            } catch {
                // Handle errors here
                print("There was an error focusing the device's camera")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bounds = UIScreen.main.bounds        
        guard let touchPointOpt = touches.first, touchPointOpt.view == cameraContainerView else {
            return
        }
        let touchPoint = touchPointOpt as UITouch
        let screenSize = bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: cameraContainerView).y / screenSize.height, y: 1.0 - touchPoint.location(in: cameraContainerView).x / screenSize.width)
        
        if let device = AVCaptureDevice.default(for:AVMediaType.video) {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
                }
                device.unlockForConfiguration()
                
            } catch {
                // Handle errors here
                print("There was an error focusing the device's camera")
            }
        }
    }
}

//MARK:- AVCapturePhotoCapture Delegate methods
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let dataImage = photo.fileDataRepresentation() {
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
//            let resizedImage = UIUtilityMethods.resizeImage(image: image, newSize: CGFloat(Constants.serverExpectedSize))
            previewImageView.image = image
            updateUI(showCamera: false)
            stopSession()
        }
    }
    
}

// MARK:- UIImagePickerController Delegate methods
extension CameraViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
            self.previewImageView.image = selectedImage
            self.updateUI(showCamera: false)
            self.stopSession()
        })
    }
}

//MARK:- LinkViewController Delegate methods
extension CameraViewController: LinkViewControllerDelegate {
    func didAttachedLink(linkStr: String) {
        guard let url = URL(string: linkStr) else {
            return
        }
        self.updateUI(showCamera: false)
        self.stopSession()
        UIApplication.showLoader()
        previewImageView.load(url: url) { (isSuccess) in
            UIApplication.hideLoader()
            if !isSuccess {
                self.updateUI(showCamera: true)
                self.startSession()
            }
        }
    }
}
