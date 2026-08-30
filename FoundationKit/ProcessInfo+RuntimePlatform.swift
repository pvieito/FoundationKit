//
//  ProcessInfo+RuntimePlatform.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/08/2026.
//  Copyright © 2026 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Darwin)
import Darwin
import Foundation
import MachO

extension ProcessInfo {
    public struct RuntimePlatform: RawRepresentable, Hashable, Sendable {
        fileprivate enum Endianness {
            case big
            case little
        }

        private typealias ProcessInformationFunction = @convention(c) (
            Int32,
            Int32,
            UInt64,
            UnsafeMutableRawPointer?,
            Int32
        ) -> Int32
        private typealias LinkerRuntimePlatformFunction = @convention(c) () -> UInt32

        private static let processPlatformInformationFlavor: Int32 = 30
        private static let dynamicLibraryHandle = dlopen(nil, RTLD_NOW)
        private static let processInformationFunction:
            ProcessInformationFunction? = resolve("proc_pidinfo")
        private static let linkerRuntimePlatformFunction:
            LinkerRuntimePlatformFunction? = resolve("dyld_get_active_platform")

        private static let machHeaderSize = 28
        private static let machHeader64Size = 32
        private static let buildVersionCommand: UInt32 = 0x32
        private static let versionMinimumMacOSCommand: UInt32 = 0x24
        private static let versionMinimumIOSCommand: UInt32 = 0x25
        private static let versionMinimumTVOSCommand: UInt32 = 0x2F
        private static let versionMinimumWatchOSCommand: UInt32 = 0x30

        public static let unknown = Self(rawValue: 0)
        public static let macOS = Self(rawValue: 1)
        public static let iOS = Self(rawValue: 2)
        public static let tvOS = Self(rawValue: 3)
        public static let watchOS = Self(rawValue: 4)
        public static let bridgeOS = Self(rawValue: 5)
        public static let macCatalyst = Self(rawValue: 6)
        public static let iOSSimulator = Self(rawValue: 7)
        public static let tvOSSimulator = Self(rawValue: 8)
        public static let watchOSSimulator = Self(rawValue: 9)
        public static let driverKit = Self(rawValue: 10)
        public static let visionOS = Self(rawValue: 11)
        public static let visionOSSimulator = Self(rawValue: 12)
        public static let firmware = Self(rawValue: 13)
        public static let sepOS = Self(rawValue: 14)
        public static let macOSExclaveCore = Self(rawValue: 15)
        public static let macOSExclaveKit = Self(rawValue: 16)
        public static let iOSExclaveCore = Self(rawValue: 17)
        public static let iOSExclaveKit = Self(rawValue: 18)
        public static let tvOSExclaveCore = Self(rawValue: 19)
        public static let tvOSExclaveKit = Self(rawValue: 20)
        public static let watchOSExclaveCore = Self(rawValue: 21)
        public static let watchOSExclaveKit = Self(rawValue: 22)
        public static let visionOSExclaveCore = Self(rawValue: 23)
        public static let visionOSExclaveKit = Self(rawValue: 24)
        public static let any = Self(rawValue: -1)

        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public var name: String {
            switch self {
            case .unknown: "Unknown"
            case .macOS: "macOS"
            case .iOS: "iOS"
            case .tvOS: "tvOS"
            case .watchOS: "watchOS"
            case .bridgeOS: "bridgeOS"
            case .macCatalyst: "Mac Catalyst"
            case .iOSSimulator: "iOS Simulator"
            case .tvOSSimulator: "tvOS Simulator"
            case .watchOSSimulator: "watchOS Simulator"
            case .driverKit: "DriverKit"
            case .visionOS: "visionOS"
            case .visionOSSimulator: "visionOS Simulator"
            case .firmware: "Firmware"
            case .sepOS: "sepOS"
            case .macOSExclaveCore: "macOS ExclaveCore"
            case .macOSExclaveKit: "macOS ExclaveKit"
            case .iOSExclaveCore: "iOS ExclaveCore"
            case .iOSExclaveKit: "iOS ExclaveKit"
            case .tvOSExclaveCore: "tvOS ExclaveCore"
            case .tvOSExclaveKit: "tvOS ExclaveKit"
            case .watchOSExclaveCore: "watchOS ExclaveCore"
            case .watchOSExclaveKit: "watchOS ExclaveKit"
            case .visionOSExclaveCore: "visionOS ExclaveCore"
            case .visionOSExclaveKit: "visionOS ExclaveKit"
            case .any: "Any"
            default: "Unknown"
            }
        }

