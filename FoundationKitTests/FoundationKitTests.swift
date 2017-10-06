//
//  FoundationKitTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 7/10/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import XCTest
import Foundation
@testable import FoundationKit

class FoundationKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHexStringPerformance() {

        let randomData = Data(randomBytesCount: 1000)
        
        self.measure {
            
            for _ in 0...1000 {
                let _ = randomData.hexString
            }
        }
    }
    
    func testHexDataPerformance() {

        let randomData = Data(randomBytesCount: 1000)
        
        self.measure {
            
            for _ in 0...1000 {
                let _ = randomData.hexData
            }
        }
    }
}
