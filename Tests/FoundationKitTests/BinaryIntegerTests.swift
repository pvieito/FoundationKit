//
//  BinaryIntegerTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 16/04/2020.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import XCTest

class BinaryIntegerTests: XCTestCase {
    func testBinaryIntegerClamping() {
        XCTAssertEqual((-45).clamped(to: -100 ... 2), -45)
        XCTAssertEqual((-45).clamped(to: -150 ... -45), -45)
        XCTAssertEqual((-45).clamped(to: -45 ... Double.infinity), -45)
        XCTAssertEqual((-45).clamped(to: -Double.infinity ... -45), -45)
        XCTAssertEqual((-45).clamped(to: (-45)...), -45)
        XCTAssertEqual((-45).clamped(to: ...(-45)), -45)

        XCTAssertEqual((-45).clamped(to: -44 ... -43), -44)
        XCTAssertEqual((-45).clamped(to: 13...124), 13)
        XCTAssertEqual((-45).clamped(to: 100...), 100)
        XCTAssertEqual((-45).clamped(to: ...2), -45)
        
        var x1 = -45
        x1.clamp(to: -79...12)
        XCTAssertEqual(x1, -45)

        var x2 = -45
        x2.clamp(to: -44 ... -44)
        XCTAssertEqual(x2, -44)
        
        var x3 = 45
        x3.clamp(to: -123 ... -10)
        XCTAssertEqual(x3, -10)

        var x4 = -45
        x4.clamp(to: 100...)
        XCTAssertEqual(x4, 100)

        var x5 = 123
        x5.clamp(to: ...2)
        XCTAssertEqual(x5, 2)
    }
}
