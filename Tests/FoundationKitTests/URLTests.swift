//
//  ProcessTest.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 2/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import XCTest

class URLTests: XCTestCase {
    static let supportedURL = URL(string: "https://pvieito.com")!
    static let unsupportedURL = URL(string: "fake-scheme://pvieito.com:51234")!

    func testURL_appendingPathComponents() {
        let testURL = URL(fileURLWithPath: "test")
        
        let testA = testURL.appendingPathComponent("A")
            .appendingPathComponent("B")
            .appendingPathComponent("C")
        
        let testB = testURL.appendingPathComponents("A", "B", "C")

        var testC = testURL
        testC.appendPathComponents("A", "B", "C")

        var testD = testURL
        testD.appendPathComponents(["A", "B", "C"])

        XCTAssertNotEqual(testURL, testA)
        XCTAssertEqual(testA, testB)
        XCTAssertEqual(testA, testC)
        XCTAssertEqual(testA, testD)
    }
    
    func testURL_isSupported() {
        #if (canImport(Cocoa) || canImport(UIKit)) && !os(watchOS) && !os(tvOS)
        XCTAssertTrue(URLTests.supportedURL.isSupported)
        XCTAssertFalse(URLTests.unsupportedURL.isSupported)
        #endif
    }
}
