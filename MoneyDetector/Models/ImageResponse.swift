//
//  ImageResponse.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public struct ImageResponse: Decodable {
    public var id: String
    public var imagePath: String
    var isCorrect: Bool?
    public var probability: Double
    
    private enum CodingKeys: String, CodingKey {
        case id
        case imagePath = "image_path"
        case isCorrect = "is_correct"
        case probability
    }
}
