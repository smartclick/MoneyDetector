//
//  LeaveFeedbackViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/11/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import MoneyDetector

// MARK: - LeaveFeedbackViewController protocol defination
protocol LeaveFeedbackViewControllerDelegate: AnyObject {
    func feedbackLeftSuccesfully(leaveFeedbackViewController: LeaveFeedbackViewController, detectResult: DetectResult)
}

// MARK: - Properties
class LeaveFeedbackViewController: UIViewController {
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var succesView: UIView!
    @IBOutlet weak var borderView: UIView!

    weak var delegate: LeaveFeedbackViewControllerDelegate?
    private var detectResult: DetectResult!

}

// MARK: - View Lifecycle
extension LeaveFeedbackViewController {
    convenience init(withDetectResult detectResult: DetectResult) {
        self.init()
        self.detectResult = detectResult
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        borderView.layer.cornerRadius = 10.0
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.black.cgColor
    }
}

// MARK: - Private Methods
extension LeaveFeedbackViewController {
    private func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

// MARK: - Actions
extension LeaveFeedbackViewController {
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func leaveFeedbackButtonAction(_ sender: Any) {
        leaveFeddbackButtonTapped()
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITextView Delegate methods
extension LeaveFeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Messages.feedbackPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        let isEnabled = textView.text != "" && textView.text != Messages.feedbackPlaceholder
        feedbackButton.isEnabled = isEnabled
        feedbackButton.backgroundColor = isEnabled ?
            UIConstants.enabledFeedbackButtonColor :
            UIConstants.disabledFeedbackButtonColor
    }
}

// MARK: - LeaveFeedbackViewController Delegate methods
extension LeaveFeedbackViewController {
    func leaveFeddbackButtonTapped() {
        dismissKeyboard()
        guard feedbackTextView.text != Messages.feedbackPlaceholder, !feedbackTextView.text.isEmpty else {
            showAlert(withMessage: Messages.feedbackEmptyText)
            return
        }
        UIApplication.showLoader()
        MoneyDetector.sendFeedback(withImageID: detectResult.detectedMoney.itemId,
                                   message: feedbackTextView.text) { [weak self] (result) in
            guard let self = self else {
                return
            }
            UIApplication.hideLoader()
            switch result {
            case .success(let response):
                print(response.message ?? "")
                DispatchQueue.main.async {
                    self.succesView.alpha = 1.0
                    self.delegate?.feedbackLeftSuccesfully(leaveFeedbackViewController: self,
                                                           detectResult: self.detectResult)
                }
            case .failure(let errorResponse):
                print(errorResponse.localizedDescription)
                self.showErrorController(withTitle: Messages.somethingWrong,
                                         message: UtilityMethods.getMessage(error: errorResponse))
            }
        }
    }
}
