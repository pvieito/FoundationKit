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

class StringTests: XCTestCase {
    
    let strings = ["Put teardown code here. This method is called after the invocation of each test method in the class.",
                   "",
                   "123"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringExtensions() {
        
        for string in strings {
            for i in -1...strings.max()!.count {
                let result = string.abbreviated(to: i)
                
                print("\"\(string)\".abbreviated(to: \(i)) -> \"\(result)\"")
                
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
                
                print("\"\(string)\".components(of: \(i)) -> \(components)")
                
                if i > 0 {
                    XCTAssertTrue(components.count == Int(ceil(Double(string.count) / Double(i))))
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
}
