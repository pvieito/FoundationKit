//
//  Bundle.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/08/2018.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

private let kCFBundleNameKey = "CFBundleName"
private let kCFBundleDisplayNameKey = "CFBundleDisplayName"
private let kCFBundleVersionKey = "CFBundleVersion"
private let kCFBundleShortVersionStringKey = "CFBundleShortVersionString"
private let kNSPrincipalClassKey = "NSPrincipalClass"

extension Bundle {
    private var bundleDisplayName: String? {
        return self.object(forInfoDictionaryKey: kCFBundleDisplayNameKey) as? String
    }
    
    private var bundleBaseName: String? {
        return self.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
    }
    
    private var executableName: String? {
        return self.executableURL?.deletingPathExtension().lastPathComponent
    }
    
    public var bundleName: String {
        return self.bundleDisplayName ??
            self.bundleBaseName ??
            self.executableName ??
            self.bundleURL.deletingPathExtension().lastPathComponent
    }
    
    public var bundleVersion: String? {
        guard let bundleVersion = self.object(forInfoDictionaryKey: kCFBundleVersionKey) as? String,
            bundleVersion != "" else {
            return nil
        }
        
        return bundleVersion
    }
    
    public var bundleShortVersion: String? {
        guard let bundleShortVersion = self.object(forInfoDictionaryKey: kCFBundleShortVersionStringKey) as? String,
            bundleShortVersion != "" else {
            return nil
        }
        
        return bundleShortVersion
    }
    
    public var principalClassString: String? {
        guard let principalClassString = self.object(forInfoDictionaryKey: kNSPrincipalClassKey) as? String,
            principalClassString != "" else {
            return nil
        }
        
        return principalClassString
    }
}

extension Bundle {
    public static func currentSourceFileDirectoryBundle(file: String = #file) -> Bundle {
        let codeFileURL = URL(fileURLWithPath: file)
        let bundleURL = codeFileURL.deletingLastPathComponent()
        return Bundle(url: bundleURL)!
    }
}
