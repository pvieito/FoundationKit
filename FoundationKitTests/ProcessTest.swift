//
//  ProcessTest.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 2/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import XCTest

class ProcessTests: XCTestCase {
    
    
    func testGetExecutableURL() {
        
        let whichExecutablePath = "/usr/bin/which"
        let whichExecutableURL = URL(fileURLWithPath: whichExecutablePath)
        let whichExecutableName = whichExecutableURL.lastPathComponent

        let executableURL = Process.getExecutableURL(name: whichExecutableName)
        
        XCTAssertEqual(executableURL?.resolvingSymlinksInPath().path, whichExecutableURL.path)
    }
}
