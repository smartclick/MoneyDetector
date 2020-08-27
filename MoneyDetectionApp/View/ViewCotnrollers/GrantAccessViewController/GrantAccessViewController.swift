//
//  GrantAccessViewController.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/24/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

//MARK:- Properties
class GrantAccessViewController: UIViewController {
}

//MARK:- View lifecycle
extension GrantAccessViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

//MARK:- IBActions
extension GrantAccessViewController {
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        Assembler.configureOnAccessDenied()
    }
    
    @IBAction func grantAccessButtonAction(_ sender: Any) {
        checkPermissions()
    }
}

//MARK:- Private methods
extension GrantAccessViewController {
    private func checkPermissions() {
        checkCameraPermission { (isSuccess) in
            self.checkGalleryPermission { (isSucces) in
                Assembler.configureRoot()
            }
        }
    }    
}
