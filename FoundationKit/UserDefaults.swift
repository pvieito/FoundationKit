//
//  UserDefaults.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 26/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(CloudKit)
import CloudKit
#endif

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
        
        let containerSuiteURL = libraryURL.appendingPathComponent("Containers")
            .appendingPathComponents(containerIdentifier, "Data", "Library", "Preferences", containerIdentifier)
            .appendingPathExtension("plist")
        guard FileManager.default.fileExists(atPath: containerSuiteURL.path) else {
            return nil
        }
        self.init(suiteName: containerSuiteURL.path)
    }
}

#if canImport(CloudKit)
extension UserDefaults {
    static let cloudKitDomain = "com.pvieito.FoundationKit.UserDefaults.CloudKitDomain"
    public static let cloudKit = UserDefaults(suiteName: cloudKitDomain)!
}
#endif

#if canImport(Darwin)
@available(watchOS 9.0, *)
extension UserDefaults {
    static let ubiquitousKeyValueStoreDomain = "com.pvieito.FoundationKit.UserDefaults.UbiquitousKeyValueStoreDomain"
    public static let ubiquitousKeyValueStore = UserDefaults(suiteName: ubiquitousKeyValueStoreDomain)!
    
    @available(*, deprecated, renamed: "ubiquitousKeyValueStore")
    public static let ubiquitousKeyValueStorage = ubiquitousKeyValueStore
}
#endif

extension UserDefaults {
    @propertyWrapper
    public struct Wrapper<Value> {
        let key: String
        let storage: UserDefaults
        let defaultValue: Value
        
#if canImport(CloudKit)
        var cloudContainerIdentifier: String? {
            return Bundle.main.foundationKitInfoDictionaryObject(keySuffix: "UserDefaultsCloudContainerIdentifier") as? String
        }
        
        var cloudContainer: CKContainer {
            if let cloudContainerIdentifier = self.cloudContainerIdentifier {
                return CKContainer(identifier: cloudContainerIdentifier)
            }
            else {
                return .default()
            }
        }
        
        var cloudRecordType: CKRecord.RecordType {
            return UserDefaults.cloudKitDomain.replacingOccurrences(of: ".", with: "_")
        }
        
        var cloudRecordIdentifier: CKRecord.ID {
            return CKRecord.ID(recordName: UserDefaults.cloudKitDomain)
        }
        
        var cloudRecord: CKRecord {
            get throws {
                do {
                    return try DispatchSemaphore.returningWait { handler in
                        self.cloudContainer.privateCloudDatabase.fetch(withRecordID: self.cloudRecordIdentifier, completionHandler: handler)
                    }
                }
                catch CKError.unknownItem {
                    return CKRecord(recordType: self.cloudRecordType, recordID: self.cloudRecordIdentifier)
                }
            }
        }
#endif
        
        public init(key: String, storage: UserDefaults = .standard, defaultValue: Value) {
            self.key = key
            self.storage = storage
            self.defaultValue = defaultValue
        }
        
        public var wrappedValue: Value {
            get {
                var value: Any?
                var handled = false
                
#if canImport(CloudKit)
                if !handled, self.storage == .cloudKit {
                    handled = true
                    value = try? self.cloudRecord.object(forKey: self.key)
                }
#endif
                
#if canImport(Darwin)
                if #available(watchOS 9.0, *), !handled, self.storage == .ubiquitousKeyValueStore {
                    handled = true
                    let storage = NSUbiquitousKeyValueStore.default
                    if storage.object(forKey: self.key) == nil {
                        value = nil
                    }
                    else if Value.self == Bool.self {
                        value = storage.bool(forKey: self.key)
                    }
                    else if Value.self == Int.self {
                        value = storage.longLong(forKey: self.key)
                    }
                    else if Value.self == Double.self || Value.self == Float.self {
                        value = storage.double(forKey: self.key)
                    }
                    else if Value.self == Data.self {
                        value = storage.data(forKey: self.key)
                    }
                    else if Value.self == Array<Any?>.self {
                        value = storage.array(forKey: self.key)
                    }
                    else if Value.self == Dictionary<AnyHashable, Any?>.self {
                        value = storage.dictionary(forKey: self.key)
                    }
                    else {
                        value = storage.object(forKey: self.key)
                    }
                }
#endif
                
                if !handled {
                    handled = true
                    if storage.object(forKey: self.key) == nil {
                        value = nil
                    }
                    else if Value.self == Bool.self {
                        value = storage.bool(forKey: self.key)
                    }
                    else if Value.self == Int.self {
                        value = storage.integer(forKey: self.key)
                    }
                    else if Value.self == Double.self {
                        value = storage.double(forKey: self.key)
                    }
                    else if Value.self == Float.self {
                        value = storage.float(forKey: self.key)
                    }
                    else if Value.self == Data.self {
                        value = storage.data(forKey: self.key)
                    }
                    else if Value.self == Array<Any?>.self {
                        value = storage.array(forKey: self.key)
                    }
                    else if Value.self == Dictionary<AnyHashable, Any?>.self {
                        value = storage.dictionary(forKey: self.key)
                    }
                    else {
                        value = storage.object(forKey: self.key)
                    }
                }
                
                return value as? Value ?? self.defaultValue
            }
            set {
                var handled = false
                
#if canImport(CloudKit)
                if !handled, self.storage == .cloudKit {
                    handled = true
                    guard let cloudRecord = try? self.cloudRecord else { return }
                    cloudRecord.setValue(newValue, forKey: self.key)
                    let _ = try? DispatchSemaphore.returningWait { handler in
                        self.cloudContainer.privateCloudDatabase.save(cloudRecord, completionHandler: handler)
                    }
                }
#endif
                
#if canImport(Darwin)
                if #available(watchOS 9.0, *), !handled, self.storage == .ubiquitousKeyValueStore {
                    handled = true
                    let storage = NSUbiquitousKeyValueStore.default
                    storage.set(newValue, forKey: self.key)
                    storage.synchronize()
                }
#endif

                
                if !handled {
                    handled = true
                    storage.set(newValue, forKey: self.key)
                    storage.synchronize()
                }
            }
        }
    }
}
