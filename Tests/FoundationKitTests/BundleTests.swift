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
        let safariName = "Safari"
		let safariIdentifier = "com.apple.\(safariName)"
        
		let safariBundle = Bundle.applicationBundle(identifier: safariIdentifier)
		XCTAssertNotNil(safariBundle)
		XCTAssertEqual(safariBundle?.bundleIdentifier, safariIdentifier)

        let safariBundle_ = Bundle.applicationBundle(name: safariName)
        XCTAssertNotNil(safariBundle_)
        XCTAssertEqual(safariBundle_?.bundleIdentifier, safariIdentifier)
        
        let fakeBundle = Bundle.applicationBundle(identifier: "_fake._fake.Bundle")
        XCTAssertNil(fakeBundle)

        let fakeBundle_ = Bundle.applicationBundle(name: "_FAKE_APP")
        XCTAssertNil(fakeBundle_)
    }
	#endif
}
