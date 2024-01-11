//
//  BundleTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 10/06/2022.
//  Copyright © 2022 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
@testable import FoundationKit
import XCTest

class BundleTests: XCTestCase {
	#if canImport(Cocoa)
	func testApplicationBundle() {
		let safariIdentifier = "com.apple.Safari"
		let safariBundle = Bundle.applicationBundle(identifier: safariIdentifier)
		XCTAssertNotNil(safariBundle)
		XCTAssertEqual(safariBundle?.bundleIdentifier, safariIdentifier)

        let safariName = "Safari"
        let safariBundle_ = Bundle.applicationBundle(name: safariName)
        XCTAssertNotNil(safariBundle_)
        XCTAssertEqual(safariBundle_?.bundleIdentifier, safariIdentifier)
    }
	#endif
}
