//
//  DetectResultTableViewCell.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/25/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

protocol DetectResultTableViewCellDelegate {
    func didTapCorrectButton(cell: DetectResultTableViewCell, detectResult: DetectResult)
    func didTapIncorrectButton(cell: DetectResultTableViewCell, detectResult: DetectResult)
    func didTapLeaveFeedbackButton(cell: DetectResultTableViewCell, detectResult: DetectResult)
}

class DetectResultTableViewCell: UITableViewCell {
    @IBOutlet weak var coinCashImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueAccuracyLabel: UILabel!
    @IBOutlet weak var correctButton: UIButton!
    @IBOutlet weak var incorrectButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var resultView: DetectCellResultView!
    
    public var delegate: DetectResultTableViewCellDelegate?
    private var detectResult: DetectResult!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(withDetectResult detectResult: DetectResult) {
        self.detectResult = detectResult
        let imageName = detectResult.detectedMoney.type == .coin ? "icon_coin" : "icon_cash"
        coinCashImageView.image = UIImage(named: imageName)
        titleLabel.text = "\(detectResult.detectedMoney.currency) (\(detectResult.detectedMoney.type.rawValue))"
        valueAccuracyLabel.text = "\(detectResult.detectedMoney.value) \(detectResult.detectedMoney.confidence)%"
        feedbackView.isHidden = true
        mainView.isHidden = false
        if let isCorrect = detectResult.isCorrect {
            correctButton.isHidden = !isCorrect
            incorrectButton.isHidden = isCorrect
            correctButton.isEnabled = false
            incorrectButton.isEnabled = false
            if !isCorrect && !detectResult.isFeedbackProvided {                
                mainView.isHidden = true
                feedbackView.isHidden = false
            }
        } else {
            correctButton.isHidden = false
            incorrectButton.isHidden = false
            correctButton.isEnabled = true
            incorrectButton.isEnabled = true
        }
        
    }
    
    func updateView(detectResult: DetectResult) {
        mainView.isHidden = true
        resultView.update(isCorrect:  detectResult.isCorrect!)
        resultView.animateView {
            self.update(withDetectResult: detectResult)
        }
    }
    
    @IBAction func incorrectButtonAction(_ sender: Any) {
        delegate?.didTapIncorrectButton(cell: self, detectResult: detectResult)
    }
    
    @IBAction func correctButtonAction(_ sender: Any) {
        delegate?.didTapCorrectButton(cell: self, detectResult: detectResult)
    }
    
    @IBAction func leaveFeedbackButtonAction(_ sender: Any) {
        delegate?.didTapLeaveFeedbackButton(cell: self, detectResult: detectResult)
    }
    
    @IBAction func cancelFeedbackAction(_ sender: Any) {
        detectResult.isFeedbackProvided = true
        update(withDetectResult: detectResult)
    }
}
