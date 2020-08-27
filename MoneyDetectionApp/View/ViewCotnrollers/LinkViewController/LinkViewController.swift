//
//  LinkViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/25/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

protocol LinkViewControllerDelegate {
    func didAttachedLink(linkStr: String)
}

class LinkViewController: UIViewController {
    @IBOutlet weak var imageLinkTextField: UITextField!
    
    var delegate: LinkViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func attachButtonAction(_ sender: Any) {
        if UtilityMethods.verifyUrl(urlString: imageLinkTextField.text) {
            dismiss(animated: true)
            delegate?.didAttachedLink(linkStr: imageLinkTextField.text!)
        } else {
            showErrorController(withTitle: Messages.somethingWrong, message: Messages.invalidUrl)            
        }
    }
    
    @IBAction func pasteButtonAction(_ sender: Any) {
        let pasteBoard = UIPasteboard.general
        imageLinkTextField.text = pasteBoard.string
    }
}
