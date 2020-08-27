//
//  UIImageViewExtensions.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/25/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

extension UIImageView {
    func load(url: URL, completion: @escaping ((Bool) -> Void)) {
        image = nil
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        completion(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}
