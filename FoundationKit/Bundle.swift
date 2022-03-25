//
//  Bundle.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/08/2018.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if os(macOS)
import Cocoa
#endif

private let kCFBundleNameKey = "CFBundleName"
private let kCFBundleDisplayNameKey = "CFBundleDisplayName"
private let kCFBundleVersionKey = "CFBundleVersion"
private let kCFBundleShortVersionStringKey = "CFBundleShortVersionString"
private let kNSPrincipalClassKey = "NSPrincipalClass"
private let kNSHumanReadableDescriptionKey = "NSHumanReadableDescription"
private let kNSHumanReadableCopyrightKey = "NSHumanReadableCopyright"

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
    
    public var bundleDisplayNameWithVersion: String {
        var bundleDisplayNameWithVersion = self.bundleName
        if let bundleShortVersion = self.bundleShortVersion {
            bundleDisplayNameWithVersion += " \(bundleShortVersion)"
        }
        if let bundleVersion = self.bundleVersion {
            bundleDisplayNameWithVersion += " (\(bundleVersion))"
        }
        return bundleDisplayNameWithVersion
    }
    
    public var humanReadableDescription: String? {
        return self.object(forInfoDictionaryKey: kNSHumanReadableDescriptionKey) as? String
    }
    
    public var humanReadableCopyright: String? {
        return self.object(forInfoDictionaryKey: kNSHumanReadableCopyrightKey) as? String
    }
}

extension Bundle: Comparable {
    private var bundleStableIdentifier: String {
        return self.bundleIdentifier ?? self.executableName ?? self.bundleName
    }
    
    public static func < (lhs: Bundle, rhs: Bundle) -> Bool {
        return lhs.bundleStableIdentifier < lhs.bundleStableIdentifier
    }
}

extension Bundle {
    private static let applicationPathExtension = "app"
    
    public var isApplication: Bool {
        return self.bundleURL.pathExtension == Self.applicationPathExtension
    }
    
    #if os(macOS)
    public var runningApplications: [NSRunningApplication] {
        guard self.isApplication, let bundleIdentifier = self.bundleIdentifier else { return [] }
        return NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
    }
    
    public var isApplicationRunning: Bool {
        return self.runningApplications.hasContent
    }
    
    @available(macOS 10.14, *)
    public func determineAutomationPermission(promptUser: Bool = false) -> Bool {
        guard self.isApplication else { return false }
        return ProcessInfo.processInfo.determineAutomationPermission(for: self.bundleStableIdentifier, promptUser: promptUser)
    }
    #endif
    
    private static let parentApplicationBundleMaximumLevels = 4
    private var parentApplicationBundleURL: URL? {
        var containingAppBundleURL = self.bundleURL
        var levels = 0
        while levels < Self.parentApplicationBundleMaximumLevels {
            containingAppBundleURL.deleteLastPathComponent()
            if containingAppBundleURL.pathExtension == Self.applicationPathExtension {
                return containingAppBundleURL
            }
            levels += 1
        }
        return nil
    }
    
    public var parentApplicationBundle: Bundle? {
        guard let containingAppBundleURL = self.parentApplicationBundleURL else { return nil }
        return Bundle(url: containingAppBundleURL)
    }
    
    public var parentApplicationBundles: [Bundle] {
        var containingAppBundles: [Bundle] = []
        var lastBundle = self
        while let containingAppBundle = lastBundle.parentApplicationBundle {
            containingAppBundles.append(containingAppBundle)
            lastBundle = containingAppBundle
        }
        return containingAppBundles
    }
}

extension Bundle {
    private static let plugInBundlePathExtension = "bundle"
    
    public var isPlugInBundle: Bool {
        return self.bundleURL.pathExtension == Self.plugInBundlePathExtension
    }
}

extension Bundle {
    private static let applicationExtensionPathExtension = "appex"
    
    public var isApplicationExtension: Bool {
        return self.bundleURL.pathExtension == Self.applicationExtensionPathExtension
    }
    
    public var applicationExtensionInfoDictionary: [String: Any?]? {
        return self.object(forInfoDictionaryKey: "NSExtension") as? [String: Any?]
    }
    
    public var applicationExtensionPointIdentifier: String? {
        return self.applicationExtensionInfoDictionary?["NSExtensionPointIdentifier"] as? String
    }
    
