//
//  UserDefault.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension UserDefaults {

    #if os(macOS)
    /// Return the User Defaults of a Sandboxed app with the specified container identifier.
    ///
    /// - Note: The returned User Defaults will be invalid in a Sanboxed environment.
    public convenience init?(containerIdentifier: String) {

        guard let libraryURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        let suiteName = libraryURL.appendingPathComponent("Containers").appendingPathComponent(containerIdentifier).appendingPathComponent("Data/Library/Preferences").appendingPathComponent(containerIdentifier).path
        self.init(suiteName: suiteName)
    }
    #endif
}
