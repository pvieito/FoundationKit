//
//  FileManager.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension FileManager {

    #if os(macOS)
    /// Returns the predicted ubiquity container of the specified identifier.
    ///
    /// - Note: The returned container will be invalid in a Sanboxed environment.
    ///
    /// - Parameter identifier: Identifier of the ubiquity container.
    /// - Returns: Predicted container URL.
    public func predictedURL(forUbiquityContainerIdentifier identifier: String) -> URL? {

        guard let libraryURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        let containerName = identifier.replacingOccurrences(of: ".", with: "~")
        return libraryURL.appendingPathComponent("Mobile Documents").appendingPathComponent(containerName)
    }
    #endif
}
