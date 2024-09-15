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

class URLTests: XCTestCase {
    static let supportedURL = URL(string: "https://pvieito.com")!
    static let unsupportedURL = URL(string: "fake-scheme://pvieito.com:51234")!

    func testURL_appendingPathComponents() {
        let testURL = URL(fileURLWithPath: "test")
        
        let testA = testURL.appendingPathComponent("A")
            .appendingPathComponent("B")
            .appendingPathComponent("C")
        
        let testB = testURL.appendingPathComponents("A", "B", "C")

        var testC = testURL
        testC.appendPathComponents("A", "B", "C")

        var testD = testURL
        testD.appendPathComponents(["A", "B", "C"])

        XCTAssertNotEqual(testURL, testA)
        XCTAssertEqual(testA, testB)
        XCTAssertEqual(testA, testC)
        XCTAssertEqual(testA, testD)
    }
    
    func testURL_commonParentDirectory() {
        let parentDirectory = URL(fileURLWithPath: "/Users/John/")
        let documentsDirectory = parentDirectory.appendingPathComponents("Documents", isDirectory: true)
        let file1 = parentDirectory.appendingPathComponents("Documents", "file1.txt")
        let file2 = parentDirectory.appendingPathComponents("Documents", "file2.txt")
        let file3 = parentDirectory.appendingPathComponents("file3.txt")
        let fileRoot = URL(fileURLWithPath: "/lol.txt")
        let rootDirectory = URL(fileURLWithPath: "/", isDirectory: true)

        
        let urls1: [URL] = [
            file1,
            file2,
            parentDirectory,
        ]
        XCTAssertEqual(urls1.commonParentDirectory, parentDirectory)
        
        let urls2: [URL] = [
            file1,
            file2,
            file3,
        ]
        XCTAssertEqual(urls2.commonParentDirectory, parentDirectory)

        let urls3: [URL] = [
            file1,
            file2,
        ]
        XCTAssertEqual(urls3.commonParentDirectory, documentsDirectory)
        
        let urls4: [URL] = [
            file1,
            file2,
            documentsDirectory,
        ]
        XCTAssertEqual(urls4.commonParentDirectory, documentsDirectory)

        let urls5: [URL] = [
            file1,
            file2,
            fileRoot,
        ]
        XCTAssertEqual(urls5.commonParentDirectory, rootDirectory)
        
        let urls6: [URL] = [
            rootDirectory,
            file2,
            fileRoot,
        ]
        XCTAssertEqual(urls6.commonParentDirectory, rootDirectory)
        
        let urls7: [URL] = [
            documentsDirectory,
            documentsDirectory,
            documentsDirectory,
        ]
        XCTAssertEqual(urls7.commonParentDirectory, documentsDirectory)
    }
    
    func testURL_isSupported() {
        #if (canImport(Cocoa) || canImport(UIKit)) && !os(watchOS) && !os(tvOS)
        XCTAssertTrue(URLTests.supportedURL.isSupported)
        XCTAssertFalse(URLTests.unsupportedURL.isSupported)
        #endif
    }
}
