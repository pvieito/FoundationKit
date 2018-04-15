//
//  FileManager.TemporaryDirectory.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 15/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension FileManager {
    
    /// Returns the temporary directory for the current user.
    ///
    /// This directory will be cleaned in the next execution of the same process or when the general temporary directory is cleaned.
    public var autocleanedTemporaryDirectory: URL {
        return AutocleanedTemporaryDirectory.autocleanedTemporaryDirectory
    }
    
    private class AutocleanedTemporaryDirectory {
        
        private static var directoryName = "AutocleanedTemporaryDirectory"
        private static var isCleaned = false
        
        static var autocleanedTemporaryDirectory: URL {
            
            let processName = Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName
            
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(directoryName)
                .appendingPathComponent(processName)
            
            if !isCleaned && FileManager.default.fileExists(atPath: temporaryDirectoryURL.path) {
                try? FileManager.default.removeItem(at: temporaryDirectoryURL)
            }
            
            isCleaned = true
            
            try? FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)

            return temporaryDirectoryURL
        }
    }
}
