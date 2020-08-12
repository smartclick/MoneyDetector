//
//  MDNetworking.swift
//  MoneyDetector
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//
import Foundation

public enum HTTPMethods: String {
    case POST,PUT,DELETE,GET
}

//MARK:- Public methods
public struct MDNetworking {
    public static func checkImageFromUrl(imageUrlLink: String,
                                         completion: @escaping (Result<MDDetectMoneyResponse,MDNetworkError>) -> Void) {
        let parameters = ["url": imageUrlLink]
        performTask(endpointAPI: MDMoneyDetectorAPI.image, httpMethod: .POST, contentType: "multipart/form-data", httpBody: parameters.percentEncoded()!, type: MDDetectMoneyResponse.self, completion: completion)
    }
    
    public static func checkImage(imageData: Data,
                                  completion: @escaping (Result<MDDetectMoneyResponse,MDNetworkError>) -> Void) {
        let boundary = UUID().uuidString
        let httpBody = NSMutableData()
        httpBody.append(convertFileData(fileData: imageData,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")
        performTask(endpointAPI: MDMoneyDetectorAPI.image, httpMethod: .POST, contentType: "multipart/form-data; boundary=\(boundary)", httpBody: httpBody as Data, type: MDDetectMoneyResponse.self, completion: completion)
    }
    
    public static func sendFeedback(imageId: String,
                                    isCorrect: Bool,
                                    completion: @escaping (Result<MDMessageResponse,MDNetworkError>) -> Void) {
        let feedbackAPI = MDMoneyDetectorAPI.feedback(imageId: imageId)
        let parameters = ["is_correct": isCorrect]
        performTask(endpointAPI: feedbackAPI, httpMethod: .POST, contentType: "application/x-www-form-urlencoded", httpBody: parameters.percentEncoded()!, type: MDMessageResponse.self, completion: completion)
    }
    
    public static func sendFeedback(imageId: String,
                                    message: String,
                                    completion: @escaping (Result<MDMessageResponse,MDNetworkError>) -> Void) {
        let feedbackAPI = MDMoneyDetectorAPI.feedback(imageId: imageId)
        let parameters = ["message": message]
        performTask(endpointAPI: feedbackAPI, httpMethod: .POST, contentType: "application/x-www-form-urlencoded", httpBody: parameters.percentEncoded()!, type: MDMessageResponse.self, completion: completion)
    }
    
    public static func performTask<T: Decodable>(endpointAPI: MDEndpointType,
                                   httpMethod: HTTPMethods,
                                   contentType: String,
                                   httpBody: Data,
                                   type: T.Type,
                                   completion: @escaping (Result<T,MDNetworkError>) -> Void) {
        let urlString = (endpointAPI.baseURL + endpointAPI.path).removingPercentEncoding!
        guard let url = URL(string: urlString) else {
            completion(.failure(.domainError))
            return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = httpBody
        urlRequest.timeoutInterval = 10.0
        performNetworkTask(type: T.self, urlRequest: urlRequest, completion: completion)
    }
}

//MARK:- Private methods
extension MDNetworking {
    private static func performNetworkTask<T: Decodable>(type: T.Type,
                                                         urlRequest: URLRequest,
                                                         completion: @escaping (Result<T,MDNetworkError>) -> Void) {
        let urlSession = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let data = data,
                let response = urlResponse as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    completion(.failure(.domainError))
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                if let response = decodeData(type: MDMessageResponse.self, data: data),let errorText = response.error {
                    completion(.failure(.apiError(errorMessage: errorText)))
                } else {
                    completion(.failure(.statusCodeError))
                }
                return
            }
            
            if let response = decodeData(type: T.self, data: data) {
                completion(.success(response))
            } else {
                let string = String(decoding: data, as: UTF8.self)
                print(string)
                completion(.failure(.decodingError))
            }
        }
        urlSession.resume()
    }
    
    private static func decodeData<T: Decodable>(type: T.Type, data: Data) -> T? {
        let jsonDecoder = JSONDecoder()
        do {
            let response = try jsonDecoder.decode(T.self, from: data)
            return response
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private static func convertFileData(fileData: Data, using boundary: String) -> Data {
        let timestamp = String(Date().timeIntervalSince1970)
        let data = NSMutableData()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(timestamp).png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data as Data
    }
}
