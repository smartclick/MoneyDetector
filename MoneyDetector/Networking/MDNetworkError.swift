//
//  MDNetworkError.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public enum MDNetworkError: Error {
    case domainError
    case statusCodeError
    case decodingError
    case apiError(errorMessage: String)
}
