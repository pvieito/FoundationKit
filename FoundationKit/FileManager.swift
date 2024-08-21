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
    public func replaceSymbolicLink(at url: URL, withDestinationURL destinationURL: URL) throws {
        try? self.removeItem(at: url)
        try self.createSymbolicLink(
            at: url, withDestinationURL: destinationURL)
    }
    
    /// Replaces a symbolic link at the specified path that points to an item at the given destination path.
    public func replaceSymbolicLink(atPath path: String, withDestinationPath destinationPath: String) throws {
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
    
    public func contentsOfDirectory(at directory: URL) throws -> [URL] {
        return try self.contentsOfDirectory(atPath: directory.path).map { directory.appendingPathComponents($0) }
    }
    
#if canImport(UniformTypeIdentifiers)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func temporaryRandomFileURL(filename: String? = nil, for contentType: UTType) -> URL {
        return self.temporaryRandomFileURL(filename: filename).appendingPathExtension(for: contentType)
    }
#endif
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

extension FileManager {
    private static let libraryName = "Library"
    
#if canImport(Darwin) && !os(macOS)
    public var homeDirectoryForCurrentUser: URL {
        return URL(fileURLWithPath: NSHomeDirectory())
    }
#endif
    
    /// Returns the Library directory for the current user.
    public var libraryDirectoryForCurrentUser: URL {
        let libraryDirectory = try? self.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return libraryDirectory ?? self.homeDirectoryForCurrentUser.appendingPathComponents(Self.libraryName)
    }
}

extension FileManager {
    /// Real URL to the user home directory, even in a sandboxed environment.
    @available(*, deprecated, renamed: "unsandboxedHomeDirectoryForCurrentUser")
    public var realHomeDirectoryForCurrentUser: URL {
        return self.unsandboxedHomeDirectoryForCurrentUser
    }
    
    public var unsandboxedHomeDirectoryForCurrentUser: URL {
        var homeDirectoryForCurrentUser: URL?
        if let userPath = getpwuid(getuid())?.pointee.pw_dir {
            homeDirectoryForCurrentUser = URL(fileURLWithPath: String(cString: userPath))
        }
        return homeDirectoryForCurrentUser ?? self.homeDirectoryForCurrentUser
    }
}

#if canImport(Cocoa)
extension FileManager {
    public var unsandboxedLibraryDirectoryForCurrentUser: URL {
        self.unsandboxedHomeDirectoryForCurrentUser.appendingPathComponents(Self.libraryName)
    }
}

extension FileManager {
    /// URL to the library of Ubiquity Containers for the user.
    private var ubiquityContainersLibrary: URL? {
        let ubiquityContainersLibrary = self.unsandboxedLibraryDirectoryForCurrentUser.appendingPathComponents("Mobile Documents")
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
    
    public struct SystemManagedContainer {
        public let identifier: String
        public let type: SystemManagedContainerType
        public let containerRoot: URL
    }
    
    public enum SystemManagedContainerType: String, CaseIterable {
        private static let containersName = "Containers"

        case `default`
        case `group`
        case `daemon`
        
        var containersLibraryDirectoryName: String {
            switch self {
            case .default:
                return Self.containersName
            case .daemon:
                return "Daemon \(Self.containersName)"
            case .group:
                return "Group \(Self.containersName)"
            }
        }
    }
    
    private func systemManagedContainersDirectory(type: SystemManagedContainerType) -> URL? {
        let containersLibrary = self.unsandboxedLibraryDirectoryForCurrentUser.appendingPathComponents(type.containersLibraryDirectoryName)
        guard self.fileExists(atPath: containersLibrary.path) else {
            return nil
        }
        return containersLibrary
    }
    
    public func systemManagedContainers(identifier: String? = nil, type: SystemManagedContainerType? = nil) throws -> [SystemManagedContainer] {
        let type = type ?? .default
        guard let containersLibrary = self.systemManagedContainersDirectory(type: type) else { return [] }
        var containers: [SystemManagedContainer] = []
        for containerRoot in try self.contentsOfDirectory(at: containersLibrary) {
            let containerMetadataPlistURL = containerRoot.appendingPathComponents(Self.systemManagedContainerMetadataPlistName)
            guard let containerPlist = NSDictionary(contentsOf: containerMetadataPlistURL) else { continue }
            if let metadataIdentifier = containerPlist[Self.systemManagedContainerMetadataIdentifierKey] as? String {
                if let identifier, metadataIdentifier != identifier {
                    continue
                }
                let container = SystemManagedContainer(identifier: metadataIdentifier, type: type, containerRoot: containerRoot)
                containers += [container]
            }
        }
        return containers
    }
    
    public func systemManagedContainer(identifier: String, type: SystemManagedContainerType? = nil) throws -> SystemManagedContainer? {
        return try self.systemManagedContainers(identifier: identifier, type: type).first
    }
}
#endif
