//
//  AppVersionTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 31/5/23.
//  Copyright © 2023 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import XCTest

class AppVersionTests: XCTestCase {
    func testAppVersionInitialization() {
        let versionString = "10.15.6"
        let appVersion = AppVersion(from: versionString)
        
        XCTAssertNotNil(appVersion)
        XCTAssertEqual(appVersion?.majorVersion, 10)
        XCTAssertEqual(appVersion?.minorVersion, 15)
        XCTAssertEqual(appVersion?.patchVersion, 6)
    }
    
    func testAppVersionInitialization0() {
        let versionString = "10.15"
        let appVersion = AppVersion(from: versionString)

        XCTAssertNotNil(appVersion)
        XCTAssertEqual(appVersion?.majorVersion, 10)
        XCTAssertEqual(appVersion?.minorVersion, 15)
        XCTAssertEqual(appVersion?.patchVersion, 0)
        
        let appVersion0 = AppVersion(from: "10.15.0")
        XCTAssertEqual(appVersion, appVersion0)
    }

    func testAppVersionComparison() {
        let versionString1 = "10.15.6"
        let versionString2 = "10.15.7"

        guard let version1 = AppVersion(from: versionString1), let version2 = AppVersion(from: versionString2) else {
            XCTFail("Invalid version string.")
            return
        }

        XCTAssertTrue(version1 < version2)
        XCTAssertFalse(version1 > version2)
        XCTAssertFalse(version1 == version2)
    }
}
