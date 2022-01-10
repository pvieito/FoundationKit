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
    static let cloudDomain = "com.pvieito.FoundationKit.CloudUserDefaults"
    public static let cloud = UserDefaults(suiteName: cloudDomain)!
    
    @propertyWrapper
    public struct Wrapper<Value> {
        let key: String
        let storage: UserDefaults
        let defaultValue: Value
        
        var isCloudStorage: Bool {
            return self.storage == .cloud
        }
        
        #if canImport(CloudKit)
        var cloudContainerIdentifier: String? {
            return Bundle.main.object(forInfoDictionaryKey: "NSXUserDefaultsCloudContainerIdentifier") as? String
        }
        
        var cloudContainer: CKContainer {
            if let cloudContainerIdentifier = self.cloudContainerIdentifier {
                return CKContainer(identifier: cloudContainerIdentifier)
            }
            else {
                return .default()
            }
        }
        
        var cloudRecordIdentifier: CKRecord.ID {
            return CKRecord.ID(recordName: UserDefaults.cloudDomain)
        }
        
        var cloudRecord: CKRecord {
            get throws {
                do {
                    return try DispatchSemaphore.returningWait { handler in
                        self.cloudContainer.privateCloudDatabase.fetch(withRecordID: self.cloudRecordIdentifier, completionHandler: handler)
                    }
                }
                catch CKError.unknownItem {
                    return CKRecord(recordType: self.cloudRecordIdentifier.recordName, recordID: self.cloudRecordIdentifier)
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
                
                if self.isCloudStorage {
                    #if canImport(CloudKit)
                    value = try? self.cloudRecord.object(forKey: self.key)
                    #endif
                }
                else {
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
                if self.isCloudStorage {
                    #if canImport(CloudKit)
                    if let cloudRecord = try? self.cloudRecord {
                        cloudRecord.setValue(newValue, forKey: self.key)
                        let _ = try? DispatchSemaphore.returningWait { handler in
                            self.cloudContainer.privateCloudDatabase.save(cloudRecord, completionHandler: handler)
                        }
                    }
                    #endif
                }
                else {
                    storage.set(newValue, forKey: self.key)
                    storage.synchronize()
                }
            }
        }
    }
}
