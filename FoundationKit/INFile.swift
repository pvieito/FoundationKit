//
//  INFile.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/04/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(Intents) && !os(tvOS)
import Foundation
import Intents

@available(iOS 13.0, *)
@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension INFile {
    public func temporaryFile() throws -> URL {
        return try self.data.writeTemporaryFile(filename: self.filename)
    }
    
    private static let intentsServiceExtensionFileSizeLimitInBytes = 5_000_000
    public func enforcingIntentsServiceExtensionMemoryLimitRestrictions() throws -> INFile {
        guard !(INExtension.isProcessRunningAsIntentsServiceExtension &&
            self.data.count >= Self.intentsServiceExtensionFileSizeLimitInBytes) else {
                throw NSError(description: "Error processing input file “\(self.filename)” as its size (\(self.data.informationStorageMeasurementString)) is bigger than the limit imposed by the system while running as an App Extension. You should resize the input file or process it using the main application.")
        }
        
        return self
    }
}

@available(iOS 13.0, *)
@available(macOS 11.0, *)
@available(watchOS 6.0, *)
extension Collection where Element: INFile {
    public func temporaryFiles() throws -> [URL] {
        return try self.map { try $0.temporaryFile() }
    }
    
    public func enforcingIntentsServiceExtensionMemoryLimitRestrictions(limitInBytes: Int? = nil) throws -> [INFile] {
        try self.map { try $0.enforcingIntentsServiceExtensionMemoryLimitRestrictions() }
    }
}
#endif
