//
//  MDImageResponse.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public struct MDDetectMoneyResponse: Decodable {
    public var publicUrl: String?
    public var results: [MDDetectedMoney]?
    
    private enum CodingKeys: String, CodingKey {
        case results = "result"
        case publicUrl = "public_url"
    }
}
