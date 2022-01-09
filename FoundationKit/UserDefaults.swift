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
    /// - Note: Not available in a sandboxed environment.
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
                var value: Any?
                if storage.object(forKey: key) == nil {
                    value = nil
                }
                else if Value.self == Bool.self {
                    value = storage.bool(forKey: key)
                }
                else if Value.self == Int.self {
                    value = storage.integer(forKey: key)
                }
                else if Value.self == Double.self {
                    value = storage.double(forKey: key)
                }
                else if Value.self == Float.self {
                    value = storage.float(forKey: key)
                }
                else if Value.self == Data.self {
                    value = storage.data(forKey: key)
                }
                else if Value.self == Array<Any?>.self {
                    value = storage.array(forKey: key)
                }
                else if Value.self == Dictionary<AnyHashable, Any?>.self {
                    value = storage.dictionary(forKey: key)
                }
                else {
                    value = storage.object(forKey: key)
                }
                return value as? Value ?? self.defaultValue
            }
            set {
                storage.set(newValue, forKey: key)
                storage.synchronize()
            }
        }
    }
}
