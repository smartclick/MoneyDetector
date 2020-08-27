//
//  DetectResultTableViewCell.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/25/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

protocol DetectResultTableViewCellDelegate: AnyObject {
    func didTapCorrectButton(cell: DetectResultTableViewCell, detectResult: DetectResult)
    func didTapIncorrectButton(cell: DetectResultTableViewCell, detectResult: DetectResult)
    func didTapLeaveFeedbackButton(cell: DetectResultTableViewCell, detectResult: DetectResult)
    func didTapCancelFeedbackButton(cell: DetectResultTableViewCell, detectResult: DetectResult)
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

    public weak var delegate: DetectResultTableViewCellDelegate?
    private var detectResult: DetectResult!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update(withDetectResult detectResult: DetectResult) {
        self.detectResult = detectResult
        let imageName = detectResult.detectedMoney.type == .coin ? UIConstants.coinIconName : UIConstants.cashIconName
        coinCashImageView.image = UIImage(named: imageName)
        titleLabel.text = "\(detectResult.detectedMoney.type.rawValue.capitalizingFirstLetter())"
        configreValueAccuracyLabel()
        configureViews()
    }

    func configreValueAccuracyLabel() {
        let mutableString = NSMutableAttributedString()
        let value = "\(detectResult.detectedMoney.value)\(detectResult.detectedMoney.currency) "
        let valueAtributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: UIConstants.helveticaFont,
             NSAttributedString.Key.foregroundColor: detectResult.color]
        let valueMutableStr = NSMutableAttributedString(string: value, attributes: valueAtributes)
        mutableString.append(valueMutableStr)
        let color = UtilityMethods.getColor(confidence: detectResult.detectedMoney.confidence)
        let confidenceAtributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: UIConstants.helveticaFont,
             NSAttributedString.Key.foregroundColor: color]
        let confidence = "\(detectResult.detectedMoney.confidence)%"
        let confidenceMutableStr = NSMutableAttributedString(string: confidence, attributes: confidenceAtributes)
        mutableString.append(confidenceMutableStr)
        valueAccuracyLabel.attributedText = mutableString
    }

    func configureViews() {
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

    func updateView(detectResult: DetectResult, completion: (() -> Void)? = nil) {
        mainView.isHidden = true
        resultView.update(isCorrect: detectResult.isCorrect!)
        resultView.animateView {
            self.update(withDetectResult: detectResult)
            completion?()
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
        delegate?.didTapCancelFeedbackButton(cell: self, detectResult: detectResult)
    }
}
