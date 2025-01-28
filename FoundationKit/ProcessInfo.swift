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
    static let pathEnvironmentVariableKey = "PATH"
    static let pathExtensionsEnvironmentVariableKey = pathEnvironmentVariableKey + "EXT"
    
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
    
    private var executablePaths: [String] {
        return self.uppercasedEnvironment[Self.pathEnvironmentVariableKey]?.environmentSeparatedPaths ?? []
    }
    
    var executableDirectories: [URL] {
        return self.executablePaths.pathURLs
    }
    
    var executableExtensions: [String] {
#if os(Windows)
        guard let executableExtensions = self.uppercasedEnvironment[Self.pathExtensionsEnvironmentVariableKey] else {
            return ProcessInfo.defaultExecutableExtensions.map { $0.lowercased() }
        }
        
        return executableExtensions.environmentSeparatedPaths.map { $0.trimmingCharacters(in: ProcessInfo.dotCharacters).lowercased() }
#else
        return ProcessInfo.defaultExecutableExtensions
#endif
    }
}

extension ProcessInfo {
#if os(macOS)
    fileprivate static let defaultExtraExecutablePaths: [String] = ["/usr/local/bin", "/usr/local/sbin", "/opt/homebrew/bin", "/opt/homebrew/sbin"]
#else
    fileprivate static let defaultExtraExecutablePaths: [String] = []
#endif

    public func extendEnvironmentExecutableDirectories(at urls: [URL]? = nil) {
        let urls = Self.defaultExtraExecutablePaths + (urls?.paths ?? Self.defaultExtraExecutablePaths)
        self.setEnvironmentVariable(key: Self.pathEnvironmentVariableKey, value: urls.environmentJoinedPaths)
    }
    
    public func setEnvironmentVariable(key: String, value: String) {
        setenv(key, value, 1)
    }
    
    public func setEnvironmentVariables(_ environment: [String: String]) {
        for (key, value) in environment {
            self.setEnvironmentVariable(key: key, value: value)
        }
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
            let campaignName = campaignName ?? Bundle.main.bundleName.lowercased().replacingOccurrences(of: " ", with: "-")
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
    
    @available(*, deprecated, message: "Use ProcessInfo.processInfo.launchUserLoginItemsPaneInSystemSettings() instead.")
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
    private static let systemSettingsURLScheme = "x-apple.systempreferences:"
    private static let systemSettingsSecurityPaneURISuffix = "com.apple.preference.security"
    private static let systemSettingsAutomationPrivacyPaneURISuffix = systemSettingsSecurityPaneURISuffix + "?Privacy_Automation"
    private static let systemSettingsAccessibilityPrivacyPaneURISuffix = systemSettingsSecurityPaneURISuffix + "?Privacy_Accessibility"
    private static let systemSettingsScreenCapturePrivacyPaneURISuffix = systemSettingsSecurityPaneURISuffix + "?Privacy_ScreenCapture"
    
    public func launchSystemSettings() throws {
        try URL(string: Self.systemSettingsURLScheme)!.open()
    }
    
    public func launchPaneInSystemSettings(uriSuffix: String) throws {
        do {
            try URL(string: Self.systemSettingsURLScheme + uriSuffix)!.open()
        }
        catch {
            try self.launchSystemSettings()
        }
    }
    
    public func launchPrivacyAndSecurityPaneInSystemSettings() throws {
        try self.launchPaneInSystemSettings(uriSuffix: Self.systemSettingsSecurityPaneURISuffix)
    }
    
    public func launchAutomationPrivacyPaneInSystemSettings() throws {
        try self.launchPaneInSystemSettings(uriSuffix: Self.systemSettingsAutomationPrivacyPaneURISuffix)
    }
    
    public func launchAccessibilityPrivacyPaneInSystemSettings() throws {
        try self.launchPaneInSystemSettings(uriSuffix: Self.systemSettingsAccessibilityPrivacyPaneURISuffix)
    }
    
    public func launchScreenCapturePrivacyPaneInSystemSettings() throws {
        try self.launchPaneInSystemSettings(uriSuffix: Self.systemSettingsScreenCapturePrivacyPaneURISuffix)
    }
}

extension ProcessInfo {
    @available(*, deprecated, renamed: "launchSystemSettings")
    public func launchSystemPreferences() throws {
        try self.launchSystemSettings()
    }
    
    @available(*, deprecated, renamed: "launchPaneInSystemSettings(uriSuffix:)")
    public func launchPaneInSystemPreferences(uriSuffix: String) throws {
        try self.launchPaneInSystemSettings(uriSuffix: uriSuffix)
    }
    
    @available(*, deprecated, renamed: "launchAutomationPrivacyPaneInSystemSettings")
    public func launchAutomationPrivacyPaneInSystemPreferences() throws {
        try self.launchAutomationPrivacyPaneInSystemSettings()
    }
    
