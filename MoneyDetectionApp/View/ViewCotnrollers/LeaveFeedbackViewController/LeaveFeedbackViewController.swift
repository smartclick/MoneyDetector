//
//  LeaveFeedbackViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/11/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import MoneyDetector

//MARK:- LeaveFeedbackViewController protocol defination
protocol LeaveFeedbackViewControllerDelegate {
    func feedbackLeftSuccesfully(leaveFeedbackViewController: LeaveFeedbackViewController, imageId: String)
}

//MARK:- Properties
class LeaveFeedbackViewController: BaseViewController {
    @IBOutlet weak var feedbackTextView: UITextView!
    
    var delegate: LeaveFeedbackViewControllerDelegate?
    private var imageId: String = ""
    
}

//MARK:- View Lifecycle
extension LeaveFeedbackViewController {
    convenience init(withImageId imageId: String) {
        self.init()
        self.imageId = imageId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
    }
}

//MARK:- Private Methods
extension LeaveFeedbackViewController {
    private func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

//MARK:- Actions
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

//MARK:- UITextView Delegate methods
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
}

//MARK:- LeaveFeedbackViewController Delegate methods
extension LeaveFeedbackViewController {
    func leaveFeddbackButtonTapped() {
        guard feedbackTextView.text != Messages.feedbackPlaceholder, !feedbackTextView.text.isEmpty else {
            showAlert(withMessage: Messages.feedbackEmptyText)
            return
        }
        activityIndicatorView.startAnimating()
        MoneyDetector.sendFeedback(withImageID: imageId, message: feedbackTextView.text) { [weak self] (result) in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
            switch result {
            case .success(let response):
                print(response.message ?? "")
                DispatchQueue.main.async {
                    self.dismiss(animated: true,completion: {
                        self.delegate?.feedbackLeftSuccesfully(leaveFeedbackViewController: self, imageId: self.imageId)
                    })
                }
            case .failure(let errorResponse):
                print(errorResponse.localizedDescription)
                self.showAlert(withMessage: UtilityMethods.getMessage(error: errorResponse))
            }
        }
    }
}
