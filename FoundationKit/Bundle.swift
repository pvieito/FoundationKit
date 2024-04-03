//
//  Bundle.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 30/08/2018.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if canImport(Cocoa)
import Cocoa
#endif


extension Bundle {
    private static let foundationKitInfoKeyPrefix = "NSX"
    
    func foundationKitInfoDictionaryObject(keySuffix: String) -> Any? {
        return self.object(forInfoDictionaryKey: Self.foundationKitInfoKeyPrefix + keySuffix)
    }
}

extension Bundle {
    private static let coreFoundationBundleNameKey = "CFBundleName"
    private static let coreFoundationBundleDisplayNameKey = "CFBundleDisplayName"
    private static let coreFoundationBundleVersionKey = "CFBundleVersion"
    private static let coreFoundationBundleShortVersionStringKey = "CFBundleShortVersionString"
    private static let foundationPrincipalClassKey = "NSPrincipalClass"
    private static let foundationHumanReadableDescriptionKey = "NSHumanReadableDescription"
    private static let foundationHumanReadableCopyrightKey = "NSHumanReadableCopyright"

    private var bundleDisplayName: String? {
        return self.object(forInfoDictionaryKey: Self.coreFoundationBundleDisplayNameKey) as? String
    }
    
    private var bundleBaseName: String? {
        return self.object(forInfoDictionaryKey: Self.coreFoundationBundleNameKey as String) as? String
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
        guard let bundleVersion = self.object(forInfoDictionaryKey: Self.coreFoundationBundleVersionKey) as? String,
              bundleVersion != "" else {
            return nil
        }
        
        return bundleVersion
    }
    
    public var bundleShortVersion: String? {
        guard let bundleShortVersion = self.object(forInfoDictionaryKey: Self.coreFoundationBundleShortVersionStringKey) as? String,
              bundleShortVersion != "" else {
            return nil
        }
        
        return bundleShortVersion
    }
    
    public var principalClassString: String? {
        guard let principalClassString = self.object(forInfoDictionaryKey: Self.foundationPrincipalClassKey) as? String,
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
        return self.object(forInfoDictionaryKey: Self.foundationHumanReadableDescriptionKey) as? String
    }
    
    public var humanReadableCopyright: String? {
        return self.object(forInfoDictionaryKey: Self.foundationHumanReadableCopyrightKey) as? String
    }
}


extension Bundle {
    private func url(forResource resourceName: String, subextension: String? = nil, pathExtension: String? = nil) -> URL? {
        var resourceName = resourceName
        if let subextension {
            resourceName += "." + subextension
        }
        return self.url(forResource: resourceName, withExtension: pathExtension)
    }
    
