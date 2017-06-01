//
//  UserDefault.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension UserDefaults {

    /// Return the User Defaults of a Sandboxed app with the specified container identifier.
    ///
    /// - Note: Not available in a Sanboxed environment.
    @available(iOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public convenience init?(containerIdentifier: String) {

        guard let libraryURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }

        let suitePreferences = libraryURL.appendingPathComponent("Containers").appendingPathComponent(containerIdentifier).appendingPathComponent("Data/Library/Preferences").appendingPathComponent(containerIdentifier).appendingPathExtension("plist")

        guard FileManager.default.fileExists(atPath: suitePreferences.path) else {
            return nil
        }

        self.init(suiteName: suitePreferences.path)
    }
}
