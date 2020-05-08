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
