//
//  ShareTableViewCell.swift
//  Viision
//
//  Created by Sevak Soghoyan on 1/20/21.
//  Copyright © 2021 Sevak Soghoyan. All rights reserved.
//

import UIKit

class ShareTableViewCell: UITableViewCell {
    @IBOutlet weak var dotImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    
    func update(withDetectResult detectResult: DetectResult) {
        dotImageView.image = UIImage(named: "\(UIConstants.inactiveIconPlaceholder)\(detectResult.colorIndex)")
        valueLabel.text = "\(detectResult.detectedMoney.value) \(detectResult.detectedMoney.currency)"
        valueLabel.textColor = Constants.colors[detectResult.colorIndex]
        typeLabel.text = detectResult.detectedMoney.type == .coin ? "\\ Coin" : "\\ Banknote"
        accuracyLabel.text = "\(detectResult.detectedMoney.confidence)% Accuracy"
    }
    
}
