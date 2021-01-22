//
//  SettingsViewController.swift
//  Viision
//
//  Created by Sevak Soghoyan on 1/18/21.
//  Copyright © 2021 Sevak Soghoyan. All rights reserved.
//

import UIKit

// MARK: - Properties
class SettingsViewController: UIViewController {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var outlineCheck: UIImageView!
    @IBOutlet weak var fillCheck: UIImageView!
}

// MARK: - View lifecycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = UIConstants.settingsVCTitle
        shadowView.dropShadow(color: .black, radius: 7, opacity: 0.2)
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController as? MainNavigationController {
            navigationController.changeNavColorToWhite()
            if #available(iOS 13.0, *) {
                navigationController.appPreferedStatusBarStyle = .darkContent
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = navigationController as? MainNavigationController {
            navigationController.changeNavColorToOpacity()
            navigationController.appPreferedStatusBarStyle = .lightContent
        }
    }
}
 
// MARK: - Private methods
extension SettingsViewController {
    private func updateUI() {
        outlineCheck.isHidden = !UserDefaults.standard.bool(forKey: Constants.outlineKey)
        fillCheck.isHidden = !UserDefaults.standard.bool(forKey: Constants.fillKey)
    }
}
 
// MARK: - IBActions
extension SettingsViewController {
    @IBAction func outlineButtonAction(_ sender: Any) {
        outlineCheck.isHidden = !outlineCheck.isHidden
        UserDefaults.standard.setValue(!outlineCheck.isHidden, forKey: Constants.outlineKey)
    }
    
    @IBAction func fillButtonAction(_ sender: Any) {
        fillCheck.isHidden = !fillCheck.isHidden
        UserDefaults.standard.setValue(!fillCheck.isHidden, forKey: Constants.fillKey)
    }
}