        public static func executableRuntimePlatforms(for executableURL: URL) -> [Self] {
            guard let data = try? Data(contentsOf: executableURL, options: .mappedIfSafe) else {
                return []
            }
            return executableRuntimePlatforms(in: data)
        }

        public static func processRuntimePlatform(for processIdentifier: Int32) -> Self? {
            guard let processInformationFunction = self.processInformationFunction else {
                return nil
            }
            var rawPlatform: UInt32 = 0
            let expectedSize = MemoryLayout<UInt32>.size
            guard processInformationFunction(
                processIdentifier,
                self.processPlatformInformationFlavor,
                0,
                &rawPlatform,
                Int32(expectedSize)
            ) == expectedSize,
                  rawPlatform != 0 else {
                return nil
            }
            return Self(rawValue: Int32(bitPattern: rawPlatform))
        }

        fileprivate static var linkerRuntimePlatform: Self? {
            guard let rawPlatform = self.linkerRuntimePlatformFunction?(), rawPlatform != 0 else {
                return nil
            }
            return Self(rawValue: Int32(bitPattern: rawPlatform))
        }

        fileprivate static func executableRuntimePlatforms(in data: Data) -> [Self] {
            let platforms: [Self]
            switch data.uint32(at: 0, endianness: .big) {
            case 0xCAFEBABE:
                platforms = fatExecutableRuntimePlatforms(in: data, endianness: .big, is64Bit: false)
            case 0xBEBAFECA:
                platforms = fatExecutableRuntimePlatforms(in: data, endianness: .little, is64Bit: false)
            case 0xCAFEBABF:
                platforms = fatExecutableRuntimePlatforms(in: data, endianness: .big, is64Bit: true)
            case 0xBFBAFECA:
                platforms = fatExecutableRuntimePlatforms(in: data, endianness: .little, is64Bit: true)
            default:
                platforms = thinExecutableRuntimePlatforms(in: data, offset: 0, size: data.count)
            }
            return Array(Set(platforms)).sorted { $0.rawValue < $1.rawValue }
        }

        private static func fatExecutableRuntimePlatforms(
            in data: Data,
            endianness: Endianness,
            is64Bit: Bool
        ) -> [Self] {
            guard let architectureCount = data.uint32(at: 4, endianness: endianness) else {
                return []
            }
            let architectureSize = is64Bit ? 32 : 20
            guard data.count >= 8,
                  Int(architectureCount) <= (data.count - 8) / architectureSize else {
                return []
            }
            return (0..<Int(architectureCount)).flatMap { architectureIndex -> [Self] in
                let architectureOffset = 8 + architectureIndex * architectureSize
                let sliceOffset: UInt64?
                let sliceSize: UInt64?
                if is64Bit {
                    sliceOffset = data.uint64(at: architectureOffset + 8, endianness: endianness)
                    sliceSize = data.uint64(at: architectureOffset + 16, endianness: endianness)
                }
                else {
                    sliceOffset = data.uint32(at: architectureOffset + 8, endianness: endianness).map(UInt64.init)
                    sliceSize = data.uint32(at: architectureOffset + 12, endianness: endianness).map(UInt64.init)
                }
                guard let sliceOffset,
                      let sliceSize,
                      sliceOffset <= UInt64(Int.max),
                      sliceSize <= UInt64(Int.max),
                      sliceOffset <= UInt64(data.count),
                      sliceSize <= UInt64(data.count) - sliceOffset else {
                    return []
                }
                return thinExecutableRuntimePlatforms(in: data, offset: Int(sliceOffset), size: Int(sliceSize))
            }
        }

