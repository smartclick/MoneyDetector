//
//  DetectResult.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/26/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation
import MoneyDetector

class DetectResult {
    let detectedMoney: MDDetectedMoney
    var isFeedbackProvided = false
    var isCorrect: Bool?

    init(detectedMoney: MDDetectedMoney) {
        self.detectedMoney = detectedMoney
    }
}
