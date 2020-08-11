//
//  ResultView.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/10/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import MoneyDetector

protocol ResultViewDelegate {
    func didTapCorrectButton(resultView: ResultView, detectedMoney: MDDetectedMoney)
    func didTapIncorrectButton(resultView: ResultView, detectedMoney: MDDetectedMoney)
    func didTapLeaveFeedbackButton(resultView: ResultView, detectedMoney: MDDetectedMoney)
}

class ResultView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var correctButton: UIButton!
    @IBOutlet weak var incorrectButton: UIButton!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var leaveFeedbackButton: UIButton!
    @IBOutlet weak var leaveFeedbackButtonHeightConstant: NSLayoutConstraint!
    
    var delegate: ResultViewDelegate?
    var view: UIView!
    var detectedMoney: MDDetectedMoney!
    
    convenience init(frame: CGRect , detectedMoney: MDDetectedMoney, polygonColor: UIColor = .clear) {
        self.init(frame: frame)        
        update(detectedMoney: detectedMoney, polygonColor: polygonColor)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()        
    }
    
    public func update(detectedMoney: MDDetectedMoney, polygonColor: UIColor) {
        self.detectedMoney = detectedMoney
        nameLabel.text = "\(detectedMoney.value) \(detectedMoney.currency) \(detectedMoney.type)"
        accuracyLabel.text = "\(detectedMoney.confidence)% accuracy"
        colorView.backgroundColor = polygonColor
    }        
    
    private func setup() {
        view = loadViewFromNib(owner: self)
        view.frame = bounds
        addSubview(view)
        view.autopinToSuperviewEdges()
    }
    
    @IBAction func correctButtonAction(_ sender: Any) {
        delegate?.didTapCorrectButton(resultView: self, detectedMoney: detectedMoney)
    }
    
    @IBAction func incorrectButtonAction(_ sender: Any) {
        delegate?.didTapIncorrectButton(resultView: self, detectedMoney: detectedMoney)
    }
    
    @IBAction func leaveFeedbackButtonAction(_ sender: Any) {
        delegate?.didTapLeaveFeedbackButton(resultView: self, detectedMoney: detectedMoney)
    }
}
