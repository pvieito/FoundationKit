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

class ProcessTests: XCTestCase {
    func testGetExecutableURL() {
        let whichExecutableName = "which"
        let executableURL = Process.getExecutableURL(name: whichExecutableName)
        
        XCTAssertNotNil(executableURL)
        XCTAssertEqual(executableURL?.lastPathComponent, whichExecutableName)
    }
}
