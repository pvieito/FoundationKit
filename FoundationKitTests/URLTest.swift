//
//  ProcessTest.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 2/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import XCTest

class URLTest: XCTestCase {
    static let supportedURL = URL(string: "https://pvieito.com")!
    static let unsupportedURL = URL(string: "___random_scheme_FAKE___://pvieito.com:51234")!

    func testURL_isSupported() {
        XCTAssertTrue(URLTest.supportedURL.isSupported)
        XCTAssertFalse(URLTest.unsupportedURL.isSupported)
    }
    
    func testURL_open() {
        XCTAssertNoThrow(try URLTest.supportedURL.open())
        XCTAssertThrowsError(try URLTest.unsupportedURL.open())
    }
}
