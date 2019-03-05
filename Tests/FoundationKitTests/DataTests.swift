//
//  DataTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 20/10/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import XCTest

class DataTests: XCTestCase {
    let randomData = Data.random(count: 1000)

    func testRandomData() {
        let randomCount = 1000
        let randomDataA = Data.random(count: randomCount)
        let randomDataB = Data.random(count: randomCount)

        XCTAssertTrue(randomDataA != randomDataB)
        XCTAssertTrue(randomDataA.count == randomCount)
        XCTAssertTrue(randomDataB.count == randomCount)
    }
    
    func testHexStringPerformance() {
        self.measure {
            for _ in 0...100 {
                let _ = randomData.hexString
            }
        }
    }
    
    func testHexDataPerformance() {
        self.measure {
            for _ in 0...100 {
                let _ = randomData.hexData
            }
        }
    }
}
