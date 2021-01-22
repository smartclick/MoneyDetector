//
//  MDMoneyDetectorAPI.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public enum MDMoneyDetectorAPI {
    case feedback(imageId: String)
    case image
}

extension MDMoneyDetectorAPI: MDEndpointType {
    public var baseURL: String {
//        return "http://192.168.88.82:8000/9726255eec083aa56dc0449a21b33190"
        return "http://api-money.smclk.net/9726255eec083aa56dc0449a21b33190"
    }

    public var path: String {
        switch self {
        case .image:
            return "/"
        case .feedback(let imageId):
            return "/\(imageId)"
        }
    }
}
