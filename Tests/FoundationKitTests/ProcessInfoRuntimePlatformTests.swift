//
//  ProcessInfoRuntimePlatformTests.swift
//  FoundationKitTests
//
//  Created by Pedro José Pereira Vieito on 30/08/2026.
//  Copyright © 2026 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Darwin)
import Foundation
import FoundationKit
import XCTest

final class ProcessInfoRuntimePlatformTests: XCTestCase {
    func testKnownRuntimePlatformsResolveCanonicalNames() {
        let platforms: [(Int32, ProcessInfo.RuntimePlatform, String)] = [
            (0, .unknown, "Unknown"),
            (1, .macOS, "macOS"),
            (2, .iOS, "iOS"),
            (3, .tvOS, "tvOS"),
            (4, .watchOS, "watchOS"),
            (5, .bridgeOS, "bridgeOS"),
            (6, .macCatalyst, "Mac Catalyst"),
            (7, .iOSSimulator, "iOS Simulator"),
            (8, .tvOSSimulator, "tvOS Simulator"),
            (9, .watchOSSimulator, "watchOS Simulator"),
            (10, .driverKit, "DriverKit"),
            (11, .visionOS, "visionOS"),
            (12, .visionOSSimulator, "visionOS Simulator"),
            (13, .firmware, "Firmware"),
            (14, .sepOS, "sepOS"),
            (15, .macOSExclaveCore, "macOS ExclaveCore"),
            (16, .macOSExclaveKit, "macOS ExclaveKit"),
            (17, .iOSExclaveCore, "iOS ExclaveCore"),
            (18, .iOSExclaveKit, "iOS ExclaveKit"),
            (19, .tvOSExclaveCore, "tvOS ExclaveCore"),
            (20, .tvOSExclaveKit, "tvOS ExclaveKit"),
            (21, .watchOSExclaveCore, "watchOS ExclaveCore"),
            (22, .watchOSExclaveKit, "watchOS ExclaveKit"),
            (23, .visionOSExclaveCore, "visionOS ExclaveCore"),
            (24, .visionOSExclaveKit, "visionOS ExclaveKit"),
            (-1, .any, "Any"),
        ]

        for (rawValue, platform, name) in platforms {
            XCTAssertEqual(ProcessInfo.RuntimePlatform(rawValue: rawValue), platform)
            XCTAssertEqual(platform.rawValue, rawValue)
            XCTAssertEqual(platform.name, name)
        }
    }

    func testUnknownRuntimePlatformPreservesRawValue() {
        let platform = ProcessInfo.RuntimePlatform(rawValue: 1_234_567)

        XCTAssertEqual(platform.rawValue, 1_234_567)
        XCTAssertEqual(platform.name, "Unknown")
    }

    func testCurrentProcessRuntimePlatforms() {
        let processInfo = ProcessInfo.processInfo

        XCTAssertEqual(processInfo.processRuntimePlatform, .macOS)
        XCTAssertEqual(
            ProcessInfo.RuntimePlatform.processRuntimePlatform(
                for: processInfo.processIdentifier
            ),
            .macOS
        )
        XCTAssertEqual(processInfo.linkerRuntimePlatform, .macOS)
        XCTAssertTrue(processInfo.executableRuntimePlatforms.contains(.macOS))
    }

    func testNonMachODataHasNoExecutableRuntimePlatforms() throws {
        XCTAssertEqual(
            try executableRuntimePlatforms(in: Data("Not a Mach-O".utf8)),
            []
        )
    }

    func testMultipleBuildVersionCommandsResolveAsExecutableRuntimePlatforms() throws {
        var machO = Data(repeating: 0, count: 80)
        machO.write(UInt32(0xFEEDFACF), at: 0)
        machO.write(UInt32(2), at: 16)
        machO.write(UInt32(48), at: 20)
        writeBuildVersionCommand(platform: 1, at: 32, to: &machO)
        writeBuildVersionCommand(platform: 6, at: 56, to: &machO)

        XCTAssertEqual(
            try executableRuntimePlatforms(in: machO),
            [.macOS, .macCatalyst]
        )
    }

    func testUniversalMachOCollectsPlatformsFromEverySlice() throws {
        var machO = Data(repeating: 0, count: 160)
        machO.writeBigEndian(UInt32(0xCAFEBABE), at: 0)
        machO.writeBigEndian(UInt32(2), at: 4)
        writeFatArchitecture(sliceOffset: 48, at: 8, to: &machO)
        writeFatArchitecture(sliceOffset: 104, at: 28, to: &machO)
        writeThinMachO(platform: 1, at: 48, to: &machO)
        writeThinMachO(platform: 7, at: 104, to: &machO)

        XCTAssertEqual(
            try executableRuntimePlatforms(in: machO),
            [.macOS, .iOSSimulator]
        )
    }

    func testCommandCannotExtendBeyondDeclaredCommandsRegion() throws {
        var machO = Data(repeating: 0, count: 56)
        machO.write(UInt32(0xFEEDFACF), at: 0)
        machO.write(UInt32(1), at: 16)
        machO.write(UInt32(8), at: 20)
        writeBuildVersionCommand(platform: 1, at: 32, to: &machO)

        XCTAssertEqual(try executableRuntimePlatforms(in: machO), [])
    }

    private func executableRuntimePlatforms(in data: Data) throws -> [ProcessInfo.RuntimePlatform] {
        let executableURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try data.write(to: executableURL)
        defer { try? FileManager.default.removeItem(at: executableURL) }
        return ProcessInfo.RuntimePlatform.executableRuntimePlatforms(for: executableURL)
    }

    private func writeFatArchitecture(sliceOffset: UInt32, at offset: Int, to data: inout Data) {
        data.writeBigEndian(sliceOffset, at: offset + 8)
        data.writeBigEndian(UInt32(56), at: offset + 12)
    }

    private func writeThinMachO(platform: UInt32, at offset: Int, to data: inout Data) {
        data.write(UInt32(0xFEEDFACF), at: offset)
        data.write(UInt32(1), at: offset + 16)
        data.write(UInt32(24), at: offset + 20)
        writeBuildVersionCommand(platform: platform, at: offset + 32, to: &data)
    }

    private func writeBuildVersionCommand(platform: UInt32, at offset: Int, to data: inout Data) {
        data.write(UInt32(0x32), at: offset)
        data.write(UInt32(24), at: offset + 4)
        data.write(platform, at: offset + 8)
    }
}

private extension Data {
    mutating func write<Integer: FixedWidthInteger>(_ value: Integer, at offset: Int) {
        var littleEndianValue = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndianValue) { bytes in
            replaceSubrange(offset..<(offset + bytes.count), with: bytes)
        }
    }

    mutating func writeBigEndian<Integer: FixedWidthInteger>(_ value: Integer, at offset: Int) {
        var bigEndianValue = value.bigEndian
        Swift.withUnsafeBytes(of: &bigEndianValue) { bytes in
            replaceSubrange(offset..<(offset + bytes.count), with: bytes)
        }
    }
}
#endif
