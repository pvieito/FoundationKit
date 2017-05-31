//
//  FileManager.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension FileManager {

    /// Returns the ubiquity container of an external app with the specified identifier.
    ///
    /// - Parameter identifier: Identifier of the ubiquity container.
    /// - Returns: Container URL.
    @available(macOSApplicationExtension 10.9, *)
    public func url(forExternalUbiquityContainerIdentifier identifier: String) -> URL? {

        guard let libraryURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        let containerName = identifier.replacingOccurrences(of: ".", with: "~")
        let containerURL = libraryURL.appendingPathComponent("Mobile Documents").appendingPathComponent(containerName)

        guard FileManager.default.fileExists(atPath: containerURL.path) else {
            return nil
        }

        return containerURL
    }

    /// Real URL to the user home directory, even in a Sanboxed environment.
    @available(macOSApplicationExtension 10.9, *)
    public var unsandboxedHomeDirectory: URL? {
        guard let userPath = getpwuid(getuid()).pointee.pw_dir else {
            return nil
        }

        let homeDirectory = URL(fileURLWithPath: String(cString: userPath))

        guard FileManager.default.fileExists(atPath: homeDirectory.path) else {
            return nil
        }

        return homeDirectory
    }
}