    public func loadResourceFile(name: String, subextension: String? = nil, pathExtension: String) throws -> URL {
        guard let url = self.url(forResource: name, subextension: subextension, pathExtension: pathExtension) else {
            throw NSError(description: "Error loading resource “\(name)” in bundle “\(self.bundleName)”.")
        }
        return url
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
    
    @discardableResult
    public func launchApplication(options: NSWorkspace.LaunchOptions = [], configuration: [NSWorkspace.LaunchConfigurationKey : Any] = [:]) throws -> NSRunningApplication {
        return try NSWorkspace.shared.launchApplication(at: self.bundleURL, options: options, configuration: configuration)
    }
    
    @discardableResult
    public func launchApplicationWith(urls: [URL], configuration: [NSWorkspace.LaunchConfigurationKey : Any] = [:]) throws -> NSRunningApplication {
        return try NSWorkspace.shared.open(urls, withApplicationAt: self.bundleURL, configuration: configuration)
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
    private enum ApplicationExtensionType {
        case foundation
        case extensionKit
    }
    
    private static let applicationExtensionPathExtension = "appex"
    
    public var isApplicationExtension: Bool {
        return self.bundleURL.pathExtension == Self.applicationExtensionPathExtension
    }
    
    private var foundationApplicationExtensionInfoDictionary: [String: Any?]? {
        return self.object(forInfoDictionaryKey: "NSExtension") as? [String: Any?]
    }
    
    private var extensionKitApplicationExtensionInfoDictionary: [String: Any?]? {
        return self.object(forInfoDictionaryKey: "EXAppExtensionAttributes") as? [String: Any?]
    }
    
    private var applicationExtensionType: ApplicationExtensionType? {
        if self.foundationApplicationExtensionInfoDictionary != nil {
            return .foundation
        }
        else if self.extensionKitApplicationExtensionInfoDictionary != nil {
            return .extensionKit
        }
        else {
            return nil
        }
    }
    
    public var applicationExtensionInfoDictionary: [String: Any?]? {
        switch self.applicationExtensionType {
        case .foundation:
            return self.foundationApplicationExtensionInfoDictionary
        case .extensionKit:
            return self.extensionKitApplicationExtensionInfoDictionary
        case .none:
            return nil
        }
    }
    
    public var applicationExtensionPointIdentifier: String? {
        switch self.applicationExtensionType {
        case .foundation:
            return self.applicationExtensionInfoDictionary?["NSExtensionPointIdentifier"] as? String
        case .extensionKit:
            return self.applicationExtensionInfoDictionary?["EXExtensionPointIdentifier"] as? String
        case .none:
            return nil
        }
    }
}
 
extension Bundle {
    private var builtInFoundationApplicationExtensionBundles: [Bundle] {
        guard let builtInPlugInsURL = self.builtInPlugInsURL,
              let extensionBundleURLs = try? FileManager.default.contentsOfDirectory(
                at: builtInPlugInsURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) else {
            return []
        }
        return extensionBundleURLs.compactMap(Bundle.init(url:)).filter(\.isApplicationExtension).sorted()
    }
}

extension Bundle {
    private var builtInExtensionsURL: URL? {
        return self.builtInPlugInsURL?.deletingLastPathComponent().appendingPathComponent("Extensions")
    }
    
    private var builtInExtensionKitApplicationExtensionBundles: [Bundle] {
        guard let builtInExtensionsURL = self.builtInExtensionsURL,
              let extensionBundleURLs = try? FileManager.default.contentsOfDirectory(
                at: builtInExtensionsURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) else {
            return []
        }
        return extensionBundleURLs.compactMap(Bundle.init(url:)).filter(\.isApplicationExtension).sorted()
    }
}
    
extension Bundle {
    public var builtInApplicationExtensionBundles: [Bundle] {
        return (self.builtInFoundationApplicationExtensionBundles + self.builtInExtensionKitApplicationExtensionBundles).sorted()
    }
}

extension Bundle {
    func loadFoundationKitInfoDictionaryLink(keySuffix: String) throws -> URL {
        guard let linkString = self.foundationKitInfoDictionaryObject(keySuffix: keySuffix) as? String, let link = linkString.genericURL else {
            throw NSError(description: "Valid link with key “\(keySuffix)” not found in the bundle “\(self.bundleName)”.")
        }
        return link
    }
    
    func loadPrivacyPolicyLink() throws -> URL {
        return try loadFoundationKitInfoDictionaryLink(keySuffix: "PrivacyPolicyLink")
    }
    
    func loadTermsOfUseLink() throws -> URL {
        return try loadFoundationKitInfoDictionaryLink(keySuffix: "TermsOfUseLink")
    }
    
    public func openPrivacyPolicyLink() throws {
        try loadPrivacyPolicyLink().open()
    }
    
    public func openTermsOfUseLink() throws {
        try loadTermsOfUseLink().open()
    }
}

#if canImport(Cocoa)
extension Bundle {
	public static func applicationBundle(identifier: String) -> Bundle? {
        return NSWorkspace._applicationBundle(identifier: identifier)
	}
    
    public static func applicationBundle(name: String) -> Bundle? {
        return NSWorkspace._applicationBundle(name: name)
    }
    
    public func systemManagedContainer(mode: FileManager.ContainersLibraryMode? = nil) -> URL? {
        guard let bundleIdentifier else { return nil }
        return try? FileManager.default.systemManagedContainer(identifier: bundleIdentifier, mode: mode)
    }
}
#endif

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
    public static func currentModuleBundle(_file: String = #filePath) -> Bundle {
        let sourceFileURL = URL(fileURLWithPath: _file)
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
