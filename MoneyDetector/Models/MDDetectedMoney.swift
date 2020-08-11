//
//  MDDetectedMoney.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/11/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public struct MDDetectedMoney: Decodable {
    public var polygon: [[MDPoint]]
    public var boundingBox: [MDPoint]
    public var type: MDMoneyType
    public var currency: String
    public var value: String
    public var confidence: Double
    public var id: String
    
    private enum CodingKeys: String, CodingKey {
        case polygon, type, currency, value, confidence, id
        case boundingBox = "bbox"
    }    
}
