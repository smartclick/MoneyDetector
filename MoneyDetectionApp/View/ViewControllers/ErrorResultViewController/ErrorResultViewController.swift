//
//  ErrorResultViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/25/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

enum ErrorType {
    case error(String, String), noResult
}

// MARK: - Properties and initilization methods
class ErrorResultViewController: UIViewController {
    @IBOutlet weak var iconImageVIew: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!

    var errorType: ErrorType = .noResult

    var onAction: (() -> Void)?
}

// MARK: - View Lifecycle
extension ErrorResultViewController {
    convenience init(withType type: ErrorType) {
        self.init()
        self.errorType = type
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
}

// MARK: - Actions
extension ErrorResultViewController {
    @IBAction func takeAnotherButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.onAction?()
        })
    }
}

// MARK: - Private methods
extension ErrorResultViewController {
    private func updateUI() {
        switch errorType {
        case .error(let title, let errorMessage):
            configureErrorView(title: title, message: errorMessage)
        default:
            break
        }
    }

    private func configureErrorView(title: String, message: String) {
        titleLabel.text = title
        if title != message {
            descriptionLabel.text = message
        } else {
            descriptionLabel.text = ""
        }
        iconImageVIew.image = UIImage(named: UIConstants.errorImage)
        mainButton.backgroundColor = UIConstants.errorButtonColor
        mainButton.setTitle(UIConstants.errorButtonTitle, for: .normal)
    }
}
