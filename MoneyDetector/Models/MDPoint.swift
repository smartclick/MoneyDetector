//
//  MDPoint.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/11/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public struct MDPoint: Decodable {
    public var xPoint: Double
    public var yPoint: Double

    private enum CodingKeys: String, CodingKey {
        case xPoint = "x"
        case yPoint = "y"
    }
}