    public var builtInApplicationExtensionBundles: [Bundle] {
        guard let builtInPlugInsURL = self.builtInPlugInsURL,
              let extensionBundleURLs = try? FileManager.default.contentsOfDirectory(
                at: builtInPlugInsURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) else {
            return []
        }
        return extensionBundleURLs.compactMap(Bundle.init(url:)).filter(\.isApplicationExtension).sorted()
    }
}

extension Bundle {
    #if canImport(Darwin)
    static var allLoadedBundles: [Bundle] {
        return allBundles + allFrameworks
    }
    #endif
    
    /// Finds the current module bundle using different techniques.
    ///
    /// The techniques used to find the module bundle are the following:
    /// - On supported platforms, it tries to find a loaded bundle with an identifier ending with then module name.
    /// - The directory of the source file.
    /// - The main bundle.
    ///
    /// The module name is inferred from the directory name of the calling source file.
    ///
    /// - Returns: The inferred module bundle.
    @available(*, deprecated, message: "Migrate to Swift PM resources: add `resources: [.process(\"Resources\")]` to the package manifest and use the `Bundle.module` accessor.")
    public static func currentModuleBundle(file: String = #file) -> Bundle {        
        let sourceFileURL = URL(fileURLWithPath: file)
        let moduleDirectoryURL = sourceFileURL.deletingLastPathComponent()
        let moduleName = moduleDirectoryURL.lastPathComponent
        
        #if canImport(Darwin)
        let loadedBundles = Bundle.allLoadedBundles.filter { bundle in
            guard let bundleIdentifier = bundle.bundleIdentifier else { return false }
            return !bundleIdentifier.hasPrefix("com.apple.") &&
                bundleIdentifier.hasSuffix(".\(moduleName)")
        }
        if let moduleBundle = loadedBundles.first {
            return moduleBundle
        }
        #endif
        
        if let sourceModuleBundle = Bundle(url: moduleDirectoryURL) {
            return sourceModuleBundle
        }
        
        return Bundle.main
    }
}

extension Bundle {
    private static let libraryDirectoryBundlePathComponent = "Library"
    private var builtInLibraryURL: URL? {
        guard let builtInPlugInsURL = self.builtInPlugInsURL else { return nil }
        return builtInPlugInsURL.deletingLastPathComponent().appendingPathComponent(Self.libraryDirectoryBundlePathComponent)
    }
    
    private static let loginItemsBundlePathComponent = "LoginItems"
    private var builtInLoginItemsDirectoryURL: URL? {
        guard let builtInLibraryURL = self.builtInLibraryURL else { return nil }
        return builtInLibraryURL.appendingPathComponent(Self.loginItemsBundlePathComponent)
    }
    
    var builtInLoginItemsBundles: [Bundle] {
        guard let builtInLoginItemsDirectoryURL = self.builtInLoginItemsDirectoryURL,
              let loginItemBundleURLs = try? FileManager.default.contentsOfDirectory(
                at: builtInLoginItemsDirectoryURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) else {
            return []
        }
        return loginItemBundleURLs.compactMap(Bundle.init(url:)).filter(\.isApplication).sorted()
    }
}

#if targetEnvironment(macCatalyst)
extension Bundle {
    private static let cocoaBundleSuffix = "+Cocoa"
    
    private var cocoaBundleName: String {
        return self.bundleName + Self.cocoaBundleSuffix
    }
    
    private var cocoaBundle: Bundle? {
        guard let cocoaBundleURL = self.builtInPlugInsURL?
                .appendingPathComponent(self.cocoaBundleName)
                .appendingPathExtension(Self.plugInBundlePathExtension) else {
            return nil
        }
        return Bundle(url: cocoaBundleURL)
    }
    
    public func loadCocoaBundleClass<T>(name: String) throws -> T {
        guard let cocoaBundle = cocoaBundle else {
            throw NSError(description: "Cocoa plug-in bundle not found in bundle “\(self.bundleName)”.")
        }
        
        if !cocoaBundle.isLoaded {
            try cocoaBundle.loadAndReturnError()
        }
        
        let cocoaModuleName = self.cocoaBundleName.applyingRegularExpression(
            pattern: #"\W"#, substitution: "_")
        let className = cocoaModuleName + "." + name
        guard let cocoaClass: AnyClass = cocoaBundle.classNamed(className) else {
            throw NSError(description: "Cocoa class “\(className)” not found in bundle “\(cocoaBundle.bundleName)”.")
        }
        return unsafeBitCast(cocoaClass, to: T.self)
    }
}
#endif
