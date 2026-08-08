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

#if canImport(Darwin)
import Darwin
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

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

    func testURL_fileContentTypeUsesItemMetadata() throws {
        #if os(macOS)
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = temporaryDirectory.appendingPathComponent("document")
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        try Data().write(to: fileURL)
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }

        var finderInfo = Data(repeating: 0, count: 32)
        finderInfo.replaceSubrange(0..<4, with: Data("PDF ".utf8))
        let result = finderInfo.withUnsafeBytes { bytes in
            setxattr(fileURL.path, "com.apple.FinderInfo", bytes.baseAddress, bytes.count, 0, 0)
        }
        XCTAssertEqual(result, 0)

        if #available(macOS 11.0, *) {
            XCTAssertEqual(fileURL.fileContentType, .pdf)
            XCTAssertTrue(fileURL.fileContentTypeConforms(to: .data))
            XCTAssertTrue(fileURL.fileContentTypeConforms(to: [.image, .pdf]))
        }
        #endif
    }

    func testURL_remoteFileContentTypeDoesNotInferPathExtension() {
        #if canImport(UniformTypeIdentifiers)
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            let remoteURL = URL(string: "https://example.invalid/video.mp4")!

            XCTAssertNil(remoteURL.fileContentType)
            XCTAssertNotNil(UTType(filenameExtension: remoteURL.pathExtension))
        }
        #endif
    }

    func testURL_missingItemHasNoFileContentType() {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        #if canImport(UniformTypeIdentifiers)
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            XCTAssertNil(fileURL.fileContentType)
        }
        #endif
    }
}
