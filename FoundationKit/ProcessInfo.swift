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
    private var loginItemBundle: Bundle? {
        return Bundle.main.builtInLoginItemsBundles.first
    }
    
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
    public func launchParentApplication(deep: Bool = true) throws {
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
    public func relaunchApplicationTerminatingCurrentInstance() throws {
        try NSWorkspace.shared.launchApplication(at: Bundle.main.bundleURL, options: [.async, .newInstance], configuration: [:])
        NSApp.terminate(self)
    }
}
#endif

fileprivate extension String {
    var paths: [String] {
        return self.split(separator: ProcessInfo.pathSeparator).map(String.init)
    }
}
