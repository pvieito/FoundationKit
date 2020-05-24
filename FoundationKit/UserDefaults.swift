//
//  UserDefaults.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

extension UserDefaults {
    /// Return the User Defaults of a sandboxed app with the specified container identifier.
    ///
    /// - Note: Not available in a sanboxed environment.
    @available(iOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public convenience init?(containerIdentifier: String) {
        guard let libraryURL = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        let suitePreferences = libraryURL.appendingPathComponent("Containers")
            .appendingPathComponents(containerIdentifier, "Data", "Library", "Preferences", containerIdentifier)
            .appendingPathExtension("plist")
        guard FileManager.default.fileExists(atPath: suitePreferences.path) else {
            return nil
        }
        self.init(suiteName: suitePreferences.path)
    }
}

extension UserDefaults {
    @propertyWrapper
    public struct Wrapper<Value> {
        let key: String
        let storage: UserDefaults
        let defaultValue: Value
        
        public init(key: String, storage: UserDefaults = .standard, defaultValue: Value) {
            self.key = key
            self.storage = storage
            self.defaultValue = defaultValue
        }
        
        public var wrappedValue: Value {
            get {
                return storage.value(forKey: key) as? Value ?? self.defaultValue
            }
            set {
                storage.setValue(newValue, forKey: key)
                storage.synchronize()
            }
        }
    }
}
