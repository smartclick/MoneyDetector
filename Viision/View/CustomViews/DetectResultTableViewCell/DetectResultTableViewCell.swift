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
    @IBOutlet weak var valueAccuracyFeedbackLabel: UILabel!
    @IBOutlet weak var correctButton: UIButton!
    @IBOutlet weak var incorrectButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var resultView: DetectCellResultView!

    public weak var delegate: DetectResultTableViewCellDelegate?
    private var detectResult: DetectResult!

    override func awakeFromNib() {
        super.awakeFromNib()
        coinCashImageView.addShadow()
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
             NSAttributedString.Key.foregroundColor: Constants.colors[detectResult.colorIndex]]
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
        valueAccuracyFeedbackLabel.attributedText = mutableString
    }

    func configureViews() {
        updateButtons()
        feedbackView.alpha = 0
        mainView.alpha = 1
        if let isCorrect = detectResult.isCorrect, !isCorrect && !detectResult.isFeedbackProvided {
            mainView.alpha = 0
            feedbackView.alpha = 1
        }
    }

    func updateButtons() {
        if let isCorrect = detectResult.isCorrect {
            correctButton.isHidden = !isCorrect
            incorrectButton.isHidden = isCorrect
            correctButton.isEnabled = false
            incorrectButton.isEnabled = false
        } else {
            correctButton.isHidden = false
            incorrectButton.isHidden = false
            correctButton.isEnabled = true
            incorrectButton.isEnabled = true
        }
    }

    func animateViews(detectResult: DetectResult, completion: (() -> Void)? = nil) {
        resultView.update(isCorrect: detectResult.isCorrect!)
        updateButtons()
        let hideStart = 1 - UIConstants.resultViewShowHideRelativeDuration
        var showView = mainView
        if let isCorrect = detectResult.isCorrect, !isCorrect && !detectResult.isFeedbackProvided {
            showView = feedbackView
        }
        UIView.animateKeyframes(withDuration: UIConstants.resultViewAnimationDuration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: UIConstants.resultViewShowHideRelativeDuration, animations: {
                self.resultView.alpha = 1.0
                self.mainView.alpha = 0.0
            })
            UIView.addKeyframe(withRelativeStartTime: hideStart, relativeDuration: UIConstants.resultViewShowHideRelativeDuration, animations: {
                self.resultView.alpha = 0.0
                showView?.alpha = 1.0
            })
        }, completion: { (_) in
            completion?()
        })
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
