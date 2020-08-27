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

    static let sessionQueueName = "ai.smartclick.MoneyDetectionApp.captureSession"

    static let serverExpectedSize = 550.0
}

struct Messages {
    static let alertButtonTitle = "Ok"
    static let cancelButtonTitle = "Cancel"
    static let settingsAlertButtonTitle = "Settings"
    static let cameraNotAvailable = "Camera not available for this device"
    static let galleryNotAvailable = "Gallery not available for this device"
    static let permission = "access is absolutely necessary to use this app"
    static let feedbackPlaceholder = "Enter feedback text..."
    static let feedbackEmptyText = "Feedback text is empty"
    static let somethingWrong = "Something went wrong"
    static let invalidUrl = "Invalid url"
    static let checkInternetConnection = "Please check your internet connection."
}

struct UIConstants {
    static let authorizedGalleryButtonTitle = "Choose from Gallery"
    static let unauthorizedGalleryButtonTitle = "Allow Acces to Gallery"

    static let safeAreaHeight = (UtilityMethods.getKeyWindow()?.safeAreaLayoutGuide.layoutFrame.height) ?? 0

    static let defaultSwipeViewHeight: CGFloat = 23.0
    static let defaultOpenedTableViewContainerHeight: CGFloat = UIConstants.safeAreaHeight * 0.74
    static let defaultOpenedTableViewHeight: CGFloat = defaultOpenedTableViewContainerHeight - defaultSwipeViewHeight

    static let resultCorrectColor = UIColor.init(hex: "73B452", alpha: 0.7)
    static let resultIncorrectColor = UIColor.init(hex: "F44336", alpha: 0.7)

    static let enabledFeedbackButtonColor = UIColor.init(hex: "3963D5", alpha: 1.0)
    static let disabledFeedbackButtonColor = UIColor.init(hex: "3963D5", alpha: 0.2)

    static let resultCorrectText = "Thanks!"
    static let resultIncorrectText = "Oh no!"

    static let resultCorrectImage = "icon_check_white"
    static let resultIncorrectImage = "icon_cancel_white"

    static let errorImage = "error_icon"
    static let noResultImage = "no_photo_icon"
    static let errorButtonColor = UIColor.init(hex: "F44336")

    static let errorButtonTitle = "Got it"
}
