//
//  MoneyDetector.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public final class MoneyDetector {
    public static func detectMoney(withImageData imageData: Data, completion:@escaping ((Result<MDImageResponse,MDNetworkError>) -> ())) {
        MDNetworking.checkImage(imageData: imageData, completion: completion)
    }
    
    public static func detectMoney(withImageLinkPath imageLink: String, completion:@escaping ((Result<MDImageResponse,MDNetworkError>) -> ())) {
        MDNetworking.checkImageFromUrl(imageUrlLink: imageLink, completion: completion)
    }
    
    public static func sendFeedback(withImageID imageID: String, isCorrect: Bool, completion:@escaping ((Result<MDMessageResponse,MDNetworkError>) -> ())) {
        MDNetworking.sendFeedback(imageId: imageID, isCorrect: isCorrect, completion: completion)
    }
}
