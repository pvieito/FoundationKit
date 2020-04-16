//
//  FloatingPointTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 16/04/2020.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import XCTest

class FloatingPointTests: XCTestCase {
    func testFloatingPointClamping() {
        XCTAssertEqual(3.45.clamped(to: 3.44...3.89), 3.45)
        XCTAssertEqual(3.45.clamped(to: 3.44...3.45), 3.45)
        XCTAssertEqual(3.45.clamped(to: 3.45...Double.infinity), 3.45)
        XCTAssertEqual(3.45.clamped(to: -Double.infinity...3.45), 3.45)
        XCTAssertEqual(3.45.clamped(to: 3.45...), 3.45)
        XCTAssertEqual(3.45.clamped(to: ...3.45), 3.45)

        XCTAssertEqual(3.45.clamped(to: 3.44...3.44), 3.44)
        XCTAssertEqual(3.45.clamped(to: -123 ... -10), -10)
        XCTAssertEqual(3.45.clamped(to: 100...), 100)
        XCTAssertEqual(3.45.clamped(to: ...2), 2)
        XCTAssertEqual((-45.21).clamped(to: ...2), -45.21)

        var x1 = 3.45
        x1.clamp(to: 3.44...4)
        XCTAssertEqual(x1, 3.45)

        var x2 = 3.45
        x2.clamp(to: 3.44...3.44)
        XCTAssertEqual(x2, 3.44)
        
        var x3 = 3.45
        x3.clamp(to: -123 ... -10)
        XCTAssertEqual(x3, -10)

        var x4 = 3.45
        x4.clamp(to: 100...)
        XCTAssertEqual(x4, 100)

        var x5 = -45.21
        x5.clamp(to: ...2)
        XCTAssertEqual(x5, -45.21)
    }
}
