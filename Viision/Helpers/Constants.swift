//
//  Constants.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

struct Constants {
    static let colors: [UIColor] = [UIColor(hex: "9143AA"),
                                    UIColor(hex: "2827A1"),
                                    UIColor(hex: "577590"),
                                    UIColor(hex: "90BE6D"),
                                    UIColor(hex: "4D908E"),
                                    UIColor(hex: "FF6060"),
                                    UIColor(hex: "F8961E"),
                                    UIColor(hex: "F3722C"),
                                    UIColor(hex: "F9C74F"),
                                    UIColor(hex: "F94144")]

    static let sessionQueueName = "ai.smartclick.viision.captureSession"

    static let serverExpectedSize = 550.0
    static let serverExpectedWidth = 1024.0
    
    static let outlineKey = "outline"
    static let fillKey = "fill"
}

struct Messages {
    static let alertButtonTitle = "Ok"
    static let cancelButtonTitle = "Cancel"
    static let cameraAlertTitle = "Camera"
    static let galleryAlertTitle = "Gallery"
    static let settingsAlertButtonTitle = "Settings"
    static let cameraNotAvailable = "Camera not available for this device"
    static let galleryNotAvailable = "Gallery not available for this device"
    static let permission = "access is absolutely necessary to use this app"
    static let feedbackPlaceholder = "Enter feedback text..."
    static let feedbackEmptyText = "Feedback text is empty"
    static let somethingWrong = "Something went wrong"
    static let invalidUrl = "Invalid url"
    static let checkInternetConnection = "Please check your internet connection."
    static let shareText = "Money detected from ai"
    static let noCurrencyTitle = "We couldn’t detect any currency"
    static let noCurrencyMessage = "Please try again"
    
    static let resultCorrectText = "Thanks!"
    static let resultIncorrectText = "Oh no!"
    
    static let authorizedGalleryButtonTitle = "Choose from Gallery"
    static let unauthorizedGalleryButtonTitle = "Allow Acces to Gallery"
}

struct UIConstants {

    static let safeAreaHeight = (UtilityMethods.getKeyWindow()?.safeAreaLayoutGuide.layoutFrame.height) ?? 0

    static let defaultSwipeViewHeight: CGFloat = 23.0
    static let defaultOpenedTableViewContainerHeight: CGFloat = UIConstants.safeAreaHeight * 0.74
    static let defaultOpenedTableViewHeight: CGFloat = defaultOpenedTableViewContainerHeight - defaultSwipeViewHeight

    static let resultCorrectColor = UIColor.init(hex: "73B452", alpha: 0.7)
    static let resultIncorrectColor = UIColor.init(hex: "F44336", alpha: 0.7)

    static let enabledFeedbackButtonColor = UIColor(named: "md_blue")!.withAlphaComponent(1.0)
    static let disabledFeedbackButtonColor = UIColor(named: "md_blue")!.withAlphaComponent(0.2)

    static let resultViewAnimationDuration = 1.5
    static let resultViewShowHideRelativeDuration = 0.25

    static let resultCorrectImage = "icon_check_white"
    static let resultIncorrectImage = "icon_cancel_white"
 
    static let errorImage = "error_icon"
    static let noResultImage = "no_photo_icon"
    static let errorButtonColor = UIColor.init(hex: "F44336")

    static let errorButtonTitle = "Got it"
    static let settingsVCTitle = "Settings"
    static let shareVCTitle = "Share Preview"
    static let helveticaFont = UIFont(name: "Helvetica", size: 14)!
    static let valueLabelColor =  UIColor(hex: "282828", alpha: 0.3)

    static let coinIconName = "icon_coin"
    static let cashIconName = "icon_cash"
    static let shareIconName = "share_icon"
    static let gearIconName = "gear_icon"
    static let feedbackIconName = "icon_feedback"
    
    static let activeIconPlaceholder = "money_icon_active_"
    static let inactiveIconPlaceholder = "money_icon_inactive_"

    static let correctnessRedColor = UIColor(hex: "F44336")
    static let correctnessOrangeColor = UIColor(hex: "D48A00")
    static let correctnessGreenColor = UIColor(hex: "73B452")
}
