//
//  MDMessageResponse.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public struct MDMessageResponse: Decodable {
    public var message: String?
    public var error: String?
}
