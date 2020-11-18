//
//  StringExtensions.swift
//  MoneyDetectionApp
//
//  Created by Sevak Soghoyan on 8/27/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
