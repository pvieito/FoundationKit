//
//  FileManager.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

extension FileManager {
    /// Returns a Boolean value that indicates whether a file or directory exists at a specified URL.
    public func fileExists(at url: URL) -> Bool {
        return self.fileExists(atPath: url.path)
    }
    
    /// Returns a Boolean value that indicates whether a directory exists at a specified URL.
    public func directoryExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return self.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    /// Returns a Boolean value that indicates whether a file exists at a specified URL.
    public func nonDirectoryFileExists(at url: URL) -> Bool {
        return self.fileExists(at: url) && !self.directoryExists(at: url)
    }
    
    /// Returns a Boolean value that indicates whether the operating system appears able to execute a specified file.
    public func isExecutableFile(at url: URL) -> Bool {
        return self.isExecutableFile(atPath: url.path)
    }
    
    /// Returns the current directory URL.
    public var currentDirectoryURL: URL {
        return URL(fileURLWithPath: self.currentDirectoryPath)
    }
    
    /// Replaces a symbolic link at the specified URL that points to an item at the given URL.
    public func replaceSymbolicLink(
        at url: URL, withDestinationURL destinationURL: URL) throws {
            try? self.removeItem(at: url)
            try self.createSymbolicLink(
                at: url, withDestinationURL: destinationURL)
        }
    
    /// Replaces a symbolic link at the specified path that points to an item at the given destination path.
    public func replaceSymbolicLink(
        atPath path: String, withDestinationPath destinationPath: String) throws {
            try? self.removeItem(atPath: path)
            try self.createSymbolicLink(atPath: path, withDestinationPath: destinationPath)
        }
    
    /// Generates a random file URL on a temporary location.
    public func temporaryRandomFileURL(filename: String? = nil, pathExtension: String? = nil) -> URL {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
        try? self.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        
        let filename = filename ?? UUID().uuidString
        var temporaryFileURL = temporaryDirectory.appendingPathComponent(filename)
        
        if let pathExtension = pathExtension {
            temporaryFileURL.appendPathExtension(pathExtension)
        }
        
        return temporaryFileURL
    }
    
#if canImport(UniformTypeIdentifiers)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func temporaryRandomFileURL(filename: String? = nil, for contentType: UTType) -> URL {
        return self.temporaryRandomFileURL(filename: filename).appendingPathExtension(for: contentType)
    }
#endif
    
    /// Real URL to the user home directory, even in a sandboxed environment.
    public var realHomeDirectoryForCurrentUser: URL {
        var homeDirectoryForCurrentUser = URL(fileURLWithPath: NSHomeDirectory())
#if os(macOS) || targetEnvironment(macCatalyst)
        if let userPath = getpwuid(getuid())?.pointee.pw_dir {
            homeDirectoryForCurrentUser = URL(fileURLWithPath: String(cString: userPath))
        }
#endif
        return homeDirectoryForCurrentUser
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
            let fileManager = FileManager.default
            let processName = Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName
            
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(directoryName)
                .appendingPathComponent(processName)
            
            if !isCleaned && fileManager.fileExists(atPath: temporaryDirectoryURL.path) {
                try? fileManager.removeItem(at: temporaryDirectoryURL)
            }
            
            isCleaned = true
            
            try? fileManager.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            return temporaryDirectoryURL
        }
    }
}

#if os(macOS) || targetEnvironment(macCatalyst)
extension FileManager {
    /// Returns the Library directory for the current user.
    public var libraryDirectoryForCurrentUser: URL? {
        guard let libraryDirectory = try? self.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        return libraryDirectory
    }
}

extension FileManager {
    /// URL to the library of Ubiquity Containers for the user.
    private var ubiquityContainersLibrary: URL? {
        let ubiquityContainersLibrary = self.realHomeDirectoryForCurrentUser.appendingPathComponents("Library", "Mobile Documents")
        guard self.fileExists(atPath: ubiquityContainersLibrary.path) else {
            return nil
        }
        return ubiquityContainersLibrary
    }
    
    /// List of available Ubiquity Containers.
    private var availableUbiquityContainers: [URL] {
        guard let ubiquityContainersLibrary = self.ubiquityContainersLibrary,
              let contents = try? self.contentsOfDirectory(atPath: ubiquityContainersLibrary.path) else {
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
    /// - Note: Not available in a sandboxed environment.
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
}

extension FileManager {
    private static let systemManagedContainerMetadataPlistName = ".com.apple.containermanagerd.metadata.plist"
    private static let systemManagedContainerMetadataIdentifierKey = "MCMMetadataIdentifier"
    
    private var systemManagedContainersLibrary: URL? {
        let containersLibrary = self.realHomeDirectoryForCurrentUser.appendingPathComponents("Library", "Containers")
        guard self.fileExists(atPath: containersLibrary.path) else {
            return nil
        }
        return containersLibrary
    }
    
    public func systemManagedContainers(forBundleIdentifier identifier: String) throws -> [URL] {
        guard let systemManagedContainersLibrary else { return [] }
        var containers: [URL] = []
        for container in try self.contentsOfDirectory(atPath: systemManagedContainersLibrary.path) {
            let container = systemManagedContainersLibrary.appendingPathComponents(container)
            let containerMetadataPlistURL = container.appendingPathComponents(Self.systemManagedContainerMetadataPlistName)
            guard FileManager.default.nonDirectoryFileExists(at: containerMetadataPlistURL) else { continue }
            let containerPlist = try NSDictionary(contentsOf: containerMetadataPlistURL, error: ())
            if let metadataIdentifier = containerPlist[Self.systemManagedContainerMetadataIdentifierKey] as? String {
                if metadataIdentifier == identifier {
                    containers += [container]
                }
            }
        }
        return containers
    }
}
#endif
