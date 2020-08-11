//
//  CameraViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import AVFoundation

//MARK:- CameraViewControllerDelegate Definitation
protocol CameraViewControllerDelegate {
    func didSelectImage(cameraViewController: CameraViewController, image :UIImage)
    func didCancel(cameraViewController: CameraViewController)
}

//MARK:- Properties
class CameraViewController: UIViewController {
    
    var captureSession : AVCaptureSession!
    var photoOutput : AVCapturePhotoOutput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var takePicture = false
    
    var delegate: CameraViewControllerDelegate?
    
    private lazy var sessionQueue = DispatchQueue(label: Constants.sessionQueueName)
    
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var proceedButton: UIButton!
    
    deinit {
        removeObservers()
    }
}

//MARK:- View Lifecycle
extension CameraViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIOnCapture(isCancel: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }
}

//MARK:- IBActions
extension CameraViewController {
    @IBAction func cameraButtonAction(_ sender: Any) {
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        setDefaultFocusAndExposure()
        updateUIOnCapture(isCancel: true)
    }
    
    @IBAction func proceedButtonAction(_ sender: Any) {
        guard let image = previewImageView.image else {
            return
        }
        pushDetectResultsViewController(withImage: image)
    }
}

//MARK:- Camera Related Private Methods
extension CameraViewController {
    private func setupCaptureSession(){
        sessionQueue.async {
            //init session
            self.captureSession = AVCaptureSession()
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
            //start running it
            self.captureSession.startRunning()
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
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        if previewLayer != nil {
            previewLayer.removeFromSuperlayer()
            previewLayer = nil
        }
        sessionQueue.async {
            self.captureSession.stopRunning()
            for input in self.captureSession.inputs {
                self.captureSession.removeInput(input)
            }
            for output in self.captureSession.outputs {
                self.captureSession.removeOutput(output)
            }
            self.captureSession = nil
        }
    }
    
    private func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraContainerView.layer.addSublayer(previewLayer)
        previewLayer.frame = cameraContainerView.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    private func updateUIOnCapture(isCancel: Bool) {
        if previewImageView.isHidden == isCancel {
            return
        }
        previewImageView.isHidden = isCancel
        cancelButton.isHidden = isCancel
        proceedButton.isHidden = isCancel
        cameraButton.isHidden = !isCancel
        sessionQueue.async {
            if nil != self.captureSession {
                isCancel ? self.captureSession.startRunning() : self.captureSession.stopRunning()
            }
        }
    }
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setDefaultFocusAndExposure),
                                               name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                               object: nil)
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

//MARK:- AVCapturePhotoCaptureDelegate methods
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let dataImage = photo.fileDataRepresentation() {
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            let resizedImage = UIUtilityMethods.resizeImage(image: image, newSize: CGFloat(Constants.serverExpectedSize))
            previewImageView.image = resizedImage
            updateUIOnCapture(isCancel: false)
        }
    }
    
}
