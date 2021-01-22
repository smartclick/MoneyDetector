//
//  DetectResult.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/26/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import MoneyDetector

class DetectResult: Hashable {
    static func == (lhs: DetectResult, rhs: DetectResult) -> Bool {
        return lhs.detectedMoney.id == rhs.detectedMoney.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(detectedMoney.id)
    }
    
    let detectedMoney: MDDetectedMoney
    var isFeedbackProvided = false
    var isCorrect: Bool?
    var colorIndex: Int

    init(detectedMoney: MDDetectedMoney, colorIndex: Int) {
        self.detectedMoney = detectedMoney
        self.colorIndex = colorIndex
    }
}
