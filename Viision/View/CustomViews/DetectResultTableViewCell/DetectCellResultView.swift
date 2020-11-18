//
//  DetectCellResultView.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/26/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

class DetectCellResultView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    func update(isCorrect: Bool) {
        backgroundColor = isCorrect ? UIConstants.resultCorrectColor : UIConstants.resultIncorrectColor
        titleLabel.text = isCorrect ? Messages.resultCorrectText : Messages.resultIncorrectText
        let image = isCorrect ? UIConstants.resultCorrectImage : UIConstants.resultIncorrectImage
        iconImageView.image = UIImage(named: image)
    }
}
