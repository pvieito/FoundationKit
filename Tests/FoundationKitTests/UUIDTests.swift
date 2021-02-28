//
//  UUIDTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 08/05/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import XCTest

class UUIDTests: XCTestCase {
    func testUUIDRandom() {
        for _ in 0...100 {
            XCTAssertNotEqual(UUID.random(), UUID.random())
        }
    }
    
    func testUUIDFromData() {
        XCTAssertNil(UUID(data: Data([])))
        XCTAssertNil(UUID(data: Data([1, 2, 3])))
        XCTAssertNil(UUID(data: Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])))
        XCTAssertNil(UUID(data: Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17])))
        XCTAssertEqual(UUID(data: Data([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]))?.uuidString, "01020304-0506-0708-090A-0B0C0D0E0F10")
        XCTAssertEqual(UUID(data: Data([255, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]))?.uuidString, "FF020304-0506-0708-090A-0B0C0D0E0F10")
        XCTAssertEqual(UUID(data: Data(repeating: 0, count: 16)), .zero)
    }
}

#if canImport(CryptoKit)
extension UUIDTests {
    func testUUIDHashing() {
        let input = [
            (Data("2019/01/05/part-00002-95aa10ed-5312-4de1-a562-0517ab73a2a1-c000.csv.gz".utf8), "2341F671-D6E9-FC31-93F8-C68B33BF1A97"),
            (Data("::SOURCE_DATA".utf8) + Data([0xFF, 0xFA, 0x88]) + Data("::".utf8), "AC42FFCD-29F7-6FCF-BA20-3E9C43F5254C"),
        ]
        
        for (input, result) in input {
            if let inputString = String(data: input, encoding: .utf8) {
                XCTAssertEqual(UUID(hashing: inputString), UUID(uuidString: result)!)
            }
            XCTAssertEqual(UUID(hashing: input), UUID(uuidString: result)!)
        }
    }
}
#endif
