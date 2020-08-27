//
//  MoneyDetectorTests.swift
//  MoneyDetectorTests
//
//  Created by Sevak Soghoyan on 8/7/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import XCTest
@testable import MoneyDetector

enum MoneyDetectorMock {
    case testDomain, testAPI, brokenURL
}

extension MoneyDetectorMock: MDEndpointType {
    public var baseURL: String {
        switch self {
        case .testAPI:
            return "http://192.168.88.232:8008/9726255eec083aa56dc09a21b33190"
        case .brokenURL:
            return "http://192.168.88.232:80"
        default:
            return ""
        }
    }

    public var path: String {
        switch self {
        case .testAPI:
            return "/test"
        default:
            return ""
        }
    }
}

class MoneyDetectorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testDetectImageWithLink() {
        let imageLink = "https://en.numista.com/catalogue/photos/armenie/643-original.jpg"
        let exp = expectation(description: "Checking if there is Money in this image Link")
        MoneyDetector.detectMoney(withImageLinkPath: imageLink) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse)
            }
            exp.fulfill()
        }

        let brokenExp = expectation(description: "Checking brokenImageLink")
        MoneyDetector.detectMoney(withImageLinkPath: "") { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse)
            }
            brokenExp.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }

    }

    func testDetectAraratWithImage() {
        let exp = expectation(description: "Checking if there are Money in this image")
        MoneyDetector.detectMoney(withImageData: Data()) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse)
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }

    }

    func testSendFeedback() {
        let correctexp = expectation(description: "Checking if works send feedback api")
        let imageId = "5f33a07acfb43250f941f379"
        MoneyDetector.sendFeedback(withImageID: imageId, isCorrect: true) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.message)
            }
            correctexp.fulfill()
        }

        let correctMessexp = expectation(description: "Checking if works send feedback api")
        MoneyDetector.sendFeedback(withImageID: image_id, message: "Great") { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.message)
            }
            correctMessexp.fulfill()
        }

        let notCorrectexp = expectation(description: "Checking if works send feedback api")
        let brokenImageId = ""
        MoneyDetector.sendFeedback(withImageID: brokenImageId, isCorrect: false) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            case .success(let imResponse):
                XCTAssertNotNil(imResponse.message)
            }
            notCorrectexp.fulfill()
        }

        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }

    }

    func testPerformDataTask() {
        let notCorrectexp = expectation(description: "Failing perform network data task")
        let parameters = ["is_correct": true]
        MDNetworking.performTask(endpointAPI: MDMoneyDetectorAPI.feedback(imageId: "5f33a07acfb43250f941f379"),
                                 httpMethod: .POST, contentType: "application/x-www-form-urlencoded",
                                 httpBody: parameters.percentEncoded()!,
                                 type: MDDetectedMoney.self) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            default:
                break
            }
            notCorrectexp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }
    }

    func testPerformDataTaskFailURL() {
        let firstExp = expectation(description: "Testing broken URL")
        let parameters = ["is_correct": true]
        MDNetworking.performTask(endpointAPI: MoneyDetectorMock.testAPI,
                                 httpMethod: .POST, contentType: "application/x-www-form-urlencoded",
                                 httpBody: parameters.percentEncoded()!,
                                 type: MDDetectedMoney.self) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            default:
                break
            }
            firstExp.fulfill()
        }
        let secExp = expectation(description: "Testing wrong domain")
        MDNetworking.performTask(endpointAPI: MoneyDetectorMock.testDomain,
                                 httpMethod: .POST,
                                 contentType: "application/x-www-form-urlencoded",
                                 httpBody: parameters.percentEncoded()!,
                                 type: MDDetectedMoney.self) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            default:
                break
            }
            secExp.fulfill()
        }
        let thirdExp = expectation(description: "Testing wrong domain")
        MDNetworking.performTask(endpointAPI: MoneyDetectorMock.brokenURL,
                                 httpMethod: .POST,
                                 contentType: "application/x-www-form-urlencoded",
                                 httpBody: parameters.percentEncoded()!,
                                 type: MDDetectedMoney.self) { (result) in
            switch result {
            case .failure(let networkError):
                XCTAssertNotNil(networkError)
            default:
                break
            }
            thirdExp.fulfill()
        }
        waitForExpectations(timeout: 10) { (error) in
            print(error?.localizedDescription ?? "error")
        }
    }

}
