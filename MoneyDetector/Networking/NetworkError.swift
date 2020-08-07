//
//  NetworkError.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case domainError
    case statusCodeError
    case decodingError
    case imageError
    case apiError(errorMessage: String)
}
