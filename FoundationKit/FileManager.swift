//
//  FileManager.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension FileManager {

    /// Returns the predicted ubiquity container of the specified identifier.
    ///
    /// - Note: The returned container will be invalid in a Sanboxed environment.
    ///
    /// - Parameter identifier: Identifier of the ubiquity container.
    /// - Returns: Predicted container URL.
    @available(macOSApplicationExtension 10.9, *)
    public func predictedURL(forUbiquityContainerIdentifier identifier: String) -> URL? {

        guard let libraryURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        let containerName = identifier.replacingOccurrences(of: ".", with: "~")
        return libraryURL.appendingPathComponent("Mobile Documents").appendingPathComponent(containerName)
    }

    /// Real URL to the user home directory, even in a Sanboxed environment.
    @available(macOSApplicationExtension 10.9, *)
    public var unsandboxedHomeDirectory: URL? {
        guard let userPath = getpwuid(getuid()).pointee.pw_dir else {
            return nil
        }

        return URL(fileURLWithPath: String(cString: userPath))
    }
}
