//
//  Constants.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

struct Constants {
    static let colors: [UIColor] = [.yellow, .red, .blue, .purple, .green, .white, .black]
    
    static var sessionQueueName = "ai.smartclick.MoneyDetectionApp.captureSession"
    
    static var serverExpectedSize = 550.0
}

struct Messages {
    static var alertButtonTitle = "Ok"
    static var cameraNotAvailable = "Camera not available for this device"
    static var galleryNotAvailable = "Gallery not available for this device"
    static var permission = "access is absolutely necessary to use this app"
    static var feedbackPlaceholder = "Enter feedback text..."
    static var feedbackEmptyText = "Feedback text is empty"
    static var somethingWrong = "Something went wrong"
}