        private static func thinExecutableRuntimePlatforms(in data: Data, offset: Int, size: Int) -> [Self] {
            let endianness: Endianness
            let headerSize: Int
            switch data.uint32(at: offset, endianness: .big) {
            case 0xFEEDFACE:
                endianness = .big
                headerSize = machHeaderSize
            case 0xCEFAEDFE:
                endianness = .little
                headerSize = machHeaderSize
            case 0xFEEDFACF:
                endianness = .big
                headerSize = machHeader64Size
            case 0xCFFAEDFE:
                endianness = .little
                headerSize = machHeader64Size
            default:
                return []
            }
            guard size >= headerSize,
                  offset >= 0,
                  offset <= data.count - size,
                  let commandCount = data.uint32(at: offset + 16, endianness: endianness),
                  let commandsSize = data.uint32(at: offset + 20, endianness: endianness),
                  Int(commandsSize) <= size - headerSize,
                  Int(commandCount) <= Int(commandsSize) / 8 else {
                return []
            }

            var platforms: [Self] = []
            var commandOffset = offset + headerSize
            let commandsEnd = commandOffset + Int(commandsSize)
            for _ in 0..<commandCount {
                guard let command = data.uint32(at: commandOffset, endianness: endianness),
                      let commandSize = data.uint32(at: commandOffset + 4, endianness: endianness),
                      commandSize >= 8,
                      commandOffset <= commandsEnd - Int(commandSize) else {
                    return platforms
                }
                if command == buildVersionCommand,
                   let rawPlatform = data.uint32(at: commandOffset + 8, endianness: endianness) {
                    platforms.append(Self(rawValue: Int32(bitPattern: rawPlatform)))
                }
                else if let platform = legacyPlatform(for: command) {
                    platforms.append(platform)
                }
                commandOffset += Int(commandSize)
            }
            return platforms
        }

        private static func legacyPlatform(for command: UInt32) -> Self? {
            switch command {
            case versionMinimumMacOSCommand: .macOS
            case versionMinimumIOSCommand: .iOS
            case versionMinimumTVOSCommand: .tvOS
            case versionMinimumWatchOSCommand: .watchOS
            default: nil
            }
        }

        private static func resolve<Function>(_ symbolName: String) -> Function? {
            guard let dynamicLibraryHandle, let symbol = dlsym(dynamicLibraryHandle, symbolName) else {
                return nil
            }
            return unsafeBitCast(symbol, to: Function.self)
        }
    }

    public var processRuntimePlatform: RuntimePlatform? {
        RuntimePlatform.processRuntimePlatform(for: self.processIdentifier)
    }

    public var linkerRuntimePlatform: RuntimePlatform? {
        RuntimePlatform.linkerRuntimePlatform
    }

    public var executableRuntimePlatforms: [RuntimePlatform] {
        guard let executableName = _dyld_get_image_name(0) else {
            return []
        }
        return RuntimePlatform.executableRuntimePlatforms(
            for: URL(fileURLWithPath: String(cString: executableName))
        )
    }
}

private extension Data {
    func uint32(
        at offset: Int,
        endianness: ProcessInfo.RuntimePlatform.Endianness
    ) -> UInt32? {
        integer(at: offset, endianness: endianness)
    }

    func uint64(
        at offset: Int,
        endianness: ProcessInfo.RuntimePlatform.Endianness
    ) -> UInt64? {
        integer(at: offset, endianness: endianness)
    }

    func integer<Integer: FixedWidthInteger>(
        at offset: Int,
        endianness: ProcessInfo.RuntimePlatform.Endianness
    ) -> Integer? {
        guard offset >= 0, offset <= count - MemoryLayout<Integer>.size else {
            return nil
        }
        var value: Integer = 0
        _ = Swift.withUnsafeMutableBytes(of: &value) { destination in
            copyBytes(to: destination, from: offset..<(offset + MemoryLayout<Integer>.size))
        }
        return switch endianness {
        case .big: Integer(bigEndian: value)
        case .little: Integer(littleEndian: value)
        }
    }
}
#endif
