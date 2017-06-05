//
//  FileManager.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension FileManager {

    /// URL to the library of Ubiquity Containers for the user.
    public var ubiquityContainersLibrary: URL? {

        guard let libraryURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        let ubiquityContainersLibrary = libraryURL.appendingPathComponent("Mobile Documents")

        guard FileManager.default.fileExists(atPath: ubiquityContainersLibrary.path) else {
            return nil
        }

        return ubiquityContainersLibrary
    }

    /// List of available Ubiquity Containers.
    public var availableUbiquityContainers: [URL] {

        guard let ubiquityContainersLibrary = self.ubiquityContainersLibrary else {
            return []
        }

        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: ubiquityContainersLibrary.path) else {
            return []
        }

        var availableUbiquityContainers: [URL] = []

        for item in contents {
            let itemURL = ubiquityContainersLibrary.appendingPathComponent(item)
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDirectory)

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

        guard FileManager.default.fileExists(atPath: containerURL.path) else {
            return nil
        }

        return containerURL
    }

    /// Real URL to the user home directory, even in a Sanboxed environment.
    public var unsandboxedHomeDirectory: URL? {
        guard let userPath = getpwuid(getuid())?.pointee.pw_dir else {
            return nil
        }

        let homeDirectory = URL(fileURLWithPath: String(cString: userPath))

        guard FileManager.default.fileExists(atPath: homeDirectory.path) else {
            return nil
        }

        return homeDirectory
    }
}
