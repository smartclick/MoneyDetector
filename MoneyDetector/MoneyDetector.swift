//
//  MoneyDetector.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public final class MoneyDetector {
    public static func detectMoney(withImageData imageData: Data, completion:@escaping ((Result<ImageResponse,NetworkError>) -> ())) {
        Networking.checkImage(imageData: imageData, completion: completion)
    }
    
    public static func detectMoney(withImageLinkPath imageLink: String, completion:@escaping ((Result<ImageResponse,NetworkError>) -> ())) {
        Networking.checkImageFromUrl(imageUrlLink: imageLink, completion: completion)
    }
    
    public static func sendFeedback(withImageID imageID: String, isCorrect: Bool, completion:@escaping ((Result<MessageResponse,NetworkError>) -> ())) {
        Networking.sendFeedback(imageId: imageID, isCorrect: isCorrect, completion: completion)
    }
}