    @available(*, deprecated, renamed: "launchAccessibilityPrivacyPaneInSystemSettings")
    public func launchAccessibilityPrivacyPaneInSystemPreferences() throws {
        try self.launchAccessibilityPrivacyPaneInSystemSettings()
    }
    
    @available(*, deprecated, renamed: "launchScreenCapturePrivacyPaneInSystemSettings")
    public func launchScreenCapturePrivacyPaneInSystemPreferences() throws {
        try self.launchScreenCapturePrivacyPaneInSystemSettings()
    }
}
#endif

#if canImport(Darwin)
extension ProcessInfo {
    private static let settingsName = "Settings"
#if canImport(Cocoa)
    private static let systemSettingsApplicationDefaultName = "System \(settingsName)"
    private static let systemSettingsApplicationBundleIdentifier = "com.apple.systempreferences"
#else
    private static let systemSettingsApplicationDefaultName = settingsName
#endif
    
    public static let systemSettingsLocalizedName: String = {
        var systemSettingsLocalizedName: String?
#if canImport(Cocoa)
        systemSettingsLocalizedName = Bundle.applicationBundle(identifier: systemSettingsApplicationBundleIdentifier)?.bundleName
#endif
        return systemSettingsLocalizedName ?? systemSettingsApplicationDefaultName
    }()
}
#endif

#if os(macOS)
extension ProcessInfo {
    private static let systemSettingsPanesDirectoryPath = "/System/Library/PreferencePanes/"
    private static let systemSettingsPaneExtension = "prefPane"
    private static let systemSettingsPanePathSuffix = "." + systemSettingsPaneExtension
    
    public func launchPaneInSystemSettings(name: String) throws {
        do {
            try URL(fileURLWithPath: Self.systemSettingsPanesDirectoryPath + name + Self.systemSettingsPanePathSuffix).open()
        }
        catch {
            try self.launchSystemSettings()
        }
    }
    
    public func launchUsersPaneInSystemSettings() throws {
        try self.launchPaneInSystemSettings(name: "Accounts")
    }
    
    public func launchUserLoginItemsPaneInSystemSettings() throws {
#if canImport(AppIntents)
        if #available(macOS 13.0, *) {
            SMAppService.openSystemSettingsLoginItems()
            return
        }
#endif
        try self.launchUsersPaneInSystemSettings()
    }
    
    public func launchExtensionsPaneInSystemSettings() throws {
#if canImport(AppIntents)
        if #available(macOS 15.0, *) {
            SMAppService.openSystemSettingsLoginItems()
            return
        }

        if #available(macOS 13.0, *) {
            do {
                try self.launchPrivacyAndSecurityPaneInSystemSettings()
                return
            }
            catch {}
        }
#endif
        try self.launchPaneInSystemSettings(name: "Extensions")
    }
}

extension ProcessInfo {
    @available(*, deprecated, renamed: "launchPaneInSystemSettings(name:)")
    public func launchPaneInSystemPreferences(name: String) throws {
        try self.launchPaneInSystemSettings(name: name)
    }
    
    @available(*, deprecated, renamed: "launchUsersPaneInSystemSettings")
    public func launchUsersPaneInSystemPreferences() throws {
        try self.launchUsersPaneInSystemSettings()
    }
    
    @available(*, deprecated, renamed: "launchUserLoginItemsPaneInSystemSettings")
    public func launchUserLoginItemsPaneInSystemPreferences() throws {
        try self.launchUserLoginItemsPaneInSystemSettings()
    }
    
    @available(*, deprecated, renamed: "launchExtensionsPaneInSystemSettings")
    public func launchExtensionsPaneInSystemPreferences() throws {
        try self.launchExtensionsPaneInSystemSettings()
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
    public func determineAutomationPermission(for bundleIdentifier: String, promptUser: Bool = false) -> Bool {
        if NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).isEmpty {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleIdentifier, options: [.andHide, .withoutActivation], additionalEventParamDescriptor: nil, launchIdentifier: nil)
        }
        let applicationTarget = NSAppleEventDescriptor(bundleIdentifier: bundleIdentifier)
        return AEDeterminePermissionToAutomateTarget(applicationTarget.aeDesc, typeWildCard, typeWildCard, promptUser) == noErr
    }
}

extension ProcessInfo {
    public func determineAccessibilityPermission(promptUser: Bool = false) -> Bool {
        return AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue(): promptUser as CFBoolean] as CFDictionary)
    }
    
    public var hasAccessibilityPermission: Bool {
        return self.determineAccessibilityPermission(promptUser: false)
    }
}
#endif

extension String {
    var environmentSeparatedPaths: [String] {
        return self.split(separator: ProcessInfo.pathSeparator).map(String.init)
    }
}

extension Collection where Element == String {
    var environmentJoinedPaths: String {
        return self.joined(separator: String(ProcessInfo.pathSeparator))
    }
}
