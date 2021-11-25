//
//  ProcessInfo.swift
//  FoundationKit
//
//  Created by Pedro José Pereira Vieito on 08/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

#if os(macOS)
import Cocoa
import ServiceManagement
#endif

extension ProcessInfo {
    #if os(Windows)
    fileprivate static let dotCharacters = CharacterSet(charactersIn: ".")
    fileprivate static let pathSeparator: Character = ";"
    fileprivate static let defaultExecutableExtensions = ["COM", "EXE", "BAT", "CMD"]
    #else
    fileprivate static let pathSeparator: Character = ":"
    fileprivate static let defaultExecutableExtensions = [""]
    #endif
    
    private var uppercasedEnvironment: [String : String] {
        var uppercasedEnvironment: [String : String] = [:]
        for (key, value) in self.environment {
            uppercasedEnvironment[key.uppercased()] = value
        }
        return uppercasedEnvironment
    }
    
    private var environmentPaths: [String] {
        guard let path = self.uppercasedEnvironment["PATH"] else {
            return []
        }
        
        return path.paths
    }
    
    var executableDirectories: [URL] {
        return self.environmentPaths.pathURLs
    }
    
    var executableExtensions: [String] {
        #if os(Windows)
        guard let pathext = self.uppercasedEnvironment["PATHEXT"] else {
            return ProcessInfo.defaultExecutableExtensions.map { $0.lowercased() }
        }
        
        return pathext.paths.map { $0.trimmingCharacters(in: ProcessInfo.dotCharacters).lowercased() }
        #else
        return ProcessInfo.defaultExecutableExtensions
        #endif
    }
}

extension ProcessInfo {
    private static let appStoreURLScheme = "itms-apps"
    private static let appStoreURLBaseComponents: URLComponents = {
        var appStoreURLBaseComponents = URLComponents()
        appStoreURLBaseComponents.scheme = appStoreURLScheme
        return appStoreURLBaseComponents
    }()
    
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    @available(macCatalystApplicationExtension, unavailable)
    public static func launchAppStore(applicationStoreIdentifier: Int? = nil, campaignProviderIdentifier: Int? = nil, campaignName: String? = nil) throws {
        var launchAppStoreURLComponents = self.appStoreURLBaseComponents
        if let applicationStoreIdentifier = applicationStoreIdentifier {
            launchAppStoreURLComponents.host = "apps.apple.com"
            launchAppStoreURLComponents.path = "/app/id\(applicationStoreIdentifier)"
        }
        if let campaignProviderIdentifier = campaignProviderIdentifier {
            let campaignName = campaignName ?? Bundle.main.bundleName
            launchAppStoreURLComponents.queryItems = [
                URLQueryItem(name: "pt", value: String(campaignProviderIdentifier)),
                URLQueryItem(name: "ct", value: campaignName),
            ]
        }
        try launchAppStoreURLComponents.url!.open()
    }
}

#if os(macOS)
extension ProcessInfo {
    @available(*, deprecated)
    private var launchdJobs: [[String: Any]]? {
        return SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: Any]]
    }
    
    @available(*, deprecated)
    private func loginItemJob(bundleIdentifier: String) -> [String: Any]? {
        return self.launchdJobs?.first(where: { $0["Label"] as? String == bundleIdentifier })
    }
    
    @available(*, deprecated)
    public func isLoginItemEnabled(bundleIdentifier: String) -> Bool {
        guard let loginItemJob = self.loginItemJob(bundleIdentifier: bundleIdentifier),
              let isLoginItemJobOnDemand = loginItemJob["OnDemand"] as? Bool else { return false }
        return isLoginItemJobOnDemand
    }
}

extension ProcessInfo {
    @available(*, deprecated)
    private var loginItemBundle: Bundle? {
        return Bundle.main.builtInLoginItemsBundles.first
    }
    
    @available(*, deprecated, message: "Use ProcessInfo.processInfo.launchUserLoginItemsPaneInSystemPreferences() instead.")
    public func configureLoginItem(bundleIdentifier: String? = nil, enabled: Bool) throws {
        guard let bundleIdentifier = loginItemBundle?.bundleIdentifier else {
            throw NSError(description: "Error configuring login item as a valid bundle is not available.")
        }
        guard SMLoginItemSetEnabled(bundleIdentifier as CFString, enabled) else {
            throw NSError(description: "Error configuring login item.")
        }
    }
}

extension ProcessInfo {
    @available(*, deprecated)
    public func launchParentApplication(deep: Bool = false) throws {
        var parentApplicationBundle: Bundle?
        if deep {
            parentApplicationBundle = Bundle.main.parentApplicationBundles.last
        }
        else {
            parentApplicationBundle = Bundle.main.parentApplicationBundle
        }
        guard let mainBundle = parentApplicationBundle else {
            throw NSError(description: "Error launching parent application, as its bundle is not available.")
        }
        guard !mainBundle.isApplicationRunning else { return }
        try mainBundle.bundleURL.open()
    }
}

extension ProcessInfo {
    private static let systemPreferencesURLScheme = "x-apple.systempreferences:"
    private static let systemPreferencesSecurityPaneURLString = systemPreferencesURLScheme + "com.apple.preference.security"
    private static let systemPreferencesAutomationPrivacyPaneURLString = systemPreferencesSecurityPaneURLString + "?Privacy_Automation"
    private static let systemPreferencesAccessibilityPrivacyPaneURLString = systemPreferencesSecurityPaneURLString + "?Privacy_Accessibility"

    public func launchSystemPreferences() throws {
        try URL(string: Self.systemPreferencesURLScheme)!.open()
    }
    
    public func launchUserLoginItemsPaneInSystemPreferences() throws {
        do {
            try URL(fileURLWithPath: "/System/Library/PreferencePanes/Accounts.prefPane").open()
        }
        catch {
            try self.launchSystemPreferences()
        }
    }
    
    private func launchAutomationPrivacyPaneInSystemPreferences(for section: String? = nil) throws {
        do {
            try URL(string: Self.systemPreferencesAutomationPrivacyPaneURLString)!.open()
        }
        catch {
            try self.launchSystemPreferences()
        }
    }

    private func launchAccessibilityPrivacyPaneInSystemPreferences(for section: String? = nil) throws {
        do {
            try URL(string: Self.systemPreferencesAccessibilityPrivacyPaneURLString)!.open()
        }
        catch {
            try self.launchSystemPreferences()
        }
    }
}

extension ProcessInfo {
    public func relaunchApplicationTerminatingCurrentInstance() throws {
        try NSWorkspace.shared.launchApplication(at: Bundle.main.bundleURL, options: [.async, .newInstance], configuration: [:])
        NSApp.terminate(self)
    }
}

@available(macOS 10.14, *)
extension ProcessInfo {
    public static func determineAutomationPermission(for bundleIdentifier: String, promptUser: Bool = false) -> Bool {
        let applicationTarget = NSAppleEventDescriptor(bundleIdentifier: bundleIdentifier)
        return AEDeterminePermissionToAutomateTarget(applicationTarget.aeDesc, typeWildCard, typeWildCard, promptUser) == noErr
    }
}

extension ProcessInfo {
    public static func determineAccessibilityPermission(promptUser: Bool = false) -> Bool {
        return AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue(): promptUser as CFBoolean] as CFDictionary)
    }

    public static var hasAccessibilityPermission: Bool {
        return self.determineAccessibilityPermission(promptUser: false)
    }
}
#endif

fileprivate extension String {
    var paths: [String] {
        return self.split(separator: ProcessInfo.pathSeparator).map(String.init)
    }
}
