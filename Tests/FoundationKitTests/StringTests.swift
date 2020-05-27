//
//  FoundationKitTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 7/10/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import XCTest
@testable import FoundationKit

class StringTests: XCTestCase {
    let strings = [
        "Put teardown code here. This method is called after the invocation of each test method in the class.",
        "",
        "123"
    ]
    
    func testStringExtensions() {
        for string in strings {
            for i in -1...strings.max()!.count {
                let result = string.abbreviated(to: i)
                
                if i >= 0 {
                    XCTAssertTrue(result.count <= i)
                }
                if i > 0, i < string.count {
                    XCTAssertTrue(result.last == "…")
                }
                if i == string.count {
                    XCTAssertTrue(string == result)
                }
                if i <= 0 {
                    XCTAssertTrue(result == "")
                }
                if i == 1, string.count > 0 {
                    XCTAssertTrue(result == "…")
                }
                
                let components = string.components(of: i)
                
                if i > 0 {
                    if string.isEmpty {
                        XCTAssertTrue(components.count == 1)
                    }
                    else {
                        XCTAssertTrue(components.count == Int(ceil(Double(string.count) / Double(i))))
                    }
                    
                    XCTAssertTrue(components.joined() == string)
                }
                else {
                    XCTAssertTrue(components == [])
                }
                
                if i >= 0 {
                    XCTAssertTrue(components.map({ $0.count }).max() ?? 0 <= i)
                }
            }
        }
    }
    
    func testStringOffsets() {
        let testString = "têst_€ËStRiNgÑù_1?ç3"
        
        XCTAssertEqual(testString[offset: 1], "ê")
        XCTAssertEqual(testString[offset: -2], "ç")
        XCTAssertEqual(testString[offset: 13], "Ñ")
        XCTAssertEqual(testString[offset: 13..<15], "Ñù")
        XCTAssertEqual(testString[offset: 13...15], "Ñù_")
        XCTAssertEqual(testString[offset: ..<3], "tês")
        XCTAssertEqual(testString[offset: ...3], "têst")
        XCTAssertEqual(testString[offset: (-1)...], "3")
        XCTAssertEqual(testString[offset: (-3)...], "?ç3")
    }
}
