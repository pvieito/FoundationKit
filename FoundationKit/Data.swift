//
//  Data.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 20/10/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension Data {
    public var bytes: Array<UInt8> {
        return Array<UInt8>(self)
    }
}

extension Data {
    public func writeTemporaryFile(
        filename: String? = nil, pathExtension: String? = nil,
        options: Data.WritingOptions = []) throws -> URL {
        let temporaryFileURL = FileManager.default.temporaryRandomFileURL(
            filename: filename, pathExtension: pathExtension)
        try self.write(to: temporaryFileURL, options: options)
        return temporaryFileURL
    }
}

extension Data {
    public func readingPipe() -> Pipe {
        let pipe = Pipe()
        pipe.fileHandleForWriting.write(self)
        return pipe
    }
}

extension Data {
    @available(*, deprecated, renamed: "Data.random(count:)")
    public init(randomBytesCount count: Int) {
        self = Data.random(count: count)
    }
    
    /// Returns a Data struct with the specified number of random bytes.
    ///
    /// - Parameter count: Number of random bytes.
    public static func random(count: Int) -> Data {
        let bytes = [UInt8](repeating: 0, count: count).map { _ -> UInt8 in
            return UInt8.random(in: .min ... .max)
        }
        return Data(bytes)
    }
}

@available(watchOS 6.0, *)
@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(macOS 10.15, *)
extension Data {
    public var informationStorageMeasurement: Measurement<UnitInformationStorage> {
        return Measurement(value: Double(self.count), unit: UnitInformationStorage.bytes)
    }
    
    public var informationStorageMeasurementString: String {
        return ByteCountFormatter.string(from: self.informationStorageMeasurement, countStyle: .file)
    }
}
