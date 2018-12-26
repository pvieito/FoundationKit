//
//  FileManager.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension FileManager {
    /// Returns a Boolean value that indicates whether a file or directory exists at a specified URL.
    public func fileExists(at url: URL) -> Bool {
        return self.fileExists(atPath: url.path)
    }
    
    /// Returns a Boolean value that indicates whether a directory exists at a specified URL.
    public func directoryExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        self.fileExists(atPath: url.path, isDirectory: &isDirectory)
        
        return isDirectory.boolValue
    }
    
    /// Returns the current directory URL.
    public var currentDirectoryURL: URL {
        return URL(fileURLWithPath: self.currentDirectoryPath)
    }
}

extension FileManager {
    /// Returns the temporary directory for the current user.
    ///
    /// This directory will be cleaned in the next execution of the same process or when the general temporary directory is cleaned.
    public var autocleanedTemporaryDirectory: URL {
        return AutocleanedTemporaryDirectory.autocleanedTemporaryDirectory
    }
    
    private struct AutocleanedTemporaryDirectory {
        
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

#if os(macOS)
extension FileManager {
    /// URL to the library of Ubiquity Containers for the user.
    public var ubiquityContainersLibrary: URL? {
        guard let libraryURL = try? self.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        let ubiquityContainersLibrary = libraryURL.appendingPathComponent("Mobile Documents")

        guard self.fileExists(atPath: ubiquityContainersLibrary.path) else {
            return nil
        }

        return ubiquityContainersLibrary
    }

    /// List of available Ubiquity Containers.
    public var availableUbiquityContainers: [URL] {
        guard let ubiquityContainersLibrary = self.ubiquityContainersLibrary else {
            return []
        }

        guard let contents = try? self.contentsOfDirectory(atPath: ubiquityContainersLibrary.path) else {
            return []
        }

        var availableUbiquityContainers: [URL] = []

        for item in contents {
            let itemURL = ubiquityContainersLibrary.appendingPathComponent(item)
            var isDirectory: ObjCBool = false
            self.fileExists(atPath: itemURL.path, isDirectory: &isDirectory)

            if isDirectory.boolValue {
                availableUbiquityContainers.append(itemURL)
            }
        }
        
        return availableUbiquityContainers
    }

    /// List of identifiers of the available Ubiquity Containers.
    public var availableUbiquityContainersIdentifiers: [String] {
        return self.availableUbiquityContainers.map({ $0.lastPathComponent.replacingOccurrences(of: "~", with: ".") })
    }

    /// Returns the ubiquity container of an external app with the specified identifier.
    ///
    /// - Note: Not available in a Sanboxed environment.
    ///
    /// - Parameter identifier: Identifier of the ubiquity container.
    /// - Returns: Container URL.
    public func url(forExternalUbiquityContainerIdentifier identifier: String) -> URL? {
        guard let ubiquityContainersLibrary = self.ubiquityContainersLibrary else {
            return nil
        }

        let containerName = identifier.replacingOccurrences(of: ".", with: "~")
        let containerURL = ubiquityContainersLibrary.appendingPathComponent(containerName).resolvingSymlinksInPath()

        guard self.fileExists(atPath: containerURL.path) else {
            return nil
        }

        return containerURL
    }

    /// Real URL to the user home directory, even in a Sanboxed environment.
    public var realHomeDirectoryForCurrentUser: URL? {
        guard let userPath = getpwuid(getuid())?.pointee.pw_dir else {
            return nil
        }

        let homeDirectory = URL(fileURLWithPath: String(cString: userPath))

        guard self.fileExists(atPath: homeDirectory.path) else {
            return nil
        }

        return homeDirectory
    }
    
    /// Returns the Library directory for the current user.
    public var libraryDirectoryForCurrentUser: URL? {
        guard let libraryDirectory = try? self.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        return libraryDirectory
    }
}
#endif
